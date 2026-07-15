#!/bin/bash

# 途中でエラーが発生した場合、スクリプトを即座に終了する
set -e

# root 権限で実行されているか確認
if [ "$EUID" -ne 0 ]; then
  echo "エラー: このスクリプトは root 権限で実行してください。" >&2
  exit 1
fi

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

# echo "AlmaLinux をアップデート..."
# dnf update -y
# dnf upgrade -y

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

echo "git をインストール中..."
dnf install -y git
git --version
