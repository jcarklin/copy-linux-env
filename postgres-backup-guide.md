# 📦 PostgreSQL + Dev Environment Backup Guide (to External Thumb Drive)

This guide explains how to back up your development environment — including your PostgreSQL databases, packages, dotfiles, and project files — to an external USB/thumb drive on a Linux Mint system.

---

## 🧰 What You'll Back Up

- Your installed package list
- Config files (`.bashrc`, `.vimrc`, `.config/`, etc.)
- Project folders (`Documents`, `Projects`, etc.)
- Your **entire PostgreSQL database cluster**

---

## 🪛 Step-by-Step Instructions

### 1. **Plug in Your Thumb Drive**

Check its mount point using:

```bash
lsblk
```

Assume it’s mounted at `/media/$USER/USB` — replace this with the actual mount point on your system.

---

### 2. **Create Backup Folder**

```bash
mkdir -p /media/$USER/USB/linux-backup/db-backups
```

---

### 3. **Back Up Installed Package List**

```bash
dpkg --get-selections > /media/$USER/USB/linux-backup/package-list.txt
```

---

### 4. **Back Up Config and Project Files**

```bash
rsync -av ~/.bashrc ~/.bash_aliases ~/.vimrc ~/.config ~/.ssh ~/Documents ~/Projects /media/$USER/USB/linux-backup/
```

---

### 5. **Back Up PostgreSQL Databases**

> This assumes you are using PostgreSQL 16 and the default cluster.

Use `sudo` to run the dump as the `postgres` OS user:

```bash
sudo -u postgres pg_dumpall > /media/$USER/USB/linux-backup/db-backups/all_databases.sql
```

---

## ✅ Verify

Make sure the following files/folders exist on the USB drive:

- `package-list.txt`
- `db-backups/all_databases.sql`
- Copied versions of `.bashrc`, `.config/`, `.ssh/`, etc.

---

## 🧪 Optional: Unmount Safely

```bash
sudo umount /media/$USER/USB
```

---

## 🔁 Restoring

Use the [`restore-dev-env.sh`](https://github.com/yourusername/linux-dev-setup) script to restore everything on a new system.

Let me know if you want this guide included in your Git repo or zipped with the setup tools.
