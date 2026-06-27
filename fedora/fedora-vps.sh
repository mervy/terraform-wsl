#!/usr/bin/env bash
# fedora-vps.sh — Hardening e monitoramento para VPS Fedora
set -e

# ============================================================
# CONFIGURAÇÕES — ajuste antes de rodar
# ============================================================
NEW_SSH_PORT=2222
ADMIN_USER="mervy"
ALERT_EMAIL=""

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

if [[ $EUID -ne 0 ]]; then
  error "Rode como root: sudo ./fedora-vps.sh"
fi

# ============================================================
# 1. ATUALIZA O SISTEMA
# ============================================================
info "Atualizando o sistema..."
dnf upgrade -y --refresh
dnf autoremove -y

# ============================================================
# 2. FERRAMENTAS DE MONITORAMENTO
# ============================================================
info "Instalando ferramentas de monitoramento..."
dnf install -y btop glances fastfetch htop ncdu nethogs iftop

info "Instalando Cockpit (acesse https://IP:9090)..."
dnf install -y cockpit
systemctl enable --now cockpit.socket

# ============================================================
# 3. FIREWALL (firewalld — padrão no Fedora)
# ============================================================
info "Configurando firewall (firewalld)..."
dnf install -y firewalld
systemctl enable --now firewalld

firewall-cmd --permanent --set-default-zone=drop
firewall-cmd --permanent --add-port=${NEW_SSH_PORT}/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=9090/tcp  # Cockpit
firewall-cmd --reload
firewall-cmd --list-all

# ============================================================
# 4. MUDA PORTA DO SSH
# ============================================================
info "Alterando porta SSH para $NEW_SSH_PORT..."
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%Y%m%d)"

if grep -q "^Port " "$SSHD_CONFIG"; then
  sed -i "s/^Port .*/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
else
  sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" "$SSHD_CONFIG"
fi

# SELinux: libera a nova porta para o SSH
dnf install -y policycoreutils-python-utils 2>/dev/null || dnf install -y policycoreutils-python 2>/dev/null || true
if command -v semanage &>/dev/null; then
  semanage port -a -t ssh_port_t -p tcp "$NEW_SSH_PORT" 2>/dev/null || true
fi

systemctl restart sshd

# ============================================================
# 5. FAIL2BAN
# ============================================================
info "Instalando e configurando fail2ban..."
dnf install -y fail2ban

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
dnf install -y dnf-automatic

sed -i 's/^apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sed -i 's/^emit_via = stdio/emit_via = motd/' /etc/dnf/automatic.conf

systemctl enable --now dnf-automatic.timer

# ============================================================
# 7. LIMITES DE SEGURANÇA DO SISTEMA
# ============================================================
info "Ajustando parâmetros do kernel (sysctl)..."

cat > /etc/sysctl.d/99-hardening.conf <<EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
EOF

sysctl --system > /dev/null

# ============================================================
# RESUMO FINAL
# ============================================================
echo ""
echo "========================================="
echo " VPS Hardening (Fedora) concluído!"
echo "========================================="
echo ""
warning "IMPORTANTE — anote antes de sair:"
echo ""
echo "  Nova porta SSH : $NEW_SSH_PORT"
echo "  Cockpit        : https://$(hostname -I | awk '{print $1}'):9090"
echo "  Firewall       : firewall-cmd --list-all"
echo "  Fail2ban       : fail2ban-client status sshd"
echo "  Monitoramento  : btop  /  glances"
echo ""
warning "Abra um NOVO terminal e teste o SSH antes de fechar esta sessão:"
echo "  ssh -p $NEW_SSH_PORT $ADMIN_USER@$(hostname -I | awk '{print $1}')"
echo ""
echo "========================================="
