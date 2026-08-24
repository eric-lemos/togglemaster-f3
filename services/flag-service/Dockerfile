# ---------------------------------------------------------------------------
# STAGE: WORKLOAD
# ---------------------------------------------------------------------------
FROM python:3.11-slim AS workload

WORKDIR /app
COPY . .
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev curl \
    && rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt
EXPOSE 8002
CMD ["gunicorn", "--bind", "0.0.0.0:8002", "app:app"]