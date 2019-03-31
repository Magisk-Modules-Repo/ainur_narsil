# Put uninstall only logic here
if [ -d "$RD/odm" ]; then
  MIXS="$(find $RD/odm -type f -name "mixer_paths*.xml")"
  ui_print "   Removing patches from odm mixers..."
  for MIX in ${MIXS}; do
    sed -i "/<!--$MODID-->/d" $MIX
    sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $MIX
  done
else
  ui_print "   No odm folder present!"
  ui_print "   No need to patch boot img"
fi
