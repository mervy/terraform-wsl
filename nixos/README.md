# NixOS — Guia Completo

NixOS é um sistema operacional declarativo e reproduzível. Diferente de outras distros, você **descreve** o estado do sistema em `/etc/nixos/configuration.nix` e o NixOS constrói esse estado. Isso permite rollbacks instantâneos, builds reproduzíveis e zero surpresas.

---

## Conceitos essenciais

| Conceito | Descrição |
|---|---|
| `configuration.nix` | Arquivo único que define TODO o sistema |
| `nixos-rebuild switch` | Aplica as mudanças do configuration.nix |
| `nix profile install` | Instala pacotes para o usuário atual (imperativo) |
| `nix-env` | Gerenciador legado (evite em favor de `nix profile`) |
| `nixpkgs` | Repositório com +100.000 pacotes |
| Flakes | Sistema moderno de gerenciamento de dependências Nix |
| Rollback | Voltar para geração anterior: `nixos-rebuild switch --rollback` |

---

## Parte 1 — NixOS no WSL

### Obtendo o NixOS-WSL

O projeto oficial para NixOS no WSL é mantido pela comunidade:

```
https://github.com/nix-community/NixOS-WSL
```

**Passo a passo:**

1. Acesse a página de releases:
   ```
   https://github.com/nix-community/NixOS-WSL/releases/latest
   ```

2. Baixe o arquivo `nixos-wsl.tar.gz`

3. Importe no WSL (PowerShell):
   ```powershell
   wsl --import NixOS "D:\WSL\NixOS" "C:\Users\SeuUsuario\Downloads\nixos-wsl.tar.gz"
   ```

4. Inicie o NixOS:
   ```powershell
   wsl -d NixOS
   ```

5. Na primeira execução, configure o usuário:
   ```bash
   sudo nixos-rebuild switch
   ```

---

### Configuração inicial após importar

```bash
# Atualiza os canais (repositórios)
sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
sudo nix-channel --update

# Habilita Flakes (recomendado)
sudo tee -a /etc/nixos/configuration.nix <<'EOF'

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
EOF

sudo nixos-rebuild switch
```

---

### Exportar e importar instâncias WSL

**Exportar (backup):**
```powershell
# Para a distro antes de exportar
wsl --terminate NixOS

# Exporta para arquivo .tar
wsl --export NixOS "E:\Backups\nixos-backup.tar"

# Com data no nome
wsl --export NixOS "E:\Backups\nixos-$(Get-Date -Format 'yyyy-MM-dd').tar"
```

**Importar (restaurar ou clonar para teste):**
```powershell
# Restaurar
wsl --import NixOS "D:\WSL\NixOS" "E:\Backups\nixos-backup.tar"

# Clonar para ambiente de teste
wsl --import NixOSTeste "D:\WSL\NixOSTeste" "E:\Backups\nixos-backup.tar"

# Entrar na instância de teste
wsl -d NixOSTeste

# Remover quando terminar
wsl --unregister NixOSTeste
```

**Definir usuário padrão após importação:**
```bash
# Dentro do NixOS
sudo tee -a /etc/nixos/configuration.nix <<'EOF'

  users.users.mervy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
EOF

sudo nixos-rebuild switch
```

---

## Parte 2 — Gerenciamento de pacotes

### Buscar pacotes

```bash
# Buscar pacote
nix search nixpkgs nginx

# Ver informações de um pacote
nix show-derivation nixpkgs#nginx
```

### Instalar pacotes (usuário atual)

```bash
# Instalar
nix profile install nixpkgs#nginx

# Listar instalados
nix profile list

# Remover
nix profile remove nginx
```

### Instalar pacotes (sistema inteiro via configuration.nix)

Edite `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    vim
    htop
    nginx
  ];
}
```

Aplique:
```bash
sudo nixos-rebuild switch
```

---

### Habilitar serviços

Tudo é declarativo. Exemplo completo:

```nix
{ config, pkgs, ... }:
{
  # Nginx
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
  };

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };

  # MySQL
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
  };

  # MongoDB (requer allowUnfree)
  nixpkgs.config.allowUnfree = true;
  services.mongodb.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
  };
}
```

Após editar:
```bash
sudo nixos-rebuild switch
```

---

### Rollback (desfazer mudanças)

```bash
# Voltar para a geração anterior
sudo nixos-rebuild switch --rollback

# Ver todas as gerações disponíveis
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Voltar para uma geração específica
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

---

### Atualizar o sistema

```bash
# Atualiza os canais
sudo nix-channel --update

# Aplica atualizações
sudo nixos-rebuild switch

