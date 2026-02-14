# Monitoring Integration Tests - CI/CD Setup

## Overview

The CI/CD pipeline now includes a dedicated **monitoring-integration-test** job that validates the monitoring stack (PostgreSQL, VictoriaMetrics, HertzBeat) separately from core application tests.

## CI/CD Workflow Structure

```
build-and-test (Core Services)
├── Kafka + Zookeeper
├── Cassandra
├── Neo4j
├── Prometheus
└── Application Tests

monitoring-integration-test (Monitoring Stack) [main/develop only]
├── PostgreSQL (hertzbeat-db)
├── VictoriaMetrics
└── Monitoring Stack Verification
```

## Jobs

### 1. `build-and-test` - Core Application Tests

**Services:**
- ✅ Kafka + Zookeeper - Event streaming
- ✅ Cassandra - Time-series storage
- ✅ Neo4j - Graph database
- ✅ Prometheus - Metrics scraping

**Tests:**
- Application build and unit tests
- Integration tests with core services
- Kafka topic creation and messaging
- Database connectivity

**When:** Every push and PR

---

### 2. `monitoring-integration-test` - Monitoring Stack Tests

**Services:**
- ✅ PostgreSQL - HertzBeat metadata storage
- ✅ VictoriaMetrics - Metrics time-series database

**Tests:**
- PostgreSQL connectivity and schema
- VictoriaMetrics HTTP endpoints (/metrics, /health)
- Service health verification
- Future: HertzBeat full stack test

**When:** Only on `main` and `develop` branches (not PRs)

**Why Separate?**
- Faster PR feedback (monitoring stack takes longer)
- Isolates monitoring issues from app issues
- Only needed for deployment branches

---

## Monitoring Test Details

### PostgreSQL Test

```bash
docker exec postgres psql -U hertzbeat -d hertzbeat -c "SELECT version();"
```

**Verifies:**
- Database is running
- User authentication works
- Database `hertzbeat` exists
- Connection from GitHub Actions runner

### VictoriaMetrics Test

```bash
curl -f http://localhost:8428/metrics
curl -f http://localhost:8428/health
```

**Verifies:**
- VictoriaMetrics HTTP server running
- Metrics endpoint accessible
- Health endpoint returns 200 OK
- Properly bound to 0.0.0.0 (not 127.0.0.1)

### Future: HertzBeat Full Stack Test

```bash
# To be implemented
docker compose -f docker-compose.monitoring.yml up -d
curl http://localhost:1157/
# Verify HertzBeat UI is accessible
```

---

## Why VictoriaMetrics is Started Manually

VictoriaMetrics binds to `127.0.0.1:8428` by default, which is not accessible from GitHub Actions runner. We start it manually with:

```bash
docker run -d \
  -p 8428:8428 \
  victoriametrics/victoria-metrics:v1.100.0 \
  -httpListenAddr=:8428  # Bind to all interfaces (0.0.0.0)
```

---

## Extending Monitoring Tests

### Add HertzBeat Full Test

1. **Create docker-compose for monitoring:**

```yaml
# docker-compose.monitoring.yml
services:
  hertzbeat:
    image: apache/hertzbeat:latest
    ports:
      - "1157:1157"
    environment:
      spring.datasource.url: jdbc:postgresql://hertzbeat-db:5432/hertzbeat
      warehouse.store.victoria-metrics.url: http://victoria-metrics:8428
```

2. **Update monitoring-integration-test job:**

```yaml
- name: Start HertzBeat Stack
  run: |
    docker compose -f docker-compose.monitoring.yml up -d
    sleep 60  # Wait for startup

- name: Test HertzBeat UI
  run: |
    curl -f http://localhost:1157/ || exit 1
    echo "✓ HertzBeat UI is accessible"
```

### Add Application Metrics Test

Test that your applications expose Prometheus metrics:

```yaml
- name: Download Build Artifacts
  uses: actions/download-artifact@v4
  with:
    name: build-artifacts-25

- name: Start API Gateway
  run: |
    java -jar api-gateway/target/*.jar &
    sleep 30

- name: Test Prometheus Metrics
  run: |
    curl -f http://localhost:8080/actuator/prometheus | grep "jvm_memory"
    echo "✓ Application exposes Prometheus metrics"
```

---

## Configuration

### Timeout

```yaml
timeout-minutes: 30  # Sufficient for monitoring stack startup
```

### Conditions

```yaml
if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop')
```

**Only runs on:**
- ✅ Push to `main` branch
- ✅ Push to `develop` branch
- ❌ NOT on PRs
- ❌ NOT on feature branches

**Rationale:** Monitoring stack tests are slower and only needed before deployment.

---

## Troubleshooting

### VictoriaMetrics "connection refused"

**Problem:** VictoriaMetrics binds to 127.0.0.1 by default.

**Solution:** Use `-httpListenAddr=:8428` to bind to all interfaces.

### PostgreSQL "connection refused"

**Problem:** PostgreSQL not ready yet.

**Solution:** Service has healthcheck, but you can add manual wait:

```yaml
- name: Wait for PostgreSQL
  run: |
    for i in {1..30}; do
      docker exec postgres pg_isready -U hertzbeat && break
      sleep 2
    done
```

### HertzBeat uses H2 instead of PostgreSQL

**Problem:** Environment variables not recognized.

**Solution:** Use underscores instead of dots in env var names:

```yaml
env:
  spring_datasource_url: jdbc:postgresql://...
```

---

## Local Testing

Test the monitoring stack locally:

```bash
# Start monitoring services
cd /path/to/project
./scripts/start-hertzbeat.sh

# Verify services
curl http://localhost:8428/metrics     # VictoriaMetrics
curl http://localhost:1157             # HertzBeat
docker exec hertzbeat-db pg_isready    # PostgreSQL
```

---

## Metrics and Performance

### CI Build Time Impact

| Job | Duration | When |
|-----|----------|------|
| build-and-test | ~5-8 min | Every push/PR |
| monitoring-integration-test | ~3-5 min | main/develop only |

**Total overhead:** ~3-5 minutes, but only on deployment branches.

### Service Startup Times

| Service | Startup Time |
|---------|-------------|
| PostgreSQL | ~5 seconds |
| VictoriaMetrics | ~2 seconds |
| HertzBeat | ~60 seconds |

---

## Future Enhancements

### 1. Add Metrics Ingestion Test

```yaml
- name: Test Metrics Ingestion
  run: |
    # Send test metrics to VictoriaMetrics
    curl -X POST http://localhost:8428/api/v1/import/prometheus \
      -d 'test_metric{label="value"} 123'
    
    # Query back the metrics
    curl http://localhost:8428/api/v1/query?query=test_metric
```

### 2. Add Alert Manager Test

```yaml
services:
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - 9093:9093
```

### 3. Add Grafana Dashboard Test

```yaml
- name: Test Grafana Dashboards
  run: |
    # Import dashboard JSON
    # Verify dashboard loads
```

---

## Summary

✅ **Monitoring stack tests isolated from core app tests**  
✅ **Only runs on deployment branches (main/develop)**  
✅ **Faster PR feedback (no monitoring overhead)**  
✅ **Validates PostgreSQL + VictoriaMetrics connectivity**  
✅ **Ready for HertzBeat full stack testing**  

**Status:** ✅ Monitoring integration test job configured and working

---

**Last Updated:** February 14, 2026  
**CI/CD Platform:** GitHub Actions  
**Workflow File:** `.github/workflows/ci.yml`

