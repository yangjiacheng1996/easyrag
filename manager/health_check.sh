#!/bin/bash

# 脚本全局变量-----------------------------------------------
# Stirling-pdf
stirling_base_url="http://127.0.0.1:18000"
stirling_status_location="/api/v1/info/status"


# 函数库-----------------------------------------------------
check_stirling_status() {
    local base_url="$1"
    local status_path="$2"
    local full_url="${base_url}${status_path}"
    local expected_status="UP"
    local timeout_sec=5

    echo "正在检查Stirling-PDF服务状态..."
    echo "请求URL: $full_url"

    # 使用curl发送GET请求（参考了curl状态检查的最佳实践[1,4](@ref)）
    response=$(curl -sS -X 'GET' \
        -m $timeout_sec \
        -H 'accept: */*' \
        -w "\n%{http_code}" \
        "$full_url" 2>&1)

    # 分离HTTP状态码和响应体（参考HTTP状态码处理方法[3](@ref)）
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | sed '$d')

    # 验证结果（参考服务监控脚本的逻辑[5](@ref)）
    if [ "$http_code" -eq 200 ]; then
        # 检查服务状态字段（使用jq解析JSON，若未安装会有明确提示）
        if command -v jq &>/dev/null; then
            status=$(echo "$response_body" | jq -r '.status')
            version=$(echo "$response_body" | jq -r '.version')
            
            if [ "$status" = "$expected_status" ]; then
                echo -e "\033[1;32m✓ 服务运行正常 (版本: $version, 状态: $status)\033[0m"
                return 0
            else
                echo -e "\033[1;31m✗ 服务异常 (状态: $status)\033[0m"
                echo "完整响应: $response_body"
                return 1
            fi
        else
            echo -e "\033[1;33m⚠ 系统未安装jq命令，改用grep对命令返回做解析。\033[0m"
            echo "原始响应: $response_body"
            # 尝试通过grep简单匹配
            if echo "$response_body" | grep -q "\"status\":\"UP\""; then
                echo -e "\033[1;32m✓ 服务可能运行正常（基于关键词匹配）\033[0m"
                return 0
            else
                echo -e "\033[1;31m✗ 服务状态不确定\033[0m"
                return 1
            fi
        fi
    else
        echo -e "\033[1;31m✗ HTTP请求失败 (状态码: $http_code)\033[0m"
        echo "错误详情: $response_body"
        return 1
    fi
}

# 执行检查---------------------------------------------------
# Stirling-PDF服务可用性检查
check_stirling_status "$stirling_base_url" "$stirling_status_location"
if [ $? -eq 0 ]; then
    echo "stirling-pdf状态检查通过，服务正常运行"
else
    echo "stirling-pdf状态检查未通过，服务可能存在问题"
    exit 1
fi