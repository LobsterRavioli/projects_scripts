Esecuzione del test
kubectl cp test.sh kafka-perf-client:/tmp/test.sh -n strimzi-components      
kubectl exec -it kafka-perf-client -n strimzi-components -- bash /tmp/test.sh 


Raccolta Metriche

kubectl cp gather.sh strimzi-components/kafka-perf-client:/home/kafka/gather.sh
kubectl exec -n strimzi-components -it kafka-perf-client -- bash /home/kafka/gather.sh
kubectl exec -n strimzi-components -it kafka-perf-client -- cat /home/kafka/producer.csv > producer.csv
kubectl exec -n strimzi-components -it kafka-perf-client -- cat /home/kafka/consumer.csv > consumer.csv

kubectl delete pod my-cluster-my-cluster-broker-0 -n strimzi-components --grace-period=0 --force
