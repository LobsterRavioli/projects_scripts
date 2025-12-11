import sys

if len(sys.argv) < 2:
    print('Usage: python check_csv_lines.py <file.csv>')
    sys.exit(1)

csv_path = sys.argv[1]

with open(csv_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

header = lines[0]
num_cols = len(header.strip().split(','))

for idx, line in enumerate(lines[1:], start=2):
    cols = line.strip().split(',')
    if len(cols) != num_cols:
        print(f"Riga {idx}: {len(cols)} colonne invece di {num_cols}")
        print(line.strip())
