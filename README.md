# Bash File Organizer 🚀

A robust, production-ready Bash script designed to clean up and automatically organize cluttered directories (like your default `Downloads` folder) by grouping files into dedicated subdirectories based on their file extensions.

It utilizes advanced Bash programming techniques such as associative-like array passing via reference flags (`local -n`), streamlined pattern matching using `case` blocks, and native high-performance array absorption via `mapfile`.

---

## ✨ Features

- **Automated Categorization**: Dynamically scans, filters, and relocates files into specific folders:
  - 🖼️ **Pictures**: `.jpg`, `.jpeg`, `.png`, `.gif`, `.svg`, `.webp`, `.bmp`
  - 🎵 **Music**: `.mp3`, `.flac`, `.wav`, `.ogg`, `.m4a`, `.aac`, `.opus`
  - 🎬 **Videos**: `.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`, `.ogv`
  - 📄 **Documents**: `.txt`, `.pdf`, `.docx`, `.xls`, `.xlsx`, `.csv`, `.md`, etc.
  - 📚 **Books**: `.epub`, `.fb2`
  - 💿 **ISO Images**: `.iso`
  - 📦 **Archives & Packages**: `.zip`, `.tar.gz`, `.deb`, `.flatpak`, `.rpm`, etc.
- **High Performance**: Employs the native Bash `mapfile` built-in and `find` commands instead of slow external loops.
- **Persistent Logging**: Writes time-stamped visual historical data to local logs for painless debugging and cron-job monitoring.
- **Portable & Safe**: Automatically resolves system paths using the environment's global `$HOME` variables, ensuring safe operation out of the box on any system (Ubuntu, Debian, Fedora, Arch Linux, etc.).

---

## 🛠️ Requirements

- **Shell**: `Bash` (v4.3 or newer due to `local -n` nameref variables).
- **Coreutils**: Common Linux utilities (`find`, `mkdir`, `mv`, `sleep`).

---

## 🚀 Quick Start

Follow these simple steps to download, configure, and use the utility on your Linux environment.

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/bash-file-organizer.git
cd bash-file-organizer
```

### 2. Make the Script Executable
Give the file execution permissions on your local machine:
```bash
chmod +x organizer.sh
```

### 3. Run the Script
Execute it directly from your terminal:
```bash
./organizer.sh
```

---

## 🎛️ Configuration

By default, the script scans your `$HOME/Downloads` directory and maps files to respective default system folders. If you want to change either the source directory or target paths, simply edit the configuration variables at the top of the script:

```bash
# Target path to be organized
FILE_DIR="$HOME/Downloads"

# Output directories
DIR_PICTURES="$HOME/Pictures"
DIR_MUSIC="$HOME/Music"
DIR_VIDEOS="$HOME/Videos"
```

---

## ⏰ Automation

To keep your workspace clean completely hands-free, you can automate this script to run in the background at regular intervals. Which tool to use depends on whether your machine is on 24/7 or not.

### Option A: Cron (machine is on 24/7, e.g. a server or always-on desktop)

`cron` fires jobs at a fixed wall-clock time. If the computer is off or asleep at that moment, the job is simply skipped — so this option only makes sense for machines that are reliably running at 3:00 AM.

1. Open your user crontab configuration:
   ```bash
   crontab -e
   ```

2. Add the following entry to automatically execute the routine **every night at 3:00 AM**:
   ```cron
   0 3 * * * /bin/bash /home/YOUR_USERNAME/projects/bash-file-organizer/organizer.sh >/dev/null 2>&1
   ```
   *(Be sure to replace `/home/YOUR_USERNAME/...` with the absolute path to your cloned script file).*

### Option B: Anacron (laptop / desktop that's often off or suspended)

If your computer isn't running 24/7 — a laptop that's frequently shut down or suspended is the typical case — `cron` jobs scheduled during "off" hours will simply never run. `anacron` solves this by tracking the last run time and executing missed jobs as soon as the machine is next on, instead of skipping them.

1. Install anacron if it isn't already present:
   ```bash
   sudo apt install anacron   # Debian/Ubuntu
   sudo dnf install cronie-anacron   # Fedora
   ```

2. Add a job that runs **daily**, regardless of exact time, tolerating missed runs:
   ```bash
   sudo nano /etc/cron.daily/bash-file-organizer
   ```
   ```bash
   #!/bin/bash
   /bin/bash /home/YOUR_USERNAME/projects/bash-file-organizer/organizer.sh >/dev/null 2>&1
   ```
   ```bash
   sudo chmod +x /etc/cron.daily/bash-file-organizer
   ```

   `anacron` (already wired into `/etc/cron.daily` via `/etc/anacrontab` on most distros) will run this once a day, catching up on any day it missed because the machine was off.

### Option C: systemd timer (recommended on modern distros)

A `systemd` user timer is the most flexible option: it survives suspend/hibernate, supports `Persistent=true` to catch up on missed runs (similar to anacron, but more configurable), and integrates with `journalctl` for logging — no separate log file needed.

1. Create the service unit:
   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/bash-file-organizer.service
   ```
   ```ini
   [Unit]
   Description=Organize Downloads folder

   [Service]
   Type=oneshot
   ExecStart=/bin/bash /home/YOUR_USERNAME/projects/bash-file-organizer/organizer.sh
   ```

2. Create the matching timer unit:
   ```bash
   nano ~/.config/systemd/user/bash-file-organizer.timer
   ```
   ```ini
   [Unit]
   Description=Run bash-file-organizer daily

   [Timer]
   OnCalendar=*-*-* 03:00:00
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

   `Persistent=true` is the key line here — it tells systemd to run the job immediately on next boot/login if the scheduled time was missed (e.g. the laptop was off or asleep at 3:00 AM), exactly the problem `cron` has on non-24/7 machines.

3. Enable and start the timer:
   ```bash
   systemctl --user enable --now bash-file-organizer.timer
   ```

4. Check status and next scheduled run:
   ```bash
   systemctl --user list-timers bash-file-organizer.timer
   ```

5. To make the user timer run even when you're not logged in, enable lingering for your user:
   ```bash
   sudo loginctl enable-linger $USER
   ```

---

## 📜 Logs

The script generates clear execution statuses. You can watch your script executions or monitor automated tasks by checking the generated log file:

```bash
tail -f ~/.local/state/bash-file-organizer/logs/organizer.log
```

---

## 📄 License

This project is licensed under the terms of the **MIT License**. Feel free to modify, distribute, and integrate it into your personal or professional infrastructure workflows.
