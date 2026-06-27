#!/usr/bin/env bash
# debian-git.sh — Git (compilado da fonte) + GitHub CLI + exemplos de uso
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Instalando dependências de compilação do Git..."
sudo apt update
sudo apt install -y \
  build-essential autoconf libssl-dev libcurl4-openssl-dev \
  libexpat1-dev gettext zlib1g-dev wget tar

echo "==> Buscando a versão mais recente do Git..."
GIT_VERSION=$(wget -qO- https://api.github.com/repos/git/git/tags \
  | grep '"name": "v[0-9]' \
  | head -1 \
  | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')

echo "==> Versão encontrada: $GIT_VERSION"

GIT_TAR="git-${GIT_VERSION}.tar.gz"
GIT_URL="https://mirrors.edge.kernel.org/pub/software/scm/git/${GIT_TAR}"

wget -O "/tmp/${GIT_TAR}" "$GIT_URL"
tar -xf "/tmp/${GIT_TAR}" -C /tmp
cd "/tmp/git-${GIT_VERSION}"

make configure
./configure --prefix=/usr/local
make -j"$(nproc)"
sudo make install

cd /
rm -rf "/tmp/git-${GIT_VERSION}" "/tmp/${GIT_TAR}"

echo "==> Git $(git --version) instalado com sucesso."

echo "==> Adicionando repositório GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list

sudo apt update
sudo apt install -y gh

echo ""
echo "==> Git instalado. Configure com seus dados:"
echo ""
echo "  git config --global user.name  'Seu Nome'"
echo "  git config --global user.email 'voce@email.com'"
echo "  git config --global init.defaultBranch main"
echo "  git config --global core.editor vim"
echo ""
echo "==> GitHub CLI instalado. Autentique com:"
echo ""
echo "  gh auth login"
echo ""
echo "=== Exemplos de uso — Git ==="
echo ""
echo "  # Iniciar repositório"
echo "  git init meu-projeto && cd meu-projeto"
echo ""
echo "  # Clonar projeto"
echo "  git clone https://github.com/usuario/repo.git"
echo ""
echo "  # Fluxo básico"
echo "  git add ."
echo "  git commit -m 'feat: primeiro commit'"
echo "  git push origin main"
echo ""
echo "  # Ver histórico resumido"
echo "  git log --oneline --graph --all"
echo ""
echo "  # Criar e trocar de branch"
echo "  git switch -c minha-feature"
echo ""
echo "=== Exemplos de uso — GitHub CLI ==="
echo ""
echo "  # Criar repositório no GitHub direto do terminal"
echo "  gh repo create meu-projeto --public --source=. --push"
echo ""
echo "  # Abrir PR"
echo "  gh pr create --title 'Minha feature' --body 'Descrição'"
echo ""
echo "  # Ver status dos workflows (Actions)"
echo "  gh run list"
echo ""
echo "  # Clonar repo de outro usuário"
echo "  gh repo clone usuario/repo"
echo ""
echo "========================================="
echo " Git + GitHub CLI prontos!"
echo "========================================="
