# Build stage
FROM golang:1.26.3-alpine AS builder

WORKDIR /build

COPY app/go.mod app/go.sum ./
RUN go mod download

COPY app/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o gatus .

# Create a non-root user
RUN addgroup -S gatus && adduser -S gatus -G gatus

# Runtime stage
FROM scratch

WORKDIR /app

COPY --from=builder /build/gatus /app/gatus
COPY --from=builder /build/config.yaml /app/config.yaml

# Copy the non-root user information
COPY --from=builder /etc/passwd /etc/passwd

USER gatus

EXPOSE 8080

ENV GATUS_CONFIG_PATH=/app/config.yaml

ENTRYPOINT ["/app/gatus"]