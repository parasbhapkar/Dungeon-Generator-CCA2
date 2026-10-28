#!/bin/bash
set -e

ADMIN_PW=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "[INFO] Fetching Jenkins CSRF crumb..."
CRUMB_JSON=$(curl -s -c /tmp/cookies.txt -u "admin:${ADMIN_PW}" http://localhost:8080/crumbIssuer/api/json)
CRUMB=$(echo "${CRUMB_JSON}" | jq -r .crumb)
FIELD=$(echo "${CRUMB_JSON}" | jq -r .crumbRequestField)
echo "[INFO] Crumb header: ${FIELD}: ${CRUMB}"

echo "[INFO] Triggering Jenkins job: dungeon-generator-cicd..."
HTTP_STATUS=$(curl -s -o /tmp/build_out.txt -w "%{http_code}" -X POST -b /tmp/cookies.txt -H "${FIELD}:${CRUMB}" -u "admin:${ADMIN_PW}" http://localhost:8080/job/dungeon-generator-cicd/build)
echo "[INFO] Trigger HTTP Status: ${HTTP_STATUS} (201 Created is expected)"

echo "[INFO] Current Job Status:"
curl -s -u "admin:${ADMIN_PW}" http://localhost:8080/job/dungeon-generator-cicd/api/json | jq -r '{name: .name, nextBuildNumber: .nextBuildNumber, inQueue: .inQueue, lastBuild: .lastBuild.number}'
