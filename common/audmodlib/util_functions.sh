##########################################################################################
#
# Magisk General Utility Functions
# by topjohnwu
#
# Modified for Unity Installer by Ahrion and Zackptg5
# Base Script Version: 1400
#
##########################################################################################

get_outfd() {
  readlink /proc/$$/fd/$OUTFD 2>/dev/null | grep /tmp >/dev/null
  if [ "$?" -eq "0" ]; then
    OUTFD=0

    for FD in `ls /proc/$$/fd`; do
      readlink /proc/$$/fd/$FD 2>/dev/null | grep pipe >/dev/null
      if [ "$?" -eq "0" ]; then
        ps | grep " 3 $FD " | grep -v grep >/dev/null
        if [ "$?" -eq "0" ]; then
          OUTFD=$FD
          break
        fi
      fi
    done
  fi
}

ui_print() {
  if $BOOTMODE; then
    echo "$1"
  else
    echo -n -e "ui_print $1\n" >> /proc/self/fd/$OUTFD
    echo -n -e "ui_print\n" >> /proc/self/fd/$OUTFD
  fi
}

grep_prop() {
  REGEX="s/^$1=//p"
  shift
  FILES=$@
  [ -z "$FILES" ] && FILES="$SYS/build.prop"
  sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
}

getvar() {
  local VARNAME=$1
  local VALUE=$(eval echo \$$VARNAME)
  [ ! -z $VALUE ] && return
  for DIR in /dev /data /cache $SYS; do
    VALUE=`grep_prop $VARNAME $DIR/.magisk`
    [ ! -z $VALUE ] && break;
  done
  eval $VARNAME=\$VALUE
}

