#!/bin/bash

set -e

CONTAINER_NAME="carolina-website"
URL="http://localhost"

echo "Starting website locally..."

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping existing container..."
  docker-compose down
fi

# Build and start
docker-compose up -d --build

# Wait for container to be healthy
echo "Waiting for container to be ready..."
sleep 2

# Check it's up
if curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200"; then
  echo "Website is running at $URL"
else
  echo "Container started but site may still be loading — check $URL"
fi
