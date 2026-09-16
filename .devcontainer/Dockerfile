FROM mcr.microsoft.com/devcontainers/base:ubuntu

COPY --from=jdxcode/mise /usr/local/bin/mise /usr/local/bin/

# make sure mise is activated in both zsh and bash. Might be overridden by a user's dotfiles.
RUN echo 'eval "$(mise activate bash)"' >> /home/vscode/.bashrc

# pre-create the Copilot auth dir so the named volume mounted there is owned by vscode
RUN install -d -o vscode -g vscode /home/vscode/.config /home/vscode/.config/github-copilot
