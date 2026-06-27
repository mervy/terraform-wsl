# Terraforms WSL

Scripts de provisionamento para ambientes WSL — instale só o que precisar, na ordem que quiser.

Estrutura: scripts para **Debian**, **Arch**, **Fedora** e **openSUSE**.

---

## Boas práticas

1. **Execução seletiva:** `sudo ./fedora-php.sh` ou `sudo ./debian-mongodb.sh`
2. **Dependências:** Scripts de DB podem falhar se `curl`/`wget` não existirem. Rode `*-essentials.sh` (ou `debian-base.sh`) primeiro.
3. **Variáveis de ambiente:** Após `node`, `rust` ou `go`, execute `source ~/.bashrc` ou reinicie o terminal.
4. **Idempotência:** Todos usam `2>/dev/null || true` nas configurações de senha para permitir reexecução.
5. **Instalar tudo de uma vez:**
   ```bash
   for f in debian-*.sh; do echo "==> $f"; bash "$f"; done
   ```

---

## Uso rápido — Debian do zero

### 1. Desinstalar instância antiga (se existir)

> Faça backup antes de desinstalar.

```powershell
wsl --unregister Debian
```

### 2. Instalar o Debian oficial

```powershell
wsl --install Debian
```

### 3. Verificar a versão instalada

```bash
sudo apt install lsb-release
lsb_release -a
```

### 4. Ajustar o sources.list

Edite `/etc/apt/sources.list` (exemplo para **Trixie**):

```
deb http://deb.debian.org/debian trixie main contrib non-free
deb http://deb.debian.org/debian trixie-updates main contrib non-free
deb http://security.debian.org/debian-security trixie-security main contrib non-free
deb http://ftp.debian.org/debian trixie-backports main contrib non-free
```

### 5. Copiar os scripts para dentro do WSL

```bash
mkdir -p ~/setup
cp -v /mnt/e/WSL/_Howtos/_terraforms/*.sh ~/setup/
chmod +x ~/setup/*.sh
cd ~/setup
```

### 6. Instalar o que precisar

```bash
./debian-base.sh          # sempre primeiro
./debian-git.sh
./debian-php.sh
./debian-nginx.sh
./node.sh                 # Node.js — funciona em qualquer distro
./debian-python.sh
./rust.sh                 # Rust — funciona em qualquer distro
./go.sh                   # Go — funciona em qualquer distro
./debian-mariadb.sh
./debian-postgres.sh
./debian-mongodb.sh
./debian-sqlite.sh
./debian-mysql.sh
./debian-docker.sh        # opcional
./debian-vps.sh           # VPS/server — hardening + monitoramento
```

---

## Scripts agnósticos de distro

| Script | O que instala |
|---|---|
| `rust.sh` | Rust via rustup + clippy, rustfmt, rust-analyzer (qualquer distro) |
| `node.sh` | Node.js via nvm + pacotes globais (qualquer distro) |
| `go.sh` | Go (última versão via download oficial — qualquer distro) |

---

## Scripts Debian disponíveis

| Script | O que instala |
|---|---|
| `debian-base.sh` | Utilitários base — **rode sempre primeiro** |
| `debian-git.sh` | Git (compilado da fonte) + GitHub CLI |
| `debian-php.sh` | PHP (última versão via Sury) + Composer + Xdebug |
| `debian-nginx.sh` | Nginx via repo oficial (remove Apache se presente) |
| `debian-python.sh` | Python via pyenv + poetry, black, ruff |
| `debian-mariadb.sh` | MariaDB via repo oficial — gera senha root |
| `debian-postgres.sh` | PostgreSQL via repo oficial — gera senha |
| `debian-mongodb.sh` | MongoDB 8.x via repo oficial + usuário admin |
| `debian-sqlite.sh` | SQLite3 |
| `debian-mysql.sh` | MySQL 9.x |
| `debian-docker.sh` | Docker Engine |
| `debian-vps.sh` | Hardening VPS: UFW, fail2ban, sysctl, Cockpit, monitoramento |

---

## Scripts multi-distro

