const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const http = require('http');

const outDir = path.join(__dirname, '..', 'docs', 'screenshots');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

const edgePath = fs.existsSync('C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe')
  ? 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
  : 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

console.log(`[INFO] Using browser executable: ${edgePath}`);
console.log(`[INFO] Output screenshots directory: ${outDir}`);

// 1. Start SSH Tunnel
console.log('[INFO] Spawning SSH tunnel to EC2 (ports 30007 and 8080)...');
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
    console.log('[INFO] SSH tunnel closed.');
  } catch (e) {}
}

process.on('exit', cleanup);
process.on('SIGINT', cleanup);

function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function checkPort(port) {
  return new Promise((resolve) => {
    const req = http.get(`http://127.0.0.1:${port}/health`, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => resolve(body));
    });
    req.on('error', () => resolve(null));
    req.setTimeout(2000, () => {
      req.abort();
      resolve(null);
    });
  });
}

async function run() {
  console.log('[INFO] Waiting for SSH tunnel to establish...');
  let connected = false;
  for (let i = 0; i < 15; i++) {
    await wait(1000);
    const body = await checkPort(30007);
    if (body) {
      console.log(`[INFO] Application reachable through tunnel! Response:\n${body}`);
      connected = true;
      break;
    }
  }

  if (!connected) {
    console.error('[ERROR] Could not connect to application through tunnel after 15s');
    cleanup();
    process.exit(1);
  }

  // Allow app JS to initialize version badge
  await wait(2000);

  // 1. Capture App Homepage
  const appShot = path.join(outDir, '01_dungeon_generator_app_v120.png');
  console.log(`[INFO] Capturing web app screenshot: ${appShot}`);
  execSync(`"${edgePath}" --headless=new --hide-scrollbars --window-size=1400,900 --screenshot="${appShot}" "http://localhost:30007"`);

  // 2. Capture Health Endpoint
  const healthShot = path.join(outDir, '02_health_endpoint_v120.png');
  console.log(`[INFO] Capturing health endpoint screenshot: ${healthShot}`);
  execSync(`"${edgePath}" --headless=new --hide-scrollbars --window-size=1200,600 --screenshot="${healthShot}" "http://localhost:30007/health"`);

  // 3. Capture Version Endpoint
  const verShot = path.join(outDir, '03_version_endpoint_v120.png');
  console.log(`[INFO] Capturing version endpoint screenshot: ${verShot}`);
  execSync(`"${edgePath}" --headless=new --hide-scrollbars --window-size=1200,600 --screenshot="${verShot}" "http://localhost:30007/api/version"`);

  console.log('[SUCCESS] All screenshots captured successfully:');
  console.log(`  - ${appShot} (${fs.statSync(appShot).size} bytes)`);
  console.log(`  - ${healthShot} (${fs.statSync(healthShot).size} bytes)`);
  console.log(`  - ${verShot} (${fs.statSync(verShot).size} bytes)`);

  cleanup();
  process.exit(0);
}

run().catch(err => {
  console.error('[ERROR]', err);
  cleanup();
  process.exit(1);
});
