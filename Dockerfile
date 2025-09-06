############################
# Stage 1: Build
############################
FROM repo.atlasdtco.com/repository/docker-host/golang:1.24.4 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod tidy

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o portal .

############################
# Stage 2: Alpine Runtime
############################
FROM repo.atlasdtco.com/repository/docker-host/alpine:3.22 AS alpine-runtime

WORKDIR /app

COPY --from=builder /app/portal .

COPY .env .
COPY templates ./templates
COPY assets ./assets

RUN adduser -D -H -u 1000 portal \
    && chown -R portal:portal /app \
    && chmod +x portal

EXPOSE 9000
USER portal

CMD ["./portal"]

############################
# Stage 3: Scratch Runtime
############################
FROM scratch AS scratch-runtime

WORKDIR /app

COPY --from=builder /app/portal .
COPY .env .
COPY templates ./templates
COPY assets ./assets

USER 1000
EXPOSE 9000

CMD ["./portal"]

