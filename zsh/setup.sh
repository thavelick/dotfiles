#!/bin/sh

oh_my_zsh_path=$HOME/.oh-my-zsh 
# install oh my zsh
[ ! -d $oh_my_zsh_path ] && /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# install p10k
p10k_path=${ZSH_CUSTOM:-$oh_my_zsh_path}/custom/themes/powerlevel10k
[ ! -d $p10k_path ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $p10k_path 

# symlink .zshrc
ln -svf $DOTFILES_HOME/zsh/zshrc $HOME/.zshrc

# symlink .p10k.zsh
ln -svf $DOTFILES_HOME/zsh/p10k.zsh $HOME/.p10k.zsh
