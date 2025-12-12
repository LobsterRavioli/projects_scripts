#!/bin/bash

# ============================================
# KAFKA FIFO TEST - Test Ordine Messaggi FIFO
# ============================================
# FIFO garantito con: 1 partizione, 2 repliche

# Configurazione FIFO
BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
TOPIC="fifo-test-topic"
NUM_PARTITIONS=1
REPLICATION_FACTOR=2
RECORDS=1000000
CONSUMER_GROUP="fifo-test-group-$$"  # Gruppo unico per ogni esecuzione

echo "============================================"
echo "        KAFKA FIFO TEST"
echo "============================================"
echo ""
echo "Configurazione FIFO:"
echo "  - Partizioni: $NUM_PARTITIONS (necessario per FIFO)"
echo "  - Repliche: $REPLICATION_FACTOR"
echo "  - Messaggi: $RECORDS"
echo ""

# Elimina topic esistente
echo "[1/4] Eliminazione topic esistente..."
/opt/kafka/bin/kafka-topics.sh --delete \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null || true

# Attendi che il topic sia effettivamente eliminato
echo "      Attendo eliminazione completa..."
sleep 5

# Verifica che il topic non esista più
while /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null | grep -q "^${TOPIC}$"; do
  echo "      Topic ancora presente, attendo..."
  sleep 2
done
echo "      Done"

# Crea topic FIFO
echo "[2/4] Creazione topic FIFO..."
/opt/kafka/bin/kafka-topics.sh --create \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions $NUM_PARTITIONS \
  --replication-factor $REPLICATION_FACTOR
echo "      Done"

# Stampa la descrizione del topic
/opt/kafka/bin/kafka-topics.sh --describe --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER

sleep 2

# Produci messaggi numerati
echo "[3/4] Produzione $RECORDS messaggi..."
for i in $(seq 1 $RECORDS); do
  echo "$i"
done | /opt/kafka/bin/kafka-console-producer.sh \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --producer-props bootstrap.servers=$BOOTSTRAP_SERVER acks=all enable.idempotence=true \
  2>/dev/null
echo "      Done"

# Consuma e stampa a terminale
echo ""
echo "============================================"
echo "[4/4] CONSUMO MESSAGGI - VERIFICA VISIVA"
echo "============================================"
echo ""
echo "Se i numeri sono in ordine 1,2,3... = FIFO OK"
echo ""
echo "--- FINE STREAM ---"
echo "--- INIZIO STREAM ---"

/opt/kafka/bin/kafka-console-consumer.sh \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --from-beginning \
  --max-messages $RECORDS \
  --group $CONSUMER_GROUP \
  --timeout-ms 600000 \

  2>/dev/null > /tmp/fifo-consumer.log

echo "--- FINE STREAM ---"
echo "Messaggi consumati salvati in /tmp/fifo-consumer.log"
echo ""
echo "============================================"
echo "Se i numeri erano in ordine: ✅ FIFO OK"
echo "Se i numeri erano disordinati: ❌ FIFO FALLITO"
echo "============================================"