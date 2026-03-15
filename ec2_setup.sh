#!/bin/bash
set -e

echo "🚀 Starting Full NanoClaw EC2 Setup..."

# 1. Update system and install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "⚠️ Docker installed. You might need to log out and log back in for group changes to take effect."
fi

# Set common variables for EC2 environment
EC2_WORKSPACE="$HOME/ws/ai-space"
mkdir -p "$EC2_WORKSPACE/nanoclaw"

echo "📂 Creating EC2-optimized initialize_project.sh..."
cat << 'EOF' > "$EC2_WORKSPACE/nanoclaw/initialize_project.sh"
#!/bin/bash

# --- CONFIGURATION ---
PROJECT_ROOT="$HOME/ws/ai-space"
ENGINE_DIR="$PROJECT_ROOT/nanoclaw"
WORKSPACE_DIR="$PROJECT_ROOT/ai-engineer"
GEMINI_KEY="AIzaSyCkEVSGkfAYnKXJzksHSn1RHafN1xZRRAo" 

echo "🚀 Starting AI Engineer Environment Setup..."

# 1. Create Directory Structure
mkdir -p $ENGINE_DIR
mkdir -p $WORKSPACE_DIR/{backend,frontend,.agent/spec,.agent/prompts}
mkdir -p $PROJECT_ROOT/nanoclaw_store

# 2. Clone NanoClaw into the engine folder
if [ ! -d "$ENGINE_DIR/.git" ]; then
    echo "📦 Cloning NanoClaw engine..."
    git clone https://github.com/qwibitai/nanoclaw.git $ENGINE_DIR
else
    echo "✅ Engine already exists, skipping clone."
fi

# 3. Create GEMINI.md (The Brain's Rules)
echo "🧠 Creating GEMINI.md persona..."
cat << 'INNER_EOF' > "$WORKSPACE_DIR/GEMINI.md"
# AI Coding Engineer Persona (Gemini 3 Powered)

## Role
You are a Senior Full-Stack Engineer. Your goal is to build, deploy, and maintain web applications on this Ubuntu EC2 instance.

## Technical Preferences
- **Backend:** Node.js (Express), MongoDB or SQLite.
- **Frontend:** React with Tailwind CSS (Vite preferred).
- **Deployment:** Run apps in the background using PM2 or Docker.
- **Ports:** Use 3000 for Frontend, 5000 for Backend.

## Behavior Rules
1. **Autonomy:** If a command requires a new directory or package, create/install it without asking.
2. **Persistence:** Check 'memory.sqlite' before starting a task to see how we did it last time.
3. **Deployment:** After writing code, always attempt to start the server and provide the local URL.
4. **Communication:** Keep WhatsApp replies concise. Send a summary of changes and the URL.
INNER_EOF

# 4. Create the run_engineer.sh inside the engine folder
echo "🛠️ Creating Master Control script..."
cat << 'INNER_EOF' > "$ENGINE_DIR/run_engineer.sh"
#!/bin/bash
CONTAINER_NAME="nanoclaw"

echo "Cleaning up old containers..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

echo "Building NanoClaw Agent Image..."
cd "$HOME/ws/ai-space/nanoclaw"
./container/build.sh

echo "Building and Launching Main Engine..."
docker compose up -d --build

echo "-------------------------------------------------------"
echo "WAITING FOR WHATSAPP QR CODE..."
echo "-------------------------------------------------------"
sleep 10
docker logs $CONTAINER_NAME | grep -A 20 "QR" || docker logs $CONTAINER_NAME
INNER_EOF

# 5. Connect .env 
cat << 'INNER_EOF' > "$ENGINE_DIR/.env"
GOOGLE_API_KEY=AIzaSyCkEVSGkfAYnKXJzksHSn1RHafN1xZRRAo
WHATSAPP_ENABLED=true
TZ=Asia/Kolkata
AGENT_RULES_FILE=/app/workspace/GEMINI.md
INNER_EOF

# 6. Override docker-compose.yml 
cat << 'INNER_EOF' > "$ENGINE_DIR/docker-compose.yml"
services:
  nanoclaw:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nanoclaw
    restart: unless-stopped
    env_file: .env
    volumes:
      - $HOME/ws/ai-space/ai-engineer:/app/workspace
      - $HOME/ws/ai-space/nanoclaw_store:/app/store
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "18789:18789"
    deploy:
      resources:
        limits:
          memory: 2g
INNER_EOF

# 7. Set Permissions
chmod +x "$ENGINE_DIR/run_engineer.sh"

echo "✅ Setup Complete!"
EOF

echo "� Creating EC2-optimized execute_engieer.sh..."
cat << 'EOF' > "$EC2_WORKSPACE/nanoclaw/execute_engieer.sh"
#!/bin/bash
# AI Coding Engineer - EC2 Execution

echo "🛠️ Starting AI Engineer via docker-compose..."

cd "$HOME/ws/ai-space/nanoclaw"

# 1. Clean up old containers to save RAM
docker compose down 2>/dev/null || sudo docker compose down 2>/dev/null

# 2. Build the Agent
./container/build.sh || sudo ./container/build.sh

# 3. Build and Launch the main container
docker compose up -d --build || sudo docker compose up -d --build

if [ $? -eq 0 ]; then
    echo "✅ Success!"
else
    echo "❌ Execution failed."
    exit 1
fi
EOF

chmod +x "$EC2_WORKSPACE/nanoclaw/initialize_project.sh"
chmod +x "$EC2_WORKSPACE/nanoclaw/execute_engieer.sh"

echo "▶️ Executing initialize_project.sh..."
bash "$EC2_WORKSPACE/nanoclaw/initialize_project.sh"

echo "▶️ Executing execute_engieer.sh..."
bash "$EC2_WORKSPACE/nanoclaw/execute_engieer.sh"

# Wait for init
echo "⏳ Waiting 10s for container to initialize..."
sleep 10

# 8. Start WhatsApp Auth Script
echo "📱 Triggering WhatsApp Authentication..."
echo "---------------------------------------------------------"
echo "To link your WhatsApp, we will generate a pairing code for +918599856571."
echo "Running the WhatsApp auth command..."
cd "$EC2_WORKSPACE/nanoclaw"
sudo docker exec nanoclaw npx tsx src/whatsapp-auth.ts --pairing-code --phone 918599856571 || docker exec nanoclaw npx tsx src/whatsapp-auth.ts --pairing-code --phone 918599856571

echo "---------------------------------------------------------"
echo "✅ EC2 Deployment Complete!"
