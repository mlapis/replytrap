# ReplyTrap

Free and open source AI-powered scambaiting suite that monitors email accounts, detects scams, and uses customizable personas to engage scammers in conversations that waste their time.

## Demo

https://github.com/user-attachments/assets/5cd2b41a-c4f6-4d40-8856-9228c1a6f3cd

## Quick Start

### Docker Setup

**Option 1: Docker Desktop GUI - recommended for beginners**

**Install Docker Desktop for Windows/Mac:** [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
1. Open Docker Desktop
2. Navigate to the reply_trap folder in your file explorer
3. Right-click on `docker-compose.yml` → "Compose Up"

**Option 2: Terminal**
**Install Docker your preferred way**
```bash
git clone https://github.com/yourusername/reply_trap.git
cd reply_trap
docker-compose up
```

**⚠️ Docker notes:**
- First run takes several minutes to download the llama3.2:3b model (around 3 GB)
- Can be resource-intensive when LLMs are running since the AI model runs locally on your computer - this eliminates external API costs and dependencies
- Runs in single user mode by default (no login required) for easy setup. Change SINGLE_USER_MODE to false in docker-compose.yml to enable user registration and login

### Local Setup

```bash
git clone https://github.com/yourusername/reply_trap.git
cd reply_trap
cp .env.example .env
# Edit .env - choose your LLM provider and delete the others
bin/setup
# In another terminal: bin/jobs
```

Visit `http://localhost:3030`

## Key Features

- **AI persona generation** - write your own personas or generate them with AI
- **Automated email monitoring and scam detection** 
- **Smart scam responses** - answers stay consistent with your persona and timing varies from minutes to 2 days to mimic human behavior
- **Auto-testing email credentials** - makes setting up your email accounts straightforward
- **Encrypted email credentials storage**
- **Ollama integration for local AI models** - Docker only. Saves configuration effort and cost
- **Disable email accounts or conversations you don't want to continue**

## Disclaimer

Educational and defensive security use only. Use responsibly and legally.
