#!/bin/bash
docker rmi $(docker images -a | grep cityapp | awk '{print $3}')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)