A estrutura se repete para Arch, Fedora e openSUSE (`arch-*`, `fedora-*`, `opensuse-*`).
Para Rust, Node.js e Go use os scripts agnósticos `rust.sh`, `node.sh`, `go.sh`.

| Script | O que instala |
|---|---|
| `*-essentials.sh` | Pacotes base |
| `*-nginx.sh` | Nginx |
| `*-php.sh` | PHP |
| `*-python.sh` | Python via pyenv |
| `*-mysql.sh` | MySQL |
| `*-postgres.sh` | PostgreSQL |
| `*-mongodb.sh` | MongoDB |
| `*-vps.sh` | Hardening VPS: firewall, fail2ban, SSH, monitoramento |

---

## Monitoramento e logs

```bash
# Processos e recursos
btop
glances
htop

# Espaço em disco
df -h
ncdu                              # navegação interativa por pastas

# Portas abertas
sudo ss -tulnp

# Tráfego de rede
sudo nethogs                      # consumo por processo
sudo iftop                        # tráfego por conexão

# Logs em tempo real
journalctl -f                     # sistema completo
journalctl -u nginx -f            # só o Nginx
journalctl -u mariadb -f          # só o MariaDB
tail -f /var/log/auth.log         # tentativas de login SSH

# Verificar IPs banidos pelo fail2ban
fail2ban-client status sshd
```

---

## Backup e restauração

### Exportar (backup)

```powershell
# Parar a distro antes
wsl --terminate Debian

# Exportar para arquivo .tar
wsl --export Debian "E:\Backups\debian-zero.tar"

# Com data no nome (recomendado)
wsl --export Debian "E:\Backups\debian-$(Get-Date -Format 'yyyy-MM-dd').tar"
```

### Importar (restaurar)

Script interativo — aceita `.tar`, `.tar.gz` ou `.zip`:

```powershell
# Salve com esse nome: import-wsl.ps1
$distroName  = Read-Host "Nome da distro (ex: Debian)"
$installPath = Read-Host "Pasta de instalação (ex: E:\WSL\Debian)"
$zipPath     = Read-Host "Caminho do arquivo .zip, .tar ou .tar.gz (ex: E:\WSL\Debian\debian-zero.zip)"

if (-not (Test-Path $zipPath)) {
    Write-Error "Arquivo não encontrado: $zipPath"
    exit 1
}

if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
    Write-Host "Pasta criada: $installPath"
}

$tarPath = $zipPath
if ($zipPath -like "*.zip") {
    $extractDir = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
    New-Item -ItemType Directory -Path $extractDir | Out-Null
    Write-Host "`nExtraindo .zip..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $extractDir
    $tarPath = Get-ChildItem -Path $extractDir -Filter "*.tar" -Recurse | Select-Object -First 1 -ExpandProperty FullName
    if (-not $tarPath) {
        Write-Error "Nenhum .tar encontrado dentro do .zip."
        exit 1
    }
}

Write-Host "`nImportando '$distroName'..." -ForegroundColor Cyan
wsl --import $distroName $installPath $tarPath

if ($zipPath -like "*.zip") {
    Remove-Item -Recurse -Force $extractDir
}

Write-Host "`nConcluído! Para abrir:" -ForegroundColor Green
Write-Host "  wsl -d $distroName"
```

Ou o comando direto:

```powershell
wsl --import Debian "E:\WSL\Debian" "E:\Backups\debian-zero.tar"
```

| Parâmetro | Descrição |
|---|---|
| `Debian` | Nome da distro no WSL |
| `E:\WSL\Debian` | Pasta onde o disco virtual (`.vhdx`) será criado |
| `E:\Backups\debian-zero.tar` | Arquivo de backup gerado na exportação |

### Definir usuário padrão após importação

```bash
# Dentro do Debian
echo "[user]
default=seu_usuario" | sudo tee -a /etc/wsl.conf
```

```powershell
wsl --terminate Debian
wsl -d Debian
```

### Listar distros instaladas

```powershell
wsl --list --verbose
```

### Remover uma distro

```powershell
wsl --unregister Debian
```

> **Atenção:** `--unregister` apaga todos os dados da distro. Faça backup antes com `--export`.
