patch_xml() {
  if [ "$(xmlstarlet sel -t -m "$3" -c . $2)" ]; then
    [ $(xmlstarlet sel -t -m "$3" -c . $2 | sed -r "s/.*value=\"(.*)\".*/\1/") == $4 ] && return
    xmlstarlet ed -L -i "$3" -t elem -n "$MODID" $2
    local LN=$(sed -n "/<$MODID\/>/=" $2)
    for i in ${LN}; do
      sed -i "$i d" $2
      sed -i "$i p" $2
      sed -ri "${i}s/(^ *)(.*)/\1<!--$MODID\2$MODID-->/" $2
      sed -i "$((i+1))s/$/<!--$MODID-->/" $2
    done
    [ "$1" == "-u" -o "$1" == "-s" ] && xmlstarlet ed -L -u "$3/@value" -v "$4" $2
  elif [ "$1" == "-s" ]; then
    local NP=$(echo "$3" | sed -r "s|(^.*)/.*$|\1|")
    local SNP=$(echo "$3" | sed -r "s|(^.*)\[.*$|\1|")
    local SN=$(echo "$3" | sed -r "s|^.*/.*/(.*)\[.*$|\1|")
    local AN=$(echo "$3" | sed -r "s|^.*/.*\[@.*=\"(.*)\".*$|\1|")
    xmlstarlet ed -L -s "$NP" -t elem -n "$SN-$MODID" -i "$SNP-$MODID" -t attr -n "name" -v "$AN" -i "$SNP-$MODID" -t attr -n "value" -v "$4" $2
    xmlstarlet ed -L -r "$SNP-$MODID" -v "$SN" $2
    xmlstarlet ed -L -i "$3" -t elem -n "$MODID" $2
    local LN=$(sed -n "/<$MODID\/>/=" $2)
    for i in ${LN}; do
      sed -i "$i d" $2
      sed -ri "${i}s/$/<!--$MODID-->/" $2
    done 
  fi
  local LN=$(sed -n "/^ *<!--$MODID-->$/=" $2 | tac)
  for i in ${LN}; do
    sed -i "$i d" $2
    sed -ri "$((i-1))s/$/<!--$MODID-->/" $2
  done 
}

if [ -d "$RD/odm" ]; then
  MIXS="$(find $RD/odm -type f -name "mixer_paths*.xml")"
  ui_print "   Adding patches to odm mixers..."  
  for MIX in ${MIXS}; do
    #ODMPATCHES
  done
else
  ui_print "   No odm folder present!"
  ui_print "   No need to patch boot img"
fi
