#!/bin/bash

# 途中でエラーが発生した場合、スクリプトを即座に終了する
set -e

# root 権限で実行されているか確認
if [ "$EUID" -ne 0 ]; then
  echo "エラー: このスクリプトは root 権限で実行してください。" >&2
  exit 1
fi

UPDATE=false
for arg in "$@"; do
    case "$arg" in
        --update)
            UPDATE=true
            break
            ;;
    esac
done

#####################################################################################

echo "WSL の DNS 設定ファイル (/etc/wsl.conf) の自動生成とドライブの自動マウント無効化中..."
cat << 'EOF' >> /etc/wsl.conf
# DNS の自動生成を無効化
[network]
generateResolvConf = false

# Windows ドライブの自動マウントを無効化
# ※併せて Windows 側の PATH 追加を無効にしないと警告が大量に表示されるので注意
[automount]
enabled = false
mountFsTab = true

# Windows 側の PATH を WSL 側へ追加しない
[interop]
appendWindowsPath = false
EOF

echo "WSL の DNS 設定ファイル (/etc/resolv.conf) を作成中..."
rm -f /etc/resolv.conf
cat << 'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
options timeout:2 attempts:3
EOF

if "$UPDATE"; then
  echo "AlmaLinux をアップデート..."
  dnf update -y
  dnf upgrade -y
fi

echo "日本語言語パックをインストール..."
dnf install -y glibc-langpack-ja

echo "タイムゾーンを Asia/Tokyo に設定..."
timedatectl set-timezone Asia/Tokyo

echo "ロケールを ja_JP.UTF-8 に設定..."
localectl set-locale LANG=ja_JP.UTF-8

echo "ユーザー dev を作成中..."
useradd -m -s /bin/bash dev

# echo "ユーザー dev に sudo 権限を設定中..."
# echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev
# chmod 0440 /etc/sudoers.d/dev

echo "WSL のデフォルトログインユーザーをユーザー dev に設定中..."
cat << 'EOF' >> /etc/wsl.conf
[user]
default=dev
EOF

echo "WSL のデフォルトユーザー作成機能を無効化中..."
sed -i -E 's|^[[:space:]]*command[[:space:]]*=[[:space:]]*/usr/lib/wsl/oobe[[:space:]]*$|# command = /usr/lib/wsl/oobe|' "/etc/wsl-distribution.conf"

echo "一般ユーザーが ping コマンドを使用できるように設定中..."
mkdir -p /etc/sysctl.d
tee /etc/sysctl.d/99-ping.conf >/dev/null <<'EOF'
net.ipv4.ping_group_range = 0 2147483647
EOF
sysctl --system

#####################################################################################

echo "git をインストール中..."
dnf install -y git
git --version

# echo "tmux 3.6b をインストール中..."
# # とほほのtmux入門
# # https://www.tohoho-web.com/ex/tmux.html
# dnf -y install gcc libevent-devel ncurses-devel automake byacc
# (
# cd /tmp
# curl -kLO https://github.com/tmux/tmux/releases/download/3.6b/tmux-3.6b.tar.gz
# tar zxvf ./tmux-3.6b.tar.gz
# cd tmux-3.6b
# ./configure
# make
# make install
# )

# echo "Herdr をインストール中..."
# curl -fsSL https://herdr.dev/install.sh | sh

# echo "Antigravity CLI をインストール中..."
# sudo -iu dev bash -lc '
# PATH="/usr/local/bin:/home/dev/.local/bin:$PATH";
# curl -fsSL https://antigravity.google/cli/install.sh | bash;
# agy --version
# '

# echo "Codex CLI をインストール中..."
# curl -fsSL https://chatgpt.com/codex/install.sh | sh

# echo "pip をインストール中..."
# dnf install -y python3-pip python3-pip-wheel
# python -m pip --version

# echo "spec-kitty-cli をインストール中..."
# python -m pip install spec-kitty-cli
# spec-kitty --version

echo "設定完了"
