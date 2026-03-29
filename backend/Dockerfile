# Backend Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 安装编译依赖
RUN apk add --no-cache gcc musl-dev git

# 复制源码
COPY . .

# 下载依赖并整理
RUN go mod tidy

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -o server main.go

# 运行镜像
FROM alpine:latest

WORKDIR /app

# 安装 CA 证书（用于 HTTPS 请求）
RUN apk add --no-cache ca-certificates tzdata

# 从 builder 复制二进制文件
COPY --from=builder /app/server .
COPY --from=builder /app/config.yaml .

EXPOSE 8080

CMD ["./server"]
