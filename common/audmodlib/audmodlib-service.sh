#!/system/bin/sh
# This script will be executed in late_start service mode
# More info in the main Magisk thread
MODID=audmodlib

if [ ! -d /magisk/$MODID ]; then
  rm /cache/$MODID-service.log
  rm -f /magisk/.core/service.d/$MODID.sh
else
  test -f "/magisk/audmodlib/update" && rm -f /magisk/audmodlib/update

  # DETERMINE IF PIXEL (A/B OTA) DEVICE
  ABDeviceCheck=$(cat /proc/cmdline | grep slot_suffix | wc -l)
  if [ "$ABDeviceCheck" -gt 0 ]; then
    isABDevice=true
    if [ -d "/system_root" ]; then
        SYS=/system_root/system
    else
        SYS=/system/system
    fi
  else
    isABDevice=false
    SYS=/system
  fi

  if [ $isABDevice == true ] || [ ! -d $SYS/vendor ]; then
    VEN=/vendor
  else
    VEN=$SYS/vendor
  fi

  supersuimg=$(ls /cache/su.img /data/su.img 2>/dev/null);

  supersu_is_mounted() {
    case `mount` in
    *" $1 "*) echo 1;;
    *) echo 0;;
  esac;
  }

  if [ "$supersuimg" ]; then
    if [ "$(supersu_is_mounted /su)" == 0 ]; then
      test ! -e /su && mkdir /su;
     mount -t ext4 -o rw,noatime $supersuimg /su 2>/dev/null
      for i in 0 1 2 3 4 5 6 7; do
	    test "$(supersu_is_mounted /su)" == 1 && break;
	    loop=/dev/block/loop$i;
	    mknod $loop b 7 $i;
	    losetup $loop $supersuimg;
	    mount -t ext4 -o loop $loop /su; 2>/dev/null
      done;
    fi;
  fi;

  # DETERMINE ROOT BOOT SCRIPT TYPE
  EXT=".sh"
  if [ -f /data/magisk.img ] || [ -f /cache/magisk.img ] || [ -d /magisk ]; then
    MAGISK=true
    SEINJECT=magiskpolicy
    SH=/magisk/.core/post-fs-data.d
  elif [ "$supersuimg" ] || [ -d /su ]; then
    SEINJECT=/su/bin/supolicy
    SH=/su/su.d
  elif [ -d $SYS/su ] || [ -f $SYS/xbin/daemonsu ] || [ -f $SYS/xbin/sugote ]; then
    SEINJECT=$SYS/xbin/supolicy
    SH=$SYS/su.d
  elif [ -f $SYS/xbin/su ]; then
    if [ "$(cat $SYS/xbin/su | grep SuperSU)" ]; then
      SEINJECT=$SYS/xbin/supolicy
      SH=$SYS/su.d
    else
      SEINJECT=/sepolicy
      SH=$SYS/etc/init.d
      EXT=""
    fi
  else
    SEINJECT=/sepolicy
    SH=$SYS/etc/init.d
    EXT=""
  fi

  if [ -d $SYS/priv-app ]; then
    SOURCE=priv_app
  else
    SOURCE=system_app
  fi

  $SEINJECT --live "allow audioserver audioserver_tmpfs file { read write execute }" \
  "allow audioserver system_file file { execmod }" \
  "allow mediaserver mediaserver_tmpfs file { read write execute }" \
  "allow mediaserver system_file file { execmod }" \
  "allow $SOURCE init unix_stream_socket { connectto }" \
  "allow $SOURCE property_socket sock_file { getattr open read write execute }"

  $SEINJECT --live "permissive $SOURCE audio_prop"

  LOG_FILE=/cache/$MODID-service.log
  if [ -e /cache/$MODID-service.log ]; then
    rm -f /cache/$MODID-service.log
  fi

  echo "$SH/$MODID-service$EXT has run successfully $(date +"%m-%d-%Y %H:%M:%S")" | tee -a $LOG_FILE;
fi
