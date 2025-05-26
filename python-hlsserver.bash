#!/bin/bash

# 入力ファイル
INPUT_FILE="test.mp4"
# 入力ファイル名をベースにした出力ディレクトリ名（拡張子を除いた部分）
BASENAME=$(basename "$INPUT_FILE" .mp4)
OUTPUT_DIR="./${BASENAME}_hls"

# ポート番号の設定（引数で指定、未指定ならデフォルト8080）
PORT=${1:-8080}

# HLS用のプレフィックス
HLS_PREFIX="http://10.0.0.1:${PORT}"

# すでに出力ディレクトリが存在するかチェック
if [ -d "$OUTPUT_DIR" ]; then
    echo "Directory $OUTPUT_DIR already exists. Skipping HLS generation and serving existing files."
else
    # 出力ディレクトリの作成と初期化
    mkdir -p "$OUTPUT_DIR"

    # 各ビットレートの設定（解像度とビットレート）
    VARIANTS=(
        "1280x720 3000k"
        "854x480 1500k"
        "640x360 800k"
        "426x240 400k"
    )

    # FFmpegで各ビットレートのHLSストリームを生成
    for variant in "${VARIANTS[@]}"; do
        IFS=' ' read -r RESOLUTION BITRATE <<< "$variant"
        OUTPUT_PATH="$OUTPUT_DIR/${RESOLUTION}_output.m3u8"

        ffmpeg -i "$INPUT_FILE" -vf "scale=${RESOLUTION}" -c:v h264 -b:v "$BITRATE" -c:a aac -ar 48000 -ac 2 \
               -hls_time 10 -hls_list_size 0 -hls_segment_filename "$OUTPUT_DIR/${RESOLUTION}_%03d.ts" \
               -f hls "$OUTPUT_PATH"
    done

    # マスタープレイリストを作成
    MASTER_PLAYLIST="$OUTPUT_DIR/master.m3u8"
    echo "#EXTM3U" > "$MASTER_PLAYLIST"
    for variant in "${VARIANTS[@]}"; do
        IFS=' ' read -r RESOLUTION BITRATE <<< "$variant"
        echo "#EXT-X-STREAM-INF:BANDWIDTH=$((${BITRATE%k} * 1000)),RESOLUTION=$RESOLUTION" >> "$MASTER_PLAYLIST"
        echo "$HLS_PREFIX/${RESOLUTION}_output.m3u8" >> "$MASTER_PLAYLIST"
    done
fi

# HLSサーバーを起動
echo "Starting HTTP server on port ${PORT}..."
python3 -m http.server --directory "$OUTPUT_DIR" "$PORT"
