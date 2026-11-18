# ---------- Stage 0: Node runtime ----------
# Browser library 21 requires Node >=22.15; Debian trixie's nodejs is 20,
# so take Node 24 LTS from the official image instead.
FROM node:24-trixie-slim AS node

# ---------- Stage 1: build / dependencies ----------
FROM python:3.12-slim-trixie AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Build-time system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps into a virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY robot-tests/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt

# ---------- Stage 2: runtime ----------
FROM python:3.12-slim-trixie AS runtime

ARG ROBOT_UID=1000
ARG ROBOT_GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

# Runtime system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        openssh-client \
        tini \
        libnss3 \
        libatk1.0-0t64 \
        libatk-bridge2.0-0t64 \
        libcups2t64 \
        libdrm2 \
        libxkbcommon0 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxrandr2 \
        libgbm1 \
        libxshmfence1 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libcairo2 \
        libcairo-gobject2 \
        libasound2t64 \
        libgtk-3-0t64 \
        libgdk-pixbuf-2.0-0 \
        libxcursor1 \
        fonts-liberation \
        fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/*

# Node 24 for the Browser library (rfbrowser init and the Node-side runtime).
# The npm/npx symlinks are recreated here because COPY dereferences symlinks.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Create non-root user matching host UID/GID
RUN groupadd -g ${ROBOT_GID} robot \
    && useradd -m -u ${ROBOT_UID} -g ${ROBOT_GID} -s /bin/bash robot

# Copy Python venv from builder stage
COPY --from=builder --chown=robot:robot /opt/venv /opt/venv

# Working directory for tests
USER root
RUN mkdir -p /tests && chown -R robot:robot /tests
WORKDIR /tests
USER robot

# Install the Node dependencies and browser binaries used by Browser library.
# The explicit checks make a failed browser download fail the build instead of
# silently leaving the image without that browser.
RUN rfbrowser init \
    && cd /opt/venv/lib/python3.12/site-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers \
    && test -n "$(find . -maxdepth 1 -type d -name 'chromium-*' -print -quit)" \
    && test -n "$(find . -maxdepth 1 -type d -name 'firefox-*' -print -quit)" \
    && test -n "$(find . -maxdepth 1 -type d -name 'webkit-*' -print -quit)"

# Use tini as PID 1 for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["tail", "-f", "/dev/null"]