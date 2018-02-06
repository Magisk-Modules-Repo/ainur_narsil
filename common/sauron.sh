#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
PATH=${0%/*}
DSPBLOCK=<DSPBLOCK>

if [ ! -d "/sbin/.core/img/ainur_sauron" ] && [ -f "$PATH/sauron-files" ]; then
  [ "$DSPBLOCK" ] && mount -o remount,rw /dsp
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 4)" == ".bak" ]; then
      continue
    elif [ -f "$LINE.bak" ]; then
      mv -f $LINE.bak $LINE
    else
      rm -f $LINE
    fi      
  done < $PATH/sauron-files
  [ "$DSPBLOCK" ] && mount -o remount,ro /dsp
  rm -f $PATH/sauron-files $0
fi
