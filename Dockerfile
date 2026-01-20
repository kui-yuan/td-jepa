FROM ubuntu:24.04

# ==============
# === common ===
# ==============

# volume
VOLUME [ "/data" ]

# environment variables
#   TZ: timezone
#   Path: add '/root/.local/bin' into system path
ENV TZ=Asia/Taipei \
    PATH=/root/.local/bin:$PATH

# common dependencies
#   Antigravity remote attaching: wget procps ca-certificates
#   Oh My Posh & Atuin: curl unzip
#   GitHub: git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

    # Oh My Posh: theme
RUN curl -s https://ohmyposh.dev/install.sh | bash -s
RUN printf '\n%s\n' 'eval "$(oh-my-posh init bash --config emodipt-extend)"' >> ~/.bashrc

# Atuin: CLI history
RUN curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# customize commands
#   rm-history: remove CLI history
#   rm-pycache: remove Python cache
RUN printf '\n%s\n%s\n%s\n' \
    'alias rm-history="history -c && history -w && atuin search --delete-it-all"' \
    'pyclear() { find "${1:-.}" -type d -name "__pycache__" -prune -exec rm -rf {} + \
    -o -type f -name "*.py[co]" -exec rm -f {} +; }' \
    'alias rm-pycache="pyclear"' \
    >> ~/.bashrc

WORKDIR /workspace

# ===============
# === project ===
# ===============

# uv: Python virtual environment
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# project-specific dependencies
#   MuJoCo & DeepMind Control Suite: libegl1 libosmesa6 patchelf
#   headless video recording: ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    libegl1 \
    libosmesa6 \
    patchelf \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/kui-yuan/td-jepa.git /workspace

# install dependencies
# RUN uv sync --all-extras

# default command
CMD [ "/bin/bash" ]
