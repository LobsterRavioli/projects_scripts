import os
import pandas as pd
import matplotlib.pyplot as plt

SCENARIOS = [
    ("Baseline", "1_baseline"),
    ("Scalabilità Topic", "2_scalabilita_topic"),
    ("Stress Throughput", "3_stress_troughput"),
    ("Messaggi Grandi", "4_messaggi_grandi"),
]

ROOT = os.path.dirname(__file__)

for scenario_name, folder in SCENARIOS:
    folder_path = os.path.join(ROOT, folder)
    if not os.path.isdir(folder_path):
        continue
    configs = []
    mean_throughput = []
    mean_latency = []
    for sub in sorted(os.listdir(folder_path), key=lambda x: int(x) if x.isdigit() else x):
        sub_path = os.path.join(folder_path, sub)
        prod_file = os.path.join(sub_path, 'producer_normalized.csv')
        if not os.path.isfile(prod_file):
            continue
        df = pd.read_csv(prod_file)
        if len(df) == 0:
            continue
        configs.append(sub)
        mean_throughput.append(df['Records_sec'].astype(float).mean())
        mean_latency.append(df['Avg_Latency'].astype(float).mean())
    if configs:
        plt.figure(figsize=(10,6))
        plt.plot(configs, mean_throughput, marker='o')
        plt.xlabel('Configurazione (sottocartella)')
        plt.ylabel('Throughput medio Producer (Records/sec)')
        plt.title(f'Throughput medio - {scenario_name}')
        plt.tight_layout()
        plt.savefig(f'plot_andamento_throughput_{folder}.png')
        plt.close()
        plt.figure(figsize=(10,6))
        plt.plot(configs, mean_latency, marker='o', color='orange')
        plt.xlabel('Configurazione (sottocartella)')
        plt.ylabel('Latenza media Producer (ms)')
        plt.title(f'Latenza media - {scenario_name}')
        plt.tight_layout()
        plt.savefig(f'plot_andamento_latenza_{folder}.png')
        plt.close()
print('Plot andamento risorse per tutti gli scenari generati.')
