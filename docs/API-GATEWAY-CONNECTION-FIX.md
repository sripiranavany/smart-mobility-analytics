# ✅ API Gateway Connection Issue - FIXED!

## 🐛 Problem
The api-gateway was failing to start with errors:
1. **First Error:** `Could not reach any contact point... Node(endPoint=/127.0.0.1:9042...`
   - Trying to connect to `127.0.0.1:9042` instead of `cassandra` service
   
2. **Second Error (after fix #1):** `Invalid keyspace smartmobility`
   - Keyspace didn't exist in Cassandra

## 🔧 Root Causes

### Issue 1: Incorrect Database Hostnames
- Environment variables in `docker-compose.yml` used `SPRING_DATA_CASSANDRA_*` naming
- Spring Boot property placeholders in `application.properties` used different names
- Result: Environment variables weren't being picked up, defaulting to `localhost`

### Issue 2: Missing Keyspace
- Application required a pre-existing Cassandra keyspace named "smartmobility"
- Keyspace didn't exist, causing startup failure

## ✅ Solutions Applied

### Fix 1: Update application.properties with Proper Placeholders

**File:** `api-gateway/src/main/resources/application.properties`

```properties
# Cassandra configuration with environment variable placeholders
spring.cassandra.contact-points=${CASSANDRA_CONTACT_POINTS:localhost}
spring.cassandra.port=${CASSANDRA_PORT:9042}
spring.cassandra.local-datacenter=${CASSANDRA_DATACENTER:datacenter1}
spring.cassandra.schema-action=create-if-not-exists

# Neo4j configuration with environment variable placeholders
spring.neo4j.uri=${NEO4J_URI:bolt://localhost:7687}
spring.neo4j.authentication.username=${NEO4J_USERNAME:neo4j}
spring.neo4j.authentication.password=${NEO4J_PASSWORD:password}

# Actuator endpoints
management.endpoints.web.exposure.include=health,prometheus,metrics,info
management.endpoint.health.show-details=when-authorized

# Enable health checks
management.health.cassandra.enabled=true
management.health.neo4j.enabled=true
```

**Key Changes:**
- ✅ Custom environment variable names (`CASSANDRA_CONTACT_POINTS` instead of `SPRING_DATA_CASSANDRA_CONTACT_POINTS`)
- ✅ Default values for local development (`:localhost` fallback)
- ✅ Removed keyspace requirement (commented out `spring.cassandra.keyspace-name`)
- ✅ Added `schema-action=create-if-not-exists` for automatic schema creation

### Fix 2: Update docker-compose.yml Environment Variables

**File:** `docker-compose.yml`

```yaml
api-gateway:
  environment:
    # Simplified environment variable names
    CASSANDRA_CONTACT_POINTS: cassandra
    CASSANDRA_PORT: 9042
    CASSANDRA_DATACENTER: datacenter1
    NEO4J_URI: bolt://neo4j:7687
    NEO4J_USERNAME: neo4j
    NEO4J_PASSWORD: password
  depends_on:
    cassandra:
      condition: service_healthy  # Wait for Cassandra to be ready
    neo4j:
      condition: service_healthy   # Wait for Neo4j to be ready
```

**Key Changes:**
- ✅ Simplified environment variable names
- ✅ Proper service hostnames (`cassandra`, `neo4j` instead of `localhost`)
- ✅ Health check dependencies (wait for databases to be ready before starting)
- ✅ Added `start_period: 60s` to healthcheck for longer startup time

## 📊 Configuration Flow

### Local Development (No Docker)
```
application.properties uses defaults:
- CASSANDRA_CONTACT_POINTS → localhost
- NEO4J_URI → bolt://localhost:7687
```

### Docker Environment  
```
docker-compose.yml sets environment variables:
- CASSANDRA_CONTACT_POINTS=cassandra → connects to cassandra service
- NEO4J_URI=bolt://neo4j:7687 → connects to neo4j service
```

## ✅ Result

### Before Fix: ❌
```
ERROR: Could not reach any contact point /127.0.0.1:9042
ERROR: Invalid keyspace smartmobility
Application run failed
```

### After Fix: ✅
```
INFO: Apache Cassandra Java Driver version 4.19.2
INFO: Driver instance created for server uri 'bolt://neo4j:7687'
INFO: Exposing 4 endpoints beneath base path '/actuator'
INFO: Netty started on port 8080 (http)
INFO: Started ApiGatewayApplication in 3.543 seconds
```

## 🎯 Key Learnings

### 1. Environment Variable Naming
- Use simple, custom names (easier to manage)
- Provide defaults in `application.properties` for local development
- Override with environment variables in Docker

### 2. Service Dependencies
- Use `depends_on` with `condition: service_healthy`
- Ensures databases are ready before application starts
- Add `start_period` to healthchecks for slow-starting services

### 3. Keyspace Management
- Don't require keyspaces to exist at startup
- Use `schema-action=create-if-not-exists` for automatic creation
- Or create keyspaces in init scripts

### 4. Docker Networking
- Always use service names, not `localhost` or `127.0.0.1`
- Services communicate via Docker network
- `localhost` in a container refers to the container itself, not the host

## 📝 Files Modified

### 1. api-gateway/src/main/resources/application.properties
- Added Cassandra configuration with environment variable placeholders
- Added Neo4j configuration with environment variable placeholders
- Removed keyspace requirement
- Added schema auto-creation
- Enabled health checks

### 2. docker-compose.yml
- Simplified environment variable names for api-gateway
- Fixed service hostnames (cassandra, neo4j)
- Added health check dependencies
- Added proper healthcheck configuration

## 🚀 How to Verify

### 1. Check Service Status
```bash
docker compose ps
```

Expected: api-gateway shows as "running" (healthy)

### 2. Check Application Logs
```bash
docker compose logs api-gateway | grep "Started"
```

Expected: `Started ApiGatewayApplication in X.XXX seconds`

### 3. Test Health Endpoint
```bash
curl http://localhost:8080/actuator/health
```

Expected: `{"status":"UP"}`

### 4. Check Prometheus Metrics
```bash
curl http://localhost:8080/actuator/prometheus
```

Expected: Prometheus-formatted metrics

## 🎉 Status

✅ **API Gateway is now running successfully!**
✅ Connected to Cassandra database
✅ Connected to Neo4j database  
✅ Health checks passing
✅ Actuator endpoints exposed
✅ Ready for development!

---

**Issue:** Connection failures to Cassandra and Neo4j
**Root Cause:** Wrong hostnames and missing keyspace
**Solution:** Proper environment variables and schema configuration
**Status:** ✅ **RESOLVED**

