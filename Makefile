# -----------------------
#  Compilation options
# -----------------------

RELEASE  := 1
STATIC   := 0

NO_DBG_SYMBOLS := 0

# Enable multi-threading.
# Warning: Experimental feature!!
# invidious is not stable when MT is enabled.
MT := 0

API_ONLY := 1

FLAGS ?=


ifeq ($(RELEASE), 1)
  FLAGS += --release
endif

ifeq ($(STATIC), 1)
  FLAGS += --static
endif

ifeq ($(MT), 1)
  FLAGS += -Dpreview_mt
endif


ifeq ($(NO_DBG_SYMBOLS), 1)
  FLAGS += --no-debug
else
  FLAGS += --debug
endif

ifeq ($(API_ONLY), 1)
  FLAGS += -Dapi_only
endif


# -----------------------
#  Main
# -----------------------

all: invidious

get-libs:
	shards install --production

# TODO: add support for ARM64 via cross-compilation
invidious: get-libs
	crystal build src/invidious.cr $(FLAGS) --progress --stats --error-trace


run: invidious
	./invidious


# -----------------------
#  Development
# -----------------------


format:
	crystal tool format

test:
	crystal spec

verify:
	crystal build src/invidious.cr -Dskip_videojs_download \
	  --no-codegen --progress --stats --error-trace


# -----------------------
#  (Un)Install
# -----------------------

# TODO


# -----------------------
#  Cleaning
# -----------------------

clean:
	rm invidious

distclean: clean
	rm -rf libs
	rm -rf ~/.cache/{crystal,shards}


# -----------------------
#  Help page
# -----------------------

help:
	@echo "このMakefileで利用可能なターゲット:"
	@echo ""
	@echo "  get-libs         Crystalライブラリを取得する"
	@echo "  invidious        Invidious を構築する"
	@echo "  run              Invidiousを起動"
	@echo ""
	@echo "  format           Crystalフォーマッタを実行する"
	@echo "  test             テストを実行する"
	@echo "  verify           コードがコンパイルされるかどうかだけ確認し、"
	@echo "                   バイナリを生成する。エラーを探すのに便利"
	@echo ""
	@echo "  clean            ビルドアーティファクトを削除する"
	@echo "  distclean        ビルド成果物とライブラリを削除する"
	@echo ""
	@echo ""
	@echo "この Makefile で使用できるビルド オプション:"
	@echo ""
	@echo "  RELEASE          リリースビルドを作成する.             (標準: 1)"
	@echo "  STATIC           ライブラリを静的にリンクする           (標準: 0)"
	@echo ""
	@echo "  API_ONLY         GUIなしでInvidiousを構築する        (標準: 0)"
	@echo "  NO_DBG_SYMBOLS   デバッグシンボルを削除する             (標準: 0)"



# No targets generates an output named after themselves
.PHONY: all get-libs build amd64 run
.PHONY: format test verify clean distclean help
