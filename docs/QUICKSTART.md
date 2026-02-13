# 🚀 Quick Start Guide - Smart Mobility Analytics

## Prerequisites
- Git
- Java 25
- Maven 3.9+
- Docker & Docker Compose
- GitHub account

## Step 1: Clone and Build

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/smart-mobility-analitics.git
cd smart-mobility-analitics

# Build all modules
mvn clean install

# Verify build success
# Expected: BUILD SUCCESS with all tests passing
```

## Step 2: Start Infrastructure

```bash
# Start all infrastructure services
docker-compose up -d zookeeper kafka cassandra neo4j prometheus grafana

# Wait for services to be ready (2-3 minutes)
docker-compose ps

# Verify health
docker-compose logs -f cassandra | grep "Starting listening for CQL clients"
docker-compose logs -f kafka | grep "started"
```

## Step 3: Run Application Services

### Option A: Using Docker Compose (Recommended)

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### Option B: Running Locally

```bash
# Terminal 1: Event Generator
cd event-generator
mvn spring-boot:run

# Terminal 2: Analytics Engine
cd analytics-engine
mvn spring-boot:run

# Terminal 3: API Gateway
cd api-gateway
mvn spring-boot:run
```

## Step 4: Verify Services

```bash
# Check API Gateway health
curl http://localhost:8080/actuator/health

# Check Prometheus metrics
curl http://localhost:8080/actuator/prometheus

# Access monitoring
# Prometheus: http://localhost:9090
# HertzBeat: http://localhost:1157 (admin/hertzbeat)
# Neo4j Browser: http://localhost:7474 (neo4j/password)
```

## Step 5: Push to GitHub

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Initial commit with CI/CD pipeline"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/smart-mobility-analitics.git
git branch -M main
git push -u origin main

# Watch CI pipeline in GitHub Actions tab
```

## 🎯 What to Expect

### CI Pipeline (2-5 minutes)
1. ✅ Code checkout
2. ✅ Maven build & test
3. ✅ Quality checks
4. ✅ Module builds
5. ✅ Docker image builds (on main/develop)
6. ✅ Test reports published

### Running Services
- **Event Generator** (8081): Generates events to Kafka
- **Analytics Engine** (8082): Processes events with Beam
- **API Gateway** (8080): REST API and GraphQL

### Monitoring
- **Prometheus** (9090): Metrics collection
- **HertzBeat** (1157): Real-time monitoring & alerting

## 🔍 Testing the System

```bash
# Generate test events
curl -X POST http://localhost:8081/api/events/generate

# Query analytics
curl http://localhost:8080/api/v1/analytics

# Check metrics
curl http://localhost:8080/actuator/metrics
```

## 🛑 Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop local Spring Boot apps
# Press Ctrl+C in each terminal
```

## 🐛 Troubleshooting

### Port Conflicts
```bash
# Check ports in use
lsof -i :8080
lsof -i :9042

# Kill process if needed
kill -9 <PID>
```

### Docker Issues
```bash
# Clean Docker
docker system prune -a

# Restart Docker daemon
sudo systemctl restart docker
```

### Build Failures
```bash
# Clean Maven cache
mvn clean
rm -rf ~/.m2/repository/com/sripiranavan

# Rebuild
mvn clean install -U
```

## 📊 Next Steps

1. ✅ Explore the API endpoints
2. ✅ Add custom HertzBeat monitoring templates
3. ✅ Configure alert rules in HertzBeat
4. ✅ Implement business logic
5. ✅ Add more tests
6. ✅ Configure production deployment

## 📚 Additional Resources

- [CI/CD Documentation](.github/workflows/README.md)
- [Project README](README.md)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Apache Beam Docs](https://beam.apache.org/documentation/)

## 🎉 Success!

You now have:
- ✅ Working multi-module Maven project
- ✅ CI/CD pipeline with GitHub Actions
- ✅ Dockerized services
- ✅ Complete monitoring stack
- ✅ Ready for development!

**Happy Coding! 🚀**

---

**Need Help?** Create an issue or check the documentation.

