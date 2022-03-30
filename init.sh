#!/bin/bash
# TODO: 判断主题文件夹是否存在，autosuggestions和syntax-highlighting，autojump是否安装

v2ray_pkg_name=v2ray-4.43.0-amd64.deb
v2ray_http_port=1080

# 判断系统类型
systemtype="$(uname -s)"
case "${systemtype}" in
	Linux*) machine=Linux;;
	Darwin*) machine=Mac;;
esac
echo ${machine}

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# 安装依赖
if [ ${machine} == "Linux" ]; then
	sudo apt update
	sudo apt install python3-dev build-essential git cmake vim tmux python3-pip -y
	sudo apt install universal-ctags global -y
	sudo apt install zsh curl wget proxychains4 -y
elif [ ${machine} == "Mac" ]; then
	brew install cmake macvim python tmux alacritty
	# 配置alacritty
	mkdir -p ~/.config/alacritty/
	ln -f -s `pwd`/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
fi

################# 安装 v2ray ###############
#echo "=========> Install v2ray"
#sudo dpkg -i ${v2ray_pkg_name}
#sudo rm /etc/v2ray/config.json
#pushd /etc/v2ray && sudo ln -s client.json config.json && popd
#sudo cp v2ray/client.json /etc/v2ray/config.json 
#sudo service v2ray restart

############### 配置 proxychains ##########
#ln -sf `pwd`/proxychains4.conf /etc/proxychains4.conf

############### 安装 github cli ###########
sudo apt install gh
gh auth login

############### 配置 git ##################
echo "=========> Configure git"
#git config --global http.proxy http://127.0.0.1:${v2ray_http_port}
#git config --global https.proxy http://127.0.0.1:${v2ray_http_port}
git config --global user.email zianglei@126.com
git config --global user.name zianglei
git config --global http.sslVerify false

############## 安装 oh-my-zsh ##################
#echo "=========> Install oh-my-zsh"
#while ! nc -z localhost 1080; do
#    sleep 0.1
#done
#https_proxy=http://127.0.0.1:${v2ray_http_port} curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
ln -sf `pwd`/.zshrc $HOME/.zshrc
ln -sf `pwd`/arch/${machine}/.zshrc $HOME/.zshrc.arch
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z

##############
# 配置vim
##############
echo "========> Configure vim"
mkdir -p ~/.vim && git clone https://github.com/zianglei/vim-init.git ~/.vim/vim-init
ln -f -s `pwd`/vim/vimrc ~/.vimrc
# 安装插件
vim -E -c PlugInstall -c qall
# 编译YouCompleteMe
if [ -d "~/.vim/bundles/YouCompleteMe" ]; then
  pip install --user cmake
  export PATH=$HOME/.local/bin:$PATH
  ~/.vim/bundles/YouCompleteMe/install.py --clangd-completer
fi

######### 安装 ccls
echo "========> Install ccls"
git clone --depth=1 --recursive https://github.com/MaskRay/ccls
os_version="$(lsb_release -r | awk '{print $2}')"
if [[ ${os_version} -lt 20.04 ]]; then
  wget -c https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz -O llvm.tar.xz
  tar -xf llvm.tar.xz -C llvm-14

  pushd ccls
  cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=`pwd`/../llvm-14
  cmake --build Release
  pushd Release && sudo make install
  popd
  popd
else
  sudo apt install clang -y
  pushd ccls
  llvm_dir=$(find /usr/lib -maxdepth 1 -name "llvm-*" | head -1)
  llvm_include_dir=$(find /usr/include -maxdepth 1 -name "llvm-*" | head -1)
  if [[ -n "$llvm_dir" ]] && [[ -n "llvm_include_dir" ]]; then
	cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
  	    -DCMAKE_PREFIX_PATH=${llvm_dir} \
  	    -DLLVM_INCLUDE_DIR=${llvm_dir}/include
  	    -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10
  	cmake --build Release
	pushd Release && sudo make install
	popd
  fi
  popd
fi
#git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

############### 配置tmux ##################
ln -f -s `pwd`/tmux/tmux.conf ~/.tmux.conf

############### 设置默认shell 为 zsh ##########
chsh -s `which zsh`
