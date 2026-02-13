# ✅ HertzBeat with PostgreSQL + VictoriaMetrics Setup

## Architecture Overview

This is the **correct** HertzBeat setup that solves the `HistoryDataWriter` bean issue:

```
┌─────────────────────────────────────────────────┐
│           HertzBeat Monitoring Stack            │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐         ┌─────────────────┐ │
│  │  PostgreSQL  │◄────────│   HertzBeat     │ │
│  │  (Metadata)  │         │   (Manager)     │ │
│  └──────────────┘         └────────┬────────┘ │
│                                    │          │
│  ┌──────────────┐                  │          │
│  │VictoriaMetrics│◄─────────────────┘          │
│  │(Time-Series) │                             │
│  └──────────────┘                             │
│                                                 │
└─────────────────────────────────────────────────┘
         ▲                    ▲
         │                    │
    ┌────┴────┐         ┌────┴────┐
    │Prometheus│         │  Spring │
    │ Metrics  │         │  Boot   │
    │          │         │  Apps   │
    └──────────┘         └─────────┘
```

## Why This Setup Works

### Previous Issue (H2 Only)
```
❌ HertzBeat → H2 Database → Missing HistoryDataWriter bean → FAILED
```

### Current Solution (PostgreSQL + VictoriaMetrics)
```
✅ HertzBeat → PostgreSQL (metadata) + VictoriaMetrics (metrics) → SUCCESS
```

## Components

### 1. PostgreSQL (hertzbeat-db)
- **Purpose:** Store HertzBeat metadata (monitors, alerts, users)
- **Image:** `postgres:17-alpine`
- **Port:** Internal only (not exposed)
- **Database:** `hertzbeat`
- **Credentials:** `hertzbeat/hertzbeat`

### 2. VictoriaMetrics (victoria-metrics)
- **Purpose:** Time-series database for metrics storage
- **Image:** `victoriametrics/victoria-metrics:v1.100.0`
- **Port:** `8428`
- **Storage:** Persistent volume with 7-day retention
- **Why:** Creates the required `HistoryDataWriter` bean

### 3. HertzBeat (hertzbeat)
- **Purpose:** Monitoring manager and collector
- **Image:** `apache/hertzbeat:latest`
- **Ports:** `1157` (Web UI), `1158` (Cluster)
- **Dependencies:** PostgreSQL + VictoriaMetrics
- **Web UI:** http://localhost:1157

## Configuration

### Environment Variables (HertzBeat)

```yaml
# PostgreSQL Connection
SPRING_DATASOURCE_URL: jdbc:postgresql://hertzbeat-db:5432/hertzbeat
SPRING_DATASOURCE_USERNAME: hertzbeat
SPRING_DATASOURCE_PASSWORD: hertzbeat
SPRING_DATASOURCE_DRIVER_CLASS_NAME: org.postgresql.Driver

# VictoriaMetrics Configuration
WAREHOUSE_STORE_VICTORIA_METRICS_ENABLED: "true"
WAREHOUSE_STORE_VICTORIA_METRICS_URL: http://victoria-metrics:8428

# Disable other storage types
WAREHOUSE_STORE_JPA_ENABLED: "false"
WAREHOUSE_STORE_MEMORY_ENABLED: "false"
```

### Key Points

1. **PostgreSQL for Metadata**
   - User accounts
   - Monitor configurations
   - Alert rules
   - Dashboard settings

2. **VictoriaMetrics for Metrics**
   - Time-series data
   - Historical metrics
   - High-performance storage
   - Creates HistoryDataWriter bean ✅

3. **Healthchecks**
   - PostgreSQL: `pg_isready`
   - VictoriaMetrics: HTTP health endpoint
   - HertzBeat: Web UI availability

## Setup Instructions

### Quick Setup

```bash
# Run the automated setup script
../scripts/setup-hertzbeat.sh
```

### Manual Setup

```bash
# 1. Stop old containers
docker stop grafana hertzbeat 2>/dev/null || true
docker rm grafana hertzbeat 2>/dev/null || true

# 2. Start PostgreSQL
docker compose up -d hertzbeat-db
sleep 10

# 3. Start VictoriaMetrics
docker compose up -d victoria-metrics
sleep 10

# 4. Start HertzBeat (wait 60 seconds for initialization)
docker compose up -d hertzbeat
sleep 60

# 5. Verify
curl http://localhost:1157
```

## Verification

### Check Services Status

```bash
# All containers
docker compose ps

# Just HertzBeat stack
docker ps | grep -E "hertzbeat|victoria"

# Check logs
docker compose logs hertzbeat --tail=50
docker compose logs victoria-metrics --tail=20
docker compose logs hertzbeat-db --tail=20
```

### Test Endpoints

```bash
# HertzBeat Web UI
curl http://localhost:1157

# VictoriaMetrics Health
curl http://localhost:8428/health

# VictoriaMetrics Metrics
curl http://localhost:8428/metrics
```

## Access Information

### HertzBeat Web UI
- **URL:** http://localhost:1157
- **Username:** `admin`
- **Password:** `hertzbeat`

### VictoriaMetrics
- **URL:** http://localhost:8428
- **UI:** http://localhost:8428/vmui
- **Health:** http://localhost:8428/health

### PostgreSQL
- **Host:** `hertzbeat-db:5432` (internal only)
- **Database:** `hertzbeat`
- **Username:** `hertzbeat`
- **Password:** `hertzbeat`

## Monitoring Your Applications

