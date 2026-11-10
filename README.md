# agy-docker

A reusable Docker image and layer based on `ubuntu:24.04` with the **Google Antigravity CLI (`agy`)** pre-installed and configured for persistent `.gemini` credentials and settings.

## Features

- **`agy` Pre-installed**: Installed system-wide at `/usr/local/bin/agy`.
- **Persistent `.gemini` Directory**: Pre-configured `/root/.gemini` volume and local `.gemini/` mount folder (git-ignored so credentials are never committed).
- **Multi-Arch Automated Builds**: Automatically rebuilt daily via GitHub Actions for `linux/amd64` and `linux/arm64` and published to GitHub Container Registry (`ghcr.io`).

---

## Usage

### 1. As a Base Image (`FROM`)

Use this image as the base for your own `Dockerfile`:

```dockerfile
FROM ghcr.io/derekjchow/agy_docker:latest

# Your custom project setup here
WORKDIR /workspace
COPY . .
```

### 2. Import the `agy` Layer into Any Existing `Dockerfile` (`COPY --from`)

If you already have another Debian/Ubuntu-based `Dockerfile` and just want to import `agy` into it:

```dockerfile
FROM ubuntu:24.04

# Copy the agy binary directly from this image
COPY --from=ghcr.io/derekjchow/agy_docker:latest /usr/local/bin/agy /usr/local/bin/agy

# Optional: declare the persistent .gemini volume
RUN mkdir -p /root/.gemini
VOLUME ["/root/.gemini"]
```

### 3. Standalone via Docker Compose

Run `agy` directly with credentials and settings persisted in the local `./.gemini` directory:

```bash
docker compose run --rm agy
```

> **Tip:** If you want the container to share your host machine's existing `agy` login and settings instead of an isolated `./.gemini` folder, update `docker-compose.yml` to mount `~/.gemini:/root/.gemini`.

### 4. Standalone via `docker run`

```bash
docker run -it --rm \
  -v "$(pwd)/.gemini:/root/.gemini" \
  -v "$(pwd):/workspace" \
  ghcr.io/derekjchow/agy_docker:latest
```

### 5. Using with Dev Containers (`.devcontainer/devcontainer.json`)

Using `initializeCommand`, the Dev Container will automatically create a `.gemini` directory in your project root on the host (if it doesn't already exist) before the container starts and bind-mount it into the container.

> **Important:** Make sure to add `.gemini/` to your project's `.gitignore` so credentials and settings are never committed.

#### Option A: Use this image directly

Create `.devcontainer/devcontainer.json` in your project:

```json
{
  "name": "Antigravity Dev Container",
  "image": "ghcr.io/derekjchow/agy_docker:latest",
  "initializeCommand": "mkdir -p \"${localWorkspaceFolder}/.gemini\"",
  "mounts": [
    "source=${localWorkspaceFolder}/.gemini,target=/root/.gemini,type=bind,consistency=cached"
  ]
}
```

#### Option B: Add `agy` to an existing custom `.devcontainer/Dockerfile`

If your devcontainer already uses a custom `Dockerfile` (for example, `mcr.microsoft.com/devcontainers/base:ubuntu` with a non-root `vscode` user):

1. Add the `COPY --from` layer to `.devcontainer/Dockerfile`:
   ```dockerfile
   FROM mcr.microsoft.com/devcontainers/base:ubuntu

   COPY --from=ghcr.io/derekjchow/agy_docker:latest /usr/local/bin/agy /usr/local/bin/agy
   ```
2. Configure `.devcontainer/devcontainer.json` to auto-create `${localWorkspaceFolder}/.gemini` and mount it into your container user's home directory:
   ```json
   {
     "name": "Custom Dev Container with agy",
     "build": {
       "dockerfile": "Dockerfile"
     },
     "initializeCommand": "mkdir -p \"${localWorkspaceFolder}/.gemini\"",
     "mounts": [
       "source=${localWorkspaceFolder}/.gemini,target=/home/vscode/.gemini,type=bind,consistency=cached"
     ],
     "remoteUser": "vscode"
   }
   ```


