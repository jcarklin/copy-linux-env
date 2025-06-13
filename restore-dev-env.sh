#!/bin/bash
set -e

echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing saved packages..."
if [ -f ~/backup/package-list.txt ]; then
    sudo dpkg --set-selections < ~/backup/package-list.txt
    sudo apt-get dselect-upgrade -y
else
    echo "⚠️  package-list.txt not found!"
fi

echo "🗂 Restoring dotfiles and config..."
rsync -av ~/backup/.bashrc ~/backup/.bash_aliases ~/backup/.vimrc ~/ ~/
rsync -av ~/backup/.config/ ~/.config/
rsync -av ~/backup/.ssh/ ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

echo "💻 Restoring documents and projects..."
rsync -av ~/backup/Documents/ ~/Documents/
rsync -av ~/backup/Projects/ ~/Projects/

echo "📦 Installing core development tools..."
sudo apt install -y build-essential curl git vim tmux htop net-tools gnupg ca-certificates wget unzip

# -- SDKMAN + Java --
echo "📦 Installing SDKMAN for Java version management..."
curl -s "https://get.sdkman.io" | bash
export SDKMAN_DIR="$HOME/.sdkman"
source "$SDKMAN_DIR/bin/sdkman-init.sh"

echo "📥 Installing Java 17 and Java 8..."
sdk install java 17.0.10-tem
sdk install java 8.0.392-tem
sdk default java 17.0.10-tem

# -- Docker --
echo "🐳 Installing Docker and Docker Compose..."
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# -- PostgreSQL 16 --
echo "🐘 Installing PostgreSQL 16..."
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-16 postgresql-client-16
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Restore DB if dump is present
if [ -f ~/backup/db-backups/all_databases.sql ]; then
    echo "💾 Restoring PostgreSQL data..."
    sudo -u postgres psql < ~/backup/db-backups/all_databases.sql
    echo "✅ Database restore complete."
else
    echo "⚠️  No PostgreSQL backup found."
fi

# -- VS Code (Optional) --
echo "🌐 Optional: Install VS Codium? (y/n)"
read -r install_vscodium
if [[ "$install_vscodium" == "y" ]]; then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update
    sudo apt install -y codium
    rm vscodium-archive-keyring.gpg
fi

# -- IntelliJ Ultimate Restore --
echo "🧠 Restoring IntelliJ Ultimate settings..."

# Install JetBrains Toolbox
echo "📦 Installing JetBrains Toolbox..."
wget -O toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.30.1.17057.tar.gz
tar -xzf toolbox.tar.gz
cd jetbrains-toolbox-* && ./jetbrains-toolbox & cd ..
rm -rf jetbrains-toolbox-* toolbox.tar.gz

echo "📂 Please install and launch IntelliJ Ultimate once, then close it."
read -p "👉 Press ENTER to continue when you're ready."

# Restore config
echo "🔁 Copying IntelliJ configuration..."
rsync -av ~/backup/.config/JetBrains/ ~/.config/JetBrains/

# Ask whether to copy cache
read -p "❓ Also copy IntelliJ cache directory (~/.cache/JetBrains)? (y/n): " copy_cache
if [[ "$copy_cache" == "y" ]]; then
    echo "📂 Copying IntelliJ cache..."
    rsync -av ~/backup/.cache/JetBrains/ ~/.cache/JetBrains/
else
    echo "⏭ Skipping IntelliJ cache restore."
fi

# Fix ownership
sudo chown -R $USER:$USER ~/.config/JetBrains ~/.cache/JetBrains

echo "🧹 Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo "✅ Setup complete! 🔁 Please reboot or log out/in for Docker group changes to take effect."
