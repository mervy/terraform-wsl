#!/usr/bin/env bash
# debian-hardening.sh — Segurança e monitoramento para VPS Debian
set -e
export DEBIAN_FRONTEND=noninteractive

# ============================================================
# CONFIGURAÇÕES — ajuste antes de rodar
# ============================================================
NEW_SSH_PORT=2222          # Nova porta SSH (mude para a sua preferida)
ADMIN_USER="mervy"         # Usuário admin que pode usar sudo
ALERT_EMAIL="webdesigner@gkult.net"             # Email para alertas do fail2ban (opcional)

# ============================================================
# CORES
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}==>${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ============================================================
# ROOT CHECK
# ============================================================
if [[ $EUID -ne 0 ]]; then
  error "Rode como root: sudo ./debian-vps.sh"
fi

# ============================================================
# 1. ATUALIZA O SISTEMA
# ============================================================
info "Atualizando o sistema..."
apt update && apt upgrade -y
apt autoremove -y

# ============================================================
# 2. FERRAMENTAS DE MONITORAMENTO
# ============================================================
info "Instalando ferramentas de monitoramento..."
apt install -y btop glances cockpit fastfetch htop ncdu nethogs iftop

info "Ativando Cockpit (acesse https://IP:9090)..."
systemctl enable --now cockpit.socket

# ============================================================
# 3. UFW — FIREWALL
# ============================================================
info "Configurando UFW..."
apt install -y ufw

# Reseta regras existentes
ufw --force reset

# Políticas padrão
ufw default deny incoming
ufw default allow outgoing

# Libera serviços essenciais
ufw allow "$NEW_SSH_PORT"/tcp comment 'SSH'
ufw allow 80/tcp   comment 'HTTP'
ufw allow 443/tcp  comment 'HTTPS'
ufw allow 9090/tcp comment 'Cockpit'

# Ativa sem confirmação interativa
ufw --force enable
ufw status verbose

# ============================================================
# 4. MUDA PORTA DO SSH
# ============================================================
info "Alterando porta SSH para $NEW_SSH_PORT..."
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%Y%m%d)"

# Atualiza ou adiciona a porta
if grep -q "^Port " "$SSHD_CONFIG"; then
  sed -i "s/^Port .*/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
else
  sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
fi

# Desativa login root via SSH
# sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
# sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"

# Desativa autenticação por senha (só chave)
# ATENÇÃO: só ative se já tiver sua chave SSH configurada!
# sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG"

systemctl restart sshd

# ============================================================
# 5. FAIL2BAN
# ============================================================
info "Instalando e configurando fail2ban..."
apt install -y fail2ban

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
${ALERT_EMAIL:+destemail = $ALERT_EMAIL}
${ALERT_EMAIL:+action = %(action_mwl)s}

[sshd]
enabled  = true
port     = $NEW_SSH_PORT
logpath  = %(sshd_log)s
backend  = systemd
maxretry = 3
bantime  = 24h
EOF

systemctl enable --now fail2ban
systemctl restart fail2ban

# ============================================================
# 6. ATUALIZAÇÕES AUTOMÁTICAS DE SEGURANÇA
# ============================================================
info "Configurando atualizações automáticas de segurança..."
apt install -y unattended-upgrades apt-listchanges

cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

systemctl enable --now unattended-upgrades

# ============================================================
# 7. LIMITES DE SEGURANÇA DO SISTEMA
# ============================================================
info "Ajustando parâmetros do kernel (sysctl)..."

cat > /etc/sysctl.d/99-hardening.conf <<EOF
# Proteção contra SYN flood
net.ipv4.tcp_syncookies = 1

# Ignora pings de broadcast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Proteção contra spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Desativa redirecionamentos ICMP
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Desativa source routing
net.ipv4.conf.all.accept_source_route = 0
EOF

sysctl --system > /dev/null

# ============================================================
# RESUMO FINAL
# ============================================================
echo ""
echo "========================================="
echo " VPS Hardening concluído!"
echo "========================================="
echo ""
warning "IMPORTANTE — anote antes de sair:"
echo ""
echo "  Nova porta SSH : $NEW_SSH_PORT"
echo "  Cockpit        : https://$(hostname -I | awk '{print $1}'):9090"
echo "  Firewall       : ufw status verbose"
echo "  Fail2ban       : fail2ban-client status sshd"
echo "  Monitoramento  : btop  /  glances"
echo ""
warning "Abra um NOVO terminal e teste o SSH antes de fechar esta sessão:"
echo "  ssh -p $NEW_SSH_PORT $ADMIN_USER@$(hostname -I | awk '{print $1}')"
echo ""
echo "========================================="