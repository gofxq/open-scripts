#!/bin/bash

# 获取连接的设备列表并选择第一个设备
device=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')

if [ -z "$device" ]; then
    echo "No device found."
    exit 1
else
    echo "Using device: $device"
fi

# 获取设备的屏幕大小
screen_size=$(adb -s $device shell wm size | awk '{print $3}')
screen_width=${screen_size%x*}
screen_height=${screen_size#*x}

# 计算基本滑动坐标，基于屏幕中心向上滑动
base_start_x=$((screen_width / 2))
base_start_y=$((screen_height * 4 / 5))
base_end_x=$((screen_width / 2))
base_end_y=$((screen_height / 5))

# 设置随机变化的范围
random_range=100

echo "Screen size: $screen_width x $screen_height"

while true; do
    # 计算随机起点和终点
    start_x=$((base_start_x - random_range / 2 + RANDOM % random_range))
    start_y=$((base_start_y - random_range / 2 + RANDOM % random_range))
    end_x=$((base_end_x - random_range / 2 + RANDOM % random_range))
    end_y=$((base_end_y - random_range / 2 + RANDOM % random_range))

    # 输出即将执行的滑动操作的日志
    echo "Swiping from ($start_x, $start_y) to ($end_x, $end_y)"

    # 执行滑动操作
    adb -s $device shell input swipe $start_x $start_y $end_x $end_y

    # 随机等待时间15-30秒
    sleep_time=$((15 + RANDOM % 16))
    # 倒计时实现
    while [ $sleep_time -gt 0 ]; do
        echo -ne "Sleep count down $sleep_times \033[0K\r"
        sleep 1
        ((sleep_time--))
    done
done
