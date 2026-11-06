FROM python:3.14-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    NODE_VERSION=22 \
    PIP_NO_CACHE_DIR=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# git is required: requirements.txt installs Astra from GitHub (git+https://...)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    gnupg \
    ffmpeg \
    wget \
    ca-certificates \
    fonts-liberation \
    libnss3 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libx11-xcb1 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxshmfence1 \
    libglib2.0-0 \
    libdrm2 \
    libxfixes3 \
    libxcb1 \
    libxi6 \
    libpango-1.0-0 \
    lsb-release \
    xdg-utils \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir yt-dlp

# Astra launches Playwright's bundled Chromium, so install that plus its system libs
RUN python -m playwright install --with-deps chromium \
    && rm -rf /var/lib/apt/lists/*

COPY . .

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s \
    CMD python -c "import sys; sys.exit(0)"

CMD ["python", "bot.py"]
