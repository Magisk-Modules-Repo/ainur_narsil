#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
#MODDIR=${0%/*}

# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

ABDeviceCheck=$(cat /proc/cmdline | grep slot_suffix | wc -l)
if [ "$ABDeviceCheck" -gt 0 ]; then
  isABDevice=true
  if [ -d "/system_root" ]; then
    ROOT=/system_root
    SYS=$ROOT/system
  else
    ROOT=""
    SYS=$ROOT/system/system
  fi
else
  isABDevice=false
  ROOT=""
  SYS=$ROOT/system
fi

if [ $isABDevice == true ] || [ ! -d $SYS/vendor ]; then
  VEN=/vendor
else
  VEN=$SYS/vendor
fi

#Force high performance DAC by ZeroInfinity@XDA
HPM=$(find $ROOT/sys/module -name high_perf_mode)
if [ $HPM ]; then
	chmod 666 $HPM
	echo "1" > $HPM
	chmod 444 $HPM
fi

#Force impedance detection by UltraM8@XDA
IDE=$(find $ROOT/sys/module -name impedance_detect_en)
if [ $IDE ]; then
	chmod 666 $IDE
	echo "1" > $IDE
	chmod 444 $IDE
fi

MSS=$(find $ROOT/sys/module -name maximum_substreams)
if [ $MSS ]; then
	chmod 666 $MSS
	echo "16" > $MSS
	chmod 444 $MSS
fi

if [ -f "$ROOT/sys/devices/virtual/switch/beats/state" ]; then
	chmod 666 $BTS
	echo "1" > $BTS
	chmod 444 $BTS
fi
