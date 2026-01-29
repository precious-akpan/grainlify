#!/bin/bash
set -e

echo "Starting Grainlify Database Setup..."

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: docker command not found"
    exit 1
fi

# Try to start the container if it exists but is stopped
echo "Ensuring patchwork-postgres container is running..."
docker start patchwork-postgres || echo "Container might typically be running or doesn't exist. Proceeding to configuration..."

echo "Creating database 'grainlify'..."
docker exec patchwork-postgres psql -U postgres -c "CREATE DATABASE grainlify;" || echo "Database might already exist"

echo "Creating user 'grainlify'..."
docker exec patchwork-postgres psql -U postgres -c "CREATE USER grainlify WITH PASSWORD 'grainlify_dev_password';" || echo "User might already exist"

echo "Granting privileges..."
docker exec patchwork-postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE grainlify TO grainlify;"

echo "Setting database owner..."
docker exec patchwork-postgres psql -U postgres -c "ALTER DATABASE grainlify OWNER TO grainlify;"

echo "Verifying connection..."
if docker exec patchwork-postgres psql -U grainlify -d grainlify -c "SELECT version();" &> /dev/null; then
    echo "✅ Database setup complete and connection verified!"
    echo "Connection URL: postgresql://grainlify:grainlify_dev_password@localhost:5432/grainlify?sslmode=disable"
else
    echo "⚠️  Setup finished but connection verification failed."
    exit 1
fi
