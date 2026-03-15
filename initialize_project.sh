#!/bin/bash

# --- CONFIGURATION ---
PROJECT_ROOT="/Users/amiyakumar.m/Ws/ai-space"
ENGINE_DIR="$PROJECT_ROOT/nanoclaw"
WORKSPACE_DIR="$PROJECT_ROOT/ai-engineer"
GEMINI_KEY="AIzaSyCkEVSGkfAYnKXJzksHSn1RHafN1xZRRAo" # <--- PASTE KEY HERE

echo "🚀 Starting AI Engineer Environment Setup..."

# 1. Create Directory Structure
mkdir -p $ENGINE_DIR
mkdir -p $WORKSPACE_DIR/{backend,frontend,.agent/spec,.agent/prompts}

# 2. Clone NanoClaw into the engine folder
if [ ! -d "$ENGINE_DIR/.git" ]; then
    echo "📦 Cloning NanoClaw engine..."
    git clone https://github.com/qwibitai/nanoclaw.git $ENGINE_DIR
else
    echo "✅ Engine already exists, skipping clone."
fi

# 3. Create GEMINI.md (The Brain's Rules)
echo "🧠 Creating GEMINI.md persona..."
cat <<EOF > $WORKSPACE_DIR/GEMINI.md
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
EOF

# 4. Create the run_engineer.sh inside the engine folder
echo "🛠️ Creating Master Control script..."
cat <<EOF > $ENGINE_DIR/run_engineer.sh
#!/bin/bash
CONTAINER_NAME="nanoclaw"
IMAGE_NAME="nanoclaw-agent"

echo "Cleaning up old containers..."
docker stop \$CONTAINER_NAME 2>/dev/null
docker rm \$CONTAINER_NAME 2>/dev/null

echo "Building and Launching..."
cd $ENGINE_DIR
docker build -t \$IMAGE_NAME .
docker run -d \\
  --name \$CONTAINER_NAME \\
  -e WHATSAPP_ENABLED=true \\
  -e GOOGLE_API_KEY="$GEMINI_KEY" \\
  -v "$WORKSPACE_DIR:/app/workspace" \\
  -p 18789:18789 \\
  --restart unless-stopped \\
  \$IMAGE_NAME

echo "-------------------------------------------------------"
echo "WAITING FOR WHATSAPP QR CODE..."
echo "-------------------------------------------------------"
sleep 10
docker logs \$CONTAINER_NAME | grep -A 20 "QR" || docker logs \$CONTAINER_NAME
EOF

# 5. Set Permissions
chmod +x $ENGINE_DIR/run_engineer.sh
chmod +x initialize_project.sh

echo "✅ Setup Complete!"
echo "Next step: Run 'cd $ENGINE_DIR && ./run_engineer.sh' to start your bot."
