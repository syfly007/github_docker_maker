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
export FTP_USER=ftpsuser
export FTP_PASS=ftpsuser
export PASV_IP=192.168.0.95
export FTP_PORT=10012
export PASV_MIN_PORT=10000
export PASV_MAX_PORT=10010
docker run -d \
  --name ftps-server \
  --restart always \
  -p ${FTP_PORT}:${FTP_PORT} \
  -p ${PASV_MIN_PORT}-${PASV_MAX_PORT}:${PASV_MIN_PORT}-${PASV_MAX_PORT} \
  -e FTP_USER=${FTP_USER} \
  -e FTP_PASS=${FTP_PASS} \
  -e PASV_IP=${PASV_IP} \
  -e FTP_PORT=${FTP_PORT} \
  -e PASV_MIN_PORT=${PASV_MIN_PORT} \
  -e PASV_MAX_PORT=${PASV_MAX_PORT} \
  -v $(pwd)/ftp_data:/home/${FTP_USER}/data \
  ftps-server
  ```
