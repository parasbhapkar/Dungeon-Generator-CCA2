const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');
const http = require('http');

const outDir = path.join(__dirname, '..', 'docs', 'screenshots');
const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

console.log('[INFO] Spawning SSH tunnel to EC2...');
const tunnel = spawn('ssh', [
  '-i', 'C:\\Users\\paras\\.ssh\\cca2.pem',
  '-o', 'StrictHostKeyChecking=no',
  '-L', '30007:127.0.0.1:30007',
  '-L', '8080:127.0.0.1:8080',
  '-N',
  'ec2-user@35.154.191.183'
], { stdio: 'ignore' });

function cleanup() {
  try {
    tunnel.kill('SIGTERM');
  } catch (e) {}
}

process.on('exit', cleanup);
process.on('SIGINT', cleanup);

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function takeScreenshot(url, outFile, width = 1200, height = 700) {
  const tmpProfile = fs.mkdtempSync(path.join(os.tmpdir(), 'edge-ss-'));
  const cmd = `"${edgePath}" --headless=new --disable-gpu --user-data-dir="${tmpProfile}" --hide-scrollbars --window-size=${width},${height} --screenshot="${outFile}" "${url}"`;
  try {
    execSync(cmd, { timeout: 15000 });
    console.log(`[OK] Saved screenshot: ${outFile} (${fs.statSync(outFile).size} bytes)`);
  } catch (err) {
    console.error(`[WARN] Failed to capture ${url}: ${err.message}`);
  } finally {
    try { fs.rmSync(tmpProfile, { recursive: true, force: true }); } catch (e) {}
  }
}

async function run() {
  await wait(3000);

  // 1. Health endpoint
  const healthShot = path.join(outDir, '02_health_endpoint_v120.png');
  takeScreenshot('http://localhost:30007/health', healthShot, 1100, 500);

  // 2. Version endpoint
  const verShot = path.join(outDir, '03_version_endpoint_v120.png');
  takeScreenshot('http://localhost:30007/api/version', verShot, 1100, 500);

  // 3. Jenkins build job page
  const jenkinsShot = path.join(outDir, '04_jenkins_builds_dashboard.png');
  takeScreenshot('http://localhost:8080/job/dungeon-generator-cicd/', jenkinsShot, 1400, 900);

  cleanup();
  process.exit(0);
}

run();
