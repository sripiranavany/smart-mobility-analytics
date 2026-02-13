# Documentation Index

This directory contains all project documentation organized by topic.

## 📚 Quick Navigation

### Getting Started
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide for the project
- [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - Quick reference guide

### Setup & Installation
- [DOCKER-BUILD-FIX.md](DOCKER-BUILD-FIX.md) - Docker build configuration and fixes
- [CI-CD-CHECKLIST.md](CI-CD-CHECKLIST.md) - CI/CD pipeline setup checklist

### Monitoring (HertzBeat)
- [HERTZBEAT-FINAL-SETUP.md](HERTZBEAT-FINAL-SETUP.md) - **START HERE** - Complete HertzBeat setup guide
- [HERTZBEAT-POSTGRESQL-VICTORIAMETRICS-SETUP.md](HERTZBEAT-POSTGRESQL-VICTORIAMETRICS-SETUP.md) - Detailed PostgreSQL + VictoriaMetrics architecture
- [POSTGRESQL-SCHEMA-FIX.md](POSTGRESQL-SCHEMA-FIX.md) - PostgreSQL schema auto-creation fix
- [VICTORIAMETRICS-HEALTHCHECK-FIX.md](VICTORIAMETRICS-HEALTHCHECK-FIX.md) - VictoriaMetrics healthcheck troubleshooting
- [HERTZBEAT-GUIDE.md](HERTZBEAT-GUIDE.md) - General HertzBeat usage guide
- [HERTZBEAT-ISSUES.md](HERTZBEAT-ISSUES.md) - Historical issues and resolutions
- [HERTZBEAT-TO-GRAFANA-MIGRATION.md](HERTZBEAT-TO-GRAFANA-MIGRATION.md) - Why we chose HertzBeat over Grafana

### Application Services
- [API-GATEWAY-CONNECTION-FIX.md](API-GATEWAY-CONNECTION-FIX.md) - API Gateway database connection fixes
- [EVENT-GENERATOR-ANALYTICS-ENGINE-FIX.md](EVENT-GENERATOR-ANALYTICS-ENGINE-FIX.md) - Background worker exit issue fixes
- [CORRECT-ARCHITECTURE-NO-WEB.md](CORRECT-ARCHITECTURE-NO-WEB.md) - **Important**: Why event-generator and analytics-engine don't need web servers

### Other
- [HELP.md](HELP.md) - Spring Boot reference documentation

## 🔧 Architecture Decisions

### Monitoring Stack
**Choice:** PostgreSQL + VictoriaMetrics + HertzBeat

**Why:**
- PostgreSQL for metadata storage (users, monitors, alerts)
- VictoriaMetrics for time-series metrics (high performance)
- HertzBeat for unified monitoring interface

See: [HERTZBEAT-POSTGRESQL-VICTORIAMETRICS-SETUP.md](HERTZBEAT-POSTGRESQL-VICTORIAMETRICS-SETUP.md)

### Background Workers
**Pattern:** CommandLineRunner instead of Web Servers

**Services:**
- event-generator: Kafka producer (no HTTP server)
- analytics-engine: Apache Beam stream processor (no HTTP server)
- api-gateway: REST API (has HTTP server)

See: [CORRECT-ARCHITECTURE-NO-WEB.md](CORRECT-ARCHITECTURE-NO-WEB.md)

## 🐛 Troubleshooting Guides

| Issue | Document |
|-------|----------|
| Docker build fails | [DOCKER-BUILD-FIX.md](DOCKER-BUILD-FIX.md) |
| API Gateway can't connect to databases | [API-GATEWAY-CONNECTION-FIX.md](API-GATEWAY-CONNECTION-FIX.md) |
| Event generators exit immediately | [EVENT-GENERATOR-ANALYTICS-ENGINE-FIX.md](EVENT-GENERATOR-ANALYTICS-ENGINE-FIX.md) |
| HertzBeat schema errors | [POSTGRESQL-SCHEMA-FIX.md](POSTGRESQL-SCHEMA-FIX.md) |
| VictoriaMetrics unhealthy | [VICTORIAMETRICS-HEALTHCHECK-FIX.md](VICTORIAMETRICS-HEALTHCHECK-FIX.md) |

## 📝 Document Status

| Status | Meaning |
|--------|---------|
| ✅ Current | Up-to-date and reflects current setup |
| ⚠️ Historical | Documents old issues/approaches for reference |
| 📚 Reference | General reference material |

### Current Documents
- ✅ HERTZBEAT-FINAL-SETUP.md
- ✅ HERTZBEAT-POSTGRESQL-VICTORIAMETRICS-SETUP.md
- ✅ POSTGRESQL-SCHEMA-FIX.md
- ✅ VICTORIAMETRICS-HEALTHCHECK-FIX.md
- ✅ CORRECT-ARCHITECTURE-NO-WEB.md
- ✅ API-GATEWAY-CONNECTION-FIX.md
- ✅ EVENT-GENERATOR-ANALYTICS-ENGINE-FIX.md

### Historical Documents
- ⚠️ HERTZBEAT-ISSUES.md (old H2-only issues)
- ⚠️ HERTZBEAT-TO-GRAFANA-MIGRATION.md (decision process)

### Reference Documents
- 📚 QUICKSTART.md
- 📚 QUICK-REFERENCE.md
- 📚 CI-CD-CHECKLIST.md
- 📚 HELP.md

## 🔗 Related Files

### Configuration
- `../infrastructure/hertzbeat/CONFIGURATION.md` - HertzBeat environment variable configuration

### Scripts
- `../script../scripts/start-hertzbeat.sh` - Start HertzBeat stack
- `../script../scripts/setup-hertzbeat.sh` - Initial setup script
- `../scripts/verify-hertzbeat.sh` - Verify HertzBeat is running
- `../scripts/verify-setup.sh` - Verify complete setup

## 📖 How to Use This Documentation

1. **New to the project?** Start with [QUICKSTART.md](QUICKSTART.md)
2. **Setting up monitoring?** Read [HERTZBEAT-FINAL-SETUP.md](HERTZBEAT-FINAL-SETUP.md)
3. **Encountering errors?** Check the Troubleshooting Guides section
4. **Understanding architecture?** See [CORRECT-ARCHITECTURE-NO-WEB.md](CORRECT-ARCHITECTURE-NO-WEB.md)

---

**Last Updated:** February 13, 2026  
**Project:** Smart Mobility Analytics  
**Status:** ✅ Production Ready

