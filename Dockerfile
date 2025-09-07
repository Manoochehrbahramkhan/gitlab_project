############################
# Stage 1: Build
############################
FROM registery.atlasdtco.com/golang:1.24 AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod tidy

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o portal .

############################
# Stage 2: Alpine Runtime
############################
FROM registery.atlasdtco.com/alpine:3.22 AS alpine-runtime

WORKDIR /app

COPY --from=builder /app/portal .
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
COPY templates ./templates
COPY assets ./assets

USER 1000
EXPOSE 9000

CMD ["./portal"]

