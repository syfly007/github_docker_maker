#!/bin/bash

# 检查是否提供了镜像名
if [ "$#" -ne 1 ]; then
    echo "用法: $0 <原始镜像名>"
    exit 1
fi

ORIGINAL_IMAGE_NAME=$1
TIMESTAMP=$(date +%Y%m%d%H%M%S)
CONTAINER_NAME=$(echo "$ORIGINAL_IMAGE_NAME" | sed 's/[:/]/_/g')_thin
DOCKERFILE_NAME="Dockerfile-${ORIGINAL_IMAGE_NAME//:/_}-thin-${TIMESTAMP}"
BACKUP_IMAGE_NAME="${ORIGINAL_IMAGE_NAME}_backup_${TIMESTAMP}"

echo "根据镜像 $ORIGINAL_IMAGE_NAME 创建并启动容器 $CONTAINER_NAME..."
# 创建并启动容器
docker run -u root --name $CONTAINER_NAME $ORIGINAL_IMAGE_NAME /bin/true &

# 等待容器停止或10秒过去，如果还在运行则强制停止
echo "等待容器停止..."
sleep 30
if docker ps -q --no-trunc | grep $(docker inspect --format='{{.Id}}' $CONTAINER_NAME); then
    echo "容器仍在运行；现在将其停止..."
    docker stop $CONTAINER_NAME || docker kill $CONTAINER_NAME
fi

echo "从容器 $CONTAINER_NAME 导出文件系统..."
# 导出容器的文件系统
docker export $CONTAINER_NAME -o "${CONTAINER_NAME}.tar"

echo "从镜像 $ORIGINAL_IMAGE_NAME 获取环境变量、CMD 和 ENTRYPOINT..."
# 获取环境变量、CMD、ENTRYPOINT
ENV_VARS=$(docker inspect $ORIGINAL_IMAGE_NAME --format='{{range .Config.Env}}{{println .}}{{end}}')
CMD=$(docker inspect $ORIGINAL_IMAGE_NAME --format='{{json .Config.Cmd}}')
ENTRYPOINT=$(docker inspect $ORIGINAL_IMAGE_NAME --format='{{json .Config.Entrypoint}}')

echo "移除容器 $CONTAINER_NAME..."
# 清理容器
docker rm $CONTAINER_NAME

echo "创建新的 Dockerfile $DOCKERFILE_NAME..."
# 创建新的 Dockerfile
cat > $DOCKERFILE_NAME <<EOF
FROM scratch
ADD ${CONTAINER_NAME}.tar /
EOF

IFS=$'\n'  # 将内部字段分隔符 (IFS) 更改为换行符
# 添加环境变量
for ENV_VAR in $ENV_VARS; do
    # 正确处理包含空格的值
    name=$(echo "$ENV_VAR" | cut -d '=' -f 1)
    value=$(echo "$ENV_VAR" | cut -d '=' -f 2-)
    # 正确处理包含空格的值，确保整个值被引号包裹
    echo "ENV $name=\"$value\"" >> "$DOCKERFILE_NAME"
done

# 添加 CMD 和 ENTRYPOINT
echo "ENTRYPOINT $ENTRYPOINT" >> $DOCKERFILE_NAME
echo "CMD $CMD" >> $DOCKERFILE_NAME

# 重命名原始镜像
docker tag $ORIGINAL_IMAGE_NAME $BACKUP_IMAGE_NAME
# 输出重命名后的镜像信息
echo "原始镜像已重命名为: $BACKUP_IMAGE_NAME"

echo "构建新镜像 $ORIGINAL_IMAGE_NAME..."
# 构建新镜像
docker build -f $DOCKERFILE_NAME -t $ORIGINAL_IMAGE_NAME .

echo "删除临时文件: ${CONTAINER_NAME}.tar"
rm ${CONTAINER_NAME}.tar

# 输出新镜像名并保留 Dockerfile 和 tar 文件以供记录
echo "压缩后的镜像已创建: $ORIGINAL_IMAGE_NAME"
echo "Dockerfile 已保存为: $DOCKERFILE_NAME"