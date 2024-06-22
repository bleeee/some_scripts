#!/bin/bash
# 获取当前时间
TIME=$(date +"%Y%m%d-%H-%M")
# 获取CPU温度
TEMP=$(vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*')
# 记录到文件
echo "$TIME, $TEMP" >> /root/temp.txt
