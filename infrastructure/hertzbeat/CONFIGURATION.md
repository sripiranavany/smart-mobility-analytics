# HertzBeat Configuration - Environment Variables Only

## ✅ Configuration Method: Environment Variables in docker-compose.yml

HertzBeat is configured **entirely through environment variables** in `docker-compose.yml`. 

**NO `application.yml` file is needed or used.**

## Current Configuration

### Database (PostgreSQL)
```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://hertzbeat-db:5432/hertzbeat
SPRING_DATASOURCE_USERNAME: hertzbeat
SPRING_DATASOURCE_PASSWORD: hertzbeat
SPRING_DATASOURCE_DRIVER_CLASS_NAME: org.postgresql.Driver
```

### JPA Schema Auto-Creation
```yaml
SPRING_JPA_DATABASE_PLATFORM: org.eclipse.persistence.platform.database.PostgreSQLPlatform
SPRING_JPA_PROPERTIES_ECLIPSELINK_DDL-GENERATION: create-or-extend-tables
SPRING_JPA_PROPERTIES_ECLIPSELINK_DDL-GENERATION_OUTPUT-MODE: database
```

### Metrics Storage (VictoriaMetrics)
```yaml
WAREHOUSE_STORE_VICTORIA_METRICS_ENABLED: "true"
WAREHOUSE_STORE_VICTORIA_METRICS_URL: http://victoria-metrics:8428
WAREHOUSE_STORE_JPA_ENABLED: "false"
WAREHOUSE_STORE_MEMORY_ENABLED: "false"
```

### Other Settings
```yaml
LANG: en_US.UTF-8
TZ: UTC
```

## Why No application.yml?

### Advantages of Environment Variables:

1. ✅ **Container-native** - Standard Docker practice
2. ✅ **Environment-specific** - Easy to change per environment (dev/staging/prod)
3. ✅ **No file management** - No need to mount config files
4. ✅ **12-Factor App** - Follows modern application principles
5. ✅ **Easy override** - Can override in docker-compose.override.yml
6. ✅ **Secret management** - Can use Docker secrets or env files

### Old approach.yml Was For:

