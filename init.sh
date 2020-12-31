#!/bin/bash
# TODO: 判断主题文件夹是否存在，autosuggestions和syntax-highlighting，autojump是否安装

# 判断系统类型
systemtype="$(uname -s)"
case "${systemtype}" in
	Linux*) machine=Linux;;
	Darwin*) machine=Mac;;
esac
echo ${machine}

# 安装依赖
if [ ${machine} == "Linux" ]; then
	sudo apt update
	sudo apt install python3-dev build-essential git cmake vim tmux -y
	sudo apt install ctags global -y
elif [ ${machine} == "Mac" ]; then
	brew install cmake macvim python tmux alacritty
	# 配置alacritty
	mkdir -p ~/.config/alacritty/
	ln -f -s `pwd`/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
fi

##############
# 配置vim
##############

mkdir -p ~/.vim && git clone https://github.com/zianglei/vim-init.git ~/.vim/vim-init
ln -f -s `pwd`/vim/vimrc ~/.vimrc
# 安装插件
vim -E -c PlugInstall -c qall
# 编译YouCompleteMe
~/.vim/bundles/YouCompleteMe/install.py --clangd-completer

#git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z

# 配置tmux
ln -f -s `pwd`/tmux/tmux.conf ~/.tmux.conf
#ln -f -s `pwd`/zsh/zshrc ~/.zshrc
