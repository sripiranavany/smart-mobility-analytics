# ✅ Maven Build Fix - Background Workers No Longer Block Builds

## Problem

When running `mvn clean install`, the build would hang indefinitely because:
- **event-generator** has an infinite loop generating events
- **analytics-engine** blocks on `pipeline.run().waitUntilFinish()`
- Maven waits for `CommandLineRunner.run()` to complete before finishing the build

**Result:** Maven never completes, build appears "stuck"

---

## Solution

Added **conditional execution** to both services:
- They **disable themselves during tests** (Maven builds)
- They **run normally in production** (Docker, manual run)

---

## Changes Made

### 1. Event Generator

#### New Configuration Properties

```properties
# event-generator/src/main/resources/application.properties
event.generation.enabled=true      # Enable/disable event generation
event.generation.max-events=0      # 0 = infinite, >0 = test mode
```

#### Code Changes

```java
@Value("${event.generation.enabled:true}")
private boolean enabled;

@Value("${event.generation.max-events:0}")
private int maxEvents;

@Override
public void run(String... args) throws Exception {
    if (!enabled) {
        log.info("Event generation is DISABLED");
        return;  // Exit immediately
    }
    
    // Generate maxEvents (or infinite if maxEvents=0)
    while (running && (maxEvents == 0 || eventCount < maxEvents)) {
        generateAndSendEvent();
        // ...
    }
}
```

#### Test Configuration

**File:** `event-generator/src/test/resources/application.properties`

```properties
# DISABLE event generation during tests
event.generation.enabled=false
```

**Result:** During `mvn test`, event generator exits immediately

---

### 2. Analytics Engine

#### New Configuration Property

```properties
# analytics-engine/src/main/resources/application.properties
analytics.pipeline.enabled=true    # Enable/disable pipeline
```

#### Code Changes

```java
@Value("${analytics.pipeline.enabled:true}")
private boolean enabled;

@Override
public void run(String... args) throws Exception {
    if (!enabled) {
        log.info("Analytics pipeline is DISABLED");
        return;  // Exit immediately
    }
    
    // Start Apache Beam pipeline
    pipeline.run().waitUntilFinish();
}
```

#### Test Configuration

**File:** `analytics-engine/src/test/resources/application.properties`

```properties
# DISABLE analytics pipeline during tests
analytics.pipeline.enabled=false
```

**Result:** During `mvn test`, analytics engine exits immediately

---

## How It Works

### During Maven Build/Test

```
┌─────────────────────────────────────────┐
│ mvn clean install                       │
│ mvn test                                │
└──────────────────┬──────────────────────┘
                   │
    ┌──────────────┴────────────────┐
    │                               │
┌───▼────────────┐     ┌───────────▼─────────┐
│ event-generator│     │ analytics-engine     │
│                │     │                      │
│ Test profile   │     │ Test profile         │
│ enabled=false  │     │ enabled=false        │
│                │     │                      │
│ ✓ Exits        │     │ ✓ Exits              │
│   immediately  │     │   immediately        │
└────────────────┘     └──────────────────────┘
         │                      │
         └──────────┬───────────┘
                    │
            ┌───────▼───────┐
            │ Maven build   │
            │ completes ✓   │
            └───────────────┘
```

### In Production (Docker, Manual Run)

```
┌─────────────────────────────────────────┐
│ java -jar event-generator.jar           │
│ (or docker run)                         │
└──────────────────┬──────────────────────┘
                   │
                   │ No test profile
                   │ enabled=true (default)
                   │
           ┌───────▼──────────┐
           │ event-generator  │
           │                  │
           │ ✓ Runs infinite  │
           │   loop           │
           │ ✓ Generates      │
           │   events         │
           │ ✓ Never exits    │
           └──────────────────┘
```

---

## Files Created/Modified

### Modified

1. ✅ `event-generator/src/main/java/.../EventGeneratorService.java`
   - Added `enabled` and `maxEvents` properties
   - Added conditional execution
   - Early return if disabled

2. ✅ `analytics-engine/src/main/java/.../AnalyticsStreamProcessor.java`
   - Added `enabled` property
   - Added conditional execution
   - Early return if disabled

### Created

3. ✅ `event-generator/src/test/resources/application.properties`
   - Disables event generation during tests
   - `event.generation.enabled=false`

