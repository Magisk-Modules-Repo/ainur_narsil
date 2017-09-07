#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread

ABDeviceCheck=$(cat /proc/cmdline | grep slot_suffix | wc -l)
if [ "$ABDeviceCheck" -gt 0 ]; then
  isABDevice=true
  if [ -d "/system_root" ]; then
    ROOT=/system_root
    SYSTEM=$ROOT/system
  else
    ROOT=""
    SYSTEM=$ROOT/system/system
  fi
else
  isABDevice=false
  ROOT=""
  SYSTEM=$ROOT/system
fi

if [ $isABDevice == true ] || [ ! -d $SYSTEM/vendor ]; then
  VENDOR=/vendor
else
  VENDOR=$SYSTEM/vendor
fi

if [ -e "$MODDIR/sauron_alsa" ]; then
  $SYSTEM/bin/sh $MODDIR/sauron_alsa
fi
