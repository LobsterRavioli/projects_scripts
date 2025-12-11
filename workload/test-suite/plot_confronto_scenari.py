import os
import pandas as pd
import matplotlib.pyplot as plt

# Definizione degli scenari e delle relative cartelle
SCENARIOS = [
    ("Baseline", "1_baseline"),
    ("Scalabilità Topic", "2_scalabilita_topic"),
    ("Stress Throughput", "3_stress_troughput"),
    ("Messaggi Grandi", "4_messaggi_grandi"),
]

ROOT = os.path.dirname(__file__)

# Raccolta dati aggregati per ogni scenario
scenario_data = []
for scenario_name, folder in SCENARIOS:
    folder_path = os.path.join(ROOT, folder)
    if not os.path.isdir(folder_path):
        continue
    all_throughput = []
    all_latency = []
    for sub in os.listdir(folder_path):
        sub_path = os.path.join(folder_path, sub)
        prod_file = os.path.join(sub_path, 'producer_normalized.csv')
        if not os.path.isfile(prod_file):
            continue
        df = pd.read_csv(prod_file)
        all_throughput.extend(df['Records_sec'].astype(float).tolist())
        all_latency.extend(df['Avg_Latency'].astype(float).tolist())
    if all_throughput and all_latency:
        scenario_data.append({
            'scenario': scenario_name,
            'mean_throughput': sum(all_throughput)/len(all_throughput),
            'mean_latency': sum(all_latency)/len(all_latency),
        })

# Plot confronto throughput medio
plt.figure(figsize=(10,6))
plt.bar([d['scenario'] for d in scenario_data], [d['mean_throughput'] for d in scenario_data])
plt.ylabel('Throughput medio Producer (Records/sec)')
plt.title('Confronto Throughput medio tra scenari')
plt.tight_layout()
plt.savefig('plot_confronto_throughput_scenari.png')
plt.close()

# Plot confronto latenza media
plt.figure(figsize=(10,6))
plt.bar([d['scenario'] for d in scenario_data], [d['mean_latency'] for d in scenario_data])
plt.ylabel('Latenza media Producer (ms)')
plt.title('Confronto Latenza media tra scenari')
plt.tight_layout()
plt.savefig('plot_confronto_latenza_scenari.png')
plt.close()

print('Plot confronto tra scenari generati.')
