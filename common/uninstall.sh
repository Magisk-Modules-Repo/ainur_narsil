AUO=$UNITY$SYS/etc/sauron_useroptions
read_uo
rm -f $AUO

if $MAGISK && ! $SYSOVERRIDE; then
  rm -f $MOUNTPATH/.core/post-fs-data.d/sauron.sh $MOUNTPATH/.core/post-fs-data.d/sauron-files
else
  mv -f $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin.bak $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin
  mv -f $UNITY$VEN/firmware/tas2557s_uCDSP.bin.bak $UNITY$VEN/firmware/tas2557s_uCDSP.bin
  mv -f $UNITY$VEN/firmware/tas2557_cal.bin.bak $UNITY$VEN/firmware/tas2557_cal.bin
  for OFILE in ${CFGS}; do
    FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
    case $FILE in
      *.conf) $ASP && sed -i "/audiosphere { #$MODID/,/} #$MODID/d" $FILE
              $SHB && sed -i "/libshoebox { #$MODID/,/} #$MODID/d" $FILE
              if $FMAS; then
                [ "$QCP" -a "$CFG" == "$SYS/etc/audio_effects.conf" ] && continue
                if [ "$(grep "#$MODID *library bundle.*" $FILE)" ] || [ "$(grep "#$MODID *library downmix.*" $FILE)" ]; then
                  sed -i -e "/library fmas #$MODID/d" -e "/uuid 36103c50-8514-11e2-9e96-0800200c9a66 #$MODID/d" $FILE
                fi
                sed -i "/fmas { #$MODID/,/} #$MODID/d" $FILE
                sed -ri -e "s|#$MODID(.*)|\1|g" $FILE
              fi;;
      *.xml) sed -i "/<!--$MODID-->/d" $FILE
             if $FMAS; then
               sed -ri "/<!--(.*<effect name=\"virtualizer\".*)$MODID-->/ s/\1/g" $FILE
               sed -ri "/<!--(.*<effect name=\"downmix\".*)$MODID-->/ s/\1/g" $FILE
             fi;;
    esac  
  done
  for OMIX in ${MIXS}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    sed -i "/<!--$MODID-->/d" $MIX
    sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $MIX
  done
fi
