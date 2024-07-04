#!/bin/bash

# 修改vsftpd配置文件中的端口
sed -i "s/\${FTP_PORT}/${FTP_PORT}/g" /etc/vsftpd/vsftpd.conf
sed -i "s/\${PASV_MIN_PORT}/${PASV_MIN_PORT}/g" /etc/vsftpd/vsftpd.conf
sed -i "s/\${PASV_MAX_PORT}/${PASV_MAX_PORT}/g" /etc/vsftpd/vsftpd.conf
sed -i "s/\${PASV_IP}/${PASV_IP}/g" /etc/vsftpd/vsftpd.conf

# 添加FTP用户
if ! id -u "$FTP_USER" > /dev/null 2>&1; then
    useradd -m "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
fi

# 启动vsftpd
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf