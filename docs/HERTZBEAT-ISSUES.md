# HertzBeat Configuration Issues - Summary

## Problems Encountered

### 1. ✅ FIXED: Flyway Migration Conflict
**Error:** `Found more than one migration with version 160`
- Cause: HertzBeat has migration scripts for both H2 and MySQL, Flyway found duplicates
- **Solution:** Configured Flyway to use only H2 migrations

```yaml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration/h2
    validate-on-migrate: false
```

### 2. ⚠️ IN PROGRESS: Missing JavaMailSender Bean
**Error:** `Parameter 0 of constructor in EmailAlertNotifyHandlerImpl required a bean of type 'org.springframework.mail.javamail.JavaMailSender'`
- Cause: HertzBeat requires email configuration even if email alerts are not used
- **Attempted Solution:** Added mail configuration to application.yml

```yaml
spring:
  mail:
    host: localhost
    port: 25
    username: hertzbeat
    password: hertzbeat
```

## Recommendation: Use Grafana Instead

HertzBeat is still in development and has dependency issues that make it difficult to configure in a containerized environment. **Grafana** is a mature, stable alternative that works out of the box.

### Advantages of Grafana:
- ✅ Stable and widely used
- ✅ Works immediately with Prometheus
- ✅ Rich dashboard ecosystem
- ✅ No complex dependencies
- ✅ Easy configuration
- ✅ Better documentation

## Option 1: Switch Back to Grafana (Recommended)

Replace HertzBeat with Grafana in docker-compose.yml:

```yaml
grafana:
  image: grafana/grafana:latest
  container_name: grafana
  ports:
    - "3000:3000"
  environment:
    GF_SECURITY_ADMIN_PASSWORD: admin
    GF_USERS_ALLOW_SIGN_UP: 'false'
    GF_INSTALL_PLUGINS: 'grafana-piechart-panel'
  volumes:
    - grafana-data:/var/lib/grafana
    - ./infrastructure/grafana/datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    - ./infrastructure/grafana/dashboards.yml:/etc/grafana/provisioning/dashboards/dashboards.yml
  depends_on:
    - prometheus
  networks:
    - smart-mobility-network
  restart: unless-stopped
```

### Create Grafana Datasource Configuration:

`infrastructure/grafana/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

### Create Grafana Dashboard Configuration:

`infrastructure/grafana/dashboards.yml`:
```yaml
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUpdating: true
    options:
      path: /var/lib/grafana/dashboards
```

## Option 2: Continue with HertzBeat (Not Recommended)

To continue troubleshooting HertzBeat:

1. Need to add full mail server dependencies
2. May need to disable email notification features entirely
3. Could require custom Docker image with patches
4. Time-consuming with uncertain outcome

## Current Status

### Services Status:
- ✅ Cassandra - Running
- ✅ Neo4j - Running  
- ✅ Kafka - Running
- ✅ Zookeeper - Running
- ✅ Prometheus - Running
- ✅ API Gateway - Running
- ❌ HertzBeat - Failing (dependency issues)

### Recommended Action:

**Switch to Grafana** for a stable, production-ready monitoring solution.

Would you like me to:
1. Replace HertzBeat with Grafana in the docker-compose configuration?
2. Continue troubleshooting HertzBeat?
3. Use Prometheus only without a visualization layer for now?

---

**Time Spent on HertzBeat:** ~30 minutes  
**Issues Fixed:** 1 (Flyway)  
**Issues Remaining:** 1+ (JavaMailSender, potentially more)  
**Recommendation:** Use Grafana instead

