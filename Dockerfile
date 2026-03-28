# Need to run `uv lock` to update `uv.lock` first

FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# Install python and other system dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3-pip \
    curl \
    git \
    libosmesa6-dev \
    libgl1-mesa-glx \
    libglfw3 \
    libglew-dev \
    libegl1-mesa-dev \
    libxrender1 \
    libxext6 \
    ffmpeg \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy uv binary from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Set the working directory
WORKDIR /app

# Set up python 3.11
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a multi-stage build
ENV UV_LINK_MODE=copy

# Install dependencies first to leverage Docker cache
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --all-extras

# Copy the rest of the application code
COPY . .

# Install the project itself
RUN uv sync --frozen --all-extras

# Set up environment variables
ENV PYTHONPATH="/app"

# Default command
CMD ["bash"]
