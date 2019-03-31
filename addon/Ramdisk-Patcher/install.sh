[ -d "$RD" ] || unpack_ramdisk
rm -f $TMPDIR/addon/Ramdisk-Patcher/ramdisk/placeholder
# Remove ramdisk mod if exists
if [ "$(grep "#$MODID-UnityIndicator" $RD/init.rc 2>/dev/null)" ]; then
  ui_print " "
  ui_print "   ! Mod detected in ramdisk!"
  ui_print "   ! Upgrading mod ramdisk modifications..."
  uninstall_files $INFORD
  sed -i "/#$MODID-UnityIndicator/d" $RD/init.rc
  . $TMPDIR/addon/Ramdisk-Patcher/ramdiskuninstall.sh
fi
# Script to remove mod from system/magisk in event mod is only removed from ramdisk (like dirty flashing)
cp -f $TMPDIR/addon/Ramdisk-Patcher/modidramdisk.sh $UF/$MODID-ramdisk.sh
sed -i -e "/# CUSTOM USER SCRIPT/ r $TMPDIR/common/uninstall.sh" -e '/# CUSTOM USER SCRIPT/d' $UF/$MODID-ramdisk.sh
install_script -p $UF/$MODID-ramdisk.sh
# Use comment as install indicator
echo "#$MODID-UnityIndicator" >> $RD/init.rc
. $TMPDIR/addon/Ramdisk-Patcher/ramdiskinstall.sh
for FILE in $(find $TMPDIR/addon/Ramdisk-Patcher/ramdisk -type f 2>/dev/null | sed "s|$TMPDIR/addon/Ramdisk-Patcher||" 2>/dev/null); do
  cp_ch $TMPDIR/addon/Ramdisk-Patcher/$FILE $UF/boot$FILE
done
[ ! -s $INFORD ] && rm -f $INFORD
