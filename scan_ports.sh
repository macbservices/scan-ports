#!/bin/bash

echo "=== Varredura de Portas Abertas e Serviços na VPS ==="
echo

# Verifica se o comando ss está disponível
if ! command -v ss &> /dev/null; then
  echo "O comando 'ss' não está instalado. Por favor, instale-o com:"
  echo "sudo apt install iproute2"
  exit 1
fi

# Cabeçalho da tabela
printf "%-10s %-20s %-20s\n" "PORTA" "ESTADO" "SERVIÇO/PROCESSO"
echo "============================================================"

# Lista todas as portas abertas e os serviços associados
ss -tuln | awk 'NR>1 {print $5 " " $1}' | while read line; do
  # Extrai porta e protocolo
  PORT=$(echo $line | awk -F':' '{print $NF}')
  PROTOCOL=$(echo $line | awk '{print $2}')
  
  # Obtém o nome do processo pelo PID que usa a porta
  SERVICE=$(sudo lsof -i :$PORT -sTCP:LISTEN -nP 2>/dev/null | awk 'NR==2 {print $1}')
  
  # Se não houver um serviço identificado, retorna 'Desconhecido'
  if [ -z "$SERVICE" ]; then
    SERVICE="Desconhecido"
  fi
  
  # Imprime o resultado
  printf "%-10s %-20s %-20s\n" "$PORT/$PROTOCOL" "ABERTA" "$SERVICE"
done
