#!/bin/sh

# install oh my zsh
/bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# install p10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# symlink .zshrc
ln -svf $DOTFILES_HOME/zsh/zshrc $HOME/.zshrc

# symlink .p10k.zsh
ln -svf $DOTFILES_HOME/zsh/p10k.zsh $HOME/.p10k.zsh