find_boot_image() {
  if [ -z "$BOOTIMAGE" ]; then
    for BLOCK in boot_a kern-a android_boot kernel boot lnx; do
      BOOTIMAGE=`find /dev/block -iname $BLOCK | head -n 1` 2>/dev/null
      [ ! -z $BOOTIMAGE ] && break
    done
  fi
  # Recovery fallback
  if [ -z "$BOOTIMAGE" ]; then
    for FSTAB in /etc/*fstab*; do
      BOOTIMAGE=`grep -v '#' $FSTAB | grep -E '\b/boot\b' | grep -oE '/dev/[a-zA-Z0-9_./-]*'`
      [ ! -z $BOOTIMAGE ] && break
    done
  fi
  [ -L "$BOOTIMAGE" ] && BOOTIMAGE=`readlink $BOOTIMAGE`
}

migrate_boot_backup() {
  # Update the broken boot backup
  if [ -f /data/stock_boot_.img.gz ]; then
    ./magiskboot --decompress /data/stock_boot_.img.gz
    mv /data/stock_boot_.img /data/stock_boot.img
  fi
  # Update our previous backup to new format if exists
  if [ -f /data/stock_boot.img ]; then
    ui_print "- Migrating boot image backup"
    SHA1=`./magiskboot --sha1 /data/stock_boot.img 2>/dev/null`
    STOCKDUMP=/data/stock_boot_${SHA1}.img
    mv /data/stock_boot.img $STOCKDUMP
    ./magiskboot --compress $STOCKDUMP
  fi
}

sign_chromeos() {
  echo > empty

  ./chromeos/futility vbutil_kernel --pack new-boot.img.signed \
  --keyblock ./chromeos/kernel.keyblock --signprivate ./chromeos/kernel_data_key.vbprivk \
  --version 1 --vmlinuz new-boot.img --config empty --arch arm --bootloader empty --flags 0x1

  rm -f empty new-boot.img
  mv new-boot.img.signed new-boot.img
}
					   
is_mounted() {
  if [ ! -z "$2" ]; then
    cat /proc/mounts | grep $1 | grep $2, >/dev/null
  else
    cat /proc/mounts | grep $1 >/dev/null
  fi
  return $?
}

remove_system_su() {
  if [ -f $SYS/bin/su -o -f $SYS/xbin/su ] && [ ! -f /su/bin/su ]; then
    ui_print "! System installed root detected, mount rw :("
    mount -o rw,remount $SYS
    # SuperSU
    if [ -e $SYS/bin/.ext/.su ]; then
      mv -f $SYS/bin/app_process32_original $SYS/bin/app_process32 2>/dev/null
      mv -f $SYS/bin/app_process64_original $SYS/bin/app_process64 2>/dev/null
      mv -f $SYS/bin/install-recovery_original.sh $SYS/bin/install-recovery.sh 2>/dev/null
      cd $SYS/bin
      if [ -e app_process64 ]; then
        ln -sf app_process64 app_process
      else
        ln -sf app_process32 app_process
      fi
    fi
    rm -rf $SYS/.pin $SYS/bin/.ext $SYS/etc/.installed_su_daemon $SYS/etc/.has_su_daemon \
    $SYS/xbin/daemonsu $SYS/xbin/su $SYS/xbin/sugote $SYS/xbin/sugote-mksh $SYS/xbin/supolicy \
    $SYS/bin/app_process_init $SYS/bin/su /cache/su $SYS/lib/libsupol.so $SYS/lib64/libsupol.so \
    $SYS/su.d $SYS/etc/install-recovery.sh $SYS/etc/init.d/99SuperSUDaemon /cache/install-recovery.sh \
    $SYS/.supersu /cache/.supersu /data/.supersu \
    $SYS/app/Superuser.apk $SYS/app/SuperSU /cache/Superuser.apk  2>/dev/null
  fi
}

api_level_arch_detect() {
  API=`grep_prop ro.build.version.sdk`
  ABI=`grep_prop ro.product.cpu.abi | cut -c-3`
  ABI2=`grep_prop ro.product.cpu.abi2 | cut -c-3`
  ABILONG=`grep_prop ro.product.cpu.abi`
  MIUIVER=`grep_prop ro.miui.ui.version.name`

  ARCH=arm
  DRVARCH=NEON
  IS64BIT=false
  if [ "$ABI" = "x86" ]; then ARCH=x86; DRVARCH=X86; fi;
  if [ "$ABI2" = "x86" ]; then ARCH=x86; DRVARCH=X86; fi;
  if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; IS64BIT=true; fi;
  if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; IS64BIT=true; DRVARCH=X86; fi;
}

boot_actions() {
  if [ ! -d /dev/magisk/mirror/bin ]; then
    mkdir -p /dev/magisk/mirror/bin
    mount -o bind $MAGISKBIN /dev/magisk/mirror/bin
  fi
  MAGISKBIN=/dev/magisk/mirror/bin
}

recovery_actions() {
  # TWRP bug fix
  mount -o bind /dev/urandom /dev/random
  # Preserve environment varibles
  OLD_PATH=$PATH
  OLD_LD_PATH=$LD_LIBRARY_PATH
  if [ ! -d $TMPDIR/bin ]; then
    # Add busybox to PATH
    mkdir -p $TMPDIR/bin
    ln -s $MAGISKBIN/busybox $TMPDIR/bin/busybox
    $MAGISKBIN/busybox --install -s $TMPDIR/bin
    export PATH=$TMPDIR/bin:$PATH
  fi
  # Temporarily block out all custom recovery binaries/libs
  mv /sbin /sbin_tmp
  # Add all possible library paths
  $IS64BIT && export LD_LIBRARY_PATH=$SYS/lib64:$VEN/lib64 || export LD_LIBRARY_PATH=$SYS/lib:$VEN/lib
}

recovery_cleanup() {
  mv /sbin_tmp /sbin 2>/dev/null
  export LD_LIBRARY_PATH=$OLD_LD_PATH
  [ -z $OLD_PATH ] || export PATH=$OLD_PATH
  ui_print "   Unmounting partitions..."
  umount -l /system 2>/dev/null
  umount -l /vendor 2>/dev/null
  umount -l /dev/random 2>/dev/null
}

abort() {
  ui_print "$1"
  $BOOTMODE || recovery_cleanup
  exit 1
}

set_perm() {
  chown $2:$3 $1 || exit 1
  chmod $4 $1 || exit 1
  [ -z $5 ] && chcon -h 'u:object_r:system_file:s0' $1 || chcon -h $5 $1
}

set_perm_recursive() {
  find $1 -type d 2>/dev/null | while read dir; do
    set_perm $dir $2 $3 $4 $6
  done
  find $1 -type f -o -type l 2>/dev/null | while read file; do
    set_perm $file $2 $3 $5 $6
  done
}

mktouch() {
  mkdir -p ${1%/*} 2>/dev/null
  [ -z $2 ] && touch $1 || echo $2 > $1
  chmod 644 $1
}

request_size_check() {
  reqSizeM=`du -s $1 | cut -f1`
  reqSizeM=$((reqSizeM / 1024 + 1))
}

request_zip_size_check() {
  reqSizeM=`unzip -l "$1" | tail -n 1 | awk '{ print int($1 / 1048567 + 1) }'`
}

image_size_check() {
  SIZE="`$MAGISKBIN/magisk --imgsize $IMG`"
  curUsedM=`echo "$SIZE" | cut -d" " -f1`
  curSizeM=`echo "$SIZE" | cut -d" " -f2`
  curFreeM=$((curSizeM - curUsedM))
}

require_new_magisk() {
  ui_print "***********************************"
  ui_print "! $MAGISKBIN isn't setup properly!"
  ui_print "! Please install Magisk v13.7+!"
  ui_print "***********************************"
  exit 1
}

require_new_api() {
  ui_print "***********************************"
  ui_print "!   Your system API of $API doesn't"
  ui_print "!    meet the minimum API of $MINAPI"
  ui_print "! Please upgrade to a newer version"
  ui_print "!  of android with at least API $MINAPI"
  ui_print "***********************************"
  exit 1
}
