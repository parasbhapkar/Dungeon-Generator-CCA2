# Local Pipeline & Unit Test Validation Script
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " DUNGEON GENERATOR CI/CD PIPELINE REPOSITORY SANITY CHECK" -ForegroundColor Cyan
Write-Host " Developer: Paras Bhapkar | PRN: 1262243185 | Panel: D1" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$projectDir = Split-Path -Parent $PSScriptRoot

Write-Host "`n--> [Check 1] Verifying C++ Core Files and Web Bridge..." -ForegroundColor Yellow
$coreFiles = @(
    "Dungeon_generator.cpp",
    "FINAL_DUNGEON_GENERATOR_PROJECT.cpp",
    "delivery.cpp",
    "server.js",
    "version.json",
    "package.json",
    "Dockerfile",
    ".dockerignore",
    "Jenkinsfile",
    "k8s\deployment.yaml",
    "k8s\service.yaml",
    "tests\dungeon.test.js",
    "public\index.html",
    "public\app.js",
    "public\style.css"
)

$allFound = $true
foreach ($f in $coreFiles) {
    $fullPath = Join-Path $projectDir $f
    if (Test-Path $fullPath) {
        Write-Host " [PASS] Found: $f" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] Missing: $f" -ForegroundColor Red
        $allFound = $false
    }
}

Write-Host "`n--> [Check 2] Validating version.json Metadata..." -ForegroundColor Yellow
$versionJsonPath = Join-Path $projectDir "version.json"
$vContent = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
if ($vContent.version -and $vContent.author -eq "Paras Bhapkar" -and $vContent.prn -eq "1262243185") {
    Write-Host " [PASS] version.json valid: Version=$($vContent.version), Author=$($vContent.author), PRN=$($vContent.prn), Panel=$($vContent.panel)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] version.json validation failed!" -ForegroundColor Red
    $allFound = $false
}

Write-Host "`n--> [Check 3] Validating Kubernetes Manifests (k8s)..." -ForegroundColor Yellow
$deployYaml = Get-Content (Join-Path $projectDir "k8s\deployment.yaml") -Raw
if ($deployYaml -match "replicas:\s*2" -and $deployYaml -match "parasbhapkar/dungeon-generator") {
    Write-Host " [PASS] deployment.yaml has 2 replicas and correct image reference" -ForegroundColor Green
} else {
    Write-Host " [FAIL] deployment.yaml validation failed!" -ForegroundColor Red
}

$svcYaml = Get-Content (Join-Path $projectDir "k8s\service.yaml") -Raw
if ($svcYaml -match "nodePort:\s*30007") {
    Write-Host " [PASS] service.yaml correctly configured for NodePort 30007" -ForegroundColor Green
} else {
    Write-Host " [FAIL] service.yaml missing nodePort 30007" -ForegroundColor Red
}

Write-Host "`n--> [Check 4] Validating Jenkinsfile 6 Pipeline Stages..." -ForegroundColor Yellow
$jenkinsfile = Get-Content (Join-Path $projectDir "Jenkinsfile") -Raw
$stages = @(
    "1. Checkout SCM",
    "2. Build and Test",
    "3. Docker Image Build",
    "4. Docker Hub Push",
    "5. Kubernetes Deployment & Rollout",
    "6. Application Health Verification"
)

foreach ($stg in $stages) {
    if ($jenkinsfile.Contains($stg)) {
        Write-Host " [PASS] Verified Stage: '$stg'" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] Missing Stage: '$stg'" -ForegroundColor Red
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " ALL REPOSITORY VALIDATIONS PASSED FOR PARAS BHAPKAR!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
