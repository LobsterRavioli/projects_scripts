#!/bin/bash

# ============================================
# KAFKA RESILIENCE TEST - CONSUMER
# ============================================

BOOTSTRAP_SERVER="my-cluster-kafka-bootstrap:9092"
TOPIC="resilience-test"
EXPECTED=${1:-1000}

echo "============================================"
echo "   CONSUMER - Verifico $EXPECTED messaggi"
echo "============================================"

echo ""
echo "Topic info:"
/opt/kafka/bin/kafka-topics.sh --describe --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER | grep Leader

echo ""
echo "Consumo messaggi..."
timeout 10 /opt/kafka/bin/kafka-console-consumer.sh --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER --from-beginning 2>/dev/null > /tmp/consumed.log

CONSUMED=$(wc -l < /tmp/consumed.log)
LOST=$((EXPECTED - CONSUMED))

echo ""
echo "============================================"
echo "   RISULTATO"
echo "============================================"
echo "Attesi:    $EXPECTED"
echo "Consumati: $CONSUMED"
echo "Persi:     $LOST"
echo ""

if [ $LOST -le 0 ]; then
  echo "✅ RESILIENZA OK!"
else
  echo "❌ MESSAGGI PERSI: $LOST"
fi
echo "============================================"
