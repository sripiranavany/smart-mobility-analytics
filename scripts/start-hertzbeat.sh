#!/bin/bash

echo "================================================"
echo " Starting HertzBeat Stack with Dependencies"
echo "================================================"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Start PostgreSQL
echo "Step 1: Starting PostgreSQL..."
docker compose up -d hertzbeat-db
echo "Waiting for PostgreSQL to be ready..."
for i in {1..15}; do
    if docker exec hertzbeat-db pg_isready -U hertzbeat > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} PostgreSQL is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""
echo ""

# Step 2: Start VictoriaMetrics
echo "Step 2: Starting VictoriaMetrics..."
docker compose up -d victoria-metrics
echo "Waiting for VictoriaMetrics to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8428/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} VictoriaMetrics is ready!"
        break
    fi
    echo -n "."
    sleep 2
done
echo ""
echo ""

# Step 3: Start HertzBeat
echo "Step 3: Starting HertzBeat..."
echo -e "${YELLOW}This may take 90-120 seconds for schema creation and initialization...${NC}"
docker compose up -d hertzbeat
echo ""

# Step 4: Wait for HertzBeat with longer timeout
echo "Waiting for HertzBeat to create schema and start..."
echo "(First startup takes longer due to database table creation)"
HERTZBEAT_READY=false
for i in {1..90}; do
    if curl -s http://localhost:1157 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} HertzBeat is ready!"
        HERTZBEAT_READY=true
        break
    fi
    # Check for errors every 15 seconds
    if [ $((i % 5)) -eq 0 ]; then
        if docker compose logs hertzbeat --tail=5 | grep -q "ERROR.*relation.*does not exist"; then
            echo -e "${RED}Schema creation issue detected. Checking...${NC}"
        fi
    fi
    echo -n "."
    sleep 3
done
echo ""
echo ""

if [ "$HERTZBEAT_READY" = false ]; then
    echo -e "${RED}HertzBeat did not start within 4.5 minutes${NC}"
    echo "Checking logs for errors..."
    docker compose logs hertzbeat --tail=50 | grep -E "ERROR|Exception"
    echo ""
    echo "Run: docker compose logs hertzbeat --tail=100"
    exit 1
fi

echo "================================================"
echo " HertzBeat Stack Status"
echo "================================================"
echo ""

# Show status
docker compose ps hertzbeat-db victoria-metrics hertzbeat 2>/dev/null || docker ps | grep -E "hertzbeat|victoria"

echo ""
echo "================================================"
echo -e " ${GREEN}✓ HertzBeat is Running!${NC}"
echo "================================================"
echo ""
echo -e " ${GREEN}Access HertzBeat:${NC} http://localhost:1157"
echo " Login: admin / hertzbeat"
echo ""
echo " VictoriaMetrics: http://localhost:8428"
echo ""
echo "================================================"
echo ""

