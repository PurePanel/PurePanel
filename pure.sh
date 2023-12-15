#!/bin/bash

echo "================================================"
echo "----------------- Pure -------------------------"
echo "----- Automated install script with Docker -----"
echo "================================================"

echo "$(date)"
docker --version
rm -rf vendor
rm -f composer.lock

cp .env-sail .env
docker compose restart pure_php

docker compose up
echo "$(date)"