The old `application.yml` file was configured for:
- ❌ H2 database (we're using PostgreSQL now)
- ❌ Flyway migrations (we're using JPA schema auto-creation)
- ❌ Memory storage (we're using VictoriaMetrics)
- ❌ Mail config that wasn't needed

**It's completely obsolete with the current PostgreSQL + VictoriaMetrics setup.**

## How to Modify Configuration

### Option 1: Edit docker-compose.yml (Recommended)

```yaml
hertzbeat:
  environment:
    # Add or modify environment variables here
    SPRING_DATASOURCE_URL: jdbc:postgresql://hertzbeat-db:5432/hertzbeat
    # ... more config
```

### Option 2: Use .env File

Create `.env` in project root:
```env
HERTZBEAT_DB_USER=hertzbeat
HERTZBEAT_DB_PASS=hertzbeat
VICTORIA_METRICS_URL=http://victoria-metrics:8428
```

Then reference in docker-compose.yml:
```yaml
hertzbeat:
  environment:
    SPRING_DATASOURCE_USERNAME: ${HERTZBEAT_DB_USER}
    SPRING_DATASOURCE_PASSWORD: ${HERTZBEAT_DB_PASS}
```

### Option 3: Docker Compose Override

Create `docker-compose.override.yml` for local customizations:
```yaml
version: '3.8'
services:
  hertzbeat:
    environment:
      # Override or add settings
      WAREHOUSE_STORE_VICTORIA_METRICS_ENABLED: "false"
      WAREHOUSE_STORE_MEMORY_ENABLED: "true"
```

## Configuration Mapping

### Spring Boot Property → Environment Variable

Spring Boot automatically maps environment variables:

| application.yml | Environment Variable |
|-----------------|---------------------|
| `spring.datasource.url` | `SPRING_DATASOURCE_URL` |
| `spring.datasource.username` | `SPRING_DATASOURCE_USERNAME` |
| `spring.jpa.database-platform` | `SPRING_JPA_DATABASE_PLATFORM` |
| `warehouse.store.victoria-metrics.enabled` | `WAREHOUSE_STORE_VICTORIA_METRICS_ENABLED` |

**Pattern:** 
- Replace `.` with `_`
- Convert to UPPERCASE
- Replace `-` with `_`

Example:
```
spring.jpa.properties.eclipselink.ddl-generation
↓
SPRING_JPA_PROPERTIES_ECLIPSELINK_DDL-GENERATION
```

## Common Configuration Changes

### Change Database Password

```yaml
hertzbeat:
  environment:
    SPRING_DATASOURCE_PASSWORD: your-secure-password

hertzbeat-db:
  environment:
    POSTGRES_PASSWORD: your-secure-password  # Must match!
```

### Change VictoriaMetrics Retention

```yaml
victoria-metrics:
  command:
    - '-retentionPeriod=30d'  # Change from 7d to 30d
```

### Enable Debug Logging

```yaml
hertzbeat:
  environment:
    LOGGING_LEVEL_ROOT: DEBUG
    LOGGING_LEVEL_ORG_APACHE_HERTZBEAT: DEBUG
```

### Change Web UI Port

```yaml
hertzbeat:
  ports:
    - "8157:1157"  # Access on port 8157 instead
```

### Add Custom Alert Webhook

```yaml
hertzbeat:
  environment:
    ALERTER_WEBHOOK_ENABLED: "true"
    ALERTER_WEBHOOK_URL: "https://your-webhook.com/alerts"
```

## Volumes Configuration

### Data Persistence

```yaml
hertzbeat:
  volumes:
    - hertzbeat-data:/opt/hertzbeat/data      # Application data
    - hertzbeat-logs:/opt/hertzbeat/logs      # Log files
```

### If You Need Custom Config (Advanced)

Only if you really need custom YAML config:

```yaml
hertzbeat:
  volumes:
    - ./infrastructure/hertzbeat/application.yml:/opt/hertzbeat/config/application.yml:ro
```

But **this is NOT recommended** - use environment variables instead!

## Complete Environment Variable Reference

### Database Connection
```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://host:5432/db
SPRING_DATASOURCE_USERNAME: user
SPRING_DATASOURCE_PASSWORD: pass
SPRING_DATASOURCE_DRIVER_CLASS_NAME: org.postgresql.Driver
```

### JPA/Hibernate
```yaml
SPRING_JPA_DATABASE_PLATFORM: org.eclipse.persistence.platform.database.PostgreSQLPlatform
SPRING_JPA_SHOW_SQL: "false"
SPRING_JPA_PROPERTIES_ECLIPSELINK_DDL-GENERATION: create-or-extend-tables
```

### Warehouse Storage
```yaml
WAREHOUSE_STORE_VICTORIA_METRICS_ENABLED: "true"
WAREHOUSE_STORE_VICTORIA_METRICS_URL: http://victoria-metrics:8428
WAREHOUSE_STORE_JPA_ENABLED: "false"
WAREHOUSE_STORE_MEMORY_ENABLED: "false"
```

### Alerting
```yaml
ALERTER_DATA_QUEUE_TYPE: memory
ALERTER_WEBHOOK_ENABLED: "true"
ALERTER_WEBHOOK_URL: http://your-webhook/alerts
```

### Mail (if needed)
```yaml
SPRING_MAIL_HOST: smtp.gmail.com
SPRING_MAIL_PORT: "587"
SPRING_MAIL_USERNAME: your-email@gmail.com
SPRING_MAIL_PASSWORD: your-app-password
SPRING_MAIL_PROPERTIES_MAIL_SMTP_AUTH: "true"
SPRING_MAIL_PROPERTIES_MAIL_SMTP_STARTTLS_ENABLE: "true"
```

### Scheduler
```yaml
SCHEDULER_SERVER_ENABLED: "true"
SCHEDULER_SERVER_PORT: "1158"
```

### Logging
```yaml
LOGGING_LEVEL_ROOT: INFO
LOGGING_LEVEL_ORG_APACHE_HERTZBEAT: INFO
LOGGING_FILE_NAME: /opt/hertzbeat/logs/hertzbeat.log
```

## Summary

✅ **Use environment variables in docker-compose.yml**  
❌ **NO application.yml file needed**  
✅ **Easier to manage and override**  
✅ **Better for containerized deployments**  
✅ **Follows Docker best practices**  

---

**Current Setup:** PostgreSQL + VictoriaMetrics configured via environment variables  
**Configuration File:** `docker-compose.yml` (environment section only)  
**Status:** ✅ Complete and working

