NOTE I GENERATED THIS SCRIPT USING CHATGPT AND HAVE NOT YET LOOKED THROUGH IT, 
SO IF YOU STUMBLE UPON IT, I DON'T RECCOMMEND YOU USE IT WITHOUT GOING THROUGH IT AND UNDERSTANDING IT FIRST  
ONCE I'VE GONE THROUGH IT AND TESTED IT I'LL REPLACE THIS MESSAGE. 

# Linux Dev Environment Setup

This repository contains a shell script to restore a full Linux Mint-based development environment, including:

- System package list
- Dotfiles and configuration files
- Java 8 and 17 via SDKMAN
- Docker and Docker Compose
- PostgreSQL 16 with optional database restore
- IntelliJ IDEA Ultimate configuration and optional cache

---

## 🛠 Prerequisites

Before using this script on your new system:

1. **Backup from your existing system (e.g., ThinkPad)**:

```bash
mkdir -p ~/backup/db-backups

# Save installed packages
dpkg --get-selections > ~/backup/package-list.txt

# Save dotfiles and project files
rsync -av ~/.bashrc ~/.bash_aliases ~/.vimrc ~/.config ~/.ssh ~/Documents ~/Projects ~/backup/

# Backup PostgreSQL data (requires password or trust authentication)
pg_dumpall -U postgres > ~/backup/db-backups/all_databases.sql
```

2. **Transfer the entire `backup/` folder to your new system**'s home directory (or the external SSD install).

---

## 🚀 How to Use This Script

1. Clone this repository on your new Linux Mint system:

```bash
git clone https://github.com/yourusername/linux-dev-setup.git
cd linux-dev-setup
```

> Or just copy this folder locally if you don't use GitHub.

2. Make the script executable and run it:

```bash
chmod +x restore-dev-env.sh
./restore-dev-env.sh
```

---

## 📦 What the Script Does

- Updates the system
- Restores installed packages using `dpkg`
- Copies user config files (`.bashrc`, `.vimrc`, `.config`, `.ssh`)
- Installs:
  - Essential dev tools
  - Java 8 + 17 via SDKMAN
  - Docker + Compose plugin
  - PostgreSQL 16 and optionally restores your databases
- Installs JetBrains Toolbox and optionally restores IntelliJ IDEA settings and caches
- Optionally installs VS Code

---

## ⚠️ Notes

- You **must** install Linux Mint to an external SSD with GRUB installed **to the external disk**, not the internal one, to avoid overwriting the internal bootloader.
- Docker requires a log out/in or reboot to apply group permissions.
- IntelliJ Ultimate must be launched once manually before restoring its settings and (optionally) cache.
- If copying `.cache/JetBrains/`, ensure versions match to avoid weird behavior.

---

## 🧰 Optional Additions

- Python, Node.js, or other language runtimes
- GUI tools like pgAdmin or DBeaver
- Terminal theming (e.g., Starship, ZSH)

Let me know if you want to add any of these.
