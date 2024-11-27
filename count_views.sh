#!/bin/bash

# Ensure correct usage
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input_file_pattern> <output_csv_file>"
    exit 1
fi

# Input file pattern (e.g., *.log) and output CSV file
INPUT_PATTERN="$1"
OUTPUT_CSV="$2"

# Check if files matching the pattern exist
if ! ls $INPUT_PATTERN 1> /dev/null 2>&1; then
    echo "Error: No files matching pattern '$INPUT_PATTERN' found."
    exit 1
fi

# Debug: Confirm input pattern and output file
echo "Reading from files matching: $INPUT_PATTERN"
echo "Writing to: $OUTPUT_CSV"

# Temporary file to collect view IDs from all logs
TEMP_FILE=$(mktemp)

# Extract view IDs from all matching files
for file in $INPUT_PATTERN; do
    echo "Processing $file..."
    grep -oP '/viewdefinition/view/[0-9]+' "$file" >> "$TEMP_FILE"
done

# Debug: Ensure temporary file is populated
if [[ ! -s $TEMP_FILE ]]; then
    echo "Error: No matching view IDs found in the files."
    rm -f "$TEMP_FILE"
    exit 1
fi

# Count occurrences and sort by count (descending), then save to the output CSV
echo "View ID,Count" > "$OUTPUT_CSV"
sort "$TEMP_FILE" | uniq -c | sort -r -n | awk '{print $2 "," $1}' >> "$OUTPUT_CSV"

# Clean up temporary file
rm -f "$TEMP_FILE"

echo "View count CSV generated at $OUTPUT_CSV"
cat "$OUTPUT_CSV"
