# Repository Guide

## Purpose

This repository defines a development-container environment and its bootstrap dotfiles.
It is intentionally small: the container image provides `mise`, `mise.toml` installs
`chezmoi`, and `setup` applies the dotfiles repository through chezmoi.

## Repository layout

- `.devcontainer/Dockerfile` builds from the Dev Containers Ubuntu base image and copies
  the `mise` binary into the image. It renames the base image's default `vscode` user to
  `juanes` and activates mise for Bash in that user's shell configuration.
- `.devcontainer/devcontainer.json` builds from the repository root and bind-mounts the
  host SSH agent socket at `/ssh-agent`.
- `mise.toml` declares tools installed by mise. Keep tool versions explicit when
  reproducibility matters; `latest` is currently intentional for chezmoi.
- `setup` is the chezmoi one-time bootstrap hook. It exits on errors and applies
  `git@github.com:juancrfig/devcontainer.git` only when chezmoi is not already present.
- `.bashrc` is managed as a dotfile inside the container. It configures DevPod on first
  use, starts an SSH agent only when no socket is available, and enables vi-mode editing.
- `symlink_dot_bashrc` maps the managed dotfile to the container user's Bash rc file.
- `main.py` is a minimal smoke program.

## Change guidelines

- Preserve the SSH-agent mount and the `SSH_AUTH_SOCK=/ssh-agent` contract together.
  Do not copy private keys into the container.
- Treat `.bashrc` as interactive-shell code: avoid non-interactive prompts and keep
  initialization idempotent.
- Keep bootstrap behavior safe to rerun. In particular, do not cause `setup` to
  reinitialize or overwrite an existing chezmoi-managed setup unexpectedly.
- Make changes to tool installation in both the image/bootstrap path and `mise.toml`
  when they must work in a freshly built container.
- Do not add credentials, private keys, or local machine paths to version control.

## Validation

Run the checks relevant to the files changed:

- Shell files: `bash -n setup .bashrc`
- Python smoke program: `python3 -m py_compile main.py && python3 main.py`
- Devcontainer configuration: parse `.devcontainer/devcontainer.json` as JSON.
- Docker image changes: rebuild the development container when a container runtime is
  available.

There is no project-specific test suite or package manifest.
