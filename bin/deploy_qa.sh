#!/bin/bash
ssh root@8.22.8.236 "docker rm -f lorry_api; docker rmi -f centurylink/lorry-api:qa; docker pull centurylink/lorry-api:qa; docker run -d --name lorry_api -p 9292:9292 centurylink/lorry-api:qa"
