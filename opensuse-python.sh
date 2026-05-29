#!/bin/bash
set -e
echo "=== Instalando Python 3.13 via pyenv no openSUSE ==="
zypper install -y gcc make zlib-devel bzip2-devel readline-devel sqlite3-devel openssl-devel tk-devel libffi-devel xz-devel
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
pyenv install 3.13.0
pyenv global 3.13.0
echo "Python: $(python --version)"