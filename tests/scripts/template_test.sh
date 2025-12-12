#!/bin/bash

# Configurazione
BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
NUM_TOPICS=20                # Numero di topic da testare
NUM_PRODUCERS=2
NUM_CONSUMERS=2   # Deve essere <= NUM_PARTITIONS
NUM_PARTITIONS=6
RECORDS=500
RECORD_SIZE=1024

echo "============================================"
echo "     KAFKA LOAD TEST CONCORRENTE - MULTI TOPIC"
echo "============================================"
echo ""
echo "Configurazione:"
echo "  - Topic: $NUM_TOPICS"
echo "  - Producer: $NUM_PRODUCERS"
echo "  - Consumer: $NUM_CONSUMERS"
echo "  - Partizioni: $NUM_PARTITIONS"
echo "  - Messaggi per producer: $RECORDS"
echo "  - Totale messaggi per topic: $((NUM_PRODUCERS * RECORDS))"
echo ""

# Pulisci log precedenti
rm -f /tmp/producer-*.log /tmp/consumer-*.log


# Esecuzione parallela su più topic
for t in $(seq 1 $NUM_TOPICS); do
  (
    TOPIC="load-test-topic-$t"
    echo "=== Test su $TOPIC ==="

    # Elimina topic esistente
    /opt/kafka/bin/kafka-topics.sh --delete --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null || true
    sleep 2

    # Crea topic
    /opt/kafka/bin/kafka-topics.sh --create \
      --topic $TOPIC \
      --bootstrap-server $BOOTSTRAP_SERVER \
      --partitions $NUM_PARTITIONS \
      --replication-factor 2 \
      --if-not-exists 2>/dev/null
    sleep 3

    /opt/kafka/bin/kafka-topics.sh --describe --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null
    sleep 2

    # Avvia producer (sequenziale)
    for i in $(seq 1 $NUM_PRODUCERS); do
      /opt/kafka/bin/kafka-producer-perf-test.sh \
        --topic $TOPIC \
        --num-records $RECORDS \
        --record-size $RECORD_SIZE \
        --throughput -1 \
        --producer-props bootstrap.servers=$BOOTSTRAP_SERVER acks=1 \
        2>&1 | grep "99th" > /tmp/producer-${t}-${i}.log
    done

    # Avvia consumer (sequenziale)
    TOTAL_MESSAGES=$((RECORDS * NUM_PRODUCERS))
    for i in $(seq 1 $NUM_CONSUMERS); do
      /opt/kafka/bin/kafka-consumer-perf-test.sh \
        --topic $TOPIC \
        --messages $TOTAL_MESSAGES \
        --bootstrap-server $BOOTSTRAP_SERVER \
        --group load-test-group-${t}-${i} \
        --timeout 60000 \
        --hide-header \
        2>&1 | tail -1 > /tmp/consumer-${t}-${i}.log
    done
  ) &
done
wait

echo ""
echo "============================================"
echo "           RISULTATI FINALI"
echo "============================================"
for t in $(seq 1 $NUM_TOPICS); do
  echo "=== Risultati per topic load-test-topic-$t ==="
  echo "--- PRODUCER ---"
  for i in $(seq 1 $NUM_PRODUCERS); do
    echo "Producer $i:"
    cat /tmp/producer-${t}-${i}.log
    echo ""
  done
  echo "--- CONSUMER ---"
  for i in $(seq 1 $NUM_CONSUMERS); do
    echo "Consumer $i:"
    cat /tmp/consumer-${t}-${i}.log
    echo ""
  done
done

# Pulizia finale: elimina tutti i topic creati
echo "Pulizia: eliminazione dei topic creati..."
for t in $(seq 1 $NUM_TOPICS); do
  TOPIC="load-test-topic-$t"
  /opt/kafka/bin/kafka-topics.sh --delete --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null || true
done
echo "Topic eliminati."


echo "============================================"
echo "Log: /tmp/producer-*-*.log /tmp/consumer-*-*.log"
echo "============================================"