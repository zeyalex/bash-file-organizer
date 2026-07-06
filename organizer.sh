#!/bin/bash
# Script to sort files in a directory based on their file extensions

# Directory to sort (Default: Downloads)
FILE_DIR="$HOME/Downloads"

# File extension patterns
TYPE_IMGS=("*.jpg" "*.jpeg" "*.png" "*.gif" "*.svg" "*.webp" "*.bmp")
TYPE_MUSICS=("*.mp3" "*.flac" "*.wav" "*.ogg" "*.m4a" "*.aac" "*.opus")
TYPE_VIDEOS=("*.mp4" "*.mkv" "*.avi" "*.mov" "*.webm" "*.ogv")
TYPE_DOCUMENTS=("*.txt" "*.odt" "*.ods" "*.odp" "*.doc" "*.docx" "*.xls" "*.xlsx" "*.pptx" "*.ppt" "*.csv" "*.md" "*.pdf")
TYPE_BOOKS=("*.epub" "*.fb2")
TYPE_ISO=("*.iso")
TYPE_ARCHIVES=("*.deb" "*.zip" "*.flatpak" "*.tar" "*.tar.gz" "*.tgz" "*.gz" "*.rpm")

# Target directories
DIR_PICTURES="$HOME/Pictures"
DIR_MUSIC="$HOME/Music"
DIR_VIDEOS="$HOME/Videos"
DIR_DOC="$HOME/Documents"
DIR_BOOKS="$HOME/Books"
DIR_ISO="$HOME/iso_images"
DIR_ARCH="$HOME/archives"
LOG_FILE="$HOME/.local/state/bash-file-organizer/logs/organizer.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Create target directories if they do not exist
mkdir -p "$DIR_PICTURES" "$DIR_MUSIC" "$DIR_VIDEOS" "$DIR_DOC" "$DIR_BOOKS" "$DIR_ISO" "$DIR_ARCH" "$(dirname "$LOG_FILE")"

echo -e "\n==================================" | tee -a "$LOG_FILE"
echo "[$DATE] Starting file search..." | tee -a "$LOG_FILE"

# Visual progress indicators
echo -e "\n[#..]"
sleep 0.5
echo "[##.]"
sleep 0.5
echo "[###]"

# Search logic using mapfile
if mapfile -t FIN_FILES < <(find "$FILE_DIR" -maxdepth 1 -type f); then
    echo -e "\n[$DATE] Search completed successfully!" | tee -a "$LOG_FILE"
    echo "Total files found: ${#FIN_FILES[@]}"
else 
    echo "[$DATE] Error: Search failed with exit code $?" | tee -a "$LOG_FILE"
fi

# Counters
count_img=0; count_mus=0; count_vid=0; count_doc=0; count_book=0; count_iso=0; count_arch=0

sort_func() {
    local -n files=$1
    local -n patterns=$2
    local target_dir=$3
    local -n counter=$4

    for i in "${!files[@]}"; do
        local file="${files[$i]}"
        for pattern in "${patterns[@]}"; do
            case "$file" in
                $pattern)
                    echo "Moving: $(basename "$file") -> $target_dir" | tee -a "$LOG_FILE"
                    if mv "$file" "$target_dir/"; then
                        unset 'files[$i]'
                        ((counter++))
                    fi 
                    break 
                    ;;
            esac
        done
    done
}

# Run sorting function for each type
sort_func FIN_FILES TYPE_IMGS "$DIR_PICTURES" count_img
sort_func FIN_FILES TYPE_MUSICS "$DIR_MUSIC" count_mus
sort_func FIN_FILES TYPE_VIDEOS "$DIR_VIDEOS" count_vid
sort_func FIN_FILES TYPE_DOCUMENTS "$DIR_DOC" count_doc
sort_func FIN_FILES TYPE_BOOKS "$DIR_BOOKS" count_book
sort_func FIN_FILES TYPE_ISO "$DIR_ISO" count_iso
sort_func FIN_FILES TYPE_ARCHIVES "$DIR_ARCH" count_arch

echo "==================================" | tee -a "$LOG_FILE"

# Display and log results
# Images
if [[ "$count_img" -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_img image(s)." | tee -a "$LOG_FILE"
else
    echo "No images found."
fi

# Music
if [[ "$count_mus" -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_mus music file(s)." | tee -a "$LOG_FILE"
else
    echo "No music files found."
fi

# Videos
if [[ $count_vid -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_vid video file(s)." | tee -a "$LOG_FILE"
else
    echo "No videos found."
fi

# Documents
if [[ $count_doc -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_doc document(s)." | tee -a "$LOG_FILE"
else
    echo "No documents found."
fi

# Books
if [[ $count_book -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_book book(s)." | tee -a "$LOG_FILE"
else
    echo "No books found."
fi

# ISO Images
if [[ $count_iso -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_iso ISO file(s)." | tee -a "$LOG_FILE"
else
    echo "No ISO files found."
fi 

# Archives
if [[ $count_arch -gt 0 ]]; then
    echo "[$DATE] Successfully moved $count_arch archive(s)/package(s)." | tee -a "$LOG_FILE"
else 
    echo "No archives or packages found."
fi 

echo "Script execution finished."
