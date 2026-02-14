package com.sripiranavan.eventgenerator.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * Event generator service that continuously produces mobility events to Kafka
 */
@Service
public class EventGeneratorService implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(EventGeneratorService.class);

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Value("${event.generation.topic:mobility-events}")
    private String topic;

    @Value("${event.generation.interval:1000}")
    private long interval;

    @Value("${event.generation.enabled:true}")
    private boolean enabled;

    @Value("${event.generation.max-events:0}")
    private int maxEvents;

    private final Random random = new Random();
    private volatile boolean running = true;

    public EventGeneratorService(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @Override
    public void run(String... args) throws Exception {
        if (!enabled) {
            log.info("Event generation is DISABLED (event.generation.enabled=false)");
            return;
        }

        log.info("Starting Event Generator Service...");
        log.info("Publishing to topic: {}", topic);
        log.info("Generation interval: {}ms", interval);

        if (maxEvents > 0) {
            log.info("Will generate {} events then exit (test mode)", maxEvents);
        } else {
            log.info("Event Generator is now running and generating events continuously...");
        }

        int eventCount = 0;
        // Keep the application running
        while (running && (maxEvents == 0 || eventCount < maxEvents)) {
            try {
                generateAndSendEvent();
                eventCount++;

                // Log summary every 10 events
                if (eventCount % 10 == 0) {
                    log.info("Generated {} events so far...", eventCount);
                }

                TimeUnit.MILLISECONDS.sleep(interval);
            } catch (InterruptedException e) {
                log.warn("Event generator interrupted", e);
                Thread.currentThread().interrupt();
                running = false;
            } catch (Exception e) {
                log.error("Error generating event", e);
            }
        }

        if (maxEvents > 0) {
            log.info("Event Generator completed - generated {} events (test mode)", eventCount);
        } else {
            log.info("Event Generator Service stopped after generating {} events", eventCount);
        }
    }

    private void generateAndSendEvent() {
        Map<String, Object> event = new HashMap<>();
        event.put("eventId", java.util.UUID.randomUUID().toString());
        event.put("timestamp", LocalDateTime.now().toString());
        event.put("vehicleId", "VH-" + random.nextInt(1000));
        event.put("latitude", 40.7128 + (random.nextDouble() - 0.5) * 0.1);
        event.put("longitude", -74.0060 + (random.nextDouble() - 0.5) * 0.1);
        event.put("speed", random.nextDouble() * 120);
        event.put("eventType", getRandomEventType());

        String vehicleId = event.get("vehicleId").toString();
        kafkaTemplate.send(topic, vehicleId, event);
        log.info("Generated and sent event: {} for vehicle: {} (type: {})",
                 event.get("eventId"), vehicleId, event.get("eventType"));
    }

    private String getRandomEventType() {
        String[] eventTypes = {"LOCATION_UPDATE", "SPEED_CHANGE", "TRAFFIC_ALERT", "PARKING"};
        return eventTypes[random.nextInt(eventTypes.length)];
    }

    public void stop() {
        running = false;
    }
}

