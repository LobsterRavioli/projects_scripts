import os
import re
import csv

# Cartelle da processare
FOLDERS = [
    '1_baseline',
    '2_scalabilita_topic',
    '3_stress_troughput',
    '4_messaggi_grandi',
]

ROOT = os.path.dirname(__file__)

# Regex per estrarre i valori
row_re = re.compile(r"""
    (?P<Topic>\d+)\s*,\s*
    (?P<Producer>\d+)\s*,\s*
    (?P<Records_Sent>\d+)\s*[^,]*,\s*
    (?P<Records_sec>[\d\.]+)\s*records/sec[^,]*,\s*
    (?P<Avg_Latency>[\d\.]+)\s*ms avg latency[^,]*,\s*
    (?P<Max_Latency>[\d\.]+)\s*ms max latency[^,]*,\s*
    (?P<P50>[\d\.]+)\s*ms 50th[^,]*,\s*
    (?P<P95>[\d\.]+)\s*ms 95th[^,]*,\s*
    (?P<P99>[\d\.]+)\s*ms 99th[^,]*,\s*
    (?P<P999>[\d\.]+)\s*ms 99.9th\.
""", re.VERBOSE)

for folder in FOLDERS:
    folder_path = os.path.join(ROOT, folder)
    if not os.path.isdir(folder_path):
        continue
    for sub in os.listdir(folder_path):
        sub_path = os.path.join(folder_path, sub)
        prod_path = os.path.join(sub_path, 'producer.csv')
        if not os.path.isfile(prod_path):
            continue
        out_path = os.path.join(sub_path, 'producer_normalized.csv')
        with open(prod_path, 'r', encoding='utf-8') as fin, open(out_path, 'w', newline='', encoding='utf-8') as fout:
            reader = csv.reader(fin)
            writer = csv.writer(fout)
            header = next(reader, None)
            writer.writerow(['Topic','Producer','Records_Sent','Records_sec','MB_sec','Avg_Latency','Max_Latency','P50','P95','P99','P999'])
            for row in reader:
                if len(row) < 10:
                    continue
                def extract_number(s):
                    m = re.search(r"([\d\.]+)", s)
                    return m.group(1) if m else ''
                def extract_mb_sec(s):
                    m = re.search(r"\(([^ ]+) MB/sec\)", s)
                    return m.group(1) if m else ''
                topic = extract_number(row[0])
                producer = extract_number(row[1])
                records_sent = extract_number(row[2])
                records_sec = extract_number(row[3])
                mb_sec = extract_mb_sec(row[3])
                avg_latency = extract_number(row[4])
                max_latency = extract_number(row[5])
                p50 = extract_number(row[6])
                p95 = extract_number(row[7])
                p99 = extract_number(row[8])
                p999 = extract_number(row[9])
                writer.writerow([topic, producer, records_sent, records_sec, mb_sec, avg_latency, max_latency, p50, p95, p99, p999])
print('Normalizzazione completata. File producer_normalized.csv creati.')
