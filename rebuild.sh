#!/usr/bin/env bash

docker exec -u $(id -u):$(id -g) -it zen-desktop-app-1 /bin/bash -c "npm run build:ui -- fix syntax" && npm run start
