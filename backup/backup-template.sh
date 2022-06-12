#!/bin/bash

printf "Backup <volume-name> volume..."
docker run --rm -v <volume-name>:/volume -v $PWD:/backup loomchild/volume-backup backup <volume-name>
printf " Done\n"

printf "Restore <volume-name> volume..."
docker volume create <volume-name>
docker run --rm -v <volume-name>:/volume -v $PWD:/backup loomchild/volume-backup restore <volume-name>
printf " Done\n"