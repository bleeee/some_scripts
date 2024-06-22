#!/bin/bash

# 定义目标IP地址
TARGET_IP="10.218.8.1"

# 定义ping次数
PING_COUNT=4

# 检查wg0网络接口是否存在
if ip link show usb0 > /dev/null 2>&1; then
    echo "usb0 interface exists. Checking packet loss..."
    if ip link show wg0 > /dev/null 2>&1; then
        echo "wg0 interface exists. Checking packet loss..."

        # 运行ping命令并检查丢包率
        LOSS=$(ping -c $PING_COUNT $TARGET_IP | grep -oP '\d+(?=% packet loss)')

        # 如果丢包率为100%，则重启WireGuard服务
        if [ "$LOSS" -eq 100 ]; then
            echo "100% packet loss detected. Restarting WireGuard service..."
            sudo systemctl restart wg-quick@wg0
        else
            echo "Packet loss is $LOSS%. No need to restart WireGuard."
        fi
    else
        echo "wg0 interface does not exist. Exiting script."
    fi
else
    echo "usb0 interface does not exist. Exiting script."
fi
