# 开源项目地址
https://github.com/opendatalab/MinerU

# 安装
## pip直接安装（cpu）
```
pip install --upgrade pip
pip install uv
uv pip install -U "mineru[core]"
```

## pip源码安装（cpu）
```
git clone https://github.com/opendatalab/MinerU.git
cd MinerU
uv pip install -e .[core]
```
## docker镜像构建安装（gpu）
官方文档：https://opendatalab.github.io/MinerU/quick_start/docker_deployment/
```
# 下载dockerfile
wget https://gcore.jsdelivr.net/gh/opendatalab/MinerU@master/docker/global/Dockerfile

# 构建本地镜像
docker build -t mineru-sglang:latest -f Dockerfile .
```
镜像说明：MinerU 的 Docker 使用 lmsysorg/sglang 作为基础镜像，因此默认包含 sglang 推理加速框架和必要的依赖项。因此，在兼容设备上，您可以直接使用 sglang 来加速 VLM 模型推理。使用 sglang 加速 VLM 模型推理的要求：
1. 设备必须配备图灵架构或更新的显卡，并具有 8GB 或以上可用显存。V100不行，RTX 2080Ti及以上可以。
2. 主机机器的图形驱动程序应支持 CUDA 12.6 或更高版本； Blackwell 平台应支持 CUDA 12.8 或更高版本。您可以使用 nvidia-smi 命令检查驱动程序版本。
3. Docker 容器必须能够访问主机机器的图形设备。主机需安装nvidia-container-toolkit。

```
# 运行容器
docker run --gpus all \
  --shm-size 32g \
  -p 30000:30000 -p 7860:7860 -p 8000:8000 \
  --ipc=host \
  -it mineru-sglang:latest \
  /bin/bash
```
通过docker run，不太方便，可以使用官方的docker compose文件。
```
# Download compose.yaml file
wget https://gcore.jsdelivr.net/gh/opendatalab/MinerU@master/docker/compose.yaml

# 启动api服务
docker compose -f compose.yaml --profile api up -d

# 启动web服务
docker compose -f compose.yaml --profile gradio up -d

# 启动sglang server服务
docker compose -f compose.yaml --profile sglang-server up -d
```

## 使用MinerU
1. 命令行方式将pdf转md
```
mineru -p <input_path> -o <output_path>
```