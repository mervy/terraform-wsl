# Terraform WSL

Instalação de programas no WSL - Debian, Fedora, Arch e OpenSuse

### 📌 Boas Práticas de Uso
1. **Execução seletiva:** `sudo ./fedora-php.sh` ou `sudo ./debian-mongodb.sh`
2. **Dependências cruzadas:** Scripts de DB podem falhar se `curl`/`wget` não existirem. Rode `*-essentials.sh` primeiro ou adapte conforme necessidade.
3. **Variáveis de ambiente:** Após scripts de `node`, `rust` ou `go`, execute `source ~/.bashrc` ou reinicie o terminal.
4. **Idempotência:** Todos usam `2>/dev/null || true` nas configurações de senha e `initdb` para permitir reexecução sem quebrar.
5. **Arquivar:** Você pode organizar tudo em `/opt/setup-scripts/` e criar um `run-all.sh` com `bash /opt/setup-scripts/fedora-*.sh` se quiser instalar tudo de uma vez.

São **40 scripts `.sh`** (10 por distribuição).

A estrutura se repete para cada distro (`fedora-*`, `arch-*`, `opensuse-*`, `debian-*`):
1. `essentials.sh`
2. `nginx.sh`
3. `node-nvm.sh`
4. `php.sh`
5. `rust.sh`
6. `go.sh`
7. `python.sh`
8. `mysql.sh`
9. `postgresql.sh`
10. `mongodb.sh`