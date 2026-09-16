FROM mcr.microsoft.com/devcontainers/base:ubuntu

# The base image leaves the shell on "vscode"; switch to root to rename it.
USER root

# Rename the base image's default "vscode" user to "juanes", keeping the same
# uid/gid so file ownership and sudoers entries carry over unchanged.
RUN usermod -l juanes -d /home/juanes -m vscode \
	&& groupmod -n juanes vscode

COPY --from=jdxcode/mise /usr/local/bin/mise /usr/local/bin/

# make sure mise is activated in both zsh and bash. Might be overridden by a user's dotfiles.
RUN echo 'eval "$(mise activate bash)"' >> /home/juanes/.bashrc

# pre-create the Copilot auth dir so the named volume mounted there is owned by juanes
RUN install -d -o juanes -g juanes /home/juanes/.config /home/juanes/.config/github-copilot

USER juanes
