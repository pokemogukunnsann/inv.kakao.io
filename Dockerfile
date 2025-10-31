# ステージ 1: ビルド環境 (crystal-alpineで軽量にビルド)
FROM crystallang/crystal:1.8.0-alpine as builder

# ビルドに必要な依存パッケージをインストール
RUN apk add --no-cache build-base git make openssl-dev yaml-dev

WORKDIR /app

# ソースコードをコンテナにコピー
COPY . .

# 依存ライブラリをインストール
RUN shards install --skip-setup

# Invidious 本体をビルド
# 💡 API_ONLY=1を明示的に指定することで、確実にAPI専用ビルドを行います
RUN CRYSTAL_NO_GIT=1 make invidious API_ONLY=1

# ----------------------------------------------------

# ステージ 2: 実行環境 (alpine:latestで最軽量化)
FROM alpine:latest

# 実行時に必要なライブラリをインストール
# Crystal実行に必要な共有ライブラリ (libstdc++, openssl, libyaml)
RUN apk add --no-cache openssl yaml libstdc++ zlib

WORKDIR /app

# ビルドステージから実行ファイルと設定ファイルのみをコピー
COPY --from=builder /app/src/invidious /app/
COPY config.yml /app/config/config.yml

# Invidiousのデフォルトポート
EXPOSE 3000

# サーバー起動コマンド
CMD ["./invidious"]
