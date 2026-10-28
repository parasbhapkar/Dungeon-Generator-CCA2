#!/bin/bash
ADMIN_PW=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "=== BUILD 3 API JSON ==="
curl -s -u "admin:${ADMIN_PW}" http://localhost:8080/job/dungeon-generator-cicd/3/api/json | jq '{
  number: .number,
  result: .result,
  duration: .duration,
  timestamp: .timestamp,
  displayName: .displayName,
  building: .building
}'
