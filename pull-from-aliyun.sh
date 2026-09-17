#!/usr/bin/env bash
# ==============================================================================
# 用途：从阿里云 ACR 拉取已同步的镜像，重新标记为内网私有仓库地址并推送到私服
# 使用方法：
#   chmod +x pull-from-aliyun.sh
#   ./pull-from-aliyun.sh <你的阿里云命名空间> [阿里云专属域名] [内网私服地址]
# 示例：
#   ./pull-from-aliyun.sh my-k8s-rook crpi-152y3mtli6krf23o.cn-hangzhou.personal.cr.aliyuncs.com registry.local/ceph
# ==============================================================================

set -e

ALIYUN_NAMESPACE="${1:-my-k8s-rook}"
ALIYUN_REGISTRY="${2:-crpi-152y3mtli6krf23o.cn-hangzhou.personal.cr.aliyuncs.com}"
LOCAL_REGISTRY="${3:-registry.local/ceph}"

ALIYUN_PREFIX="${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}"

# 映射定义：阿里云镜像名 -> 内网私服完整路径
declare -A IMAGE_MAP=(
  ["csi-provisioner:v4.0.1"]="${LOCAL_REGISTRY}/sig-storage/csi-provisioner:v4.0.1"
  ["csi-attacher:v4.5.1"]="${LOCAL_REGISTRY}/sig-storage/csi-attacher:v4.5.1"
  ["csi-snapshotter:v7.0.2"]="${LOCAL_REGISTRY}/sig-storage/csi-snapshotter:v7.0.2"
  ["csi-resizer:v1.10.1"]="${LOCAL_REGISTRY}/sig-storage/csi-resizer:v1.10.1"
  ["csi-node-driver-registrar:v2.10.1"]="${LOCAL_REGISTRY}/sig-storage/csi-node-driver-registrar:v2.10.1"
  ["cephcsi:v3.11.0"]="${LOCAL_REGISTRY}/cephcsi/cephcsi:v3.11.0"
  ["ceph:v18.2.4"]="${LOCAL_REGISTRY}/ceph/ceph:v18.2.4"
  ["ceph:v1.14.9"]="${LOCAL_REGISTRY}/rook/ceph:v1.14.9"
)

echo "=================================================="
echo "阿里云源前缀: ${ALIYUN_PREFIX}"
echo "目标内网私服: ${LOCAL_REGISTRY}"
echo "=================================================="

for img in "${!IMAGE_MAP[@]}"; do
  src="${ALIYUN_PREFIX}/${img}"
  dst="${IMAGE_MAP[$img]}"

  echo ">>> [1/3] 从阿里云拉取: ${src}"
  docker pull "${src}"

  echo ">>> [2/3] 重新打标签:   ${dst}"
  docker tag "${src}" "${dst}"

  echo ">>> [3/3] 推送到内网私服: ${dst}"
  docker push "${dst}"

  # 清理本地阿里云镜像缓存
  docker rmi "${src}" || true
  echo "--- 完成: ${img} ---"
done

echo "=================================================="
echo "🎉 所有镜像拉取并推送到私服完毕！"
echo "=================================================="
