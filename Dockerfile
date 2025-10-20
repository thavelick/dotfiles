FROM debian:12-slim

# Install zsh and basic utilities
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install neovim from AppImage (v0.11.4)
RUN curl -L https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage -o nvim.appimage && \
    chmod +x nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    mv squashfs-root/usr/bin/nvim /usr/local/bin/nvim && \
    rm -rf nvim.appimage squashfs-root

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

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

# Use entrypoint script to always run setup, regardless of CMD override
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]