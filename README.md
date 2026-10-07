# IBM Spectrum Scale CSI 离线镜像转存指南 (GitHub Actions -> 阿里云 ACR)

已为您在系统默认浏览器中打开两个配置页面：
1. **[阿里云容器镜像服务 (ACR)](https://cr.console.aliyun.com/)**
2. **[GitHub 新建仓库页面](https://github.com/new)**

---

### 第一步：阿里云 ACR 控制台配置（在已打开的阿里云页面）

1. 点击 **“个人版实例”**（免费开通）。
2. 点击左侧导航栏 **“访问凭证”**：
   - 设置一个固定的 **“设置访问密码”**（记录下此密码，用于后续 GitHub Actions 登录）。
   - 查看并记录你的 **用户名**（通常在密码上方显示）。
3. 点击左侧导航栏 **“命名空间”** $\rightarrow$ **“创建命名空间”**：
   - 命名空间名称：例如输入 `my-k8s-rook`（全局唯一，建议小写英文字母）。
   - 访问级别：选择 **“公开”**（国内拉取免登录更方便）或 **“私有”**。
   - **务必开启**：**“自动创建镜像仓库”**（非常重要，免去手动建仓库的麻烦）。
4. 记录你的地域域名（例如华东1杭州对应：`registry.cn-hangzhou.aliyuncs.com`）。

---

### 第二步：创建并推送 GitHub 仓库

1. 在已打开的 GitHub 页面中：
   - 输入 Repository name（例如：`k8s-image-sync`）。
   - 选择 Public 或 Private 均可。
   - 点击绿色的 **“Create repository”**。
2. 在本地终端（当前项目目录下）执行初始化并推送代码：
   ```bash
   git init
   git add .
   git commit -m "feat: add k8s and rook-ceph image sync workflow"
   git branch -M main
   # 替换为你刚创建的 github 仓库地址
   git remote add origin https://github.com/<你的GitHub用户名>/k8s-image-sync.git
   git push -u origin main
   ```

---

### 第三步：在 GitHub 仓库添加 Secrets 凭证

1. 进入刚创建的 GitHub 仓库页面。
2. 依次点击：**Settings** $\rightarrow$ 左侧 **Secrets and variables** $\rightarrow$ **Actions**。
3. 点击 **“New repository secret”** 按钮，分别添加以下两个变量：
   - **名称 1**：`ALIYUN_REGISTRY_USER`
     - 内容：第一步中获取的阿里云用户名
   - **名称 2**：`ALIYUN_REGISTRY_PASSWORD`
     - 内容：第一步中设置的 ACR 访问固定密码

---

### 第四步：一键运行同步工作流

1. 点击 GitHub 仓库顶部的 **Actions** 标签。
2. 在左侧选择 **“Sync IBM Spectrum Scale CSI Images to Aliyun ACR”**。
3. 点击右侧 **“Run workflow”** 下拉菜单：
   - 输入你的阿里云命名空间（如 `my-k8s-rook`）。
   - 输入地域代码（默认 `cn-hangzhou`）。
   - 点击绿色 **“Run workflow”** 按钮。
4. 海外服务器将在 **1~2 分钟内** 将所有海外镜像转存至你的阿里云 ACR。

---

### 第五步：国内机器拉取与推送至私有 Harbor

镜像同步完成后，在国内能连公网的机器上执行本目录下的脚本：

```bash
chmod +x pull-from-aliyun.sh

# 用法：./pull-from-aliyun.sh <命名空间> [阿里云专属域名] [内网私服地址]
./pull-from-aliyun.sh my-k8s-rook crpi-152y3mtli6krf23o.cn-hangzhou.personal.cr.aliyuncs.com registry.local/ibm-spectrum-scale
```
脚本会自动拉取阿里云镜像并批量标记、推送到你的离线内网 Harbor。
