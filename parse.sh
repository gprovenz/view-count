#!/bin/bash

# Ensure correct usage
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input_file_pattern> <output_csv_file>"
    exit 1
fi

INPUT_PATTERN="$1"
OUTPUT_CSV="$2"

# Check if any files match the input pattern
if ! ls $INPUT_PATTERN 1> /dev/null 2>&1; then
    echo "Error: No files matching the pattern '$INPUT_PATTERN' found."
    exit 1
fi

# Create the output CSV with headers
echo "View ID,Date" > "$OUTPUT_CSV"

# Log the files being read
echo "Processing the following files:"
for file in $INPUT_PATTERN; do
    echo "Reading file: $file"

    # Use grep to extract View IDs and Dates efficiently and append them to the CSV
    grep -oP '\[.*?\].*/viewdefinition/view/[0-9]+' "$file" | \
        awk -F'/' '{view_id="viewdefinition/view/"$NF; date=substr($0, index($0, "[")+1, 11); print view_id","date}' \
        >> "$OUTPUT_CSV"
done

echo "Writing output to: $OUTPUT_CSV"

# Print the generated CSV to console
cat "$OUTPUT_CSV"