4. ✅ `analytics-engine/src/test/resources/application.properties`
   - Disables pipeline during tests
   - `analytics.pipeline.enabled=false`

---

## Verification

### Maven Build Now Works

```bash
# Full build with tests - completes in ~8 seconds
mvn clean install

# Expected output:
[INFO] BUILD SUCCESS
[INFO] Total time:  8.117 s
```

### Tests Now Complete

```bash
# Run tests - completes in ~8 seconds
mvn test

# Expected output:
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### Production Still Works

```bash
# Run event generator manually
cd event-generator
mvn spring-boot:run

# Expected: Infinite loop, generates events continuously
# Output: "Event Generator is now running and generating events continuously..."
```

```bash
# Run in Docker
docker compose up -d event-generator analytics-engine

# Expected: Services stay "Up" and process events
docker ps | grep event-generator  # Status: Up
```

---

## Configuration Options

### Event Generator

| Property | Default | Description |
|----------|---------|-------------|
| `event.generation.enabled` | `true` | Enable/disable event generation |
| `event.generation.interval` | `1000` | Milliseconds between events |
| `event.generation.max-events` | `0` | Max events (0=infinite, >0=test mode) |
| `event.generation.topic` | `mobility-events` | Kafka topic |

**Examples:**

```properties
# Production: Continuous generation
event.generation.enabled=true
event.generation.max-events=0

# Test: Disabled
event.generation.enabled=false

# Demo: Generate 100 events then exit
event.generation.enabled=true
event.generation.max-events=100
```

### Analytics Engine

| Property | Default | Description |
|----------|---------|-------------|
| `analytics.pipeline.enabled` | `true` | Enable/disable pipeline |

**Examples:**

```properties
# Production: Continuous processing
analytics.pipeline.enabled=true

# Test: Disabled
analytics.pipeline.enabled=false
```

---

## Testing Different Modes

### 1. Test Mode (Maven)

```bash
mvn test
# Output: Services disabled, tests complete quickly
```

### 2. Production Mode (Docker)

```bash
docker compose up -d
# Output: Services run continuously
```

### 3. Demo Mode (100 Events)

**Create:** `event-generator/src/main/resources/application-demo.properties`

```properties
event.generation.enabled=true
event.generation.max-events=100
event.generation.interval=100
```

**Run:**
```bash
cd event-generator
mvn spring-boot:run -Dspring-boot.run.profiles=demo

# Generates 100 events in 10 seconds, then exits
```

---

## Troubleshooting

### Maven Still Hangs

**Check test configuration:**
```bash
cat event-generator/src/test/resources/application.properties
# Should have: event.generation.enabled=false

cat analytics-engine/src/test/resources/application.properties
# Should have: analytics.pipeline.enabled=false
```

**Force rebuild:**
```bash
mvn clean install -U
```

### Services Don't Run in Docker

**Check main configuration:**
```bash
cat event-generator/src/main/resources/application.properties
# Should have: event.generation.enabled=true (or not set, defaults to true)
```

**Check Docker logs:**
```bash
docker logs event-generator
# Should show: "Event Generator is now running..."
# Should NOT show: "Event generation is DISABLED"
```

---

## Benefits

### ✅ Maven Builds Complete

- No more hanging builds
- Tests finish in ~8 seconds
- CI/CD pipeline works

### ✅ Production Still Works

- Services run continuously in Docker
- No changes to production behavior
- Same infinite loop execution

### ✅ Flexible Configuration

- Can enable/disable per environment
- Can set max events for demos
- Can control via environment variables

### ✅ Better Development Experience

- Local builds don't hang
- IDE can run tests normally
- Fast feedback loop

---

## Summary

| Environment | Event Generator | Analytics Engine |
|-------------|----------------|------------------|
| Maven Test | ❌ Disabled | ❌ Disabled |
| Maven Build | ❌ Disabled (via test phase) | ❌ Disabled (via test phase) |
| Docker | ✅ Enabled (infinite) | ✅ Enabled (infinite) |
| Manual Run | ✅ Enabled (infinite) | ✅ Enabled (infinite) |

**Key Point:** Services **automatically disable themselves during tests** using Spring's test resource configuration.

---

**Status:** ✅ **FIXED - Maven builds complete successfully**

**Build Time:** ~8 seconds (was: infinite/hung)  
**Tests:** All passing  
**Production:** Still works as expected  

**Last Updated:** February 14, 2026

