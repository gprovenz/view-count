# View count

A bash script to parse and aggregate view statistics from log files. It extracts view IDs from lines containing `/viewdefinition/view/{ID}`, counts their occurrences, and outputs the results in a CSV file sorted by count in descending order.

## Features

- Processes a single log file or multiple log files using wildcard patterns (e.g., `*.log`).
- Extracts view IDs and counts their occurrences across all matching files.
- Outputs results to a CSV file with headers `View ID` and `Count`.
- Handles input validation, missing files, and cleans up temporary files.

## Requirements

- **Bash** (tested on version 4.0+).
- Utilities used:
  - `grep`
  - `sort`
  - `uniq`
  - `awk`
  - `ls`
  - `mktemp`

## Usage

### Launch it 
```sh count.sh "*.log" output.csv```

### Output
The script generates a CSV file (output.csv) containing view ID statistics sorted by count in descending order, for example:
```
View ID,Count
/viewdefinition/view/32,14
/viewdefinition/view/1110,11
/viewdefinition/view/38,6
/viewdefinition/view/1000,6
/viewdefinition/view/1078,2
/viewdefinition/view/1070,2
```

### Troubleshooting
In case of errors, you can try converting the script file to Unix line endings using the dos2unix command:
```dos2unix count.sh```
