#!/bin/sh

# Set build command options here
# Uncomment the one you want to use, or define a custom option in the `BUILD_CMD` variable

# BUILD_CMD="docker-compose build --no-cache"
BUILD_CMD="docker-compose build --no-cache | tee scripts/rebuild.log"
# BUILD_CMD="docker-compose up --build --force-recreate"
# BUILD_CMD="docker-compose build | tee rebuild.txt"
# BUILD_CMD="docker-compose build --verbose | tee scripts/rebuild.log"
# BUILD_CMD="docker-compose build web | tee scripts/rebuild.log"
# BUILD_CMD="docker-compose build --no-cache | tee scripts/rebuild.log"
# BUILD_CMD="docker-compose up --build | tee tee scripts/rebuild.log"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker and try again."
    exit 1
fi

# Attempt to stop and remove containers, networks, and volumes, retrying if necessary
attempt=1
while [ $attempt -le 2 ]; do
    echo "Attempt $attempt to stop and remove containers..."
    docker-compose down
    
    # Check if any containers or networks remain
    if [ -z "$(docker ps -aq)" ] && [ -z "$(docker network ls -q --filter "name=blaster-net")" ]; then
        echo "All containers and networks stopped and removed."
        break
    fi
    
    attempt=$((attempt + 1))
done

# Remove unused volumes, networks, and images
docker system prune -af --volumes

# Replace 'your_db_volume_name' with the actual name of your database volume
# docker volume rm blaster-cms_pgadmin-data 2>/dev/null || echo "Database volume already removed"
# docker volume rm blaster-cms_postgres-data 2>/dev/null || echo "Database volume already removed"


echo "Rebuilding containers..."

# Attempt to rebuild containers, log output, and check for errors
if ! eval "$BUILD_CMD"; then
    echo "Error rebuilding containers"
    exit 1
fi


#echo "Starting containers..."
#if ! docker-compose up -d; then
#    echo "Error starting containers"
#    exit 1
#fi

# Final status check
echo "Build complete."
docker ps -a

echo "Checking volumes..."
docker volume ls





