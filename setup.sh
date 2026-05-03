#!/bin/bash
CONFIGS=$(dirname $0)
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
ln -sf $CONFIGS/bashrc ~/$BASHRC
ln -sf $CONFIGS/p10k.zsh ~/.p10k.zsh
ln -sf $CONFIGS/zshrc ~/.zshrc
ln -sf $CONFIGS/gitconfig ~/.gitconfig
ln -sf $CONFIGS/vim ~/.vim
ln -sf $CONFIGS/vimrc ~/.vimrc

echo "Done. Please relog into your shell."
