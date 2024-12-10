#!/bin/bash

# Ensure correct usage
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input_file_pattern> <output_csv_file>"
    exit 1
fi

# Input file pattern (e.g., /path/to/*.log) and output CSV file
INPUT_PATTERN="$1"
OUTPUT_CSV="$2"

# Check if any files match the input pattern
if ! ls $INPUT_PATTERN 1> /dev/null 2>&1; then
    echo "Error: No files matching the pattern '$INPUT_PATTERN' found."
    exit 1
fi

# Debug: Confirm input pattern and output file
echo "Reading from files matching: $INPUT_PATTERN"
echo "Writing to: $OUTPUT_CSV"

# Temporary file to collect data
TEMP_FILE=$(mktemp)

# Function to convert date format from dd/Mon/yyyy to yyyy/mm/dd using awk
convert_date() {
    input_date="$1"
    output_date=$(echo "$input_date" | awk -F'/' '{printf "%s/%02d/%02d\n", $3, (index("JanFebMarAprMayJunJulAugSepOctNovDec", $2) + 2) / 3, $1}')
    echo "$output_date"
}

# Extract View IDs and timestamps from all matching log files
for file in $INPUT_PATTERN; do
    echo "Processing $file..."
    grep -oP '\[.*?\].*/viewdefinition/view/[0-9]+' "$file" | \
    while IFS= read -r line; do
        # Extract raw date from the log line
        raw_date=$(echo "$line" | grep -oP '\[.*?\]' | tr -d '[]' | sed 's!:.*$!!')  # Extract date, remove time
        formatted_date=$(convert_date "$raw_date")  # Convert date to yyyy/mm/dd
        if [[ -n "$formatted_date" ]]; then
            # Extract View ID
            view_id=$(echo "$line" | grep -oP '/viewdefinition/view/[0-9]+' | cut -d/ -f4)
            echo "$formatted_date,$view_id" >> "$TEMP_FILE"
        else
            echo "Warning: Failed to convert date '$raw_date' in line: $line" >&2
        fi
    done
done

# Debug: Check that the temporary file contains data
if [[ ! -s $TEMP_FILE ]]; then
    echo "Error: No data extracted from the log files."
    rm -f "$TEMP_FILE"
    exit 1
fi

# Calculate the count and last-viewed date for each View ID
echo "View ID,Count,Last-viewed" > "$OUTPUT_CSV"
awk -F, '{count[$2]++; if (!max[$2] || max[$2] < $1) max[$2] = $1} END {for (id in count) print id "," count[id] "," max[id]}' "$TEMP_FILE" | \
sort -t, -k2 -nr >> "$OUTPUT_CSV"

# Remove the temporary file
rm -f "$TEMP_FILE"

echo "CSV generated at $OUTPUT_CSV"
cat "$OUTPUT_CSV"
