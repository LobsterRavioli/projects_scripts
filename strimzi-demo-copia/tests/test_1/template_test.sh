#!/bin/bash

# ============================================
# KAFKA LOAD TEST - Test di Carico Concorrente
# ============================================

# Configurazione
BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
TOPIC="load-test-topic"
NUM_PRODUCERS=10
NUM_CONSUMERS=10   # Deve essere <= NUM_PARTITIONS
NUM_PARTITIONS=12  # Partizioni 
RECORDS=2000        # Ridotto per non sovraccaricare
RECORD_SIZE=1024

echo "============================================"
echo "     KAFKA LOAD TEST CONCORRENTE"
echo "============================================"
echo ""
echo "Configurazione:"
echo "  - Producer: $NUM_PRODUCERS"
echo "  - Consumer: $NUM_CONSUMERS"
echo "  - Partizioni: $NUM_PARTITIONS"
echo "  - Messaggi per producer: $RECORDS"
echo "  - Totale messaggi: $((NUM_PRODUCERS * RECORDS))"
echo ""

# Pulisci log precedenti
rm -f /tmp/producer-*.log /tmp/consumer-*.log

# Elimina topic esistente per resettare offset
echo "[1/5] Eliminazione topic esistente..."
/opt/kafka/bin/kafka-topics.sh --delete \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null || true
sleep 2

# Crea topic
echo "[2/5] Creazione topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions $NUM_PARTITIONS \
  --replication-factor 2 \
  --if-not-exists 2>/dev/null
echo "      Done"

sleep 3

# FASE 1: Avvia producer in background
echo "[3/5] Avvio producer..."
START_TIME=$(date +%s)

for i in $(seq 1 $NUM_PRODUCERS); do
  /opt/kafka/bin/kafka-producer-perf-test.sh \
    --topic $TOPIC \
    --num-records $RECORDS \
    --record-size $RECORD_SIZE \
    --throughput -1 \
    --producer-props bootstrap.servers=$BOOTSTRAP_SERVER acks=1 \
    2>&1 | grep "99th" > /tmp/producer-$i.log &
done
echo "      $NUM_PRODUCERS producer avviati"

# Attendi completamento producer
echo ""
echo "[4/5] Attendo completamento producer..."
wait

# FASE 2: Avvia consumer concorrenti (gruppi separati = ognuno legge tutto)
echo "[5/5] Avvio $NUM_CONSUMERS consumer concorrenti..."
TOTAL_MESSAGES=$((RECORDS * NUM_PRODUCERS))

for i in $(seq 1 $NUM_CONSUMERS); do
  /opt/kafka/bin/kafka-consumer-perf-test.sh \
    --topic $TOPIC \
    --messages $TOTAL_MESSAGES \
    --bootstrap-server $BOOTSTRAP_SERVER \
    --group load-test-group-$i \
    --timeout 60000 \
    --hide-header \
    2>&1 | tail -1 > /tmp/consumer-$i.log &
done
echo "      $NUM_CONSUMERS consumer avviati"

# Attendi completamento consumer
wait

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Mostra risultati
echo ""
echo "============================================"
echo "           RISULTATI FINALI"
echo "============================================"
echo "Durata: $DURATION secondi"
echo ""

echo "--- PRODUCER ---"
for i in $(seq 1 $NUM_PRODUCERS); do
  echo "Producer $i:"
  cat /tmp/producer-$i.log
  echo ""
done

echo "--- CONSUMER ---"
for i in $(seq 1 $NUM_CONSUMERS); do
  echo "Consumer $i:"
  cat /tmp/consumer-$i.log
  echo ""
done

echo "============================================"
echo "Log: /tmp/producer-*.log /tmp/consumer-*.log"
echo "============================================"