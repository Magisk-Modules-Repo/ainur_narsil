[ -d "$RD" ] || unpack_ramdisk
uninstall_files $INFORD "~"
sed -i "/#$MODID-UnityIndicator/d" $RD/init.rc
. $TMPDIR/addon/Ramdisk-Patcher/ramdiskuninstall.sh
