#!/bin/bash

cleanUp() {
  rm -rf Python-App
  # Remove dangling images left-over from build
  if [[ `docker images -q --filter "dangling=true"` ]]
  then
    echo
    echo "Deleting intermediate containers..."
    docker images -q --filter "dangling=true" | xargs docker rmi;
  fi
}
trap cleanUp EXIT

# Build ECommerce Containers
echo "Building ECommerce-Containers..." 
(git clone -b FaultInjection https://github.com/Appdynamics/ECommerce-Docker.git)
(cp env.sh ECommerce-Docker)
(cd ECommerce-Docker && ./build.sh)
(cp ECommerce-Docker/run.sh ./startECommerce.sh)

echo; echo "Building Partner Portal containers"

echo; echo "Building Python App: "
(git clone https://github.com/Appdynamics/Python-Demo-App.git Python-App)
(cp -rf python-siege Python-App/Docker/)

echo; echo "Building Python Postgres Database..." 
(cd Python-App/Docker/python-postgresql && docker build -t appdynamics/python-postgresql .)

echo; echo "Building Python MySQL Database..." 
(cd Python-App/Docker/python-mysql && docker build -t appdynamics/python-mysql .)

echo; echo "Building Python App..." 
(cd Python-App/Docker/python-app && docker build -t appdynamics/python-app .)

echo; echo "Building Siege Load Generator..." 
(cd Python-App/Docker/python-siege && docker build -t appdynamics/python-siege .)

echo; echo "Building PHP App..."
(cd PHP-App && docker build -t appdynamics/partner-catalog-service .)

echo; echo "Building Node App..." 
(cd Node-App && docker build -t appdynamics/customer-survey-service .)