# Smart Mobility Analytics Platform

![CI Pipeline](https://github.com/YOUR_USERNAME/smart-mobility-analitics/workflows/CI%20Pipeline/badge.svg)
![Java](https://img.shields.io/badge/Java-25-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.2-brightgreen)
![Apache Beam](https://img.shields.io/badge/Apache%20Beam-2.61.0-blue)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A comprehensive real-time analytics platform for smart mobility data using Spring Boot, Apache Beam, Kafka, Cassandra, and Neo4j.

## 🚀 Quick Start

```bash
# 1. Start all infrastructure services
docker compose up -d

# 2. Start HertzBeat monitoring stack
./scripts/start-hertzbeat.sh

# 3. Verify everything is running
./scripts/verify-setup.sh
```

**Access Points:**
- **HertzBeat Monitoring:** http://localhost:1157 (admin/hertzbeat)
- **API Gateway:** http://localhost:8080/actuator/health
- **Prometheus:** http://localhost:9090
- **Neo4j Browser:** http://localhost:7474 (neo4j/password)
- **VictoriaMetrics:** http://localhost:8428

## 📚 Documentation

All documentation is organized in the [`docs/`](docs/) directory:

- **[Quick Start Guide](docs/QUICKSTART.md)** - Get started quickly
- **[HertzBeat Setup](docs/HERTZBEAT-FINAL-SETUP.md)** - Complete monitoring setup
- **[Architecture Guide](docs/CORRECT-ARCHITECTURE-NO-WEB.md)** - System architecture decisions
- **[Full Documentation Index](docs/INDEX.md)** - Complete documentation catalog

## 🔧 Scripts

Utility scripts are in the [`scripts/`](scripts/) directory:

- **[start-hertzbeat.sh](scripts/start-hertzbeat.sh)** - Start HertzBeat monitoring stack
- **[verify-hertzbeat.sh](scripts/verify-hertzbeat.sh)** - Verify HertzBeat is running
- **[verify-setup.sh](scripts/verify-setup.sh)** - Verify complete platform setup
- **[Scripts README](scripts/README.md)** - Detailed script documentation

## 🏗️ Architecture

This is a multi-module Maven project consisting of:

```
smart-mobility-analitics/
├── common-lib/          # Shared models and utilities
├── event-generator/     # Kafka event producer (background worker)
├── analytics-engine/    # Apache Beam streaming pipeline (background worker)
├── api-gateway/         # REST API with WebFlux, Cassandra & Neo4j
├── infrastructure/      # Docker configs, monitoring setup
├── docs/               # All project documentation
└── scripts/            # Utility scripts
```

## 📦 Modules

### 1. **common-lib**
Shared library containing:
- Common data models
- DTOs and entities
- Utility classes
- Jackson configurations

### 2. **event-generator** (Background Worker)
Event generation service:
- Generates realistic mobility events using DataFaker
- Publishes to Kafka topics
- Configurable event rate and patterns
- Runs as CommandLineRunner (no web server)

### 3. **analytics-engine** (Stream Processor)
Real-time analytics processing:
- Apache Beam streaming pipeline
- Reads from Kafka topics
- Processes and aggregates data
- Writes to Cassandra
- Runs continuously (no web server)

### 4. **api-gateway** (REST API)
Reactive REST API:
- Spring WebFlux for reactive endpoints
- Cassandra for time-series data
- Neo4j for graph relationships
- Prometheus metrics via Actuator
- Health checks and monitoring

## 🚀 Quick Start

### Prerequisites
- Java 25
- Maven 3.9+
- Docker & Docker Compose
- Kafka
- Cassandra
- Neo4j

### Build the Project

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/smart-mobility-analitics.git
cd smart-mobility-analitics

# Build all modules
mvn clean install

# Build specific module
mvn clean install -pl event-generator -am
```

### Run with Docker Compose

```bash
# Start infrastructure services
cd infrastructure
docker-compose up -d

# Verify services are running
docker-compose ps
```

### Run Services

```bash
# Terminal 1: Event Generator
cd event-generator
mvn spring-boot:run

# Terminal 2: Analytics Engine
cd analytics-engine
mvn spring-boot:run

# Terminal 3: API Gateway
cd api-gateway
mvn spring-boot:run
```

## 🔧 Configuration

### application.properties

Each module has its own configuration. Key properties:

**Event Generator:**
```properties
spring.kafka.bootstrap-servers=localhost:9092
spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
spring.kafka.producer.value-serializer=org.springframework.kafka.support.serializer.JsonSerializer
```

**Analytics Engine:**
```properties
beam.kafka.bootstrap-servers=localhost:9092
beam.cassandra.contact-points=localhost
beam.cassandra.port=9042
```

**API Gateway:**
```properties
spring.cassandra.contact-points=localhost
spring.cassandra.port=9042
spring.neo4j.uri=bolt://localhost:7687
management.endpoints.web.exposure.include=health,prometheus,metrics
```

## 📊 Monitoring

### Prometheus Metrics

Access metrics endpoint:
```bash
curl http://localhost:8080/actuator/prometheus
```

### Health Checks

```bash
curl http://localhost:8080/actuator/health
```

### Infrastructure Monitoring

Prometheus and Apache HertzBeat dashboards available:
- Prometheus: http://localhost:9090
- HertzBeat: http://localhost:1157 (admin/hertzbeat)

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run tests for specific module
mvn test -pl api-gateway

# Skip tests during build
mvn clean install -DskipTests

# Run integration tests
mvn verify
```

## 🐳 Docker Build

Build Docker images for services:

```bash
# Build image for event-generator
cd event-generator
docker build -t event-generator:latest .

# Build image for analytics-engine
cd analytics-engine
docker build -t analytics-engine:latest .

# Build image for api-gateway
cd api-gateway
docker build -t api-gateway:latest .
```

## 📈 CI/CD Pipeline

This project uses GitHub Actions for continuous integration:

### Workflow Features
- ✅ Automated build and test on every push/PR
- ✅ Parallel module builds
- ✅ Code quality checks
- ✅ Dependency security scanning
- ✅ Docker image builds (main/develop only)
- ✅ Test report generation
- ✅ Artifact uploads

### Triggers
- Push to `main`, `develop`, `feature/**`, `hotfix/**`
- Pull requests to `main`, `develop`
- Manual workflow dispatch

See [.github/workflows/README.md](.github/workflows/README.md) for details.

## 🏛️ Technology Stack

### Core Framework
- **Spring Boot 4.0.2** - Application framework
- **Spring WebFlux** - Reactive web framework
- **Spring Kafka** - Kafka integration

### Data Processing
- **Apache Beam 2.61.0** - Stream processing
- **Direct Runner** - Local execution

### Databases
- **Cassandra** - Time-series data storage
- **Neo4j** - Graph database for relationships

### Messaging
- **Apache Kafka** - Event streaming platform

### Monitoring
- **Prometheus** - Metrics collection
- **Apache HertzBeat** - Real-time monitoring & alerting
- **Spring Actuator** - Application health & metrics

### Testing
- **JUnit 5** - Unit testing
- **Spring Test** - Integration testing
- **Testcontainers** - Container-based testing

### Data Generation
- **DataFaker 2.4.0** - Realistic test data generation

## 📝 API Endpoints

### API Gateway (Port 8080)

```bash
# Health check
GET /actuator/health

# Prometheus metrics
GET /actuator/prometheus

# Custom endpoints (to be implemented)
GET /api/v1/vehicles
GET /api/v1/routes
GET /api/v1/analytics
```

## 🛣️ Development Roadmap

- [x] Multi-module Maven setup
- [x] CI/CD pipeline with GitHub Actions
- [x] Infrastructure setup
- [ ] Event schemas and models
- [ ] Event generator implementation
- [ ] Beam pipeline implementation
- [ ] REST API endpoints
- [ ] GraphQL API
- [ ] WebSocket support for real-time updates
- [ ] Authentication & Authorization
- [ ] Rate limiting
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Performance testing
- [ ] Production deployment scripts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Java coding conventions
- Use meaningful variable and method names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Sripiranavan Yogarajah** - *Initial work*

## 🙏 Acknowledgments

- Spring Boot team for excellent framework
- Apache Beam community
- DataFaker for test data generation
- GitHub Actions for CI/CD

## 📞 Support

For support, email info@sripiranavan.com or create an issue in the repository.

---

**Built with ❤️ using Spring Boot and Apache Beam**

