#!/bin/bash

echo "======================================"
echo "HertzBeat Stack Setup & Verification"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Stop any existing monitoring services
echo "Step 1: Cleaning up old containers..."
docker stop grafana hertzbeat 2>/dev/null || true
docker rm grafana hertzbeat 2>/dev/null || true
echo -e "${GREEN}✓${NC} Cleanup complete"
echo ""

# Step 2: Start PostgreSQL
echo "Step 2: Starting PostgreSQL database..."
docker compose up -d hertzbeat-db
sleep 10
if docker ps | grep -q hertzbeat-db; then
    echo -e "${GREEN}✓${NC} PostgreSQL is running"
else
    echo -e "${RED}✗${NC} PostgreSQL failed to start"
    docker compose logs hertzbeat-db --tail=20
    exit 1
fi
echo ""

# Step 3: Start VictoriaMetrics
echo "Step 3: Starting VictoriaMetrics..."
docker compose up -d victoria-metrics
sleep 10
if docker ps | grep -q victoria-metrics; then
    echo -e "${GREEN}✓${NC} VictoriaMetrics is running"
    # Test VictoriaMetrics health
    if curl -s http://localhost:8428/health | grep -q "OK"; then
        echo -e "${GREEN}✓${NC} VictoriaMetrics health check passed"
    fi
else
    echo -e "${RED}✗${NC} VictoriaMetrics failed to start"
    docker compose logs victoria-metrics --tail=20
    exit 1
fi
echo ""

# Step 4: Start HertzBeat
echo "Step 4: Starting HertzBeat (this may take 30-60 seconds)..."
docker compose up -d hertzbeat
echo "Waiting for HertzBeat to initialize..."

# Wait up to 90 seconds for HertzBeat to start
MAX_WAIT=90
COUNTER=0
while [ $COUNTER -lt $MAX_WAIT ]; do
    if curl -s http://localhost:1157 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} HertzBeat is running!"
        break
    fi
    echo -n "."
    sleep 3
    COUNTER=$((COUNTER + 3))
done
echo ""

if [ $COUNTER -ge $MAX_WAIT ]; then
    echo -e "${RED}✗${NC} HertzBeat failed to start within ${MAX_WAIT} seconds"
    echo "Checking logs..."
    docker compose logs hertzbeat --tail=50
    exit 1
fi

echo ""
echo "======================================"
echo "Verification Summary"
echo "======================================"

# Check all services
echo ""
echo "Service Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|hertzbeat|victoria"

echo ""
echo "Access Points:"
echo -e "${GREEN}HertzBeat UI:${NC}       http://localhost:1157"
echo -e "                      Username: admin"
echo -e "                      Password: hertzbeat"
echo ""
echo -e "${GREEN}VictoriaMetrics:${NC}    http://localhost:8428"
echo ""
echo -e "${GREEN}Prometheus:${NC}         http://localhost:9090"
echo ""

echo "======================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:1157 in your browser"
echo "2. Login with admin/hertzbeat"
echo "3. Add monitors for your applications"
echo ""

