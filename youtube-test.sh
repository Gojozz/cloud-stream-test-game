#!/data/data/com.termux/files/usr/bin/bash

echo "=== YouTube RTMPS Test ==="
read -rsp "Masukkan YouTube Stream Key: " STREAM_KEY
echo
echo

SERVER="rtmps://a.rtmps.youtube.com/live2"

echo "Memulai stream..."
echo "Durasi: 60 detik"
echo

ffmpeg \
  -hide_banner \
  -loglevel info \
  -re \
  -f lavfi \
  -i "color=c=black:s=1280x720:r=30" \
  -f lavfi \
  -i "anullsrc=channel_layout=stereo:sample_rate=44100" \
  -t 60 \
  -c:v libx264 \
  -preset ultrafast \
  -tune zerolatency \
  -b:v 4000k \
  -minrate 4000k \
  -maxrate 4000k \
  -bufsize 8000k \
  -pix_fmt yuv420p \
  -g 60 \
  -keyint_min 60 \
  -sc_threshold 0 \
  -c:a aac \
  -b:a 128k \
  -ar 44100 \
  -ac 2 \
  -f flv \
  "${SERVER}/${STREAM_KEY}"

RESULT=$?

unset STREAM_KEY

echo
echo "FFmpeg selesai dengan kode: $RESULT"
