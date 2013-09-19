#!/usr/bin/env bash

# set -x # Debug

DOTFILES=~/.dotfiles

[[ ! -d ~/.dotfiles ]] && git clone https://github.com/ULHPC/dotfiles.git $DOTFILES
[[ -d ~/.dotfiles ]] && ( cd $DOTFILES ; git pull )

cd ~

## bash

ln -sf $DOTFILES/bash/bashrc       ~/.bashrc
ln -sf $DOTFILES/bash/inputrc      ~/.inputrc
ln -sf $DOTFILES/bash/bash_profile ~/.bash_profile
ln -sf $DOTFILES/bash/profile      ~/.profile
ln -sf $DOTFILES/bash/bash_logout  ~/.bash_logout

if [[ ! -f ~/.git-prompt.sh ]] ; then
    curl -o ~/.git-prompt.sh \
         https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
fi

## vim

ln -sf $DOTFILES/vim/vimrc ~/.vimrc

## screen

ln -sf $DOTFILES/screen/screenrc ~/.screenrc

