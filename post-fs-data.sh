# Post Fs controller script

#Force high performance DAC by ZeroInfinity@XDA
#requires custom kernel support for uhqa
HPM=$(find /sys/module -name high_perf_mode)
change_module "$HPM" "1"

#Force impedance detection by UltraM8@XDA
IDE=$(find /sys/module -name impedance_detect_en)
change_module "$IDE" "1"

#Preallocate DMA memory buffer expander by UltraM8@XDA
MSS=$(find /sys/module -name maximum_substreams)
change_module "$MSS" "8"

#Double-volume for htc's 3.5 amp
BTS=$(find /sys/devices/virtual/switch/beats/state)
change_module "$BTS" "1"

#Quad DAC advanced mode
QDA=$(find /sys/devices -name force_advanced_mode)
change_module "$QDA" "1"