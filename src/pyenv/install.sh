#!/bin/bash

set -e

# Logging function
log() {
    echo "[pyenv-install] $1"
}

# Error handling function
error() {
    log "Error: $1"
    exit 1
}

# Determine the OS
OS=$(uname -s)
if [ "$OS" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS_ID=$ID
    else
        error "Unsupported OS: /etc/os-release not found"
    fi
else
    error "Unsupported OS: $OS"
fi

# Install dependencies based on the OS
log "Installing dependencies for $OS_ID..."
case $OS_ID in
    debian|ubuntu)
        log "Installing dependencies for Debian/Ubuntu..."
        apt-get update
        apt-get install -y --no-install-recommends \
            build-essential \
            libssl-dev \
            zlib1g-dev \
            libbz2-dev \
            libreadline-dev \
            libsqlite3-dev \
            wget \
            curl \
            llvm \
            libncurses5-dev \
            xz-utils \
            tk-dev \
            libxml2-dev \
            libxmlsec1-dev \
            libffi-dev \
            liblzma-dev \
            pkg-config
        ;;
    fedora|rhel|centos)
        log "Installing dependencies for Fedora/RHEL/CentOS..."
        dnf install -y \
            gcc gcc-c++ gdb lzma glibc-devel libstdc++-devel openssl-devel \
            readline-devel zlib-devel libffi-devel bzip2-devel xz-devel \
            sqlite sqlite-devel sqlite-libs libuuid-devel gdbm-libs perf \
            expat expat-devel mpdecimal python3-pip
        ;;
    *)
        error "Unsupported OS: $OS_ID"
        ;;
esac

# Install pyenv
log "Installing pyenv..."
if [ "$PYENV_VERSION" != "latest" ]; then
    PYENV_GIT_TAG="v$PYENV_VERSION"
fi
curl https://pyenv.run | bash
log "pyenv installation completed successfully."

# Set environment variables
export PYENV_ROOT="${_REMOTE_USER_HOME}/.pyenv"
export PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH"

# Install Python version
if [ "$PYTHON_VERSION" = "latest" ]; then
    PYTHON_VERSION=3
fi
log "Installing Python version $PYTHON_VERSION..."
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION

log "Python $PYTHON_VERSION installation completed successfully."
