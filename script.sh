GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

FILE_PATH="original_files/file_1.txt"

# FUNÇÕES DE ANIMAÇÃO

spinner() {
	local message="${1:-Processando...}"
	local duration="${2:-2}"
	local spin_chars='|/-\|'
	local delay=0.1

	printf "%s " "$message"

	local start_time=$(date +%s)
	local i=0

	while (( $(date +%s) - start_time < duration )); do
		printf "\r${CYAN}%s %s" "$message" "${spin_chars:i++%${#spin_chars}:1}${RESET}"
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

# FUNÇÕES DE ANIMÇÃO INICIAIS

beginConnection() {
	local pid=$!
	local delay=0.1
	local spin='|/-\'
	while ps -p $pid > /dev/null 2>&1; do
		for i in $(seq 0 3); do
			echo -ne "\r${CYAN}Estabelecendo conexão segura com o ${RESET}${YELLOW}BDE_Missao_Artemis${RESET}${CYAN} ${spin:$i:1}${RESET}"
			sleep $delay
		done
	done
	echo -ne "\r\033[K${GREEN}\u2714 Conexão segura estabelecida com o ${RESET}${YELLOW}BDE_Missao_Artemis${RESET}\n"
}

transferingData() {
	local pid=$!
	local delay=0.1
	local spin='|/-\'
	while ps -p $pid > /dev/null 2>&1; do
		for i in $(seq 0 3); do
			echo -ne "\r${CYAN}Transferindo dados... ${spin:$i:1}${RESET}"
			sleep $delay
		done
	done
	echo -ne "\r\033[K${GREEN}\u2714 Transferência concluída${RESET}\n"
}

processingData() {
	local pid=$!
	local delay=0.1
	local spin='|/-\'
	while ps -p $pid > /dev/null 2>&1; do
		for i in $(seq 0 3); do
			echo -ne "\r${CYAN}Processando dados recebidos... ${spin:$i:1}${RESET}"
			sleep $delay
		done
	done
	echo -ne "\r\033[K${GREEN}\u2714 Processamento concluído${RESET}\n"
}

# SIMULAÇÕES

view_log() {
	echo -e "${CYAN}"
	cat $FILE_PATH
	echo -e "${RESET}"
	echo
}

diagnostico() {
	spinner "Iniciando diagnóstico de integridade..."
	result_wc=$(wc $FILE_PATH)
	type_text "$result_wc"
	echo
}

filter_errors() {
	spinner "Detectando anomalias..."
	spinner "Extraindo logs detectados..."
	result_scan=$(grep -E --color=always -i "erro|alerta|log_corrompido" $FILE_PATH)
	type_text "$result_scan"
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

clear

echo "======================================================"
echo "===== Diagnóstico e Processamento SRDI - v2.13.7 ====="
echo "======================================================"
echo
(sleep 2) & beginConnection
(sleep 2) & transferingData
(sleep 1) & processingData
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
