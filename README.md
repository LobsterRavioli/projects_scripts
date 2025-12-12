## Test Strimzi

1. Si accede alla macchina virtuale (assicurarsi che la configurazione di kubectl sia per dev)
2. Si apre visual studio code sulla macchina virtuale:
    1. Si crea il file test.sh e si copia lo script template_tesh.sh dalla macchina in locale.
    2. Si crea il file kafka-perf-client.sh e si copia lo script kafka-perf-client.sh dalla macchina in locale.
    3. Si crea il file gather.sh e si copia lo script gather.sh dalla macchina in locale.

3. Si effettua il deploy del client nel namespace del cluster kafka
k apply -f kafka-perf-client.yaml

4. Si eseguono i test:
kubectl cp test.sh kafka-perf-client:/tmp/test.sh -n strimzi-components      
kubectl exec -it kafka-perf-client -n strimzi-components -- bash /tmp/test.sh 

5. Si raccolgono i risultati:
kubectl cp gather.sh strimzi-components/kafka-perf-client:/home/kafka/gather.sh
kubectl exec -n strimzi-components -it kafka-perf-client -- bash /home/kafka/gather.sh
kubectl exec -n strimzi-components -it kafka-perf-client -- cat /home/kafka/producer.csv > producer.csv
kubectl exec -n strimzi-components -it kafka-perf-client -- cat /home/kafka/consumer.csv > consumer.csv

I risultati sono visibili sulla macchina virtuale nei corrispettivi file:
    - log producers: producers.csv
    - log consumers: consumer.csv

Per la simulazione del failover:
kubectl delete pod my-cluster-my-cluster-broker-0 -n strimzi-components --grace-period=0 --force
