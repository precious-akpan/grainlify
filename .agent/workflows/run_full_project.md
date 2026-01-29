---
description: Fully run the Grainlify project (Frontend + Backend + Database)
---
# Run Full Project

This workflow sets up the database, configured the environment, and starts both backend and frontend servers.

## 1. Environment Setup

Ensure your local environment files are configured.

```bash
# Verify environment files exist (these should have been created/updated already)
ls -la backend/.env frontend/.env
```

## 2. Database Setup

We need to ensure the PostgreSQL container is running and correctly configured.

### 2.1 Start PostgreSQL Container

Check if `patchwork-postgres` exists. If not, create and start it.

```bash
// turbo
# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^patchwork-postgres$"; then
    echo "Creating patchwork-postgres container..."
    docker run --name patchwork-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15
else
    echo "Container exists. Ensuring it is running..."
    docker start patchwork-postgres
fi
```

### 2.2 Configure Database Schema

Run the setup script to create the database and user.

```bash
// turbo
# Make executable just in case
chmod +x backend/setup_grainlify_db.sh
# Run setup script (might require sudo if docker needs it, but try without first given previous context)
./backend/setup_grainlify_db.sh
```

## 3. Run Backend

Start the Go backend server using the provided script.

```bash
cd backend
# This script handles auto-reload with 'air' if available, or falls back to 'go run'
./run-dev.sh
```

## 4. Run Frontend

Start the React frontend in a separate terminal.

```bash
cd frontend
pnpm run dev
```

## Verification

- **Backend Health:** Visit [http://localhost:8080/health](http://localhost:8080/health) (or similar endpoint)
- **Frontend:** Visit [http://localhost:5173](http://localhost:5173)
- **Database:** Connect via `psql postgresql://grainlify:grainlify_dev_password@localhost:5432/grainlify`

> [!NOTE]
> If `run-dev.sh` fails with database connection errors, ensure Step 2 completed successfully.