### 1. Add Spring Boot Application Monitor

In HertzBeat UI:
1. Go to **Monitors** → **Add Monitor**
2. Select **Spring Boot 2.x** or **Spring Boot 3.x**
3. Fill in:
   - **Host:** `api-gateway` (or `localhost`)
   - **Port:** `8080`
   - **Base Path:** `/actuator`
   - **Collection Interval:** `60` seconds

### 2. Monitor Endpoints

HertzBeat will automatically monitor:
- `/actuator/health` - Health status
- `/actuator/metrics` - JVM metrics
- `/actuator/prometheus` - Prometheus metrics
- `/actuator/info` - Application info

### 3. Set Up Alerts

1. Go to **Alerts** → **Alert Rules**
2. Create rules for:
   - Response time > 1000ms
   - Error rate > 5%
   - Memory usage > 80%
   - CPU usage > 70%

## Complete Stack

After this setup, your complete monitoring stack is:

### Infrastructure (7 services)
1. ✅ Zookeeper (2181)
2. ✅ Kafka (9092)
3. ✅ Cassandra (9042)
4. ✅ Neo4j (7474, 7687)
5. ✅ Prometheus (9090)
6. ✅ **PostgreSQL (hertzbeat-db)** ⭐
7. ✅ **VictoriaMetrics (8428)** ⭐

### Monitoring (1 service)
8. ✅ **HertzBeat (1157)** ⭐

### Applications (3 services)
9. ✅ event-generator (background worker)
10. ✅ analytics-engine (stream processor)
11. ✅ api-gateway (8080)

## Advantages Over Previous Setup

### H2-Only Setup (Failed)
```
❌ Single database
❌ No time-series optimization
❌ Missing HistoryDataWriter bean
❌ Not production-ready
❌ Limited metrics retention
```

### PostgreSQL + VictoriaMetrics (Success)
```
✅ Separate metadata and metrics storage
✅ Optimized time-series database
✅ HistoryDataWriter bean created
✅ Production-ready architecture
✅ 7-day metrics retention (configurable)
✅ High-performance queries
✅ Scalable design
```

## Troubleshooting

### HertzBeat Won't Start

**Check dependencies:**
```bash
docker compose ps hertzbeat-db victoria-metrics
```

**Check logs:**
```bash
docker compose logs hertzbeat --tail=100
```

**Common issues:**
- PostgreSQL not ready → Wait longer
- VictoriaMetrics not ready → Check port 8428
- Wrong database URL → Check environment variables

### Can't Access Web UI

**Test connection:**
```bash
curl -v http://localhost:1157
```

**Check container:**
```bash
docker ps | grep hertzbeat
docker compose logs hertzbeat | grep "Started"
```

### PostgreSQL Connection Failed

**Test PostgreSQL:**
```bash
docker exec -it hertzbeat-db psql -U hertzbeat -d hertzbeat -c "SELECT version();"
```

### VictoriaMetrics Not Storing Data

**Check health:**
```bash
curl http://localhost:8428/health
```

**Check logs:**
```bash
docker compose logs victoria-metrics
```

## Data Retention

### VictoriaMetrics
- **Default:** 7 days (`-retentionPeriod=7d`)
- **Customize:** Edit `docker-compose.yml`
- **Example:** `-retentionPeriod=30d` for 30 days

### PostgreSQL
- **Metadata:** No automatic cleanup
- **Manual cleanup:** Via HertzBeat UI or SQL

## Backup Strategy

### PostgreSQL Backup
```bash
docker exec hertzbeat-db pg_dump -U hertzbeat hertzbeat > backup.sql
```

### VictoriaMetrics Backup
```bash
# Stop VictoriaMetrics
docker compose stop victoria-metrics

# Copy data
docker run --rm -v smart-mobility-analitics_victoria-metrics-data:/data \
  -v $(pwd):/backup alpine tar czf /backup/vm-backup.tar.gz /data

# Restart VictoriaMetrics
docker compose up -d victoria-metrics
```

## Performance Tuning

### VictoriaMetrics
```yaml
command:
  - '-storageDataPath=/storage'
  - '-httpListenAddr=:8428'
  - '-retentionPeriod=30d'          # Increase retention
  - '-memory.allowedPercent=80'     # Memory limit
  - '-search.maxConcurrentRequests=16'  # Query concurrency
```

### PostgreSQL
```yaml
environment:
  POSTGRES_INITDB_ARGS: "-E UTF8 --locale=en_US.UTF-8"
  POSTGRES_MAX_CONNECTIONS: "200"
  POSTGRES_SHARED_BUFFERS: "256MB"
```

## Integration with Prometheus

HertzBeat can pull metrics from Prometheus:

1. In HertzBeat UI:
   - Add **Prometheus** monitor
   - Host: `prometheus`
   - Port: `9090`

2. This gives you:
   - Unified dashboard
   - Combined alerts
   - Single monitoring interface

## Next Steps

1. ✅ Access HertzBeat: http://localhost:1157
2. ✅ Login with admin/hertzbeat
3. ✅ Change default password (Settings → Account)
4. ✅ Add application monitors
5. ✅ Configure alert rules
6. ✅ Create custom dashboards
7. ✅ Set up notification channels (Email, Slack, Webhook)

---

**Status:** ✅ **PRODUCTION-READY HERTZBEAT SETUP**  
**Architecture:** PostgreSQL + VictoriaMetrics + HertzBeat  
**Result:** Fully functional monitoring with proper time-series storage

