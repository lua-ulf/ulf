#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 --headless -u <init_file> -i <input_file> -o <output_file> -f <flag>"
  exit 1
}

# Initialize variables for arguments
init_file=""
command=""
output_file=""
flag=""

# Parse command-line arguments using getopts
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --headless)
    headless="--headless"
    ;;
  -u)
    init_file="$2"
    shift
    ;;
  -c)
    command="$2"
    shift
    ;;
  -o)
    output_file="$2"
    shift
    ;;
  *)
    usage
    ;;
  esac
  shift
done

# Check that all required arguments are provided
# if [[ -z "$headless" || -z "$init_file" || -z "$input_file" || -z "$output_file" || -z "$flag" ]]; then
#   usage
# fi

# Set the base nvim command
# NVIM_CMD="nvim $headless -n -u $init_file -c \"$command\""
# echo $NVIM_CMD
# $NVIM_CMD

#!/bin/bash

# Parse the input arguments here if necessary...

echo "nvim wrap!"
# Set the base nvim command in an array to preserve quotes
NVIM_CMD=("nvim" "-V50/Users/al/.cache/nvim/ulf-doc.txt" "$headless" "-n" "-u" "$init_file" "-c" "$command")

# Print for debugging purposes (optional)
echo "${NVIM_CMD[@]}"

# Execute the nvim command
"${NVIM_CMD[@]}"

#
# # Execute the nvim command with the parsed arguments
# $NVIM_CMD -c "lua require('ulf.doc.gendocs.backend').runner.vim.callback('$input_file', '$output_file', '$flag')"
