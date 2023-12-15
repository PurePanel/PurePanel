#!/bin/bash

echo "================================================"
echo "----------------- Pure -------------------------"
echo "----- Automated install script with Docker -----"
echo "================================================"

echo "$(date)"
docker --version
cp .env-sail .env
docker compose up
echo "$(date)"
