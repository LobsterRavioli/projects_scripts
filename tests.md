# Test di resilienza
1. Prevede mandare 1000 messaggi su un Topic che ha 2 replicas come option
```
Usa seq 1 $RECORDS per generare i messaggi.
Li invia al topic tramite kafka-console-producer.sh.
```
1. Viene fatto fuori uno dei pod di kafka
2. Viene lanciato lo script che verifica che 1000 messaggi sono stati mandati
3. Vengono contati i messaggi consumati

```bash
CONSUMED=$(wc -l < /tmp/consumed.log)
LOST=$((EXPECTED - CONSUMED))
```


Test FIFO

Prevede di produrre i numeri da 1 a 50 e vedere poi come vengono consumati.
FIFO e' garantita con partition 1 e replica > 1.

Si producono il messaggi su topic:
```bash
echo "[3/4] Produzione $RECORDS messaggi..."
for i in $(seq 1 $RECORDS); do
  echo "$i"
done | /opt/kafka/bin/kafka-console-producer.sh \
  --topic $TOPIC \
  --bootstrap-server $BOOTSTRAP_SERVER \
  2>/dev/null
echo "Done"
```


e poi si stampano con console-consumer
```bash
/opt/kafka/bin/kafka-console-consumer.sh \
  --topic $TOPIC 
  --bootstrap-server $BOOTSTRAP_SERVER \
  --from-beginning \
  --max-messages $RECORDS \
  --group $CONSUMER_GROUP \
  --timeout-ms 10000 \
  2>/dev/null
```
