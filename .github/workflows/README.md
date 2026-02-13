# GitHub Actions CI/CD Pipeline

This repository uses GitHub Actions for continuous integration and deployment.

## 🚀 CI Pipeline Overview

The CI pipeline automatically runs on:
- **Push** to `main`, `develop`, `feature/**`, and `hotfix/**` branches
- **Pull Requests** to `main` and `develop` branches
- **Manual trigger** via workflow_dispatch

## 📋 Pipeline Jobs

### 1. **Build and Test** (`build-and-test`)
- Checks out the code
- Sets up JDK 21 (Java 25 not yet available in GitHub Actions)
- Caches Maven dependencies for faster builds
- Builds all modules: `mvn clean install`
- Runs all tests: `mvn test`
- Uploads test reports and build artifacts

**Artifacts Generated:**
- Test results (retained for 7 days)
- JAR files for all modules (retained for 7 days)

### 2. **Code Quality Analysis** (`code-quality`)
- Runs after successful build
- Verifies code compilation: `mvn verify -DskipTests`
- Ensures code quality standards

### 3. **Dependency Security Check** (`dependency-check`)
- Analyzes dependency tree
- Checks for vulnerable dependencies
- Helps maintain secure dependencies

### 4. **Module Build** (`module-build`)
- Builds and tests each module independently
- Runs in parallel for:
  - `common-lib`
  - `event-generator`
  - `analytics-engine`
  - `api-gateway`
- Ensures each module can build standalone

### 5. **Docker Build** (`docker-build`)
- Triggered only on pushes to `main` or `develop`
- Builds Docker images for services
- Saves and uploads Docker images as artifacts
- Tags images with commit SHA and `latest`

**Services:**
- `event-generator`
- `analytics-engine`
- `api-gateway`

### 6. **Build Summary** (`summary`)
- Generates build summary report
- Shows module build status
- Available in GitHub Actions Summary tab

## 🔧 Configuration

### Java Version
- Pipeline uses **JDK 25** (Temurin distribution)
- Project targets **Java 25**

### Maven Settings
- Maven opts: `-Xmx3072m`
- Transfer progress disabled for cleaner logs
- Batch mode enabled for CI environment

### Caching
- Maven dependencies cached using `actions/cache@v4`
- Cache key based on `pom.xml` checksums
- Significantly speeds up subsequent builds

## 📊 Test Reporting

- Test results are automatically published
- Uses `dorny/test-reporter@v1`
- Supports JUnit XML format
- Reports available in the "Checks" tab of Pull Requests

## 🐳 Docker Image Artifacts

When building on `main` or `develop` branches:
- Docker images are built for each service
- Images are compressed and uploaded as artifacts
- Retained for 7 days
- Can be downloaded and loaded: `docker load < image.tar.gz`

## 📦 Build Artifacts

All JAR files are uploaded as artifacts:
- Available in Actions run summary
- Retained for 7 days
- Excludes source and javadoc JARs

## 🔄 Workflow Triggers

```yaml
# Automatically on push
git push origin main
git push origin develop
git push origin feature/my-feature

# Automatically on PR
# Create PR to main or develop

# Manual trigger
# Go to Actions tab → Select CI Pipeline → Run workflow
```

## 🎯 Module Build Order

The Maven reactor builds modules in this order:
1. `smart-mobility-analitics` (parent POM)
2. `common-lib` (shared library)
3. `event-generator`
4. `analytics-engine`
5. `api-gateway`

## 🛠️ Local Development

To run the same checks locally:

```bash
# Full build with tests
mvn clean install

# Build without tests
mvn clean install -DskipTests

# Run tests only
mvn test

# Build specific module
mvn clean install -pl api-gateway -am

# Verify code quality
mvn verify
```

## 📈 Status Badges

Add these badges to your README.md:

```markdown
![CI Pipeline](https://github.com/YOUR_USERNAME/smart-mobility-analitics/workflows/CI%20Pipeline/badge.svg)
![Build Status](https://github.com/YOUR_USERNAME/smart-mobility-analitics/actions/workflows/ci.yml/badge.svg)
```

## 🐛 Troubleshooting

### Build Failures
1. Check the Actions tab for detailed logs
2. Review test reports in the artifacts
3. Ensure all dependencies are available in Maven Central

### Cache Issues
- Manual cache clearing: Delete cache in repository settings
- Or update `pom.xml` to invalidate cache automatically

### Java Version Compatibility
- If Java 25 becomes available in GitHub Actions, update `JAVA_VERSION` in ci.yml
- Current fallback is JDK 21 (tested and working)

## 🔐 Secrets Required

Currently, no secrets are required. If you add Docker registry push or deployment:

```yaml
# Add these secrets in repository settings
DOCKER_USERNAME
DOCKER_PASSWORD
DOCKER_REGISTRY
```

## 📝 Notes

- All jobs run on `ubuntu-latest` runners
- Module builds run in parallel for faster execution
- Docker builds only on main/develop to save resources
- Artifacts auto-expire after 7 days

## 🚧 Future Enhancements

Potential additions:
- [ ] SonarQube/SonarCloud integration
- [ ] Code coverage reporting (JaCoCo)
- [ ] Docker image push to registry
- [ ] Kubernetes deployment
- [ ] Release automation
- [ ] Semantic versioning
- [ ] Changelog generation

---

**Last Updated:** February 13, 2026

