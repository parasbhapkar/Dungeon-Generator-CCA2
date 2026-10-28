#!/usr/bin/env bash
# ==============================================================================
# AWS EC2 (Amazon Linux 2023) PROVISIONING SCRIPT — DUNGEON GENERATOR CI/CD
# Student: Paras Bhapkar (PRN: 1262243185, Panel: D1)
# Course: TYCSE Cloud Computing & DevOps (CCA 2) - MIT-WPU Pune
# ==============================================================================

set -euo pipefail

echo "=================================================================="
echo "🚀 STARTING AMAZON LINUX 2023 CI/CD ENVIRONMENT SETUP"
echo "=================================================================="

# Check root privilege
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Please run this script as root (sudo bash setup-ec2-amazonlinux2023.sh)"
  exit 1
fi

# 1. Update Packages & Dependencies
echo "--> [1/6] Updating system packages..."
dnf update -y
dnf install -y git curl wget conntrack iptables socat shadow-utils tar gzip jq

# 2. Install Docker
echo "--> [2/6] Installing and starting Docker engine..."
dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# 3. Install Java 17 (Amazon Corretto) & Jenkins LTS
echo "--> [3/6] Installing Java 17 & Jenkins LTS..."
dnf install -y java-17-amazon-corretto-devel
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf upgrade -y
dnf install -y jenkins
usermod -aG docker jenkins
chmod 666 /var/run/docker.sock || true
systemctl enable --now jenkins

# 4. Install Node.js 20 LTS
echo "--> [4/6] Installing Node.js 20 & NPM..."
dnf module reset nodejs -y || true
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
node -v
npm -v

# 5. Install Lightweight Kubernetes (k3s) & Configure Permissions
echo "--> [5/6] Installing Lightweight Kubernetes (k3s)..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Setup kubeconfig for ec2-user
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# Setup kubeconfig for Jenkins
mkdir -p /var/lib/jenkins/.kube
cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
chown -R jenkins:jenkins /var/lib/jenkins/.kube
chmod 600 /var/lib/jenkins/.kube/config

# Restart Jenkins to activate new group and kubeconfig
systemctl restart jenkins

# 6. Summary and Connection Information
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "YOUR-EC2-IP")
INITIAL_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Check /var/lib/jenkins/secrets/initialAdminPassword")

echo "=================================================================="
echo "✅ AMAZON LINUX 2023 SETUP COMPLETE"
echo "=================================================================="
echo "📍 EC2 Public IP:          http://${PUBLIC_IP}"
echo "🌐 Jenkins Web Dashboard:  http://${PUBLIC_IP}:8080"
echo "🔑 Initial Admin Password: ${INITIAL_PASSWORD}"
echo "🎮 Dungeon Generator App:  http://${PUBLIC_IP}:30007"
echo "☸️ Kubernetes Node Status: $(kubectl get nodes --no-headers)"
echo "=================================================================="
