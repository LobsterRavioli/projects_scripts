import pandas as pd
import matplotlib.pyplot as plt

# Carica il file CSV
df = pd.read_csv('consumer.csv')

# Plot 1: MB/sec medio per Topic
mb_sec = df.groupby('Topic')['MB/sec'].mean().reset_index()
plt.figure(figsize=(10,6))
plt.bar(mb_sec['Topic'].astype(str), mb_sec['MB/sec'])
plt.xlabel('Topic')
plt.ylabel('MB/sec (media)')
plt.title('Velocità di consumo media per Topic')
plt.tight_layout()
plt.savefig('plot_mb_sec_per_topic.png')
plt.show()

# Plot 2: Msg/sec medio per Topic
msg_sec = df.groupby('Topic')['Msg/sec'].mean().reset_index()
plt.figure(figsize=(10,6))
plt.bar(msg_sec['Topic'].astype(str), msg_sec['Msg/sec'])
plt.xlabel('Topic')
plt.ylabel('Msg/sec (media)')
plt.title('Throughput messaggi medio per Topic')
plt.tight_layout()
plt.savefig('plot_msg_sec_per_topic.png')
plt.show()

# Plot 3: Fetch Time (ms) medio per Topic
fetch_time = df.groupby('Topic')['Fetch Time (ms)'].mean().reset_index()
plt.figure(figsize=(10,6))
plt.bar(fetch_time['Topic'].astype(str), fetch_time['Fetch Time (ms)'])
plt.xlabel('Topic')
plt.ylabel('Fetch Time (ms) (media)')
plt.title('Tempo di fetch medio per Topic')
plt.tight_layout()
plt.savefig('plot_fetch_time_per_topic.png')
plt.show()