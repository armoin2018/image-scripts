#!/bin/bash

# Default values
input=""
from_color=""
to_color=""
skip_missing="FALSE"
recursive="FALSE"
replaceFile="FALSE"

# Function to display script usage
function usage() {

    # Parse the current script and replace special symbols with comment markers
    echo "Usage: $0 -input=<file> -fromColor=<color> -toColor=<color> -skipMissing -recursive"

    awk '/^#~/{gsub(/^#~/,"");print}' "$0"
    exit 1
}


# Function to process a single SVG file
function process_file () {
    local _file="$1"
    local _output="$2"
    
    # Replace or add the fill color
    if [ -f "${_output}" ]; then
        if [ "${replaceFile}" == "FALSE" ]; then
            echo "Skipping ${_output}"
            return
        else 
            rm "${_output}"
        fi
    fi
    echo "Processing ${_file}"
    if [ ! -d $(dirname "${_output}") ]; then
        mkdir -p $(dirname "${_output}")
    fi
    
    if [ "${from_color}" != "" ]; then
        cat "${_file}" | sed -re "s|fill=\"${from_color}\"|fill=\"${to_color}\"|g" > "${_output}"
    fi
    if [ "${skip_missing}" == "FALSE" ] && ! grep -q "fill" "${_file}"; then
        cat "${_file}" | sed -re "s|<path d|<path fill=\"${to_color}\" d|g" > "${_output}"
    fi
}

# Parse command-line arguments
for arg in "$@"; do
    case $arg in
        #~      -input         : Input file or folder
        -input=*)
            input="${arg#*=}"
            ;;
        #~      -fromColor     : Color to replace (default: black)
        -fromColor=*)
            from_color="${arg#*=}"
            ;;
        #~      -toColor       : Color to set
        -toColor=*)
            to_color="${arg#*=}"
            ;;
        #~      -skipMissing   : Skip files that don't have a fill color (optional)
        -skipMissing)
            skip_missing="TRUE"
            ;;
        #~      -replaceFile   : Replace if the file exists, otherwise it will be skipped (optional)
        -replaceFile)
            replaceFile="TRUE"
            ;;
        #~      -recursive     : Recursively process SVG files (optional, requires -outputFolder)
        -recursive)
            recursive="TRUE"
            ;;
        *)
            echo "Unknown argument: $arg"
            usage
            ;;
    esac
done

# Check if required arguments are missing
if [ -z "$to_color" ]; then
    echo "Missing required argument: -toColor"
    usage
fi



depth="-depth 1"
if [ "${recursive}" == "TRUE" ]; then
    depth=""
fi


if [ -f "${input}" ]; then
    input_folder=$(dirname "$input")
    declare -a find_results=( "${input}" )
else
    input_folder="${input}"
    find_results=$(find ${input_folder} ${depth} -name "*.svg" -not -path "${input_folder}/output/*" )
fi
repl_folder=`echo "${input_folder}/output" | sed -re 's|/|\/|g'`
    
for file in ${find_results}; do
    __file=`echo "${file}" | sed -re "s|/./|/|"`
    output=`echo "${__file}" | sed -re "s|${input_folder}|${repl_folder}|"`
    process_file "${file}" "${output}"
done

echo "Done"