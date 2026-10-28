# ⚔️ Dungeon-Generator-CCA2 — Enterprise CI/CD on AWS EC2

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-Jenkins%20LTS-2496ED?logo=jenkins&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-Hub%20Registry-0db7ed?logo=docker&logoColor=white)](#)
[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes%20(k3s)-326ce5?logo=kubernetes&logoColor=white)](#)
[![Cloud](https://img.shields.io/badge/Cloud-AWS%20EC2%20(ap--south--1)-FF9900?logo=amazon-aws&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)

> **College Continuous Competency Assessment 2 (CCA 2) Project**  
> **Student Name:** Paras Bhapkar  
> **PRN:** 1262243185  
> **Panel:** D1  
> **Department:** Department of Computer Science & Engineering (TYCSE)  
> **Institution:** Dr. Vishwanath Karad MIT World Peace University (MIT-WPU), Pune  
> **Course:** Cloud Computing and DevOps  
> **GitHub Profile:** [https://github.com/parasbhapkar](https://github.com/parasbhapkar)  
> **Target Repository:** [https://github.com/parasbhapkar/Dungeon-Generator-CCA2](https://github.com/parasbhapkar/Dungeon-Generator-CCA2)  
> **Original Project Attribution:** Derived from [akhand012/OOPS-Project-Dungeon-Generator](https://github.com/akhand012/OOPS-Project-Dungeon-Generator)  

---

## 📖 1. Project Overview & C++ Architecture Preservation

**Dungeon Generator** is an interactive, object-oriented procedural game application originally engineered in C++ utilizing core Object-Oriented Programming (OOP) paradigms:
- **Polymorphic Enemy Hierarchy:** Base `Enemy` class with derived `Goblin` (30 HP, 5 ATK), `Skeleton` (40 HP, 7 ATK), and `Dragon Boss` (100 HP, 20 ATK).
- **Polymorphic Item Hierarchy:** Base `Item` class with derived `Potion` (+25 HP healing) and `Treasure` (+50 Gold).
- **Player Mechanics & Rank Progression:** HP management (100 HP max), procedural attack calculations (`rand() % 15 + 10`), damage mitigation, and a dynamic rank engine tied to the player's Sneak Count:
  - 0 Sneaks &rarr; `🔥 LEGEND`
  - 1 Sneak &rarr; `💪 TITAN`
  - 2 Sneaks &rarr; `⚔️ CHAMPION`
  - 3 Sneaks &rarr; `💎 CRYSTAL`
  - 4 Sneaks &rarr; `🥈 SILVER`
  - 5+ Sneaks &rarr; `🪙 BRONZE`
- **Procedural Chamber Generator:** Dynamic room synthesis with an invariant that guarantees a showdown with the Dragon Boss in the final chamber.

### Web Bridge Adaptation for Cloud Headless Hosting
The original native C++ application (`Dungeon_generator.cpp`, `FINAL_DUNGEON_GENERATOR_PROJECT.cpp`, `delivery.cpp`) is preserved in the repository root. To host the project on a headless cloud environment (AWS EC2 / Kubernetes), an ergonomic containerized web bridge (`server.js`, `public/`) executes the exact same OOP game logic and exposes a retro browser UI alongside dynamic health probes (`/health`) and version tracking (`/api/version`).

---

## 🏗️ 2. CI/CD Architecture & Pipeline Workflow

```
[Developer Commit & Push to GitHub]
                 │
                 ▼
 [GitHub Repository: parasbhapkar/Dungeon-Generator-CCA2]
                 │
                 ▼ (Triggered via Jenkins "Build Now")
 [Jenkins Automation Server on AWS EC2 (Port 8080)]
   ├── Stage 1: Checkout SCM (Commit Hash & Branch)
   ├── Stage 2: Build & Test (npm test - 8 Unit Tests)
   ├── Stage 3: Docker Image Build (Multi-stage build tagged :${BUILD_NUMBER} and :latest)
   ├── Stage 4: Docker Hub Push (parasbhapkar/dungeon-generator via Jenkins Credentials)
   ├── Stage 5: Kubernetes Rollout (k3s RollingUpdate with 2 Pod Replicas)
   └── Stage 6: Application Health Verification (HTTP 200 on /health, version match assertion)
                 │
                 ▼
 [Live Dungeon Generator Application (NodePort: 30007)]
```

---

## 📂 3. Repository Directory Structure

```
Dungeon-Generator-CCA2/
├── .dockerignore                     # Excludes unwanted files from Docker image
├── .gitignore                        # Git exclusion rules (node_modules, credentials)
├── Dockerfile                        # Multi-stage Docker build with non-root security
├── Jenkinsfile                       # 6-stage Declarative CI/CD pipeline definition
├── package.json                      # Node.js dependencies and test scripts
├── version.json                      # Authoritative application version source (v1.0.0)
├── server.js                         # C++ OOP Web Bridge & REST API
├── Dungeon_generator.cpp             # Authentic C++ OOP Game Engine
├── FINAL_DUNGEON_GENERATOR_PROJECT.cpp # Authentic C++ Win32 Project
├── delivery.cpp                      # Supplementary C++ mechanics
├── README.md                         # Project documentation and deployment guide
├── k8s/
│   ├── deployment.yaml               # Kubernetes Deployment (2 replicas, rolling updates)
│   └── service.yaml                  # Kubernetes NodePort Service (Port 30007)
├── public/
│   ├── index.html                    # Retro terminal dungeon interface
│   ├── app.js                        # Client gameplay controller & version fetcher
│   └── style.css                     # Dark glassmorphism gaming HUD styles
├── scripts/
│   ├── setup-ec2-amazonlinux2023.sh  # Automated provisioning script for Amazon Linux 2023
│   ├── ec2-setup.sh                  # Automated provisioning script for Ubuntu 22.04/24.04
│   ├── test-local-dungeon.ps1        # Local syntax & manifest validation script
│   └── job-config.xml                # Automated Jenkins pipeline job configuration
└── tests/
    └── dungeon.test.js               # 8-point automated test suite
```

---

## 🧪 4. Automated Test Suite (8 Points)

Run tests locally:
```bash
npm test
```

Expected output:
```
=============================================================
🧪 RUNNING DUNGEON GENERATOR AUTOMATED CI/CD TEST SUITE
   Developer: Paras Bhapkar | PRN: 1262243185 | Panel: D1
   University: MIT-WPU Pune | Target: AWS EC2 Jenkins & k3s
=============================================================

✅ PASS: Test 1 - Enemy Polymorphic Hierarchy (Goblin, Skeleton, Dragon)
✅ PASS: Test 2 - Item Polymorphic Hierarchy (Potion and Treasure)
✅ PASS: Test 3 - Player Character Initialization & Damage Bounds
✅ PASS: Test 4 - Player Rank Progression Hierarchy (LEGEND to BRONZE)
✅ PASS: Test 5 - Procedural Dungeon Room Generation Count
✅ PASS: Test 6 - Final Room Invariant: Final chamber always spawns Dragon Boss
✅ PASS: Test 7 - Combat Damage Mechanics & Death State Evaluation
✅ PASS: Test 8 - Application Version Metadata File Schema & Validation
   (Verified Version: 1.0.0 | Author: Paras Bhapkar)

-------------------------------------------------------------
📊 TEST SUITE SUMMARY: 8 / 8 TESTS PASSED (100% SUCCESS)
-------------------------------------------------------------
```

---

## 🚀 5. Teacher Demonstration Walkthrough (Version Bump Workflow)

### Step 1: Baseline Verification
1. Access the live URL: `http://<EC2-PUBLIC-IP>:30007/`
2. Confirm the version badge displays **`v1.0.0`** and the student name displays **`Paras Bhapkar (PRN: 1262243185)`**.
3. Confirm the `/health` endpoint returns:
   ```json
   {
     "status": "UP",
     "healthy": true,
     "version": "1.0.0",
     "student": "Paras Bhapkar"
   }
   ```

### Step 2: Code Version Change
1. Edit `version.json` in GitHub:
   ```json
   {
     "version": "1.1.0",
     "appName": "Dungeon Generator CI/CD",
     "buildDate": "2026-10-28",
     "author": "Paras Bhapkar",
     "prn": "1262243185",
     "panel": "D1",
     "university": "Dr. Vishwanath Karad MIT World Peace University, Pune",
     "pipeline": "Jenkins AWS EC2 Pipeline"
   }
   ```
2. Commit and push the change to `main` branch:
   ```bash
   git commit -am "feat(release): upgrade dungeon generator to version v1.1.0"
   git push origin main
   ```

### Step 3: Trigger CI/CD Pipeline
1. Open Jenkins: `http://<EC2-PUBLIC-IP>:8080/job/dungeon-generator-cicd/`
2. Click **Build Now**.
3. Jenkins executes all 6 stages sequentially:
   - Stage 1: Checkout SCM
   - Stage 2: Build & Test (validates all 8 tests)
   - Stage 3: Docker Image Build (`parasbhapkar/dungeon-generator:${BUILD_NUMBER}`)
   - Stage 4: Docker Hub Push
   - Stage 5: Kubernetes Deployment & Rollout (2 replicas rolling update)
   - Stage 6: Application Health Verification (verifies `/health` reports `1.1.0`)

### Step 4: Live URL Verification
1. Refresh `http://<EC2-PUBLIC-IP>:30007/` in the browser.
2. The page immediately reflects **`v1.1.0`** without downtime or caching delays!

---

## 🔒 6. Security and Cloud Configuration

1. **Least-Privilege Ingress:** Security group opens only port 22 (SSH), port 8080 (Jenkins), and port 30007 (NodePort application).
2. **Encrypted Credentials:** Docker Hub authentication is handled through Jenkins `withCredentials`, never hardcoded into source files.
3. **Non-Root Container:** Multi-stage Docker build drops root privileges and executes as the `node` user.
4. **Cache-Control:** Dynamic `Cache-Control: no-cache, no-store, must-revalidate` headers ensure instantaneous reflection of version bumps.
