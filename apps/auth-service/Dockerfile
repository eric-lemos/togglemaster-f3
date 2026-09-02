# ---------------------------------------------------------------------------
# STAGE: BUILD
# ---------------------------------------------------------------------------
FROM golang:1.26-alpine AS build

WORKDIR /app
COPY . .
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o auth-service .

# ---------------------------------------------------------------------------
# STAGE: WORKLOAD
# ---------------------------------------------------------------------------
FROM alpine:3.23 AS workload

WORKDIR /app
RUN apk add --no-cache curl
COPY --from=build /app/auth-service .
EXPOSE 8001
USER nobody
CMD ["./auth-service"]