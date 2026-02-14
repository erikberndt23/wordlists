#!/bin/bash

# Check argument count
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_wordlist> <output_file>"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

# Check input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: File '$INPUT' not found."
    exit 1
fi

# Hash each line
while IFS= read -r word; do
    printf "%s" "$word" | sha1sum | awk '{print $1}'
done < "$INPUT" > "$OUTPUT"

echo "Done. Hashes written to $OUTPUT"
