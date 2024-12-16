#!/bin/bash

echo "=== Varredura de Serviços Instalados na VPS ==="
echo

# Diretórios padrão do Ubuntu 20.04 (para exclusão da análise)
UBUNTU_DEFAULTS=(
  "/bin" "/boot" "/dev" "/etc" "/home" "/lib" "/lib32" "/lib64" "/libx32"
  "/media" "/mnt" "/opt" "/proc" "/root" "/run" "/sbin" "/srv" "/sys"
  "/tmp" "/usr" "/var" "/swapfile"
)

# Função para verificar se um diretório está nos padrões do Ubuntu
is_default_dir() {
  for dir in "${UBUNTU_DEFAULTS[@]}"; do
    if [[ "$1" == "$dir" ]]; then
      return 0
    fi
  done
  return 1
}

# Função para consultar informações sobre um serviço na internet
check_service_info() {
  local service="$1"
  echo "Consultando informações para o serviço: $service"
  curl -s "https://api.github.com/search/repositories?q=$service" | jq '.items[] | .html_url' | head -n 5
}

# Varredura dos diretórios
echo "Identificando serviços instalados (excluindo arquivos padrão do Ubuntu)..."
SERVICES=()
for dir in /*; do
  if ! is_default_dir "$dir"; then
    SERVICES+=("$dir")
  fi
done

# Exibir resultados preliminares
echo
echo "=== Serviços Identificados ==="
for service in "${SERVICES[@]}"; do
  echo "Possível Serviço: $(basename "$service")"
  check_service_info "$(basename "$service")"
done

# Consulta de portas usadas pelos serviços
echo
echo "=== Portas Usadas pelos Serviços ==="
for service in "${SERVICES[@]}"; do
  echo "Portas usadas pelo serviço $(basename "$service"):"
  sudo lsof -i -nP | grep "$(basename "$service")"
done
