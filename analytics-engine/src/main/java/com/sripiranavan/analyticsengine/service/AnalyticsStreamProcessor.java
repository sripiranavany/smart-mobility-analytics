package com.sripiranavan.analyticsengine.service;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.kafka.KafkaIO;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.values.KV;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Service;

/**
 * Analytics Engine service that processes Kafka streams using Apache Beam
 */
@Service
public class AnalyticsStreamProcessor implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(AnalyticsStreamProcessor.class);

    @Value("${spring.kafka.bootstrap-servers}")
    private String kafkaBootstrapServers;

    @Value("${event.generation.topic:mobility-events}")
    private String inputTopic;

    @Value("${analytics.pipeline.enabled:true}")
    private boolean enabled;

    @Override
    public void run(String... args) throws Exception {
        if (!enabled) {
            log.info("Analytics pipeline is DISABLED (analytics.pipeline.enabled=false)");
            return;
        }

        log.info("=== Analytics Stream Processor Starting ===");
        log.info("Kafka Bootstrap Servers: {}", kafkaBootstrapServers);
        log.info("Input Topic: {}", inputTopic);
        log.info("Initializing Apache Beam pipeline...");

        // Create Apache Beam pipeline
        Pipeline pipeline = Pipeline.create(PipelineOptionsFactory.create());

        // Read from Kafka
        pipeline.apply("ReadFromKafka",
            KafkaIO.<String, String>read()
                .withBootstrapServers(kafkaBootstrapServers)
                .withTopic(inputTopic)
                .withKeyDeserializer(StringDeserializer.class)
                .withValueDeserializer(StringDeserializer.class)
                .withoutMetadata()
        )
        .apply("ProcessEvents", ParDo.of(new DoFn<KV<String, String>, String>() {
            private int processedCount = 0;

            @ProcessElement
            public void processElement(@Element KV<String, String> element, OutputReceiver<String> out) {
                processedCount++;
                log.info("[Event #{}] Processing: vehicleId={}, data={}",
                         processedCount, element.getKey(), element.getValue());
                // TODO: Add your analytics logic here
                // - Parse JSON
                // - Perform aggregations
                // - Write to Cassandra
                out.output(element.getValue());
            }
        }));

        log.info("=== Apache Beam pipeline configured successfully ===");
        log.info("Starting pipeline execution (will block and listen for Kafka messages)...");
        log.info("Analytics Engine is now running and waiting for events from topic: {}", inputTopic);

        // This will block and keep the application running
        pipeline.run().waitUntilFinish();

        log.info("Analytics Stream Processor stopped");
    }
}

