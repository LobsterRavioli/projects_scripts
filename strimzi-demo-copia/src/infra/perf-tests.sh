#!/bin/bash

# Suite di test di performance per Kafka
# Esegue vari scenari per testare il cluster

NAMESPACE="strimzi-components"
BROKER_POD="my-cluster-my-cluster-broker-0"
BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
RESULTS_DIR="./perf-results"

# Crea directory per i risultati
mkdir -p "$RESULTS_DIR"
echo "=== Kafka Performance Test Suite ==="
echo "Risultati salvati in: $RESULTS_DIR"
echo ""

# Test 1: Throughput massimo - messaggi piccoli
echo "Test 1: Throughput massimo - messaggi piccoli (100 bytes)"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-small-messages \
  --num-records 1000000 \
  --record-size 100 \
  --throughput -1 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER \
  | tee "$RESULTS_DIR/01-producer-small-messages.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-small-messages \
  --messages 1000000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-1 \
  | tee "$RESULTS_DIR/01-consumer-small-messages.txt"

echo ""
echo "---"
echo ""

# Test 2: Throughput - messaggi medi
echo "Test 2: Throughput - messaggi medi (1KB)"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-medium-messages \
  --num-records 500000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER \
  | tee "$RESULTS_DIR/02-producer-medium-messages.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-medium-messages \
  --messages 500000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-2 \
  | tee "$RESULTS_DIR/02-consumer-medium-messages.txt"

echo ""
echo "---"
echo ""

# Test 3: Throughput - messaggi grandi
echo "Test 3: Throughput - messaggi grandi (10KB)"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-large-messages \
  --num-records 100000 \
  --record-size 10240 \
  --throughput -1 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER \
  | tee "$RESULTS_DIR/03-producer-large-messages.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-large-messages \
  --messages 100000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-3 \
  | tee "$RESULTS_DIR/03-consumer-large-messages.txt"

echo ""
echo "---"
echo ""

# Test 4: Latency test - throughput limitato
echo "Test 4: Latency test - throughput controllato (10K msg/sec)"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-latency-test \
  --num-records 100000 \
  --record-size 1024 \
  --throughput 10000 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER \
  | tee "$RESULTS_DIR/04-producer-latency-test.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-latency-test \
  --messages 100000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-4 \
  | tee "$RESULTS_DIR/04-consumer-latency-test.txt"

echo ""
echo "---"
echo ""

# Test 5: Burst test - simula carichi irregolari
echo "Test 5: Burst test - batch di messaggi"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-burst-test \
  --num-records 200000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER batch.size=32768 linger.ms=10 \
  | tee "$RESULTS_DIR/05-producer-burst-test.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-burst-test \
  --messages 200000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-5 \
  | tee "$RESULTS_DIR/05-consumer-burst-test.txt"

echo ""
echo "---"
echo ""

# Test 6: Compression test
echo "Test 6: Compression test - GZIP"
kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-producer-perf-test.sh \
  --topic perf-compression-test \
  --num-records 200000 \
  --record-size 1024 \
  --throughput -1 \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER compression.type=gzip \
  | tee "$RESULTS_DIR/06-producer-compression-test.txt"

sleep 5

kubectl exec -n $NAMESPACE $BROKER_POD -- bin/kafka-consumer-perf-test.sh \
  --topic perf-compression-test \
  --messages 200000 \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --group test-group-6 \
  | tee "$RESULTS_DIR/06-consumer-compression-test.txt"

echo ""
echo "=== Test completati ==="
echo "Riepilogo risultati in: $RESULTS_DIR"
echo ""

# Genera un report sommario
echo "=== REPORT SOMMARIO ===" > "$RESULTS_DIR/summary.txt"
echo "" >> "$RESULTS_DIR/summary.txt"
echo "Test eseguiti: $(date)" >> "$RESULTS_DIR/summary.txt"
echo "" >> "$RESULTS_DIR/summary.txt"

for file in "$RESULTS_DIR"/*.txt; do
  if [[ "$file" != *"summary.txt" ]]; then
    echo "---" >> "$RESULTS_DIR/summary.txt"
    echo "File: $(basename $file)" >> "$RESULTS_DIR/summary.txt"
    tail -n 3 "$file" >> "$RESULTS_DIR/summary.txt"
    echo "" >> "$RESULTS_DIR/summary.txt"
  fi
done

cat "$RESULTS_DIR/summary.txt 