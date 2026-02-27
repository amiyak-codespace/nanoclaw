# STEP 1: Foundation (The Build Stage)
FROM node:20-bookworm-slim

# STEP 2: Install system dependencies for WhatsApp and Docker CLI
RUN apt-get update && apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli

WORKDIR /app

# STEP 3: Setup Node environment
COPY package*.json ./
RUN npm install

# STEP 4: Copy source code and Compile
COPY . .
RUN npm run build

EXPOSE 18789

CMD ["npm", "start"]
