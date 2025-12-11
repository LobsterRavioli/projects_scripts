import os
import pandas as pd
import matplotlib.pyplot as plt

# Directory principale dei test scalabilità topic
SCALABILITA_DIR = os.path.join(os.path.dirname(__file__), '2_scalabilita_topic')

# Trova tutte le sottocartelle numeriche (1, 2, 3, ...)
folders = [f for f in os.listdir(SCALABILITA_DIR) if os.path.isdir(os.path.join(SCALABILITA_DIR, f)) and f.isdigit()]
folders.sort(key=int)

for folder in folders:
    path = os.path.join(SCALABILITA_DIR, folder)
    prod_file = os.path.join(path, 'producer.csv')
    cons_file = os.path.join(path, 'consumer.csv')
    if not (os.path.exists(prod_file) and os.path.exists(cons_file)):
        continue

    # Producer plots
    dfp = pd.read_csv(prod_file)
    dfp.columns = [c.strip() for c in dfp.columns]
    dfp['Records/sec'] = dfp['Records/sec'].apply(lambda x: float(str(x).strip().split()[0]))
    dfp['MB/sec'] = dfp['MB/sec'].apply(lambda x: float(str(x).strip().split()[0]))
    dfp['Avg Latency'] = dfp['Avg Latency'].apply(lambda x: float(str(x).strip().split()[0]))
    dfp['Max Latency'] = dfp['Max Latency'].apply(lambda x: float(str(x).strip().split()[0]))

    # Plot throughput producer
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Records/sec'])
    plt.xlabel('Producer')
    plt.ylabel('Records/sec')
    plt.title(f'Throughput Producer - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_throughput.png'))
    plt.close()

    # Plot latenza media producer
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Avg Latency'])
    plt.xlabel('Producer')
    plt.ylabel('Avg Latency (ms)')
    plt.title(f'Latenza Media Producer - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_avg_latency.png'))
    plt.close()

    # Plot latenza massima producer
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Max Latency'])
    plt.xlabel('Producer')
    plt.ylabel('Max Latency (ms)')
    plt.title(f'Latenza Massima Producer - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_max_latency.png'))
    plt.close()

    # Consumer plots
    dfc = pd.read_csv(cons_file)
    dfc.columns = [c.strip() for c in dfc.columns]
    # Plot throughput consumer (MB/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['MB/sec'])
    plt.xlabel('Consumer')
    plt.ylabel('MB/sec')
    plt.title(f'Throughput Consumer (MB/sec) - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_mb_sec.png'))
    plt.close()

    # Plot throughput consumer (Msg/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Msg/sec'])
    plt.xlabel('Consumer')
    plt.ylabel('Msg/sec')
    plt.title(f'Throughput Consumer (Msg/sec) - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_msg_sec.png'))
    plt.close()

    # Plot fetch time medio consumer
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Fetch Time (ms)'])
    plt.xlabel('Consumer')
    plt.ylabel('Fetch Time (ms)')
    plt.title(f'Fetch Time Medio Consumer - Scalabilità Topic {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_fetch_time.png'))
    plt.close()

print('Plot generati per tutti i test di scalabilità topic.')
