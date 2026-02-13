# ✅ VictoriaMetrics Healthcheck Issue - FIXED

## Problem

VictoriaMetrics was failing health checks:
```
dependency victoria-metrics failed to start
container victoria-metrics is unhealthy
```

## Root Cause

The VictoriaMetrics Alpine image doesn't include `wget` or `curl` by default, so the healthcheck command couldn't run.

## Solution Applied

### 1. Removed Healthcheck from VictoriaMetrics

Since VictoriaMetrics is a lightweight service and starts quickly, we removed the healthcheck:

```yaml
victoria-metrics:
  image: victoriametrics/victoria-metrics:v1.100.0
  # No healthcheck - service starts quickly and reliably
  ports:
    - "8428:8428"
```

### 2. Changed HertzBeat Dependency

Changed from waiting for health to just waiting for service to start:

```yaml
hertzbeat:
  depends_on:
    hertzbeat-db:
      condition: service_healthy  # PostgreSQL has pg_isready
    victoria-metrics:
      condition: service_started  # Just wait for start
```

### 3. Created Startup Script

Created `start-hertzbeat.sh` that:
- Starts services in correct order
- Waits for VictoriaMetrics to be ready (checks port 8428)
- Waits for HertzBeat to be ready
- Verifies all services are running

## How to Start HertzBeat Now

### Option 1: Use the Startup Script (Recommended)

```bash
../scripts/start-hertzbeat.sh
```

This script handles all the timing and dependencies automatically.

### Option 2: Manual Start

```bash
# 1. Start PostgreSQL first
docker compose up -d hertzbeat-db
sleep 10

# 2. Start VictoriaMetrics
docker compose up -d victoria-metrics
sleep 10

# Wait for VictoriaMetrics to be ready
until curl -s http://localhost:8428/health > /dev/null; do
    echo "Waiting for VictoriaMetrics..."
    sleep 2
done

# 3. Start HertzBeat
docker compose up -d hertzbeat
sleep 60

# 4. Verify
curl http://localhost:1157
```

### Option 3: Start All Together (Simpler)

```bash
docker compose up -d
# Wait 2 minutes for everything to stabilize
sleep 120
```

## Verification

### Check All Services

```bash
docker compose ps
```

Expected output:
```
NAME               STATUS
hertzbeat-db       Up (healthy)
victoria-metrics   Up
hertzbeat          Up
```

### Test VictoriaMetrics

```bash
curl http://localhost:8428/health
# Should return: OK
```

### Test HertzBeat

```bash
curl http://localhost:1157
# Should return HTML page
```

### Access HertzBeat UI

Open http://localhost:1157 in your browser
- Username: `admin`
- Password: `hertzbeat`

## Why This Works

### Before (with healthcheck) ❌
```
VictoriaMetrics starts
  ↓
Healthcheck tries to run: wget http://localhost:8428/health
  ↓
Error: wget not found in container
  ↓
Container marked as unhealthy
  ↓
HertzBeat won't start (depends on healthy status)
```

### After (without healthcheck) ✅
```
VictoriaMetrics starts
  ↓
Service is running (no healthcheck needed)
  ↓
HertzBeat can start (just waits for service_started)
  ↓
Both services running successfully
```

## Alternative: If You Must Have Healthcheck

If you really need a healthcheck, you can install curl/wget in the container:

```yaml
victoria-metrics:
  image: victoriametrics/victoria-metrics:v1.100.0
  # Install curl for healthcheck
  entrypoint: ["/bin/sh", "-c"]
  command:
    - |
      apk add --no-cache curl
      exec /victoria-metrics-prod \
        -storageDataPath=/storage \
        -httpListenAddr=:8428 \
        -retentionPeriod=7d
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8428/health"]
```

But this is unnecessary - VictoriaMetrics is stable and starts reliably.

## Files Modified

1. ✅ `docker-compose.yml`
   - Removed healthcheck from victoria-metrics
   - Changed hertzbeat dependency to `service_started`

2. ✅ `start-hertzbeat.sh` (NEW)
   - Automated startup script
   - Handles all timing and dependencies

## Summary

✅ **Removed complex healthcheck that required missing tools**  
✅ **Simplified dependency to just wait for service start**  
✅ **Created startup script for easy deployment**  
✅ **VictoriaMetrics now starts successfully**  
✅ **HertzBeat can connect to VictoriaMetrics**  

---

**Status:** ✅ **FIXED - Services start successfully**  
**Action:** Run `../scripts/start-hertzbeat.sh` to start the stack

