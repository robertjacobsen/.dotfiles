#!/bin/bash
DOTFILES=$(cd "$(dirname "$0")" && pwd)
ARCH=$(uname)
BASHRC=".bashrc"
if [[ "$ARCH" = "Darwin" ]]; then
    BASHRC=".bash_profile"
fi

cd ~
if [ ! -d .bak ]; then
    echo ".bak dir not found. Creating it...";
    mkdir .bak
fi

echo "Moving existing files to backup directory..."
mv $BASHRC .bak
mv .gitconfig .bak
mv .vim .bak
mv .vimrc .bak

echo "Linking config files..."
ln -sf $DOTFILES/bashrc $HOME/$BASHRC
ln -sf $DOTFILES/p10k.zsh $HOME/.p10k.zsh
ln -sf $DOTFILES/zshrc $HOME/.zshrc
ln -sf $DOTFILES/gitconfig $HOME/.gitconfig
ln -sf $DOTFILES/vim $HOME/.vim
ln -sf $DOTFILES/vimrc $HOME/.vimrc
ln -sf $DOTFILES/ghostty $HOME/.config/ghostty

echo "Done. Please relog into your shell."
