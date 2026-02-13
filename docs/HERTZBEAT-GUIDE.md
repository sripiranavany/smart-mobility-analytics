# Apache HertzBeat Monitoring Setup

## 🎯 What is Apache HertzBeat?

Apache HertzBeat is an open-source, real-time monitoring and alerting system that provides:
- **Real-time Monitoring** - Monitor applications, databases, middleware, and infrastructure
- **Auto-Discovery** - Automatically discover Spring Boot Actuator endpoints
- **Rich Visualizations** - Built-in dashboards for various monitoring scenarios
- **Flexible Alerting** - Multi-channel alert notifications (Webhook, Email, SMS, etc.)
- **No Agent Required** - Agentless monitoring using various protocols (HTTP, JDBC, SSH, etc.)
- **Lightweight** - Lower resource consumption compared to traditional monitoring stacks

## 🚀 Quick Start

### Access HertzBeat

Once your Docker stack is running:

```bash
# Start all services
docker-compose up -d

# Wait for HertzBeat to initialize (30-60 seconds)
docker-compose logs -f hertzbeat

# Access the web UI
open http://localhost:1157
```

**Default Credentials:**
- Username: `admin`
- Password: `hertzbeat`

### Ports

- **1157** - Web UI and API
- **1158** - Cluster communication port

## 📊 Monitoring Your Services

### Automatic Spring Boot Monitoring

HertzBeat automatically discovers and monitors Spring Boot applications through their Actuator endpoints.

### Manually Add Monitors

