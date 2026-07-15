#!/bin/bash

# 途中でエラーが発生した場合、スクリプトを即座に終了する
set -e

# root 権限で実行されているか確認
if [ "$EUID" -ne 0 ]; then
  echo "エラー: このスクリプトは root 権限で実行してください。" >&2
  exit 1
fi

# echo "AlmaLinux をアップデート..."
# dnf update -y
# dnf upgrade -y

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

echo "設定完了"
