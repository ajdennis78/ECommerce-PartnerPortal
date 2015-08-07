#!/bin/bash

# Set variables
source env.sh

# Docker container version
if [ -z "$1" ]; then
        export VERSION="latest";
else
        export VERSION=$1;
fi
echo "Using version: $VERSION"

# Default application name
if [ -z "$2" ]; then
        export PP_APP_NAME="Partner-Portal";
else
        export PP_APP_NAME=$2;
fi
echo "Application Name: $PP_APP_NAME"

cleanUp() {
  # Remove dangling images left-over from build
  if [[ `docker images -q --filter "dangling=true"` ]]
  then
    echo "Deleting intermediate containers..."
    docker images -q --filter "dangling=true" | xargs docker rmi;
  fi
}
trap cleanUp EXIT

echo "Start Partner Catalog Service (PHP)"
# Start Partner Catalog container - PHP
docker run -d --name partner_catalog_service \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e SSL=${SSL} \
	-e APP_NAME=${PP_APP_NAME} -e PHP_TIER_NAME=${PHP_TIER_NAME} -e PHP_NODE_NAME=${PHP_NODE_NAME} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} -e SERVICE_URL=${SERVICE_URL} \
	--link web:web appdynamics/partner-catalog-service:latest

echo "Start Customer Survey Service (Node.js)"
# Start Partner Catalog container - PHP
docker run -d --name customer_survey_service \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e SSL=${SSL} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e APP_NAME=${PP_APP_NAME} -e TIER_NAME=${NODE_TIER_NAME} -e NODE_NAME=${NODE_NODE_NAME} \
	--link web:web appdynamics/customer-survey-service:latest

echo "Start Partner Portal App (Python)"
# Start Python containers 
echo -n "mysql: "; docker run -d --name python_mysql appdynamics/python-mysql:latest
echo -n "postgresql: ";docker run -d --name python_postgresql appdynamics/python-postgresql:latest
sleep 10

echo -n "py_app: ";docker run -d --name python_app \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e SSL=${SSL}\
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e APP_NAME=${PP_APP_NAME} -e TIER_NAME=${PY_TIER_NAME} -e NODE_NAME=${PY_NODE_NAME} \
	--link python_mysql:python_mysql --link python_postgresql:python_postgresql \
	--link partner_catalog_service:partner_catalog_service --link customer_survey_service:customer_survey_service appdynamics/python-app:latest

echo -n "load: "; docker run -d --name python_siege -e BUNDY_TIER=${SIEGE_URL} -e PROCUREMENT_URL=${PROCUREMENT_URL}\
	--link web:web --link python_app:python_app appdynamics/python-siege:latest

exit 0