1. **Log in to HertzBeat** (http://localhost:1157)

2. **Add API Gateway Monitor:**
   - Navigate to: Monitors → Application → Spring Boot
   - Click "New Monitor"
   - Configuration:
     ```
     Name: API Gateway
     Host: api-gateway
     Port: 8080
     Base Path: /actuator
     Monitoring Interval: 60s
     ```

3. **Add Event Generator Monitor:**
   - Name: Event Generator
   - Host: event-generator
   - Port: 8081
   - Base Path: /actuator

4. **Add Analytics Engine Monitor:**
   - Name: Analytics Engine
   - Host: analytics-engine
   - Port: 8082
   - Base Path: /actuator

### Infrastructure Monitoring

Add monitors for infrastructure components:

#### Cassandra
- Monitor Type: Database → Cassandra
- Host: cassandra
- Port: 9042
- Username: cassandra (if authentication enabled)

#### Neo4j
- Monitor Type: Database → Neo4j
- Host: neo4j
- Port: 7687
- Username: neo4j
- Password: password

#### Kafka
- Monitor Type: Middleware → Kafka
- Host: kafka
- Port: 9092

#### Prometheus
- Monitor Type: Custom → HTTP
- URL: http://prometheus:9090/-/healthy

## 🔔 Setting Up Alerts

### Create Alert Rules

1. Go to **Alerts → Alert Rules**
2. Click **New Alert Rule**
3. Configure:
   ```yaml
   Name: High Response Time
   Monitor: API Gateway
   Metric: response_time
   Condition: > 1000ms
   Duration: 2 minutes
   Level: Warning
   ```

### Configure Alert Channels

#### Webhook (Default)
Already configured to send to: `http://localhost:8080/api/alerts`

#### Add Email Notifications
1. Go to **Alerts → Notification Settings**
2. Add Email Server:
   ```
   SMTP Host: smtp.gmail.com
   SMTP Port: 587
   Username: your-email@gmail.com
   Password: your-app-password
   ```

#### Add Slack/Discord
Configure webhook URLs in the notification settings.

## 📈 Dashboard Features

### Pre-built Dashboards

HertzBeat includes dashboards for:
- **Application Performance** - Response times, throughput, error rates
- **JVM Metrics** - Heap usage, GC activity, thread counts
- **Database Performance** - Connection pools, query times
- **Infrastructure Health** - CPU, memory, disk usage

### Custom Dashboards

Create custom dashboards:
1. Go to **Dashboards → Custom**
2. Add widgets for specific metrics
3. Combine multiple data sources
4. Set refresh intervals

## 🔧 Advanced Configuration

### Prometheus Integration

HertzBeat is configured to pull metrics from Prometheus:

```yaml
exporter:
  prometheus:
    enabled: true
    host: prometheus
    port: 9090
```

This allows HertzBeat to:
- Query existing Prometheus metrics
- Combine Prometheus data with HertzBeat's native monitoring
- Create unified dashboards

### Custom Monitoring Templates

Create custom monitoring templates in:
`/opt/hertzbeat/config/define/`

Example for custom API monitoring:
```yaml
category: custom
app: smart-mobility-api
metrics:
  - name: custom_endpoint
    protocol: http
    host: ^_^host^_^
    port: ^_^port^_^
    uri: /api/custom/metrics
    method: GET
    parseType: json
    fields:
      - field: status
        type: 0
      - field: count
        type: 1
```

### Data Retention

Configure data retention in `application.yml`:

```yaml
warehouse:
  store:
    type: memory  # or jpa, victoria-metrics, etc.
    memory:
      enabled: true
      init-size: 1024
    jpa:
      expire-time: 7d  # Keep data for 7 days
```

## 🎨 Comparison: HertzBeat vs Grafana

| Feature | Apache HertzBeat | Grafana |
|---------|------------------|---------|
| **Setup Complexity** | ⭐⭐ Easy | ⭐⭐⭐ Moderate |
| **Built-in Monitoring** | ✅ Yes | ❌ No (needs exporters) |
| **Auto-discovery** | ✅ Yes | ❌ Limited |
| **Alerting** | ✅ Built-in | ⚠️ Requires configuration |
| **Agent Required** | ❌ No | ⚠️ Sometimes |
| **Resource Usage** | ⭐⭐⭐ Light | ⭐⭐ Moderate |
| **Data Sources** | Multiple built-in | Requires plugins |
| **Learning Curve** | ⭐⭐ Easy | ⭐⭐⭐ Steep |

## 🔍 Troubleshooting

### HertzBeat Not Starting

```bash
# Check logs
docker-compose logs hertzbeat

# Common issues:
# 1. Port 1157 already in use
# 2. Configuration file syntax error
# 3. Insufficient memory

# Restart HertzBeat
docker-compose restart hertzbeat
```

### Monitors Not Discovering Services

```bash
# Ensure services are accessible
docker-compose exec hertzbeat wget -O- http://api-gateway:8080/actuator/health

# Check network connectivity
docker-compose exec hertzbeat ping api-gateway
```

### Data Not Persisting

If using H2 database (default), data is stored in:
`/opt/hertzbeat/data/hertzbeat.mv.db`

Ensure the volume is properly mounted:
```bash
docker volume inspect smart-mobility-analitics_hertzbeat-data
```

## 📚 Useful Resources

- **Official Documentation:** https://hertzbeat.apache.org/docs/
- **GitHub Repository:** https://github.com/apache/hertzbeat
- **Community:** https://github.com/apache/hertzbeat/discussions

## 🎯 Quick Commands

```bash
# Start HertzBeat
docker-compose up -d hertzbeat

# View logs
docker-compose logs -f hertzbeat

# Restart HertzBeat
docker-compose restart hertzbeat

# Stop HertzBeat
docker-compose stop hertzbeat

# Access HertzBeat shell
docker-compose exec hertzbeat sh

# Check HertzBeat health
curl http://localhost:1157/api/account/auth/refresh
```

## 🚀 Production Recommendations

### High Availability Setup

For production, consider:
1. **External Database** - Use MySQL/PostgreSQL instead of H2
2. **Redis Cache** - For better performance
3. **Load Balancer** - Multiple HertzBeat instances
4. **Persistent Storage** - External volumes for data

### Security

1. **Change Default Password** immediately after first login
2. **Enable HTTPS** using a reverse proxy (Nginx/Traefik)
3. **Configure Firewall** rules for ports 1157-1158
4. **Use Strong Authentication** and enable 2FA if available

### Monitoring Best Practices

1. **Set Appropriate Intervals** - Don't monitor too frequently
2. **Use Alert Thresholds Wisely** - Avoid alert fatigue
3. **Group Related Monitors** - Organize by service/environment
4. **Regular Maintenance** - Clean up old monitors and data
5. **Monitor the Monitor** - Set up external health checks for HertzBeat

---

**Updated:** February 13, 2026
**Status:** ✅ Ready for Use

