#!/bin/bash
# AI Coding Engineer - Absolute Path Execution

echo "🛠️ Starting AI Engineer..."

# 1. Clean up old containers to save RAM
docker compose down 2>/dev/null

# 2. Build and Launch using the direct binary path
# Note: This is the most stable way to run on EC2
docker compose up -d --build

if [ $? -eq 0 ]; then
    echo "✅ Success! Waiting for WhatsApp QR..."
    sleep 8
    docker compose logs -f nanoclaw
else
    echo "❌ Execution failed. Trying with sudo..."
    sudo docker compose up -d --build
    sudo docker compose logs -f nanoclaw
fi
