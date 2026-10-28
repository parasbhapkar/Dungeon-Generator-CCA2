#!/usr/bin/env bash
# ==============================================================================
# AWS EC2 (Amazon Linux 2023) PROVISIONING SCRIPT — DUNGEON GENERATOR CI/CD
# Student: Paras Bhapkar (PRN: 1262243185, Panel: D1)
# Course: TYCSE Cloud Computing & DevOps (CCA 2) - MIT-WPU Pune
# ==============================================================================
set -e

LOG_FILE="/var/log/cca2_provision.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================================="
echo "🚀 STARTING AMAZON LINUX 2023 CI/CD ENVIRONMENT SETUP"
echo "Timestamp: $(date -u)"
echo "=================================================================="

# 0. Check and Create 2GB Swap Space
echo "--> [Step 0/7] Setting up Swap memory..."
if [ ! -f /swapfile ]; then
    echo "Allocating 2GB swap file..."
    dd if=/dev/zero of=/swapfile bs=128M count=16
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
    fi
    echo "Swap enabled successfully:"
    free -h
else
    echo "Swap file already exists:"
    free -h
fi

# 1. Update Packages & Dependencies (using --allowerasing for AL2023 curl-minimal compatibility)
echo "--> [Step 1/7] Installing base packages..."
dnf install -y --allowerasing git wget tar gzip jq iptables conntrack socat shadow-utils procps-ng

# 2. Install Docker
echo "--> [Step 2/7] Installing Docker Engine..."
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user
chmod 666 /var/run/docker.sock || true
docker --version

# 3. Install Java 17 & Jenkins LTS
echo "--> [Step 3/7] Installing Java 17 & Jenkins LTS..."
dnf install -y java-17-amazon-corretto-devel
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf clean all
dnf install -y jenkins

# Configure JVM heap limits to 512MB max for stability on 1GB RAM
mkdir -p /etc/systemd/system/jenkins.service.d
cat << 'EOF' > /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Xms128m -Xmx512m"
EOF
systemctl daemon-reload

usermod -aG docker jenkins || true
systemctl enable --now jenkins

# 4. Install Node.js 20 & NPM
echo "--> [Step 4/7] Installing Node.js 20..."
dnf install -y --allowerasing nodejs npm || {
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    dnf install -y nodejs
}
node -v
npm -v

# 5. Install Lightweight Kubernetes (k3s)
echo "--> [Step 5/7] Installing k3s Kubernetes..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable traefik" sh -

# Symlink binaries to /usr/bin
ln -sf /usr/local/bin/kubectl /usr/bin/kubectl || true
ln -sf /usr/local/bin/k3s /usr/bin/k3s || true

# Wait for k3s cluster to be ready
echo "Waiting for k3s node to be Ready..."
for i in {1..30}; do
    if kubectl get nodes 2>/dev/null | grep -q "Ready"; then
        echo "k3s is Ready!"
        break
    fi
    sleep 2
done
kubectl get nodes

# 6. Setup Kubeconfig Permissions
echo "--> [Step 6/7] Setting up Kubeconfig for ec2-user and jenkins..."
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube
chmod 644 /home/ec2-user/.kube/config

mkdir -p /var/lib/jenkins/.kube
cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
chown -R jenkins:jenkins /var/lib/jenkins/.kube
chmod 644 /var/lib/jenkins/.kube/config

# Ensure Jenkins has Docker permissions
chmod 666 /var/run/docker.sock || true
systemctl restart jenkins

# Wait for Jenkins initial admin password
echo "--> [Step 7/7] Verifying Jenkins and gathering credentials..."
sleep 5
INITIAL_PASSWORD=""
for i in {1..20}; do
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
        break
    fi
    sleep 2
done

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "35.154.191.183")

echo "=================================================================="
echo "✅ AMAZON LINUX 2023 SETUP COMPLETE"
echo "=================================================================="
echo "📍 Public IP:              ${PUBLIC_IP}"
echo "🌐 Jenkins Web URL:        http://${PUBLIC_IP}:8080"
echo "🔑 Jenkins Admin Password: ${INITIAL_PASSWORD}"
echo "🎮 Application URL:        http://${PUBLIC_IP}:30007"
echo "☸️ Kubernetes Node:        $(kubectl get nodes --no-headers)"
echo "💾 Free Memory & Swap:"
free -h
echo "=================================================================="
