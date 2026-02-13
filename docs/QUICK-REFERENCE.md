# 🚀 Smart Mobility Analytics - Quick Reference

## Start/Stop Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]
```

## Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **HertzBeat** | http://localhost:1157 | admin/hertzbeat |
| **Prometheus** | http://localhost:9090 | - |
| **Neo4j** | http://localhost:7474 | neo4j/password |
| **API Gateway** | http://localhost:8080 | - |
| **Event Generator** | http://localhost:8081 | - |
| **Analytics Engine** | http://localhost:8082 | - |

## Service Ports

| Service | Port(s) | Purpose |
|---------|---------|---------|
| Zookeeper | 2181 | Coordination |
| Kafka | 9092, 9093 | Messaging |
| Cassandra | 9042, 7000 | Database |
| Neo4j | 7474, 7687 | Graph DB |
| Prometheus | 9090 | Metrics |
| HertzBeat | 1157, 1158 | Monitoring |
| API Gateway | 8080 | REST API |
| Event Generator | 8081 | Events |
| Analytics Engine | 8082 | Processing |

## Maven Commands

```bash
# Build all modules
mvn clean install

# Build specific module
mvn clean install -pl [module-name] -am

# Run tests
mvn test

# Skip tests
mvn clean install -DskipTests

# Run specific module
cd [module-name] && mvn spring-boot:run
```

## Verification Scripts

```bash
# Verify Java 25 and Docker setup
./verify-setup.sh

# Verify HertzBeat migration
./verify-hertzbeat.sh
```

## HertzBeat Quick Setup

1. **Access:** http://localhost:1157
2. **Login:** admin/hertzbeat
3. **Change Password:** Settings → Account
4. **Add Monitors:** Monitors → Add Monitor
5. **Configure Alerts:** Alerts → Alert Rules

### Auto-Discovered Services
- API Gateway (8080) - Automatic
- Event Generator (8081) - Automatic
- Analytics Engine (8082) - Automatic

## Docker Compose Services

```bash
# List all services
docker-compose ps

# Check specific service
docker-compose ps [service-name]

# View service logs
docker-compose logs -f [service-name]

# Execute command in container
docker-compose exec [service-name] sh
```

## Health Checks

```bash
# API Gateway
curl http://localhost:8080/actuator/health

# Event Generator
curl http://localhost:8081/actuator/health

# Analytics Engine
curl http://localhost:8082/actuator/health

# Prometheus
curl http://localhost:9090/-/healthy

# HertzBeat
curl http://localhost:1157
```

## Common Issues

### Port Conflicts
```bash
# Check what's using a port
lsof -i :[port-number]

# Kill process
kill -9 [PID]
```

### Docker Issues
```bash
# Clean up
docker system prune -a

# Remove volumes
docker volume prune

# Restart Docker
sudo systemctl restart docker
```

### Maven Build Issues
```bash
# Clean and rebuild
mvn clean install -U

# Clear local repo
rm -rf ~/.m2/repository/com/sripiranavan
```

## Project Structure

```
smart-mobility-analitics/
├── common-lib/          # Shared models & utilities
├── event-generator/     # Kafka event producer
├── analytics-engine/    # Apache Beam pipeline
├── api-gateway/         # REST API
├── infrastructure/      # Config files
│   ├── prometheus/
│   └── hertzbeat/
└── .github/workflows/   # CI/CD pipeline
```

## Documentation Files

- **README.md** - Full project documentation
- **QUICKSTART.md** - Quick start guide
- **HERTZBEAT-GUIDE.md** - Monitoring setup guide
- **CI-CD-CHECKLIST.md** - Deployment checklist

## Git Commands

```bash
# View changes
git status

# Commit changes
git add .
git commit -m "Your message"

# Push to GitHub
git push origin main

# View commit history
git log --oneline
```

## Technology Versions

- **Java:** 25
- **Spring Boot:** 4.0.2
- **Apache Beam:** 2.61.0
- **Maven:** 3.9+
- **Docker Compose:** 3.8

## Key Features

✅ Multi-module Maven project
✅ CI/CD with GitHub Actions
✅ Docker containerization (Java 25)
✅ Auto-discovery monitoring
✅ Real-time stream processing
✅ Graph + Time-series databases
✅ Prometheus metrics
✅ HertzBeat dashboards

## Need Help?

- Check logs: `docker-compose logs -f`
- Run verification: `./verify-setup.sh`
- Read guides: `HERTZBEAT-GUIDE.md`
- Check health: Visit actuator endpoints

---

**Quick Start:** `docker-compose up -d && open http://localhost:1157`

