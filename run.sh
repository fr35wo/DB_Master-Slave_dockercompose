#!/bin/bash

set -e

# 환경 변수 설정
MASTER_PORT=33306
SLAVE_PORT=43306
ROOT_PASSWORD=$(cat ./mariadb_root_password.txt)
MASTER_USER="db_name"
MASTER_PASSWORD="rootpassword"

# Docker Compose 실행
docker-compose -f ./docker-compose.yml up -d

# 컨테이너 준비 대기
echo "Waiting for Master and Slave to be ready..."
until docker exec db_master mysqladmin ping -h"127.0.0.1" --silent; do
  sleep 2
done
echo "Master is ready."

until docker exec db_slave mysqladmin ping -h"127.0.0.1" --silent; do
  sleep 2
done
echo "Slave is ready."

# Master 정보 가져오기
echo "Fetching master log file and position..."
MASTER_STATUS=$(docker exec db_master mysql -uroot -p$ROOT_PASSWORD -e "SHOW MASTER STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | awk '/File:/ {print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | awk '/Position:/ {print $2}')

if [[ -z "$MASTER_LOG_FILE" || -z "$MASTER_LOG_POS" ]]; then
    echo "Error: Failed to retrieve master log file or position."
    exit 1
fi

echo "Master Log File: $MASTER_LOG_FILE"
echo "Master Log Position: $MASTER_LOG_POS"

# Slave 설정
QUERY="CHANGE MASTER TO MASTER_HOST='db_master', MASTER_USER='$MASTER_USER', MASTER_PASSWORD='$MASTER_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;"
echo "Setting up slave with query: $QUERY"

docker exec db_slave mysql -uroot -p$ROOT_PASSWORD -e "STOP SLAVE;"
docker exec db_slave mysql -uroot -p$ROOT_PASSWORD -e "$QUERY"
docker exec db_slave mysql -uroot -p$ROOT_PASSWORD -e "START SLAVE;"

echo "Master-Slave setup completed successfully."
