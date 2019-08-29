# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=auto;
is_slot_device=auto;
ramdisk_compression=auto;
MODID=ainur_sauron;
UNINSTALL=false;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
# set_perm_recursive 0 0 755 644 $ramdisk/*;
# set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;


## AnyKernel install
dump_boot;

# begin ramdisk changes

patch_xml() {
  if [ "$($tools/xmlstarlet sel -t -m "$3" -c . $2)" ]; then
    [ $($tools/xmlstarlet sel -t -m "$3" -c . $2 | $tools/sed -r "s/.*value=\"(.*)\".*/\1/") == $4 ] && return
    $tools/xmlstarlet ed -L -i "$3" -t elem -n "$MODID" $2
    local LN=$($tools/sed -n "/<$MODID\/>/=" $2)
    for i in ${LN}; do
      $tools/sed -i "$i d" $2
      $tools/sed -i "$i p" $2
      $tools/sed -ri "${i}s/(^ *)(.*)/\1<!--$MODID\2$MODID-->/" $2
      $tools/sed -i "$((i+1))s/$/<!--$MODID-->/" $2
    done
    [ "$1" == "-u" -o "$1" == "-s" ] && $tools/xmlstarlet ed -L -u "$3/@value" -v "$4" $2
  elif [ "$1" == "-s" ]; then
    local NP=$(echo "$3" | $tools/sde -r "s|(^.*)/.*$|\1|")
    local SNP=$(echo "$3" | $tools/sed -r "s|(^.*)\[.*$|\1|")
    local SN=$(echo "$3" | $tools/sed -r "s|^.*/.*/(.*)\[.*$|\1|")
    local AN=$(echo "$3" | $tools/sed -r "s|^.*/.*\[@.*=\"(.*)\".*$|\1|")
    $tools/xmlstarlet ed -L -s "$NP" -t elem -n "$SN-$MODID" -i "$SNP-$MODID" -t attr -n "name" -v "$AN" -i "$SNP-$MODID" -t attr -n "value" -v "$4" $2
    $tools/xmlstarlet ed -L -r "$SNP-$MODID" -v "$SN" $2
    $tools/xmlstarlet ed -L -i "$3" -t elem -n "$MODID" $2
    local LN=$($tools/sed -n "/<$MODID\/>/=" $2)
    for i in ${LN}; do
      $tools/sed -i "$i d" $2
      $tools/sed -ri "${i}s/$/<!--$MODID-->/" $2
    done
  fi
  local LN=$($tools/sed -n "/^ *<!--$MODID-->$/=" $2 | tac)
  for i in ${LN}; do
    $tools/sed -i "$i d" $2
    $tools/sed -ri "$((i-1))s/$/<!--$MODID-->/" $2
  done
}

MIXS="$(find $ramdisk/odm -type f -name "mixer_paths*.xml" 2>/dev/null)"
if [ "$MIXS" ]; then
  $UNINSTALL && ui_print "Removing patches from odm mixers..." || ui_print "Patching odm mixers..."
  for MIX in ${MIXS}; do
    $tools/sed -i "/<!--$MODID-->/d" $MIX
    $tools/sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $MIX
    $UNINSTALL && continue
    #ODMPATCHES
  done
else
  ui_print "   No odm folder detected!"
  ui_print "   No need to patch ramdisk"
  abort ""
fi

# end ramdisk changes

write_boot;
## end install
