#!/usr/bin/env bash
# gentoo-vps.sh — Hardening e monitoramento para VPS Gentoo
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

[[ $EUID -ne 0 ]] && error "Rode como root: sudo ./gentoo-vps.sh"

# ============================================================
# 1. ATUALIZA O SISTEMA
# ============================================================
info "Atualizando o sistema..."
emaint sync -a
emerge -uDN --with-bdeps=y @world
emerge --depclean

# ============================================================
# 2. FERRAMENTAS DE MONITORAMENTO
# ============================================================
info "Instalando ferramentas de monitoramento..."
emerge sys-process/btop app-misc/glances sys-process/htop \
       sys-fs/ncdu net-analyzer/nethogs net-analyzer/iftop \
       app-misc/fastfetch

# ============================================================
# 3. FIREWALL (nftables)
# ============================================================
info "Configurando firewall (nftables)..."
emerge net-firewall/nftables

cat > /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iif lo accept
    tcp dport ${NEW_SSH_PORT} accept
    tcp dport { 80, 443 } accept
    icmp type echo-request accept
  }
  chain forward { type filter hook forward priority 0; policy drop; }
  chain output  { type filter hook output  priority 0; policy accept; }
}
EOF

rc-update add nftables default
rc-service nftables start

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

rc-service sshd restart

# ============================================================
# 5. FAIL2BAN
# ============================================================
info "Instalando e configurando fail2ban..."
emerge net-analyzer/fail2ban

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
logpath  = /var/log/auth.log
maxretry = 3
bantime  = 24h
EOF

rc-update add fail2ban default
rc-service fail2ban start

# ============================================================
# 6. LIMITES DE SEGURANÇA DO SISTEMA
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
echo " VPS Hardening (Gentoo) concluído!"
echo "========================================="
echo ""
warning "IMPORTANTE — anote antes de sair:"
echo ""
echo "  Nova porta SSH : $NEW_SSH_PORT"
echo "  Firewall       : nft list ruleset"
echo "  Fail2ban       : fail2ban-client status sshd"
echo "  Monitoramento  : btop  /  glances"
echo ""
warning "Abra um NOVO terminal e teste o SSH antes de fechar esta sessão:"
echo "  ssh -p $NEW_SSH_PORT $ADMIN_USER@$(hostname -I | awk '{print $1}')"
echo ""
echo "========================================="
