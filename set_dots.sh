#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Create directories needed for dotfiles
cd "$SCRIPT_DIR" || exit
find . -type d -exec mkdir -p $HOME/{} \;
# Create links to dotfiles
stow --adopt --restow -t "$HOME" .

git clone https://github.com/tychobrouwer/everblush-gtk.git "$HOME/Projects/everblush-gtk"
ln -s "$HOME/Projects/everblush-gtk" "$HOME/.local/share/themes/everblush-gtk"

git clone https://github.com/tychobrouwer/papirus-icon-theme.git "$HOME/Projects/papirus-icon-theme"
ln -s "$HOME/Projects/papirus-icon-theme/Papirus-Dark" "$HOME/.local/share/icons/papirus"
./dolphin-folder-color.sh -c cyan -d "$HOME/.local/share/icons/papirus"

# Reset to master branch
# git reset --hard
# git pull
# cd "$SCRIPT_DIR"

# sudo fc-cache -f
