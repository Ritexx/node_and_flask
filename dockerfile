# Stage 1: Node.js scraper
FROM node:18-bullseye-slim AS scraper

# Used this to render faster
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list

# Used this to render faster
RUN sed -i 's/deb.debian.org/mirror.rackspace.com/g' /etc/apt/sources.list && \
    sed -i 's/debian-security/mirror.rackspace.com/g' /etc/apt/sources.list && \
    echo 'Acquire::http::Timeout "10";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/99timeout

# Minimal Chromium install
RUN apt-get update -o Acquire::http::Timeout=10 && \
    apt-get install -y --no-install-recommends \
        chromium \
        libxss1 \
    && rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app
COPY scraper/package.json .
RUN npm install
COPY scraper/scrape.js .

# Stage 2: Flask server
FROM python:3.10-slim-bullseye

WORKDIR /app
COPY --from=scraper /app/scraped_data.json .
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY server/app.py .

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]