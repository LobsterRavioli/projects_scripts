# Producer CSV
echo "Topic,Producer,Records Sent,Records/sec,MB/sec,Avg Latency,Max Latency,50th,95th,99th,99.9th" > /home/kafka/producer.csv
for f in /tmp/producer-*-*.log; do
  fname=$(basename "$f")
  topic=$(echo $fname | cut -d'-' -f2)
  producer=$(echo $fname | cut -d'-' -f3 | cut -d'.' -f1)
  line=$(grep "records sent" "$f" | \
    sed -E 's/([0-9]+) records sent, ([0-9\\.]+) records\/sec \(([0-9\\.]+) MB\/sec\), ([0-9\\.]+) ms avg latency, ([0-9\\.]+) ms max latency, ([0-9]+) ms 50th, ([0-9]+) ms 95th, ([0-9]+) ms 99th, ([0-9]+) ms 99.9th\\./\\1,\\2,\\3,\\4,\\5,\\6,\\7,\\8,\\9/')
  if [ -n "$line" ]; then
    echo "$topic,$producer,$line" >> /home/kafka/producer.csv
  fi
done

# Consumer CSV
echo "Topic,Consumer,Start Time,End Time,Data Consumed (MB),MB/sec,Messages Consumed,Msg/sec,Rebalance Time (ms),Fetch Time (ms),Fetch MB/sec,Fetch Msg/sec" > /home/kafka/consumer.csv
for f in /tmp/consumer-*-*.log; do
  fname=$(basename "$f")
  topic=$(echo $fname | cut -d'-' -f2)
  consumer=$(echo $fname | cut -d'-' -f3 | cut -d'.' -f1)
  line=$(cat "$f" | tr -d ' ')
  if [ -n "$line" ]; then
    echo "$topic,$consumer,$line" >> /home/kafka/consumer.csv
  fi
done