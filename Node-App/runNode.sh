#!/bin/bash

# Set variables
CONTR_HOST=ec2-54-188-200-55.us-west-2.compute.amazonaws.com
CONTR_PORT=8090
SSL=off
ACCOUNT_NAME=customer1
ACCESS_KEY=573a095d-cb98-4289-832e-31d246fd6608

# Set App Variables
APP_NAME=Node_App
NODE_TIER_NAME=Customer-Survey-Tier
NODE_NODE_NAME=Customer-Survey-Node

echo "${CONTR_HOST} is the controller name and ${CONTR_PORT} is the controller port"

# Pull images
# docker pull appdynamics/customer-survey-service:latest

# Start container 
docker run -d --name customer_survey_service -p 3000:3000 \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e SSL=${SSL} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e APP_NAME=${APP_NAME} -e TIER_NAME=${NODE_TIER_NAME} -e NODE_NAME=${NODE_NODE_NAME} \
	--link web:web appdynamics/customer-survey-service:latest

exit 0