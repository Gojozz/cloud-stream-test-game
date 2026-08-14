#!/data/data/com.termux/files/usr/bin/bash

STREAM_KEY="vtvh-59y0-advx-cyqx-8jxk"

ffmpeg \
  -hide_banner \
  -loglevel info \
  -re \
  -f lavfi \
  -i "testsrc2=size=1280x720:rate=30" \
  -f lavfi \
  -i "sine=frequency=1000:sample_rate=44100" \
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
  "rtmps://a.rtmps.youtube.com/live2/${STREAM_KEY}"
