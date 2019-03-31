# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread
DSPBLOCK=<DSPBLOCK>

if [ ! -d "$MOUNTEDROOT/ainur_sauron" ] && [ -f "$MOUNTEDROOT/ainur_sauron/sauron-files" ]; then
  [ "$DSPBLOCK" ] && mount -o remount,rw /dsp
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 4)" == ".bak" ]; then
      continue
    elif [ -f "$LINE.bak" ]; then
      mv -f $LINE.bak $LINE
    else
      rm -f $LINE
    fi      
  done < $MOUNTEDROOT/ainur_sauron/sauron-files
  [ "$DSPBLOCK" ] && mount -o remount,ro /dsp
  rm -f $MOUNTEDROOT/ainur_sauron/sauron-files $0
fi
