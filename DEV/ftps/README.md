# ftps server

## build
```bash
docker compose build
```

## run

```bash
docker compose up -d
```

## run in docker
```bash
docker run -d \
  --name ftps-server \
  -p 10012:10012 \
  -p 10000-10010:10000-10010 \
  -e FTP_USER=ftpsuser \
  -e FTP_PASS=userpass \
  -e PASV_IP=192.168.0.100 \
  -e FTP_PORT=10012 \
  -e PASV_MIN_PORT=10000 \
  -e PASV_MAX_PORT=10010 \
  -v $(pwd)/ftp_cfg:/etc/vsftpd/ \
  -v $(pwd)/ftp_data:/home/ \
  ftps-server
  ```
