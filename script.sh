#!/usr/bin/env bash

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Resolve the log file from the script's own directory, so it can be run from
# anywhere.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
FILE_PATH="$SCRIPT_DIR/original_files/file_1.txt"

SPIN_CHARS='|/-\'

# ANIMATION FUNCTIONS

spinner() {
	local message="${1:-Processing...}"
	local duration="${2:-2}"
	local delay=0.1

	local start_time=$(date +%s)
	local i=0

	while (( $(date +%s) - start_time < duration )); do
		printf "\r${CYAN}%s %s${RESET}" "$message" "${SPIN_CHARS:i++%${#SPIN_CHARS}:1}"
		sleep "$delay"
	done

	printf "\r\033[K${GREEN}%s done!${RESET}\n" "$message"
}

type_text() {
	local text="$1"
	local delay="${2:-0.02}"

	for ((i=0; i<${#text}; i++)); do
		printf "%s" "${text:i:1}"
		sleep "$delay"
	done
	echo
}

# Spins while the given process is still running.
wait_spinner() {
	local message="$1"
	local done_message="$2"
	local pid="$3"
	local delay=0.1
	local i=0

	while ps -p "$pid" > /dev/null 2>&1; do
		printf "\r${CYAN}%s %s${RESET}" "$message" "${SPIN_CHARS:i++%${#SPIN_CHARS}:1}"
		sleep "$delay"
	done

	printf "\r\033[K${GREEN}✔ %s${RESET}\n" "$done_message"
}

# SIMULATIONS

view_log() {
	echo -e "${CYAN}"
	cat "$FILE_PATH"
	echo -e "${RESET}"
	echo
}

run_diagnostics() {
	spinner "Running integrity diagnostics..."
	result_wc=$(wc "$FILE_PATH")
	# Show the relative path instead of the absolute one.
	result_wc="${result_wc/$SCRIPT_DIR\//}"
	type_text "$result_wc"
	echo
}

filter_errors() {
	spinner "Detecting anomalies..."
	spinner "Extracting matching entries..."

	local result_scan
	result_scan=$(grep -E --color=always -i "error|alert|corrupted_log" "$FILE_PATH")

	if [[ -z "$result_scan" ]]; then
		echo "${GREEN}No anomalies detected.${RESET}"
	else
		type_text "$result_scan"
	fi
	echo
}

close_sdps() {
	echo -e "${CYAN}"
	spinner "Closing link..."
	echo "SDPS system shut down"
	echo -e "${RESET}"
	echo
}

##############################################################
# SCRIPT
##############################################################

if [[ ! -f "$FILE_PATH" ]]; then
	echo "${RED}Log file not found: ${FILE_PATH}${RESET}" >&2
	exit 1
fi

clear

echo "======================================================"
echo "====== SDPS Diagnostics and Processing - v2.13.7 ====="
echo "======================================================"
echo
(sleep 2) & wait_spinner \
	"Opening secure link to ${RESET}${YELLOW}BDE_Mission_Artemis${RESET}${CYAN}" \
	"Secure link established with ${RESET}${YELLOW}BDE_Mission_Artemis" $!
(sleep 2) & wait_spinner "Transferring data..." "Transfer complete" $!
(sleep 1) & wait_spinner "Processing received data..." "Processing complete" $!
echo

PS3="${YELLOW}➡ Choose an option: ${RESET}"
options=("View logs" "Diagnostics" "Detect errors and anomalies" "Exit")

select opt in "${options[@]}"; do
	case $opt in
		"View logs")
			echo
			view_log
			;;
		"Diagnostics")
			echo
			run_diagnostics
			;;
		"Detect errors and anomalies")
			echo
			filter_errors
			;;
		"Exit")
			echo
			close_sdps
			break
			;;
		*)
			echo
			echo "Invalid option. Try again."
			;;
	esac
done