# Atualizar + limpar gerações antigas (libera espaço)
sudo nixos-rebuild switch
sudo nix-collect-garbage -d
```

---

## Parte 3 — Usando os scripts deste repositório

Os scripts da pasta `nixos/` adaptam a instalação para o paradigma declarativo do NixOS:

```bash
# Copia os scripts para dentro do WSL
cp /mnt/e/WSL/_terraforms/nixos/*.sh ~/setup/
chmod +x ~/setup/*.sh

# Ordem recomendada
sudo ~/setup/nixos-essentials.sh
sudo ~/setup/nixos-nginx.sh
sudo ~/setup/nixos-php.sh
sudo ~/setup/nixos-python.sh
sudo ~/setup/nixos-postgres.sh
sudo ~/setup/nixos-mysql.sh
sudo ~/setup/nixos-mongodb.sh
sudo ~/setup/nixos-vps.sh    # apenas para VPS/servidor
```

> **Nota:** Rust, Node.js e Go use os scripts universais da raiz do repositório:
> ```bash
> bash /mnt/e/WSL/_terraforms/rust.sh
> bash /mnt/e/WSL/_terraforms/node.sh
> bash /mnt/e/WSL/_terraforms/go.sh
> ```

---

## Parte 4 — Dual Boot: Windows 11 + NixOS (instalação nativa)

> Esta seção cobre instalação nativa em dual boot — não WSL.

### Pré-requisitos

- Windows 11 já instalado em modo UEFI (não Legacy BIOS)
- Pelo menos **50 GB livres** para NixOS (recomendado: 100 GB+)
- Pendrive USB de 8 GB+
- Backup completo dos seus dados

---

### Passo 1 — Criar espaço para o NixOS

No Windows, pressione `Win + X` → **Gerenciamento de Disco**:

1. Clique com botão direito na partição Windows (C:)
2. Selecione **Diminuir Volume**
3. Defina o espaço a liberar (ex: 100.000 MB = ~100 GB)
4. Confirme — o espaço não alocado aparecerá ao lado

---

### Passo 2 — Desabilitar Fast Startup e Secure Boot

**Fast Startup (Windows):**
```
Painel de Controle → Opções de Energia
→ Escolher a função dos botões de energia
→ Desativar "Inicialização Rápida"
```

**Secure Boot (BIOS/UEFI):**
- Reinicie e entre na BIOS (Del, F2, F12 — depende do fabricante)
- Procure `Secure Boot` e **desabilite**
- Salve e reinicie

---

### Passo 3 — Criar pendrive bootável

Baixe a ISO do NixOS:
```
https://nixos.org/download/
```
Escolha: **NixOS Graphical ISO** (GNOME ou KDE, 64-bit)

Grave no pendrive:
- **Windows:** use [Rufus](https://rufus.ie) ou [Ventoy](https://www.ventoy.net)
- **Linux:** `sudo dd if=nixos.iso of=/dev/sdX bs=4M status=progress`

---

### Passo 4 — Boot pelo pendrive

1. Reinicie com o pendrive conectado
2. Entre no boot menu (F12, F8, Esc — depende da placa)
3. Selecione o pendrive
4. Escolha **NixOS Installer**

---

### Passo 5 — Instalação via Calamares (modo gráfico)

O instalador gráfico do NixOS (Calamares) é o mais simples:

1. Selecione idioma: **Português (Brasil)**
2. Fuso horário: **America/Sao_Paulo**
3. Teclado: **Portuguese (Brazil)**
4. **Particionamento:**
   - Escolha **Particionamento manual**
   - No espaço não alocado criado no Passo 1, crie:
     - `/boot/efi` — 512 MB — FAT32 — **use a partição EFI existente do Windows, não crie uma nova!**
     - `swap` — 2x a RAM (ou 8 GB) — swap
     - `/` (root) — resto do espaço — ext4 ou btrfs
   - **Não formate a partição EFI do Windows!** Só monte-a.
5. Crie seu usuário e senha
6. Clique em **Instalar**

---

### Passo 6 — Configurar bootloader após instalação

O NixOS instala o **systemd-boot** por padrão em UEFI, que detecta automaticamente o Windows. Ao reiniciar você verá o menu com as duas opções.

Se o Windows não aparecer:
```bash
# Dentro do NixOS instalado
sudo bootctl update

# Verifique as entradas
bootctl list
```

Se usar GRUB (alternativa):
```nix
# /etc/nixos/configuration.nix
boot.loader.grub = {
  enable = true;
  device = "nodev";
  efiSupport = true;
  useOSProber = true;  # detecta Windows automaticamente
};
```
```bash
sudo nixos-rebuild switch
```

---

### Passo 7 — Primeira configuração do NixOS nativo

```bash
# Atualiza canais
sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
sudo nix-channel --update
sudo nixos-rebuild switch

# Habilita flakes
sudo nano /etc/nixos/configuration.nix
# Adicione dentro do bloco:
#   nix.settings.experimental-features = [ "nix-command" "flakes" ];

sudo nixos-rebuild switch
```

---

### Dicas pós dual boot

```bash
# Ver qual geração está ativa
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Limpar gerações antigas (libera espaço do /nix/store)
sudo nix-collect-garbage -d
sudo nixos-rebuild boot  # atualiza o bootloader

# Voltar pro Windows: basta selecionar no menu do bootloader
```

**Para acessar arquivos do Windows dentro do NixOS:**
```bash
# A partição Windows fica em /dev/sdaX
sudo mkdir -p /mnt/windows
sudo mount /dev/sda3 /mnt/windows   # ajuste o número da partição
ls /mnt/windows
```

**Para acessar arquivos do NixOS dentro do Windows:**
- Instale o [Ext2Fsd](https://sourceforge.net/projects/ext2fsd/) ou
- Use o WSL: `\\wsl$\NixOS\` no Explorer (se tiver NixOS no WSL também)

---

## Referências

- Documentação oficial: https://nixos.org/manual/nixos/stable/
- Pacotes disponíveis: https://search.nixos.org/packages
- Opções de configuração: https://search.nixos.org/options
- NixOS-WSL: https://github.com/nix-community/NixOS-WSL
- NixOS Wiki: https://nixos.wiki
