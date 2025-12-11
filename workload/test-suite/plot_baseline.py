import os
import pandas as pd
import matplotlib.pyplot as plt

# Directory principale dei test baseline
BASELINE_DIR = os.path.join(os.path.dirname(__file__), '1_baseline')

# Trova tutte le sottocartelle numeriche (1, 2, 3, ...)
folders = [f for f in os.listdir(BASELINE_DIR) if os.path.isdir(os.path.join(BASELINE_DIR, f)) and f.isdigit()]
folders.sort(key=int)

for folder in folders:
    path = os.path.join(BASELINE_DIR, folder)

    prod_file = os.path.join(path, 'producer_normalized.csv')
    cons_file = os.path.join(path, 'consumer.csv')
    if not os.path.exists(prod_file) or not os.path.exists(cons_file):
        continue
    dfp = pd.read_csv(prod_file)
    # Plot throughput producer (Records/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Records_sec'])
    plt.xlabel('Producer')
    plt.ylabel('Records/sec')
    plt.title(f'Throughput Producer (Records/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_throughput.png'))
    plt.close()
    # Plot throughput producer (MB/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['MB_sec'])
    plt.xlabel('Producer')
    plt.ylabel('MB/sec')
    plt.title(f'Throughput Producer (MB/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_mb_sec.png'))
    plt.close()
    # Plot latenza media producer
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Avg_Latency'])
    plt.xlabel('Producer')
    plt.ylabel('Avg Latency (ms)')
    plt.title(f'Latenza Media Producer - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_producer_avg_latency.png'))
    plt.close()
    # Plot latenza massima producer
    plt.figure(figsize=(10,6))
    plt.bar(dfp['Producer'].astype(str), dfp['Max_Latency'])
    plt.xlabel('Producer')
    plt.ylabel('Max Latency (ms)')
    plt.title(f'Latenza Massima Producer - Baseline {folder}')
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
    plt.title(f'Throughput Consumer (MB/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_mb_sec.png'))
    plt.close()
    # Plot throughput consumer (Msg/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Msg/sec'])
    plt.xlabel('Consumer')
    plt.ylabel('Msg/sec')
    plt.title(f'Throughput Consumer (Msg/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_msg_sec.png'))
    plt.close()
    # Plot fetch time medio consumer
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Fetch Time (ms)'])
    plt.xlabel('Consumer')
    plt.ylabel('Fetch Time (ms)')
    plt.title(f'Fetch Time Medio Consumer - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_fetch_time.png'))
    plt.close()

    # Plot fetch time medio aggregato (media su tutti i consumer della baseline)
    mean_fetch_time = dfc['Fetch Time (ms)'].mean()
    plt.figure(figsize=(6,6))
    plt.bar([f'Baseline {folder}'], [mean_fetch_time], color='green')
    plt.ylabel('Fetch Time medio (ms)')
    plt.title(f'Fetch Time medio aggregato - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_fetch_time_mean.png'))
    plt.close()

    # Consumer plots
    dfc = pd.read_csv(cons_file)
    dfc.columns = [c.strip() for c in dfc.columns]
    # Plot throughput consumer (MB/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['MB/sec'])
    plt.xlabel('Consumer')
    plt.ylabel('MB/sec')
    plt.title(f'Throughput Consumer (MB/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_mb_sec.png'))
    plt.close()

    # Plot throughput consumer (Msg/sec)
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Msg/sec'])
    plt.xlabel('Consumer')
    plt.ylabel('Msg/sec')
    plt.title(f'Throughput Consumer (Msg/sec) - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_msg_sec.png'))
    plt.close()

    # Plot fetch time medio consumer
    plt.figure(figsize=(10,6))
    plt.bar(dfc['Consumer'].astype(str), dfc['Fetch Time (ms)'])
    plt.xlabel('Consumer')
    plt.ylabel('Fetch Time (ms)')
    plt.title(f'Fetch Time Medio Consumer - Baseline {folder}')
    plt.tight_layout()
    plt.savefig(os.path.join(path, 'plot_consumer_fetch_time.png'))
    plt.close()

print('Plot generati per tutti i baseline.')
