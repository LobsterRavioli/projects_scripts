#!/bin/bash

# ============================================
# KAFKA RESILIENCE TEST - PRODUCER
# ============================================
# Uso:
#   1. Esegui questo script (produce messaggi)
#   2. Killa un broker: kubectl delete pod my-cluster-my-cluster-broker-0 -n strimzi-components
#   3. Esegui consume.sh per verificare i dati
# ============================================

BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
TOPIC="resilience-test"
RECORDS=${1:-1000}

echo "============================================"
echo "   PRODUCER - $RECORDS messaggi"
echo "============================================"

# Setup topic
/opt/kafka/bin/kafka-topics.sh --delete --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null || true
sleep 2
/opt/kafka/bin/kafka-topics.sh --create --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER \
  --partitions 1 --replication-factor 2 --config min.insync.replicas=1 2>/dev/null
#  Kafka considera la scrittura riuscita se almeno 1 replica è "in sync" (cioè aggiornata).
echo ""
echo "Topic creato. Leader:"
/opt/kafka/bin/kafka-topics.sh --describe --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER | grep Leader

echo ""
echo "Produco $RECORDS messaggi..."
seq 1 $RECORDS | /opt/kafka/bin/kafka-console-producer.sh --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER 2>/dev/null

echo ""
echo "✅ Done! Ora puoi killare un broker e poi eseguire consume.sh"
echo "============================================"