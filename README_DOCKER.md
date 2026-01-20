# Docker Setup for TD-JEPA

This guide describes how to set up and run the TD-JEPA environment using Docker. This provides an isolated, reproducible Linux environment, recommended for Windows users or anyone wanting to avoid managing dependencies on their host machine.

## Prerequisites

- **Docker**: Ensure Docker Desktop (Windows/Mac) or Docker Engine (Linux) is installed and running.
- **NVIDIA GPU (Optional but Recommended)**: For GPU acceleration, you need:
    - An NVIDIA GPU.
    - Updated NVIDIA drivers on your host.
    - **Windows**: Docker Desktop with execution by WSL 2 (usually default).
    - **Linux**: NVIDIA Container Toolkit installed.

## 1. Build the Image

Run the following command in the root of the repository:

```bash
docker build -t td-jepa .
```

This may take a few minutes as it downloads the base image and installs dependencies.

## 2. Run the Container

### Basic Usage (CPU only)

```bash
docker run -it --rm td-jepa /bin/bash
```

This opens a shell inside the container where you can run `uv` commands.

### With GPU Support (Recommended)

To enable GPU access inside the container:

```bash
docker run -it --rm --gpus all td-jepa /bin/bash
```

*Note: On Windows with Docker Desktop using WSL 2 backend, `--gpus all` should work out of the box if you have recent NVIDIA drivers.*

### Mounting Data and Results

To ensure downloaded datasets and training results adhere to your host machine (so they aren't lost when the container stops), mount the `datasets` and `results` directories:

**Windows (PowerShell):**
```powershell
docker run -it --rm --gpus all `
  -v ${PWD}/datasets:/app/datasets `
  -v ${PWD}/results:/app/results `
  td-jepa /bin/bash
```

**Linux / Mac / Windows (Git Bash):**
```bash
docker run -it --rm --gpus all \
  -v "$(pwd)/datasets:/app/datasets" \
  -v "$(pwd)/results:/app/results" \
  td-jepa /bin/bash
```

*(Note: Create `datasets` and `results` folders in your current directory first if they don't exist, to avoid permission issues sometimes triggered by Docker creating them as root.)*

## 3. Running Experiments

Once inside the container, you can run the standard `uv` commands as documented in the main `README.md`.

**Example: Check setup**
```bash
uv run python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

**Example: Download ExORL data**
```bash
uv run -m scripts.data_processing.exorl.download --output_folder datasets/exorl
```

**Example: Train TD-JEPA**
```bash
uv run -m scripts.train.proprio.launch_td_jepa_dmc --use_wandb --wandb_gname test_run --data_path datasets --workdir_root results --sweep_config sweep_walker
```

## Troubleshooting

- **Permissions**: If you encounter permission errors writing to mounted volumes, ensure the folders on your host are writable.
- **Rendering**: MuJoCo rendering (especially `dm_control`) can sometimes be tricky in Docker. The installed `libosmesa6` usually handles software rendering (headless) fine.
