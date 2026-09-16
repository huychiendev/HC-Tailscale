FROM tailscale/tailscale:latest

# Cài thêm SOCKS5 server
RUN apk add --no-cache microsocks

# XÓA TRẮNG ENTRYPOINT: Vứt bỏ hoàn toàn thủ phạm gây lỗi K8s của Tailscale
ENTRYPOINT []

# Giao toàn quyền điều phối cho Shell. 
# 1. Chạy ngầm tiến trình mạng
# 2. Chờ 3s và xác thực Exit Node
# 3. Chạy ngầm SOCKS5 ở localhost (Tailnet gọi IP:1080 sẽ tự động chui vào đây)
# 4. Chạy Web UI ở chế độ foreground để mở Port, chặn Render kill app.
CMD tailscaled --tun=userspace-networking --state=/tmp/tailscale.state & \
    sleep 3 && \
    tailscale up --authkey=${TS_AUTHKEY} --advertise-exit-node && \
    microsocks -i 127.0.0.1 -p 1080 & \
    exec tailscale web --listen=0.0.0.0:${PORT:-10000}
