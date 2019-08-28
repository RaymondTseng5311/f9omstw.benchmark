#!/bin/bash

service irqbalance stop

# 將 CPU 時脈調到最高.
# max_freq=$(for i in $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies); do echo $i; done | sort -nr | head -1)
# for cpu_max_freq in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do echo $max_freq > $cpu_max_freq; done
for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > $governor; done

