FROM debian:12-slim

# Install zsh and basic utilities
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/zsh testuser

# Set up environment
USER testuser
WORKDIR /home/testuser

# Set DOTFILES_HOME environment variable (mounted volume)
ENV DOTFILES_HOME=/home/testuser/Projects/dotfiles

# Create symlink to zshrc (will be done at runtime when volume is mounted)
# For now, create a placeholder that will be replaced
RUN echo '# Placeholder - will be replaced by symlink' > .zshrc

# Set zsh as default shell and start with zsh
CMD ["sh", "-c", "ln -sf $DOTFILES_HOME/zsh/zshrc ~/.zshrc && exec /bin/zsh -l"]