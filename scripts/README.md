# Scripts Directory

This directory contains utility scripts for managing the Smart Mobility Analytics platform.

## 📜 Available Scripts

### HertzBeat Management

#### `start-hertzbeat.sh` ⭐ **Primary Script**
Starts the complete HertzBeat monitoring stack with proper dependency handling.

```bash
./scripts/start-hertzbeat.sh
```

**What it does:**
1. Starts PostgreSQL database
2. Waits for PostgreSQL to be ready
3. Starts VictoriaMetrics
4. Waits for VictoriaMetrics to be ready
5. Starts HertzBeat
6. Waits for HertzBeat to initialize (including schema creation)
7. Displays status and access information

**First run:** ~2-3 minutes (schema creation)  
**Subsequent runs:** ~45-60 seconds

---

#### `setup-hertzbeat.sh`
Legacy setup script. Use `start-hertzbeat.sh` instead.

```bash
./scripts/setup-hertzbeat.sh
```

---

#### `verify-hertzbeat.sh`
Verifies that HertzBeat is running and accessible.

```bash
./scripts/verify-hertzbeat.sh
```

**Checks:**
- PostgreSQL is healthy
- VictoriaMetrics is responding
- HertzBeat web UI is accessible
- Database schema exists

---

#### `verify-setup.sh`
Comprehensive verification of the entire platform setup.

```bash
./scripts/verify-setup.sh
```

**Checks:**
- All infrastructure services (Kafka, Cassandra, Neo4j, etc.)
- Monitoring stack (PostgreSQL, VictoriaMetrics, HertzBeat)
- Application services (event-generator, analytics-engine, api-gateway)

## 🚀 Quick Start

### Start Everything

```bash
# Start all services
docker compose up -d

# Start HertzBeat monitoring (with proper initialization)
./scripts/start-hertzbeat.sh

# Verify everything is running
./scripts/verify-setup.sh
```

### Stop Everything

```bash
# Stop all services
docker compose down
```

## 📋 Script Usage Examples

### Example 1: First Time Setup

```bash
# 1. Start infrastructure and applications
docker compose up -d zookeeper kafka cassandra neo4j prometheus
docker compose up -d api-gateway event-generator analytics-engine

# 2. Start monitoring stack with proper initialization
./scripts/start-hertzbeat.sh

# 3. Verify everything is running
./scripts/verify-setup.sh
```

### Example 2: Restart HertzBeat Only

```bash
# Stop HertzBeat
docker compose stop hertzbeat

# Start with proper initialization
./scripts/start-hertzbeat.sh
```

### Example 3: Check Status

```bash
# Quick check
./scripts/verify-hertzbeat.sh

# Comprehensive check
./scripts/verify-setup.sh
```

## 🔧 Script Maintenance

### Making Scripts Executable

If scripts aren't executable, run:

```bash
chmod +x scripts/*.sh
```

### Customizing Scripts

All scripts can be edited to suit your needs:

```bash
# Example: Change wait times in start-hertzbeat.sh
nano scripts/start-hertzbeat.sh
```

## 📝 Script Details

### start-hertzbeat.sh

**Dependencies:** docker, docker-compose, curl  
**Timeout:** 90 seconds for HertzBeat initialization  
**Exit Codes:**
- `0` - Success
- `1` - HertzBeat failed to start

**Environment Variables:** None required

**Output:**
- Colored status messages (green = success, yellow = warning, red = error)
- Progress dots during waiting
- Final status summary
- Access URLs

---

### verify-hertzbeat.sh

**Dependencies:** docker, curl, psql (optional for database checks)  
**Exit Codes:**
- `0` - All checks passed
- `1` - One or more checks failed

---

### verify-setup.sh

**Dependencies:** docker, curl  
**Exit Codes:**
- `0` - All services running
- `1` - One or more services not running

---

## 🐛 Troubleshooting

### Script Won't Run

```bash
# Check if executable
ls -la scripts/*.sh

# Make executable if needed
chmod +x scripts/*.sh
```

### Script Hangs

```bash
# Check what it's waiting for
docker compose ps

# Check logs
docker compose logs <service-name>

# Kill and restart
Ctrl+C
docker compose restart <service-name>
```

### HertzBeat Won't Start

```bash
# Check dependencies first
docker compose ps hertzbeat-db victoria-metrics

# Check logs
docker compose logs hertzbeat --tail=100

# Check for port conflicts
lsof -i :1157
```

## 📚 Related Documentation

- [HertzBeat Setup Guide](../docs/HERTZBEAT-FINAL-SETUP.md)
- [PostgreSQL Schema Fix](../docs/POSTGRESQL-SCHEMA-FIX.md)
- [VictoriaMetrics Fix](../docs/VICTORIAMETRICS-HEALTHCHECK-FIX.md)
- [Full Documentation Index](../docs/INDEX.md)

## 🔄 Script Update History

| Date | Script | Change |
|------|--------|--------|
| 2026-02-13 | start-hertzbeat.sh | Increased timeout for schema creation |
| 2026-02-13 | start-hertzbeat.sh | Added error checking for schema issues |
| 2026-02-13 | All scripts | Moved to scripts/ directory |

---

**Directory:** `/scripts`  
**Purpose:** Automation and verification scripts  
**Maintained:** Yes  
**Status:** ✅ Active

