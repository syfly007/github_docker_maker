# 使用Ubuntu 22.04作为基础镜像
FROM ubuntu:22.04

# 设置环境变量
ENV FTP_USER=ftpsuser
ENV FTP_PASS=ftpsuser
ENV FTP_PORT=10012
ENV PASV_MIN_PORT=10000
ENV PASV_MAX_PORT=10012

# 使用国内阿里源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装vsftpd和openssl
RUN apt-get update && \
    apt-get install -y vsftpd openssl && \
    apt-get clean

# 生成自签名证书
RUN mkdir -p /etc/vsftpd/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/vsftpd/ssl/vsftpd.key -out /etc/vsftpd/ssl/vsftpd.crt \
    -subj "/C=CN/ST=State/L=City/O=Organization/OU=Department/CN=localhost"

# 配置vsftpd
COPY vsftpd.conf /etc/vsftpd.conf

# 添加启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露端口
EXPOSE ${FTP_PORT} ${PASV_MIN_PORT}-${PASV_MAX_PORT}

# 启动vsftpd
CMD ["/start.sh"]
