#!/bin/bash
cd /opt/wordpress_docker 
docker-compose down
docker rmi $(docker images -a -q)
cd /opt/wordpress_docker
docker-compose up --build -d
exit 0 
