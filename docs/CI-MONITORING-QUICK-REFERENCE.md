# CI/CD Quick Reference - Monitoring Tests

## ✅ What Was Fixed

1. **VictoriaMetrics startup issue** - Now binds to 0.0.0.0 instead of 127.0.0.1
2. **Monitoring stack separated** - No longer blocks PR builds
3. **Test coverage added** - PostgreSQL + VictoriaMetrics verified
4. **Documentation created** - Complete troubleshooting guide

## 🚀 Quick Commands

### Test Monitoring Stack Locally

```bash
# Start VictoriaMetrics
docker run -d --name vm-test -p 8428:8428 \
  victoriametrics/victoria-metrics:v1.100.0 \
  -httpListenAddr=:8428

# Test it
curl http://localhost:8428/metrics
curl http://localhost:8428/health

# Start PostgreSQL
docker run -d --name pg-test -p 5432:5432 \
  -e POSTGRES_USER=hertzbeat \
  -e POSTGRES_PASSWORD=hertzbeat \
  -e POSTGRES_DB=hertzbeat \
  postgres:17-alpine

# Test it
docker exec pg-test pg_isready -U hertzbeat
```

### Test Full Monitoring Stack

```bash
cd /path/to/project
./scripts/start-hertzbeat.sh
```

## 📋 CI/CD Jobs Overview

| Job | When | Duration | Tests |
|-----|------|----------|-------|
| build-and-test | Every push/PR | 5-8 min | App + Kafka + Cassandra + Neo4j |
| code-quality | After build | 1-2 min | Code verification |
| dependency-check | After build | 1 min | Security scan |
| module-build | After build | 2-3 min | Per-module tests |
| docker-build | main/develop | 3-4 min | Docker images |
| **monitoring-integration-test** | **main/develop** | **3-5 min** | **PostgreSQL + VictoriaMetrics** |
| summary | Always | <1 min | Build report |

## 🔍 Monitoring Test Details

### What It Tests

✅ PostgreSQL connectivity  
✅ PostgreSQL authentication  
✅ VictoriaMetrics HTTP endpoints  
✅ VictoriaMetrics /metrics endpoint  
✅ VictoriaMetrics /health endpoint  

### What It Doesn't Test (Yet)

⏭️ HertzBeat full stack (ready to add)  
⏭️ Metrics ingestion  
⏭️ Application metrics endpoints  
⏭️ Alert configuration  

## 📊 When Monitoring Tests Run

```
Feature Branch → PR → ❌ No monitoring tests
                      ✅ Core tests only

Main Branch → Push → ✅ Core tests
                     ✅ Monitoring tests
                     ✅ Docker builds

Develop Branch → Push → ✅ Core tests
                        ✅ Monitoring tests
                        ✅ Docker builds
```

## 🐛 Troubleshooting

### VictoriaMetrics "connection refused"
```bash
# Use this command:
docker run ... -httpListenAddr=:8428  # Binds to 0.0.0.0
# NOT:
# Default binds to 127.0.0.1
```

### PostgreSQL not ready
```bash
# Wait for it:
for i in {1..30}; do
  docker exec postgres pg_isready && break
  sleep 2
done
```

### Monitoring test fails but app works
- This is expected on feature branches (test doesn't run)
- Only fails on main/develop if monitoring stack is broken

## 📝 Adding More Tests

### Add HertzBeat Full Test

Edit `.github/workflows/ci.yml`:

```yaml
- name: Start HertzBeat
  run: |
    docker run -d --name hertzbeat \
      -p 1157:1157 \
      -e spring.datasource.url=jdbc:postgresql://... \
      apache/hertzbeat:latest
    sleep 60

- name: Test HertzBeat UI
  run: curl -f http://localhost:1157/
```

### Add Metrics Ingestion Test

```yaml
- name: Test Metrics Ingestion
  run: |
    # Send test metric
    curl -X POST http://localhost:8428/api/v1/import/prometheus \
      -d 'test_metric 123'
    
    # Verify it's stored
    curl http://localhost:8428/api/v1/query?query=test_metric
```

## 📚 Documentation

- **Full Guide:** `docs/MONITORING-CI-TESTS.md`
- **Setup Summary:** `docs/CI-MONITORING-SETUP-SUMMARY.md`
- **Workflow File:** `.github/workflows/ci.yml`

## ✅ Validation

Run this before committing:

```bash
# Validate YAML syntax
yamllint .github/workflows/ci.yml

# Test VictoriaMetrics locally
docker run -d -p 8428:8428 victoriametrics/victoria-metrics:v1.100.0 -httpListenAddr=:8428
curl http://localhost:8428/health

# Test PostgreSQL locally
docker run -d -p 5432:5432 -e POSTGRES_USER=hertzbeat -e POSTGRES_PASSWORD=hertzbeat -e POSTGRES_DB=hertzbeat postgres:17-alpine
docker exec $(docker ps -q -f ancestor=postgres:17-alpine) pg_isready -U hertzbeat
```

## 🎯 Success Criteria

✅ Core tests pass on all branches  
✅ Monitoring tests pass on main/develop  
✅ VictoriaMetrics endpoints accessible  
✅ PostgreSQL connection successful  
✅ GitHub Actions summary generated  

---

**Status:** ✅ Complete and ready to use  
**Next:** Push to main/develop to see monitoring tests in action!

