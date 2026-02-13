#!/bin/bash
# Verification script for HertzBeat migration

echo "======================================"
echo "  HertzBeat Migration Verification"
echo "======================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check 1: No Grafana in docker-compose
echo "1. Checking for Grafana removal..."
if grep -q "grafana" docker-compose.yml; then
    echo -e "${RED}❌ Grafana still found in docker-compose.yml${NC}"
else
    echo -e "${GREEN}✅ Grafana successfully removed${NC}"
fi
echo ""

# Check 2: HertzBeat present
echo "2. Checking for HertzBeat..."
HERTZBEAT_COUNT=$(grep -c "hertzbeat:" docker-compose.yml)
if [ "$HERTZBEAT_COUNT" -ge 1 ]; then
    echo -e "${GREEN}✅ HertzBeat service configured${NC}"
    echo "   Service name: hertzbeat"
    echo "   Port: 1157 (Web UI)"
    echo "   Port: 1158 (Cluster)"
else
    echo -e "${RED}❌ HertzBeat not found in docker-compose.yml${NC}"
fi
echo ""

# Check 3: HertzBeat config file
echo "3. Checking HertzBeat configuration..."
if [ -f "infrastructure/hertzbeat/application.yml" ]; then
    echo -e "${GREEN}✅ HertzBeat configuration file exists${NC}"
    echo "   Location: infrastructure/hertzbeat/application.yml"
else
    echo -e "${RED}❌ HertzBeat configuration file missing${NC}"
fi
echo ""

# Check 4: Volume configuration
echo "4. Checking Docker volumes..."
if grep -q "hertzbeat-data" docker-compose.yml && grep -q "hertzbeat-logs" docker-compose.yml; then
    echo -e "${GREEN}✅ HertzBeat volumes configured${NC}"
    echo "   - hertzbeat-data"
    echo "   - hertzbeat-logs"
else
    echo -e "${RED}❌ HertzBeat volumes not properly configured${NC}"
fi

if grep -q "grafana-data" docker-compose.yml; then
    echo -e "${YELLOW}⚠️  grafana-data volume still present (can be removed)${NC}"
else
    echo -e "${GREEN}✅ Grafana volumes removed${NC}"
fi
echo ""

# Check 5: Documentation updates
echo "5. Checking documentation updates..."
DOCS_OK=true

if ! grep -q "HertzBeat" README.md; then
    echo -e "${RED}❌ README.md not updated${NC}"
    DOCS_OK=false
else
    echo -e "${GREEN}✅ README.md updated${NC}"
fi

if ! grep -q "HertzBeat" QUICKSTART.md; then
    echo -e "${RED}❌ QUICKSTART.md not updated${NC}"
    DOCS_OK=false
else
    echo -e "${GREEN}✅ QUICKSTART.md updated${NC}"
fi

if [ -f "HERTZBEAT-GUIDE.md" ]; then
    echo -e "${GREEN}✅ HERTZBEAT-GUIDE.md created${NC}"
else
    echo -e "${YELLOW}⚠️  HERTZBEAT-GUIDE.md not found${NC}"
fi
echo ""

# Summary
echo "======================================"
echo "  Migration Summary"
echo "======================================"
echo ""
echo "Old Stack: Prometheus + Grafana"
echo "New Stack: Prometheus + HertzBeat"
echo ""
echo "Access URLs:"
echo "  - Prometheus: http://localhost:9090"
echo "  - HertzBeat:  http://localhost:1157"
echo "  - Credentials: admin/hertzbeat"
echo ""
echo -e "${GREEN}✅ Migration verification complete!${NC}"
echo ""
echo "Next steps:"
echo "1. docker-compose up -d"
echo "2. Access HertzBeat at http://localhost:1157"
echo "3. Login with admin/hertzbeat"
echo "4. Add monitors for your services"
echo ""

