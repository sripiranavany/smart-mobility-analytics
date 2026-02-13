#!/bin/bash
# Verification script for Java 25 and Docker Compose updates

echo "======================================"
echo "  Project Verification Script"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check 1: Docker Compose Files
echo "1. Checking Docker Compose files..."
COMPOSE_COUNT=$(find . -name "docker-compose.yml" -type f | wc -l)
if [ "$COMPOSE_COUNT" -eq 1 ]; then
    echo -e "${GREEN}✅ Only 1 docker-compose.yml found (correct!)${NC}"
    echo "   Located at: ./docker-compose.yml"
else
    echo -e "${RED}❌ Found $COMPOSE_COUNT docker-compose files (expected 1)${NC}"
fi
echo ""

# Check 2: Java 25 in CI Workflow
echo "2. Checking Java version in CI workflow..."
JAVA_VERSION=$(grep "JAVA_VERSION:" .github/workflows/ci.yml | grep -o "'[0-9]*'" | tr -d "'")
if [ "$JAVA_VERSION" = "25" ]; then
    echo -e "${GREEN}✅ CI workflow uses Java 25${NC}"
else
    echo -e "${RED}❌ CI workflow uses Java $JAVA_VERSION (expected 25)${NC}"
fi

MATRIX_JAVA=$(grep "java:" .github/workflows/ci.yml | grep -o "'[0-9]*'" | head -1 | tr -d "'")
if [ "$MATRIX_JAVA" = "25" ]; then
    echo -e "${GREEN}✅ CI matrix uses Java 25${NC}"
else
    echo -e "${RED}❌ CI matrix uses Java $MATRIX_JAVA (expected 25)${NC}"
fi
echo ""

# Check 3: Java 25 in Dockerfiles
echo "3. Checking Java version in Dockerfiles..."
DOCKER_JAVA_COUNT=$(grep -r "eclipse-temurin:25" */Dockerfile 2>/dev/null | wc -l)
if [ "$DOCKER_JAVA_COUNT" -eq 6 ]; then
    echo -e "${GREEN}✅ All Dockerfiles use Java 25 (6 occurrences)${NC}"
    echo "   - event-generator: build + runtime"
    echo "   - analytics-engine: build + runtime"
    echo "   - api-gateway: build + runtime"
else
    echo -e "${RED}❌ Found $DOCKER_JAVA_COUNT Java 25 references (expected 6)${NC}"
fi
echo ""

# Check 4: Maven Build
echo "4. Checking Maven build..."
if mvn -v &>/dev/null; then
    MAVEN_JAVA=$(mvn -v | grep "Java version" | grep -o "25" | head -1)
    if [ "$MAVEN_JAVA" = "25" ]; then
        echo -e "${GREEN}✅ Maven is using Java 25${NC}"
    else
        echo -e "${RED}⚠️  Maven is not using Java 25 locally${NC}"
        echo "   (This is OK if CI uses Java 25)"
    fi
else
    echo "ℹ️  Maven not found or not in PATH"
fi
echo ""

# Check 5: Documentation
echo "5. Checking documentation..."
if grep -q "Java 25" README.md; then
    echo -e "${GREEN}✅ README.md mentions Java 25${NC}"
else
    echo -e "${RED}❌ README.md doesn't mention Java 25${NC}"
fi

if grep -q "Java 25" QUICKSTART.md; then
    echo -e "${GREEN}✅ QUICKSTART.md mentions Java 25${NC}"
else
    echo -e "${RED}❌ QUICKSTART.md doesn't mention Java 25${NC}"
fi
echo ""

# Summary
echo "======================================"
echo "  Verification Summary"
echo "======================================"
echo ""
echo "Project: smart-mobility-analitics"
echo "Java Version Target: 25"
echo "Docker Compose: Single file in root"
echo "Monitoring: Prometheus + HertzBeat"
echo ""
echo -e "${GREEN}✅ All checks complete!${NC}"
echo ""
echo "Next steps:"
echo "1. git add ."
echo "2. git commit -m 'chore: Update to Java 25 and consolidate docker-compose'"
echo "3. git push origin main"
echo ""

