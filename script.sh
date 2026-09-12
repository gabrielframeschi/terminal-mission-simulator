#!/usr/bin/env bash

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Resolve o log a partir da pasta do próprio script, para que ele possa ser
# executado de qualquer diretório.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
FILE_PATH="$SCRIPT_DIR/original_files/file_1.txt"

SPIN_CHARS='|/-\'

# FUNÇÕES DE ANIMAÇÃO

spinner() {
	local message="${1:-Processando...}"
	local duration="${2:-2}"
	local delay=0.1

	local start_time=$(date +%s)
	local i=0

	while (( $(date +%s) - start_time < duration )); do
		printf "\r${CYAN}%s %s${RESET}" "$message" "${SPIN_CHARS:i++%${#SPIN_CHARS}:1}"
		sleep "$delay"
	done

	printf "\r\033[K${GREEN}%s concluído!${RESET}\n" "$message"
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

# Gira o spinner enquanto o processo informado estiver em execução.
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

# SIMULAÇÕES

view_log() {
	echo -e "${CYAN}"
	cat "$FILE_PATH"
	echo -e "${RESET}"
	echo
}

diagnostico() {
	spinner "Iniciando diagnóstico de integridade..."
	result_wc=$(wc "$FILE_PATH")
	# Exibe o caminho relativo em vez do absoluto.
	result_wc="${result_wc/$SCRIPT_DIR\//}"
	type_text "$result_wc"
	echo
}

filter_errors() {
	spinner "Detectando anomalias..."
	spinner "Extraindo logs detectados..."

	local result_scan
	result_scan=$(grep -E --color=always -i "erro|alerta|log_corrompido" "$FILE_PATH")

	if [[ -z "$result_scan" ]]; then
		echo "${GREEN}Nenhuma anomalia detectada.${RESET}"
	else
		type_text "$result_scan"
	fi
	echo
}

fechar_srdi() {
	echo -e "${CYAN}"
	spinner "Encerrando comunicação..."
	echo "Sistema SRDI finalizado"
	echo -e "${RESET}"
	echo
}

##############################################################
# SCRIPT
##############################################################

if [[ ! -f "$FILE_PATH" ]]; then
	echo "${RED}Arquivo de logs não encontrado: ${FILE_PATH}${RESET}" >&2
	exit 1
fi

clear

echo "======================================================"
echo "===== Diagnóstico e Processamento SRDI - v2.13.7 ====="
echo "======================================================"
echo
(sleep 2) & wait_spinner \
	"Estabelecendo conexão segura com o ${RESET}${YELLOW}BDE_Missao_Artemis${RESET}${CYAN}" \
	"Conexão segura estabelecida com o ${RESET}${YELLOW}BDE_Missao_Artemis" $!
(sleep 2) & wait_spinner "Transferindo dados..." "Transferência concluída" $!
(sleep 1) & wait_spinner "Processando dados recebidos..." "Processamento concluído" $!
echo

PS3="${YELLOW}➡ Escolha uma opção: ${RESET}"
options=("Visualizar logs" "Diagnóstico" "Detectar erros e anomalias" "Sair")

select opt in "${options[@]}"; do
	case $opt in
		"Visualizar logs")
			echo
			view_log
			;;
		"Diagnóstico")
			echo
			diagnostico
			;;
		"Detectar erros e anomalias")
			echo
			filter_errors
			;;
		"Sair")
			echo
			fechar_srdi
			break
			;;
		*)
			echo
			echo "Opção inválida. Tente novamente."
			;;
	esac
done
