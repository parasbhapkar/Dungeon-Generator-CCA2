#!/bin/bash
BUILD_NUM=3
ADMIN_PW=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
JOB_URL="http://localhost:8080/job/dungeon-generator-cicd/${BUILD_NUM}"

echo "=========================================================="
echo "⏳ MONITORING JENKINS BUILD #${BUILD_NUM}"
echo "=========================================================="

# Wait for build to start
for i in {1..30}; do
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u "admin:${ADMIN_PW}" "${JOB_URL}/api/json")
    if [ "$STATUS_CODE" -eq 200 ]; then
        echo "Build #${BUILD_NUM} has started execution!"
        break
    fi
    echo "Waiting for Build #${BUILD_NUM} to transition from queue to running... (attempt $i/30)"
    sleep 3
done

# Poll build execution
for i in {1..60}; do
    BUILD_INFO=$(curl -s -u "admin:${ADMIN_PW}" "${JOB_URL}/api/json" || echo "{}")
    IS_BUILDING=$(echo "$BUILD_INFO" | jq -r '.building // empty')
    RESULT=$(echo "$BUILD_INFO" | jq -r '.result // empty')
    DURATION=$(echo "$BUILD_INFO" | jq -r '.duration // 0')

    echo "[$(date +%T)] Build #${BUILD_NUM} status - Building: ${IS_BUILDING}, Result: ${RESULT:-IN_PROGRESS}, Elapsed: $((DURATION / 1000))s"

    if [ "$IS_BUILDING" = "false" ]; then
        echo "=========================================================="
        echo "🏁 BUILD #${BUILD_NUM} COMPLETED WITH RESULT: ${RESULT}"
        echo "=========================================================="
        break
    fi
    sleep 5
done

echo ""
echo "=========================================================="
echo "📜 JENKINS BUILD #${BUILD_NUM} CONSOLE OUTPUT (TAIL 100 LINES)"
echo "=========================================================="
curl -s -u "admin:${ADMIN_PW}" "${JOB_URL}/consoleText" | tail -n 100
