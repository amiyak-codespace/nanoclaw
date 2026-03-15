#!/bin/bash
CONTAINER_NAME="nanoclaw"
IMAGE_NAME="nanoclaw-agent"

echo "Cleaning up old containers..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

echo "Building and Launching..."
cd /Users/amiyakumar.m/Ws/ai-space/nanoclaw
docker build -t $IMAGE_NAME .
docker run -d \
  --name $CONTAINER_NAME \
  -e WHATSAPP_ENABLED=true \
  -e GOOGLE_API_KEY="AIzaSyCkEVSGkfAYnKXJzksHSn1RHafN1xZRRAo" \
  -v "/Users/amiyakumar.m/Ws/ai-space/ai-engineer:/app/workspace" \
  -p 18789:18789 \
  --restart unless-stopped \
  $IMAGE_NAME

echo "-------------------------------------------------------"
echo "WAITING FOR WHATSAPP QR CODE..."
echo "-------------------------------------------------------"
sleep 10
docker logs $CONTAINER_NAME | grep -A 20 "QR" || docker logs $CONTAINER_NAME
