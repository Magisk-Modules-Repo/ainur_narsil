# FUNCTIONS
backup_and_patch() {
  if [ -z $6 ]; then
    if [ ! "$(grep "#$MODID *$2.*" $4)" ] && [ ! "$(grep " *$3 *$" $4)" ]; then
      sed -i "/$1 {/,/}/ s/\( *\)$2\(.*\)/$MODID\1$2\2\n#$MODID\1$2\2/g;" $4
      sed -ri "s/^$MODID( *)$2.*/\1$3 #$MODID/g" $4
    fi
  else
    if [ ! "$(grep "#$MODID *$2.*" $6)" ] && [ ! "$(grep " *$3 *$" $6)" ]; then
      sed -i "/$1 {/,/}/ s/\( *\)$2\(.*\)/$MODID\1$2\2\n#$MODID\1$2\2/g; s/\( *\)$4\(.*\)/$MODID\1$4\2\n#$MODID\1$4\2/g;" $6
      sed -ri -e "s/^$MODID( *)$2.*/\1$3 #$MODID/g" -e "s/^$MODID( *)$4.*/\1$5 #$MODID/" $6
    fi
  fi
}
patch_audpol() {
  if [ "$(sed -n "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"$1\"/,/<\/mixPort>/p}" $3)" ]; then
    sed -n "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"$1\"/,/<\/mixPort>/p}" $3 > $INSTALLER/tpatch
    sed -i -e "s/^\( *\)<mixPort/\1<!--BEG-$MODID--><mixPort/" -e "s/<\/mixPort>/<\/mixPort><!--END-$MODID-->/" $INSTALLER/tpatch
    sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"$1\"/,/<\/mixPort>/ {$2}}" $INSTALLER/tpatch
    line=$(($(sed -n "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"$1\"/=}" $3) - 1))
    sed -i "/<module name=\"primary\"/,/<\/module>/ { s/^\( *\)\(<mixPort name=\"$1\"\)/\1<!--$MODID\2/; /<!--$MODID<mixPort name=\"$1\"/,/<\/mixPort>/{s/\(<\/mixPort>\)/\1$MODID-->/}}" $3
    sed -i "$line r $INSTALLER/tpatch" $3
  fi
}
patch_xml() {
  local VAR1 VAR2 NAME NAMEC VALC VAL
  NAME=$(echo "$3" | sed -r "s|^.*/.*\[@.*=\"(.*)\".*$|\1|")
  NAMEC=$(echo "$3" | sed -r "s|^.*/.*\[@(.*)=\".*\".*$|\1|")
  if [ "$(echo $4 | grep '=')" ]; then
    VALC=$(echo "$4" | sed -r "s|(.*)=.*|\1|"); VAL=$(echo "$4" | sed -r "s|.*=(.*)|\1|")
  else
    VALC="value"; VAL="$4"
  fi
  case $2 in
    *mixer_paths*.xml) sed -i "/#MIXERPATCHES/a\                       patch_xml $1 \$MODPATH/\$NAME '$3' \"$4\"" $INSTALLER/common/aml.sh; VAR1=ctl; VAR2=mixer;;
    *sapa_feature*.xml) sed -i "/#SAPAPATCHES/a\                        patch_xml $1 \$MODPATH/\$NAME '$3' \"$4\"" $INSTALLER/common/aml.sh; VAR1=feature; VAR2=model;;
    *mixer_gains*.xml) sed -i "/#GAINPATCHES/a\                       patch_xml $1 \$MODPATH/\$NAME '$3' \"$4\"" $INSTALLER/common/aml.sh; VAR1=ctl; VAR2=mixer;;
    *audio_device*.xml) sed -i "/#ADPATCHES/a\                        patch_xml $1 \$MODPATH/\$NAME '$3' \"$4\"" $INSTALLER/common/aml.sh; VAR1=kctl; VAR2=mixercontrol;;
    *audio_platform_info*.xml) sed -i "/#APLIPATCHES/a\                               patch_xml $1 \$MODPATH/\$NAME '$3' \"$4\"" $INSTALLER/common/aml.sh; VAR1=param; VAR2=config_params;;
  esac
  if [ "$1" == "-t" -o "$1" == "-ut" -o "$1" == "-tu" ] && [ "$VAR1" ]; then
    if [ "$(grep "<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" />" $2)" ]; then
      sed -i "0,/<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" \/>/ {/<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" \/>/p; s/\(<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" \/>\)/<!--$MODID\1$MODID-->/}" $2
      sed -i "0,/<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" \/>/ s/\(<$VAR1 $NAMEC=\"$NAME\" $VALC=\"\).*\(\" \/>\)/\1$VAL\2<!--$MODID-->/" $2
    elif [ "$1" == "-t" ]; then
      sed -i "/<$VAR2>/ a\    <$VAR1 $NAMEC=\"$NAME\" $VALC=\"$VAL\" \/><!--$MODID-->" $2
    fi    
  elif [ "$(xmlstarlet sel -t -m "$3" -c . $2)" ]; then
    [ "$(xmlstarlet sel -t -m "$3" -c . $2 | sed -r "s/.*$VALC=(\".*\").*/\1/")" == "$VAL" ] && return
    xmlstarlet ed -P -L -i "$3" -t elem -n "$MODID" $2
    sed -ri "s/(^ *)(<$MODID\/>)/\1\2\n\1/g" $2
    local LN=$(sed -n "/<$MODID\/>/=" $2)
    for i in ${LN}; do
      sed -i "$i d" $2
      case $(sed -n "$((i-1)) p" $2) in
        *">$MODID-->") sed -i -e "${i-1}s/<!--$MODID-->//" -e "${i-1}s/$/<!--$MODID-->/" $2;;
        *) sed -i "$i p" $2
           sed -ri "${i}s/(^ *)(.*)/\1<!--$MODID\2$MODID-->/" $2
           sed -i "$((i+1))s/$/<!--$MODID-->/" $2;;
      esac
    done
    case "$1" in
      "-u"|"-s") xmlstarlet ed -L -u "$3/@$VALC" -v "$VAL" $2;;
      "-d") xmlstarlet ed -L -d "$3" $2;;
    esac
  elif [ "$1" == "-s" ]; then
    local NP=$(echo "$3" | sed -r "s|(^.*)/.*$|\1|")
    local SNP=$(echo "$3" | sed -r "s|(^.*)\[.*$|\1|")
    local SN=$(echo "$3" | sed -r "s|^.*/.*/(.*)\[.*$|\1|")
    xmlstarlet ed -L -s "$NP" -t elem -n "$SN-$MODID" -i "$SNP-$MODID" -t attr -n "$NAMEC" -v "$NAME" -i "$SNP-$MODID" -t attr -n "$VALC" -v "$VAL" $2
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

# Tell user aml is needed if applicable
if $MAGISK && ! $SYSOVERRIDE; then
  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" -o -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml" -o -name "*mixer_paths*.xml" 2>/dev/null)
  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
    ui_print " "
    ui_print "   ! Conflicting audio mod found!"
    ui_print "   ! You will need to install !"
    ui_print "   ! Audio Modification Library !"
    sleep 3
  fi
fi

AUO=$SDCARD/sauron_useroptions
ui_print " "
[ -f $AUO ] && UVER=$(grep_prop Version $AUO)
if [ ! -f $AUO ] || [ -z $UVER ]; then
  if [ ! -f $AUO ]; then ui_print "   ! Sauron_useroptions not detected !"; else ui_print "   Deprecated version of sauron_useroptions detected!"; fi
  ui_print "   Creating $AUO with default options..."
  ui_print "   Using default options"
  cp -f $INSTALLER/sauron_useroptions $AUO
elif [ $UVER -lt $(grep_prop Version $INSTALLER/sauron_useroptions) ]; then
  ui_print "   Older version of sauron_useroptions detected!"
  ui_print "   Updating sauron_useroptions!"
  get_uo -u
  ui_print "   Using specified options"
else
  ui_print "   Up to date sauron_useroptions detected! "
  ui_print "   Using specified options"
fi
# Make sure EOL is unix
cat $AUO | sed 's/\r$//g' | tr '\r' '\n' > $AUO.tmp; mv -f $AUO.tmp $AUO
cp_ch -n $AUO $UNITY$SYS/etc/sauron_useroptions
AUO=$UNITY$SYS/etc/sauron_useroptions
if ! $MAGISK || $SYSOVERRIDE; then sed -i "/^EOF/ i\\$AUO" $INSTALLER/common/unityfiles/addon.sh; fi
get_uo
ui_print " "

## Install logic by UltraM8@XDA DO NOT MODIFY ##
## Script edits & fixes by Zackptg5 ##
## aptX edits by Laster K. ##
mkdir -p $INSTALLER$ACDB $INSTALLER$BIN $INSTALLER$ETC/audio $INSTALLER$ETC/firmware $INSTALLER$ETC/permissions $INSTALLER$ETC/settings $INSTALLER$ETC/tfa $INSTALLER$SYS/framework $INSTALLER$SFX $INSTALLER$SFX64 $INSTALLER$VETC/firmware $INSTALLER$VETC/tfa $INSTALLER$VSFX $INSTALLER$VSFX64 $MODU/modules
cp -f $INSTALLER/common/xmlstarlet/$ARCH32/xmlstarlet $INSTALLER$BIN/xmlstarlet
cp -f $BAR/APU.so $INSTALLER$SFX/libaudiopreprocessing.so
cp -f $BAR/BWU.so $INSTALLER$SFX/libbundlewrapper.so
cp -f $BAR/RWU.so $INSTALLER$SFX/libreverbwrapper.so
cp -f $BAR/APU2.so $INSTALLER$SFX64/libaudiopreprocessing.so
cp -f $BAR/BWU2.so $INSTALLER$SFX64/libbundlewrapper.so
if [ ! $API -ge 27 ]; then
cp -f $BAR/EPU.so $INSTALLER$SFX/libeffectproxy.so
cp -f $BAR/EPU2.so $INSTALLER$SFX64/libeffectproxy.so
fi
cp -f $BAR/RWU2.so $INSTALLER$SFX64/libreverbwrapper.so
if [ $API -ge 26 ] && [ ! $API -ge 27 ]; then
  cp -f $BAR/APO.so $INSTALLER$SFX/libaudiopreprocessing.so
  cp -f $BAR/APO2.so $INSTALLER$SFX64/libaudiopreprocessing.so  
fi
if [ ! -f "$SYS/bin/tinymix" ]; then
  if $IS64BIT; then
    cp -f $GOR/tinymix $INSTALLER$BIN/tinymix
  else
    cp -f $GOR/tinymix2 $INSTALLER$BIN/tinymix
  fi
fi

if [ "$QCP" ]; then
  prop_process $INSTALLER/common/propsqcp.prop
  if [ $API -ge 26 ] && [ ! "$OP3" ] && [ ! "$OP5" ]; then
    prop_process $INSTALLER/common/propsqcporeo.prop
  fi
  [ "$OP3" ] && sed -i -e 's/audio.offload.multiple.enabled(.?)true/d' -e 's/audio.offload.pcm.enable(.?)true/d' -e 's/audio.playback.mch.downsample(.?)false/d' $INSTALLER/common/system.prop
  cp -f $BAR/BWQ.so $INSTALLER$SFX/libbundlewrapper.so
  cp -f $BAR/BWQ2.so $INSTALLER$SFX64/libbundlewrapper.so
  cp -f $BAR/RWQ.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $BAR/DMQ.so $INSTALLER$SFX/libdownmix.so
  cp -f $BAR/RWQ2.so $INSTALLER$SFX64/libreverbwrapper.so
  cp -f $BAR/DMQ2.so $INSTALLER$SFX64/libdownmix.so
  if [ $API -ge 26 ]; then
    cp -f $BAR/DMQO.so $INSTALLER$SFX/libdownmix.so
    cp -f $BAR/DMQO2.so $INSTALLER$SFX64/libdownmix.so
  fi
  cp -f $BAR/BBQ.so $INSTALLER$VSFX/libqcbassboost.so
  cp -f $BAR/RQ.so $INSTALLER$VSFX/libqcreverb.so
  cp -f $BAR/VQ.so $INSTALLER$VSFX/libqcvirt.so
  cp -f $BAR/BBQ2.so $INSTALLER$VSFX64/libqcbassboost.so
  cp -f $BAR/RQ2.so $INSTALLER$VSFX64/libqcreverb.so
  cp -f $BAR/VQ2.so $INSTALLER$VSFX64/libqcvirt.so
  if [ $API -ge 28 ]; then
    cp -f $BAR/BWQP.so $INSTALLER$SFX/libbundlewrapper.so
    cp -f $BAR/RWQP.so $INSTALLER$SFX/libreverbwrapper.so
	if [ ! -f "$LIB/qtigef.so" ]; then 
	cp -f $GOR/libqtigefP.so $INSTALLER$LIB/libqtigef.so
	cp -f $GOR/libqtigefP2.so $INSTALLER$LIB64/libqtigef.so
	fi
	cp -f $BAR/DMQP.so $INSTALLER$SFX/libdownmix.so
    cp -f $BAR/APP.so $INSTALLER$SFX/libaudiopreprocessing.so
    cp -f $BAR/APP2.so $INSTALLER$SFX64/libaudiopreprocessing.so
    cp -f $BAR/BWQP2.so $INSTALLER$SFX64/libbundlewrapper.so
    cp -f $BAR/DMQP2.so $INSTALLER$SFX64/libdownmix.so
    cp -f $BAR/RWQP2.so $INSTALLER$SFX64/libreverbwrapper.so
    cp -f $BAR/BBQP.so $INSTALLER$VSFX/libqcbassboost.so
    cp -f $BAR/RQP.so $INSTALLER$VSFX/libqcreverb.so
    cp -f $BAR/VQP.so $INSTALLER$VSFX/libqcvirt.so   
    cp -f $BAR/BBQP2.so $INSTALLER$VSFX64/libqcbassboost.so
    cp -f $BAR/RQP2.so $INSTALLER$VSFX64/libqcreverb.so
    cp -f $BAR/VQP2.so $INSTALLER$VSFX64/libqcvirt.so   
  fi  
  if [ -d "$SYS/lib/modules" ] || [ -d "$VEN/lib/modules" ]; then
    cp -f $CIRU/mpq-adapter.ko $MODU/modules/mpq-adapter.ko
    cp -f $CIRU/mpq-dmx-hw-plugin.ko $MODU/modules/mpq-dmx-hw-plugin.ko
  	cp -f $CIRU/audio_q6.ko $MODU/modules/audio_q6.ko
  	cp -f $CIRU/snd-soc-wcd9xxx.ko $MODU/modules/snd-soc-wcd9xxx.ko
  	cp -f $CIRU/snd-soc-wcd-mbhc.ko $MODU/modules/snd-soc-wcd-mbhc.ko
  	cp -f $CIRU/snd-soc-wcd-spi.ko $MODU/modules/snd-soc-wcd-spi.ko
  	cp -f $CIRU/wcd-core.ko $MODU/modules/wcd-core.ko
  	cp -f $CIRU/wcd-dsp-glink.ko $MODU/modules/wcd-dsp-glink.ko
  	if [ "$QC8996" ] || $QCNEW; then
  	  cp -f $CIRU/snd-soc-wsa881x.ko $MODU/modules/snd-soc-wsa881x.ko
	  echo "vendor.audio.matrix.limiter.enable=0" >> $INSTALLER/common/system.prop
  	fi
  	if [ "$QC8996" ] || [ "$QC8998" ] || [ "$SD660" ] || [ "$QC8953" ] || [ "$SD660" ]; then
  	  cp -f $CIRU/audio_wcd9335.ko $MODU/modules/audio_wcd9335.ko
  	fi
  	if [ "$SD845" ]; then
  	  cp -f $CIRU/snd-soc-sdm845.ko $MODU/modules/snd-soc-sdm845.ko
  	fi
  fi
  cp_ch $CIRU/SAPlusCmnModule.so.1 $ADSP2/SAPlusCmnModule.so.1
  cp_ch $CIRU/SVACmnModule.so.1 $ADSP2/SVACmnModule.so.1  
  cp_ch $CIRU/libAudienceAZA.so $ADSP2/libAudienceAZA.so
  if [ -f "$SYS/etc/htc_audio_effects.conf" ] || [ -f "$VEN/etc/htc_audio_effects.conf" ]; then
    prop_process $INSTALLER/common/propshtc.prop
    cp -f $CAR/default_vol_level.conf $INSTALLER$ETC/default_vol_level.conf
    cp -f $CAR/TFA_default_vol_level.conf $INSTALLER$ETC/TFA_default_vol_level.conf
    cp -f $CAR/NOTFA_default_vol_level.conf $INSTALLER$ETC/NOTFA_default_vol_level.conf
    [ "$NX9" -o "$M10" -o "$BOLT" -o -f "$AMPA" ] || { cp -f $CAR/libhtcacoustic.so $INSTALLER$LIB/libhtcacoustic.so;
                                                       $CAR/libhtcacoustic2.so $INSTALLER$LIB64/libhtcacoustic.so; }
  fi
  if [ "$M10" ] || [ "$BOLT" ]; then
    cp -f $CAR/libaudio-ftm.so $INSTALLER$LIB/libaudio-ftm.so
    cp -f $CAR/libaudio-ftm2.so $INSTALLER$LIB64/libaudio-ftm.so
  fi
  if [ "$M9" ]; then
    prop_process $INSTALLER/common/propsresample.prop
  fi
  if [ "$M8" ]; then
    cp -f $CAR/tfa9887_feature.config $INSTALLER$ETC/audio/tfa9887_feature.config
    cp -f $CAR/libtfa9887.so $INSTALLER$LIB/libtfa9887.so
  fi
  if [ -f "$AMPA" ]; then
    prop_process $INSTALLER/common/propsresample.prop
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/TAS2557_A.ftcfg
    cp -f $CAR/TAS2557_B.ftcfg $INSTALLER$VETC/TAS2557_B.ftcfg
    cp -f $CAR/tas2557s_uCDSP_PG21.bin $INSTALLER$ETC/firmware/tas2557s_uCDSP_PG21.bin
    if [ -f "$U11P" ]; then
      cp -f $CAR/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin
      cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    fi
    cp -f $CAR/ti_audio_s $INSTALLER$BIN/ti_audio_s
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if [ "$MI8SE" ]; then
    cp -f $CAR/ti_audio_s $INSTALLER$BIN/ti_audio_s
    cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/tas2557_aac.ftcfg
    cp -f $CAR/TAS2557_B.ftcfg $INSTALLER$VETC/tas2557_goer.ftcfg
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    #test
    cp -f $CAR/tas2557_uCDSP $INSTALLER$VETC/firmware/tas2557_uCDSP
    cp -f $CAR/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin
    cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if [ "$MI8EE" ] || [ "$MI8UD" ]; then
    cp -f $CAR/ti_audio_s $INSTALLER$BIN/ti_audio_s
    cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/tas2557.ftcfg
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp -f $CAR/tas2557_uCDSP $INSTALLER$VETC/firmware/tas2557_uCDSP
    #test
    cp -f $CAR/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin
    cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if [ "$MIA2" ]; then
    cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/speaker.ftcfg
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp -f $CAR/tas2557_uCDSP $INSTALLER$VETC/firmware/tas2557_uCDSP
    #test
    cp -f $CAR/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin
    cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if [ "$POC" ]; then
   cp -f $CAR/tas2559_l.ftcfg $INSTALLER$VETC/tas2559_l.ftcfg
   cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/tas2557.ftcfg
   cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if [ "$OP5" ]; then
    cp -f $CAR/TFA9890_N1B12_N1C3_v3.config $INSTALLER$ETC/settings/TFA9890_N1C3_2_1_1.patch
  fi
  if [ "$P2XL" ] || [ "$P2" ]; then
    cp -f $SAU/files/bin/ti_audio_s $INSTALLER$BIN/ti_audio_s
    if $MAGISK && ! $SYSOVERRIDE; then
      mktouch $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin
      mktouch $UNITY$VEN/firmware/tas2557s_uCDSP.bin
      mktouch $UNITY$VEN/firmware/tas2557_cal.bin
    else
      mv -f $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin.bak
      mv -f $UNITY$VEN/firmware/tas2557s_uCDSP.bin $UNITY$VEN/firmware/tas2557s_uCDSP.bin.bak
      mv -f $UNITY$VEN/firmware/tas2557_cal.bin $UNITY$VEN/firmware/tas2557_cal.bin.bak
    fi
    cp -f $CAR/tas2557s_uCDSP_PG21.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_PG21.bin
    cp -f $CAR/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin
    cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    cp -f $CAR/TAS2557_A.ftcfg $INSTALLER$VETC/TAS2557_A.ftcfg
    cp -f $CAR/TAS2557_B.ftcfg $INSTALLER$VETC/TAS2557_B.ftcfg
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
    [ "$P2" ] && cp -f $CAR/tfa98xx.cnt $INSTALLER$VETC/firmware/tfa98xx.cnt
  fi
  if [ "$P1XL" ] || [ "$P1" ]; then
  	cp -f $CAR/tfa98xx.cnt $INSTALLER$VETC/firmware/tfa98xx.cnt
  fi
  if [ "$X5P" ]; then
    if $MAGISK && ! $SYSOVERRIDE; then
      mktouch $UNITY$ETC/firmware/tas2557_uCDSP.bin
    else
      mv -f $UNITY$ETC/firmware/tas2557_uCDSP.bin $UNITY$VEN/firmware/tas2557_uCDSP.bin.bak
    fi
    cp -f $CAR/tas2557s_uCDSP.bin $INSTALLER$ETC/firmware/tas2557s_uCDSP.bin
    cp -f $CAR/files/TAS2557_A.ftcfg $INSTALLER$VETC/TAS2557_A.ftcfg
    cp -f $CAR/files/TAS2557_B.ftcfg $INSTALLER$VETC/TAS2557_B.ftcfg
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp_ch $CIRU/capi_v2_smartAmp_TAS25xx.so.1 $ADSP2/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if $QCNEW && $ACDBP; then
    if [ -f "$ACDB/Codec_cal.acdb" ]; then
      cp -f $MOR/Codec_cal.acdb $INSTALLER$ACDB/Codec_cal.acdb
      if [ "$SD845" ]; then
        cp -f $MOR/Headset_cal.acdb $INSTALLER$ACDB/Headset_cal.acdb
        cp -f $MOR/General_cal.acdb $INSTALLER$ACDB/General_cal.acdb	
        cp -f $MOR/Global_cal.acdb $INSTALLER$ACDB/Global_cal.acdb	  
      fi
  	fi
  fi
  if [ "$M9" ] && $ACDBP; then
    cp -f $MOR/Headset_cal2.acdb $INSTALLER$ETC/Headset_cal.acdb
    cp -f $MOR/General_cal2.acdb $INSTALLER$ETC/General_cal.acdb
    cp -f $MOR/Global_cal2.acdb $INSTALLER$ETC/Global_cal.acdb
  elif [ "$QC94" ] && $ACDBP; then
    cp -f $MOR/Headset_cal2.acdb $INSTALLER$ACDB/Headset_cal.acdb
    cp -f $MOR/General_cal2.acdb $INSTALLER$ACDB/General_cal.acdb
    cp -f $MOR/Global_cal2.acdb $INSTALLER$ACDB/Global_cal.acdb	
  fi
  if [ ! -f "$HWDTS" ]; then
    cp_ch $TORU/DTS_HPX_MODULE.so.1 $ADSP2/DTS_HPX_MODULE.so.1
    cp_ch $TORU/SrsTruMediaModule.so.1 $ADSP2/SrsTruMediaModule.so.1
    cp_ch $TORU/effect /data/misc/dts/effect
	cp_ch $TORU/effect6 /data/misc/dts/effect6
    cp_ch $TORU/effect9 /data/misc/dts/effect9
    cp_ch $TORU/effect10 /data/misc/dts/effect10
    cp_ch $TORU/effect15 /data/misc/dts/effect15
    cp_ch $TORU/effect16 /data/misc/dts/effect16
    cp_ch $TORU/effect28 /data/misc/dts/effect28
    cp_ch $TORU/effect29 /data/misc/dts/effect29
    cp_ch $TORU/effect30 /data/misc/dts/effect30
	cp_ch $TORU/effect31 /data/misc/dts/effect31
	cp_ch $TORU/effect32 /data/misc/dts/effect32
	cp_ch $TORU/effect33 /data/misc/dts/effect33
	cp_ch $TORU/effect95 /data/misc/dts/effect95
    cp_ch -n $TORU/origeffect.bak /data/misc/dts/origeffect.bak
    cp -f $CIRU/audio_snd-soc-tas2557.ko $MODU/modules/audio_q6.ko
  fi
  if $ASP; then
    sed -i -r "s/audio.pp.asphere.enabled(.?)false/audio.pp.asphere.enabled\1true/" $INSTALLER/common/system.prop
    [ $API -ge 26 ] && echo "vendor.audio.pp.asphere.enabled=1" >> $INSTALLER/common/system.prop
    cp -f $GOR/audiosphere.jar $INSTALLER$SYS/framework/audiosphere.jar
    cp -f $GOR/audiosphere.xml $INSTALLER$SYS/etc/permissions/audiosphere.xml
    cp -f $GOR/AS.so $INSTALLER$SFX/libasphere.so
    cp -f $GOR/AS2.so $INSTALLER$SFX64/libasphere.so
    cp_ch $TORU/AudioSphereModule.so.1 $ADSP2/AudioSphereModule.so.1
    if [ ! -f "$VEN/lib/libqtigef.so" ] && [ ! $API -ge 28 ]; then
      cp -f $GOR/libqtigef.so $INSTALLER$VLIB/libqtigef.so
      cp -f $GOR/libqtigef2.so $INSTALLER$VLIB64/libqtigef.so
    fi
    if [ $API -ge 28 ]; then
      cp -f $GOR/ASP.so $INSTALLER$SFX/libasphere.so
      cp -f $GOR/ASP2.so $INSTALLER$SFX64/libasphere.so	 
    fi
  fi
  if $SHB; then
    cp -f $GOR/SBQ.so $INSTALLER$SFX/libshoebox.so
    cp -f $GOR/SBQ2.so $INSTALLER$SFX64/libshoebox.so
    if [ ! -f "$VEN/lib/libqtigef.so" ] && [ ! $API -ge 28 ]; then
      cp -f $GOR/libqtigef.so $INSTALLER$VLIB/libqtigef.so
      cp -f $GOR/libqtigef2.so $INSTALLER$VLIB64/libqtigef.so
    fi
    if [ $API -ge 28 ]; then
      cp -f $GOR/SBQP.so $INSTALLER$SFX/libasphere.so
      cp -f $GOR/SBQP2.so $INSTALLER$SFX64/libasphere.so	 
    fi	
  fi
  if $RPCM; then
    cp -f $GOR/RPRW.so $INSTALLER$SFX/libreverbwrapper.so
    cp -f $GOR/RPRW2.so $INSTALLER$SFX64/libreverbwrapper.so
    cp -f $GOR/libaudioutils.so $INSTALLER$LIB/libaudioutils.so
    cp -f $GOR/libaudioutils2.so $INSTALLER$LIB64/libaudioutils.so
    cp -f $GOR/RPEP.so $INSTALLER$SFX/libeffectproxy.so
    cp -f $GOR/RPEP2.so $INSTALLER$SFX64/libeffectproxy.so
    cp -f $GOR/libclang_rt.ubsan_standalone-aarch64-android.so $INSTALLER$LIB64/libclang_rt.ubsan_standalone-aarch64-android.so
    if [ $API -ge 26 ]; then
      cp -f $GOR/libaudioutilsP.so $INSTALLER$LIB/libaudioutils.so
      cp -f $GOR/libaudioutilsP2.so $INSTALLER$LIB64/libaudioutils.so
      cp -f $GOR/libclang_rt.ubsan_standalone-aarch64-androidP.so $INSTALLER$LIB64/libclang_rt.ubsan_standalone-aarch64-android.so
      cp -f $BAR/RWQ.so $INSTALLER$SFX/libreverbwrapper.so
      cp -f $BAR/RWQ2.so $INSTALLER$SFX64/libreverbwrapper.so
    fi
  fi
  if $APTX; then
    prop_process $INSTALLER/common/propsaptx.prop
    cp_ch $MOR/capi_v2_aptX_Classic.so $ADSP2/capi_v2_aptX_Classic.so
    cp_ch $MOR/capi_v2_aptX_HD.so $ADSP2/capi_v2_aptX_HD.so
    if [ $API -ge 25 ]; then
      [ -f "$VLIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" ] && cp -f $MOR/libaptX-1.0.0-rel-Android21-ARMv7A.so $INSTALLER$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" ] && cp -f $MOR/libaptXHD-1.0.0-rel-Android21-ARMv7A.so $INSTALLER$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXScheduler.so" -o -f "$LIB/libaptXScheduler.so" ] && cp -f $MOR/libaptXScheduler.so $INSTALLER$LIB/libaptXScheduler.so
      [ -f "$VLIB/libbt-codec_aptx.so" -o -f "$LIB/libbt-codec_aptx.so" ] && cp -f $MOR/libbt-codec_aptx.so $INSTALLER$LIB/libbt-codec_aptx.so
      [ -f "$VLIB/libbt-codec_aptxhd.so" -o -f "$LIB/libbt-codec_aptxhd.so" ] && cp -f $MOR/libbt-codec_aptxhd.so $INSTALLER$LIB/libbt-codec_aptxhd.so
    fi
    if [ $API -ge 26 ]; then
      cp -f $MOR/libelda.so $INSTALLER$LIB/libldacBT_enc.so
      cp -f $MOR/libelda2.so $INSTALLER$LIB64/libldacBT_enc.so
      cp -f $MOR/adsp_avs_config.acdb $INSTALLER$ACDB/adsp_avs_config.acdb
      cp -f $MOR/libaptXHD_encoder.so $INSTALLER$LIB/libaptXHD_encoder.so
      cp -f $MOR/libaptXHD_encoder64.so $INSTALLER$LIB64/libaptXHD_encoder.so
      cp -f $MOR/libaptX_encoder.so $INSTALLER$LIB/libaptX_encoder.so
      cp -f $MOR/libaptX_encoder64.so $INSTALLER$LIB64/libaptX_encoder.so
    fi
    if [ $API -ge 28 ] && $QCNEW; then
      cp -f $MOR/adsp_avs_config2.acdb $INSTALLER$ACDB/adsp_avs_config.acdb
      sed -i 's/persist.bt.a2dp_offload_cap(.?)sbc-aac-aptx-aptXHD-ldac/'d $INSTALLER/common/system.prop
      echo "persist.vendor.bt.a2dp_offload_cap=sbc-aptx-aptxhd-aac-ldac" >> $INSTALLER/common/system.prop
      cp_ch $MOR/capi_v2_aptX_ClassicP.so $ADSP2/capi_v2_aptX_Classic.so
      cp_ch $MOR/capi_v2_aptX_HDP.so $ADSP2/capi_v2_aptX_HD.so	  
    fi
  fi
fi

if [ "$MTK" ]; then
  prop_process $INSTALLER/common/propsmtk.prop
  cp -f $BAR/BWM.so $INSTALLER$SFX/libbundlewrapper.so
  cp -f $BAR/DMM.so $INSTALLER$SFX/libdownmix.so
  cp -f $BAR/RWM.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $BAR/DMM2.so $INSTALLER$SFX64/libdownmix.so
  cp -f $BAR/RWM2.so $INSTALLER$SFX64/libreverbwrapper.so
  cp -f $BAR/BWM2.so $INSTALLER$SFX64/libbundlewrapper.so
  if [ $API -ge 25 ]; then
    cp -f $BAR/EPM25.so $INSTALLER$SFX/libeffectproxy.so
    cp -f $BAR/EPM252.so $INSTALLER$SFX64/libeffectproxy.so
  fi
fi

if [ "$KIR" ]; then
  cp -f $BAR/BWK.so $INSTALLER$SFX/libbundlewrapper.so
  cp -f $BAR/BWK2.so $INSTALLER$SFX64/libbundlewrapper.so
fi

if [ "$EXY" ]; then
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  cp -f $BAR/DME.so $INSTALLER$SFX/libdownmix.so
  cp -f $BAR/RWE.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $BAR/RWE2.so $INSTALLER$SFX64/libreverbwrapper.so
  cp -f $BAR/DME2.so $INSTALLER$SFX64/libdownmix.so
  cp -f $BAR/BWE.so $INSTALLER$SFX/libbundlewrapper.so
  cp -f $BAR/BWE2.so $INSTALLER$SFX/libbundlewrapper.so
  if [ $API -ge 26 ]; then
    cp -f $BAR/BWEO.so $INSTALLER$SFX/libbundlewrapper.so
  fi 
  if [ $API -ge 28 ]; then
    cp -f $BAR/BWEP2.so $INSTALLER$SFX/libbundlewrapper.so
    cp -f $BAR/DMEP2.so $INSTALLER$SFX64/libdownmix.so
    cp -f $BAR/RWEP2.so $INSTALLER$SFX64/libreverbwrapper.so
  fi
fi

if [ "$MIUI" ]; then
  sed -i 's/persist.audio.hifi(.?)true/'d $INSTALLER/common/system.prop
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  sed -i 's/persist.audio.hifi.volume(.?)1/'d $INSTALLER/common/system.prop
fi

if [ "$VSTP" ]; then
  echo "ro.config.media_vol_steps=$VSTP" >> $INSTALLER/common/system.prop
fi

if $FMAS; then
  prop_process $INSTALLER/common/propsfmas.prop
  if [ $API -ge 26 ]; then
   cp -f $GOR/FMO.so $INSTALLER$SFX/libfmas.so
  fi
  if [ $API -ge 28 ]; then
  cp -f $GOR/FM.so $INSTALLER$SFX/libfmas.so
  fi
fi

if [ "$SONY" ]; then
  ### UltraM8's hex props
  echo "persist.vendor.audio.latency_deep_buffer_speaker=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_headset=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_usb=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_a2dp=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_compress_offload_speaker=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_compress_offload_headset=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_compress_offload_usb=0" >> $INSTALLER/common/system.prop
  echo "persist.vendor.audio.latency_compress_offload_a2dp=0" >> $INSTALLER/common/system.prop
fi

if [ "$LG" ]; then
  prop_process $INSTALLER/common/propslg.prop
fi

$CPGD && echo -e 'for i in $(find /sys/module -name "*collapse_enable"); do\n  echo 0 > $i\ndone\n' >> $INSTALLER/common/post-fs-data.sh

for i in "AX7" "V20" "V30" "G6" "Z9" "Z9M" "Z11" "LX3" "X9"; do
  sed -i "2i $i=$(eval echo \$$i)" $INSTALLER/common/service.sh
done

ui_print "   Patching audio_effects configs"
for OFILE in ${CFGS}; do
  FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch -nn $ORIGDIR$OFILE $FILE
  case $FILE in
    *.conf) if $CMPSR; then
              sed -i "/^effects {/,/^}/ {/loudness_enhancer {/,/}/ s/^/#$MODID/}" $FILE
            fi
	          if $ASP; then
              sed -i "/audiosphere {/,/}/d" $FILE
              sed -i "s/^effects {/effects {\n  audiosphere { #$MODID\n    library audiosphere\n    uuid 184e62ab-2d19-4364-9d1b-c0a40733866c\n  } #$MODID/g" $FILE
              sed -i "s/^libraries {/libraries {\n  audiosphere { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libasphere.so\n  } #$MODID/g" $FILE
            fi
            if $SHB; then
              sed -i "/libshoebox {/,/}/d" $FILE
              sed -i "s/^effects {/effects {\n  shoebox { #$MODID\n    library shoebox\n    uuid 1eab784c-1a36-4b2a-b7fc-e34c44cab89e\n  } #$MODID/g" $FILE
              sed -i "s/^libraries {/libraries {\n  shoebox { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libshoebox.so\n  } #$MODID/g" $FILE
            fi
            if $FMAS; then
              [ "$QCP" -a "$FILE" == "$UNITY/system/etc/audio_effects.conf" ] && continue
              backup_and_patch "virtualizer" "library bundle" "library fmas" "uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $FILE
              backup_and_patch "virtualizer" "library cm" "library fmas" "uuid 7c6cc5f8-6f34-4449-a282-bed84f1a5b5a" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $FILE
              backup_and_patch "downmix" "library downmix" "library fmas" "uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f" "uuid 36103c51-8514-11e2-9e96-0800200c9a66" $FILE
              sed -i "s/^libraries {/libraries {\n  fmas { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libfmas.so\n  } #$MODID/g" $FILE
            fi;;
    *.xml) if $CMPSR; then
            sed -ri "/^ *<effects>/,/^ *<\/effects>/ s/(<effect name=\"loudness_enhancer\".*)/<!--$MODID\1$MODID-->/g" $FILE
           fi
	         if $ASP && [ ! "$(grep "audiosphere" $FILE)" ]; then
             sed -i "/audiosphere/d" $FILE
             sed -i "/<libraries>/ a\        <library name=\"audiosphere\" path=\"libasphere.so\"\/><!--$MODID-->" $FILE
             sed -i "/<effects>/ a\        <effect name=\"audiosphere\" library=\"audiosphere\" uuid=\"184e62ab-2d19-4364-9d1b-c0a40733866c\"\/><!--$MODID-->" $FILE
           fi
           if $SHB && [ ! "$(grep "shoebox" $FILE)" ]; then
             sed -i "/libshoebox/d" $FILE
             sed -i "/<libraries>/ a\        <library name=\"shoebox\" path=\"libshoebox.so\"\/><!--$MODID-->" $FILE
             sed -i "/<effects>/ a\        <effect name=\"shoebox\" library=\"shoebox\" uuid=\"1eab784c-1a36-4b2a-b7fc-e34c44cab89e\"\/><!--$MODID-->" $FILE
           fi
           if $FMAS && [ ! "$(grep "fmas" $FILE)" ]; then
             sed -ri "/<effect name=\"virtualizer\"/ s/<!--(.*)$MODID-->/\1/g" $FILE
             sed -ri "/<effect name=\"downmix\" / s/<!--(.*)$MODID-->/\1/g" $FILE
             sed -i "/<effects>/ a\        <effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $FILE
             sed -i "/<effects>/ a\        <effect name=\"downmix\" library=\"fmas\" uuid=\"36103c51-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $FILE
             sed -i "/<libraries>/ a\        <library name=\"fmas\" path=\"libfmas.so\"\/><!--$MODID-->" $FILE
           fi
  esac
done

##                    POLICY CONFIGS EDITS BY ULTRAM8                           ##
##                    OREO POLICY PATCHES BY Laster K.                          ##
if $AP || $OAP; then ui_print "   Patching audio policies"; fi
for OFILE in ${POLS}; do
  FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch -nn $ORIGDIR$OFILE $FILE
  case $FILE in
    *audio_policy.conf) if $AP; then
                          cp_ch -nn $ORIGDIR$OFILE $FILE
                          for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                            [ "$AUD" != "compress_offload" ] && backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_8_24_BIT" $FILE
                            [ "$AUD" == "direct_pcm" -o "$AUD" == "direct" -o "$AUD" == "raw" ] && backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $FILE
                            backup_and_patch "$AUD" "sampling_rates" "sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000" $FILE
                          done
                        fi;;
    *audio_output_policy.conf) if $OAP; then
                                 cp_ch -nn $ORIGDIR$OFILE $FILE
                                 for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                   [[ "$AUD" != "compress_offload"* ]] && backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT" $FILE
                                   if [ "$AUD" == "direct" ]; then
                                     if [ "$(grep "compress_offload" $FILE)" ]; then
                                       backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING" $FILE
                                     else
                                       backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $FILE
                                     fi
                                   fi
                                   backup_and_patch "$AUD" "sampling_rates" "sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000" $FILE
                                   [ -z $BIT ] || backup_and_patch "$AUD" "bit_width" "bit_width $BIT" $FILE
                                 done
                               fi;;
    *audio_policy_configuration.xml) if $AP; then
                                       cp_ch -nn $ORIGDIR$OFILE $FILE
                                       patch_audpol "primary output" "s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/" $FILE
                                       patch_audpol "raw" "s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/" $FILE
                                       patch_audpol "deep_buffer" "s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"192000\1/" $FILE
                                       patch_audpol "multichannel" "s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/" $FILE
                                       # Use 'channel_masks' for conf files and 'channelMasks' for xml files
                                       patch_audpol "direct_pcm" "s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/; s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/" $FILE
                                       patch_audpol "compress_offload" "s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/" $FILE
                                     fi;;
  esac
done

### Mixer edits by UltraM8 ###
ui_print "   Patching mixer"
if [ "$QCP" ]; then
  for OMIX in ${MIXS}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$OMIX $MIX
    if [ "$BIT" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_0_RX Format"]' "$BIT"
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_5_RX Format"]' "$BIT"
	  ###
	  if [ ! "$LG" ]; then
	  patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX Format"]' "$BIT"
	  fi
	  ###
      [ "$QC8996" -o "$QC8998" -o "$SD660" -o "$SD670" -o "$SD710" -o "$SD845" ] && { patch_xml -s $MIX '/mixer/ctl[@name="SLIM_6_RX Format"]' "$BIT"; patch_xml -s $MIX '/mixer/ctl[@name="SLIM_2_RX Format"]' "$BIT"; patch_xml -s $MIX '/mixer/ctl[@name="ASM Bit Width"]' "$BIT"; }
      patch_xml -s $MIX '/mixer/ctl[@name="USB_AUDIO_RX Format"]' "$BIT"
      patch_xml -s $MIX '/mixer/ctl[@name="HDMI_RX Bit Format"]' "$BIT"
      if [ "$V30" ] || [ "$G7" ]; then
        #patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX Format"]' "$BIT"
		patch_xml -s $MIX '/mixer/ctl[@name="TERT_MI2S_RX Format"]' "$BIT"
      fi
    fi
    if [ "$QIMPEDANCE" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="HPHR Impedance"]' "$QIMPEDANCE"
      patch_xml -s $MIX '/mixer/ctl[@name="HPHL Impedance"]' "$QIMPEDANCE"
    fi
    if [ "$RESAMPLE" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_0_RX SampleRate"]' "$RESAMPLE"
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_5_RX SampleRate"]' "$RESAMPLE"
	  ###
	  if [ ! "$LG" ]; then
	  patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX SampleRate"]' "$RESAMPLE"
	  fi
	  ###
      [ "$QC8996" -o "$QC8998" -o "$SD660" -o "$SD670" -o "$SD710" -o "$SD845" ] && { patch_xml -s $MIX '/mixer/ctl[@name="SLIM_6_RX SampleRate"]' "$RESAMPLE"; patch_xml -s $MIX '/mixer/ctl[@name="SLIM_2_RX SampleRate"]' "$RESAMPLE"; }
      patch_xml -s $MIX '/mixer/ctl[@name="USB_AUDIO_RX SampleRate"]' "$RESAMPLE"
      patch_xml -s $MIX '/mixer/ctl[@name="HDMI_RX SampleRate"]' "$RESAMPLE"
      if [ "$V30" ] || [ "$G7" ]; then
        #patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX SampleRate"]' "$RESAMPLE"
		patch_xml -s $MIX '/mixer/ctl[@name="TERT_MI2S_RX SampleRate"]' "$RESAMPLE"
      fi
    fi
    if [ "$AX7" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="AK4490 Super Slow Roll-off Filter"]' "On"
    fi
    if [ "$LX3" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 CLK Divider"]' "DIV4"
      patch_xml -s $MIX '/mixer/ctl[@name="ESS_HEADPHONE Off"]' "On"
    fi
    if [ "$X9" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 CLK Divider"]' "DIV4"
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 Hifi Switch"]' "1"
    fi
    if [ "$Z9" ] || [ "$Z9M" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="HP Out Volume"]' "22"
      patch_xml -s $MIX '/mixer/ctl[@name="ADC1 Digital Filter"]' "sharp_roll_off_88"
      patch_xml -s $MIX '/mixer/ctl[@name="ADC2 Digital Filter"]' "sharp_roll_off_88"
    fi
    if [ "$Z11" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 DAC Digital Filter Mode"]' "Slow Roll-Off"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HPL Power-down Resistor"]' "Hi-Z"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HPR Power-down Resistor"]' "Hi-Z"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HP-Amp Analog Volume"]' "15"
    fi
    if [ "$V20" ] || [ "$V30" ] || [ "$G6" ] || [ "$G7" ]; then
      #patch_xml -tu $MIX "Es9018 AVC Volume" "14"
      #patch_xml -tu $MIX "Es9018 HEADSET TYPE" "2"
      #patch_xml -tu $MIX "Es9018 Master Volume" "0"
      # ENABLE HIGH IMPEDENCE MODE ON ESS
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 AVC Volume"]' "0"
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 Master Volume"]' "0"
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 HEADSET TYPE"]' "2"
	  if [ ! "$G7" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 State"]' "Hifi"
	  fi
      patch_xml -u $MIX '/mixer/ctl[@name="HIFI Custom Filter"]' "6"
      patch_xml -u $MIX '/mixer/ctl[@name="LGE ESS DIGITAL FILTER SETTING"]' "6"
      patch_xml -tu $MIX "Es9218 Bypass" "0"
    fi
    if [ -f "$AMPA" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="HTC_AS20_VOL Index"]' "Twelve"
    fi
    if [ "$QC8996" ] || $QCNEW; then
      patch_xml -s $MIX '/mixer/ctl[@name="VBoost Ctrl"]' "AlwaysOn"
      #patch_xml -s $MIX '/mixer/ctl[@name="VBoost Volt"]' "8.6V"
    fi
    patch_xml -s $MIX '/mixer/ctl[@name="Set Custom Stereo OnOff"]' "Off"
    if $APTX; then
      patch_xml -s $MIX '/mixer/ctl[@name="APTX Dec License"]' "21"
    fi
    patch_xml -s $MIX '/mixer/ctl[@name="Set HPX OnOff"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="Set HPX ActiveBe"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 9 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 13 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 17 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 21 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 24 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 15 Topology"]' "DTS"
    patch_xml -s $MIX '/mixer/ctl[@name="PCM_Dev 33 Topology"]' "DTS"
    #if [ ! "$M10" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="DS2 OnOff"]' "Off"
    #fi
    patch_xml -s $MIX '/mixer/ctl[@name="Codec Wideband"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="HPH Type"]' "1"
#    patch_xml -tu $MIX "RX HPH Mode" "CLS_H_HIFI"
    patch_xml -s $MIX '/mixer/ctl[@name="RX HPH Mode"]' "CLS_H_HIFI"
    if $ASP; then
      patch_xml -s $MIX '/mixer/ctl[@name="Audiosphere Enable"]' "On"
      patch_xml -s $MIX '/mixer/ctl[@name="MSM ASphere Set Param"]' "1"
    fi
    if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TFA9895 Profile"]' "hq"
      patch_xml -s $MIX '/mixer/ctl[@name="TFA9895 Playback Volume"]' "255"
      patch_xml -s $MIX '/mixer/ctl[@name="SmartPA Switch"]' "1"
    fi
    #patch_xml -u $MIX '/mixer/ctl[@name="TAS2552 Volume"]' "125"
    if [ -f "$AMPA" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2557 Volume"]' "30"
    fi
    patch_xml -s $MIX '/mixer/ctl[@name="SRS Trumedia"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="SRS Trumedia HDMI"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="SRS Trumedia I2S"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="SRS Trumedia MI2S"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="HiFi Function"]' "On"
    if [ -f "$MNPRO" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Custom Filter"]' "ON"
      patch_xml -s $MIX '/mixer/ctl[@name="Filter Shape"]' "Slow Rolloff"
      patch_xml -s $MIX '/mixer/ctl[@name="THD3 Compensation"]' "0"
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2552 Volume"]' "27"
    fi
    if [ -f "$RN5PRO" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2557 ClassD Edge"]' "7"
    fi
    if $COMP; then
      # sed -i "/<ctl name=\"COMP*[0-9] Switch\"/p" $MIX
      # sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ { s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/><!--$MODID-->/; n; s/\( *\)\(.*\)/\1<!--$MODID\2$MODID-->/}" $MIX
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP1"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP2"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-generic"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-generic"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-44.1"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-44.1"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP0 RX1"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP0 RX2"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-fb-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-fb-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="tty-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="tty-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="aac-initial"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="aac-initial"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-on"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-on"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc2-on"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc2-on"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphone-combo"]/ctl[@name="COMP1 Switch"]' 0 
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphone-combo"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voiceanc-headphone"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voiceanc-headphone"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="handset"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="handset"]/ctl[@name="COMP2 Switch"]' 0  
    fi
  done
  ### Audio platform patches section
  for OAPLI in ${APLIS}; do
    APLI="$UNITY$(echo $OAPLI | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$OAPLI $APLI
	if [ ! "$OP5" ]; then
    patch_xml -s $APLI '/audio_platform_info/config_params/param[@key="native_audio_mode"]' 'src'
	fi
    if [ "$BIT" == "S24_3LE" ]; then
      patch_xml -u $APLI '/audio_platform_info/app_types/app[@mode="default"]' 'bit_width=24'
      patch_xml -u $APLI '/audio_platform_info/app_types/app[@mode="default"]' 'max_rate=192000'
      if [ ! "$P1" ] && [ ! "$P1XL" ] && [ ! "$P2XL" ] && [ ! "$P2" ] && [ ! "$PXL3XL" ]; then
        if [ ! "$(grep '<app_types>' $APLI)" ]; then
          sed -i "s/<\/audio_platform_info>/  <app_types><!--$MODID-->\n    <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"69936\" max_rate=\"192000\" \/><!--$MODID-->\n    <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"69940\" max_rate=\"192000\" \/><!--$MODID-->\n  <app_types><!--$MODID-->\n<\/audio_platform_info>/" $APLI        
        else
          for i in 69936 69940; do
            [ "$(xmlstarlet sel -t -m "/audio_platform_info/app_types/app[@uc_type=\"PCM_PLAYBACK\"][@mode=\"default\"][@id=\"$i\"]" -c . $APLI)" ] || sed -i "/<audio_platform_info>/,/<\/audio_platform_info>/ {/<app_types>/,/<\/app_types>/ s/\(^ *\)\(<\/app_types>\)/\1  <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"$i\" max_rate=\"192000\" \/><!--$MODID-->\n\1\2/}" $APLI              
          done   
        fi
      fi
    fi
  done
fi


if [ "$EXY" ]; then
  for OMIX in ${MIXS}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$OMIX $MIX
    patch_xml -s $MIX '/mixer/ctl[@name="Output Ramp Up"]' "0ms/6dB"
    patch_xml -s $MIX '/mixer/ctl[@name="Output Ramp Down"]' "0ms/6dB"
    patch_xml -s $MIX '/mixer/ctl[@name="Virtual Bass Boost"]' "Off"
  	patch_xml -s $MIX '/mixer/ctl[@name="Speaker Gain"]' "25"
  	if [ "$ESMPL" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Sample Rate 2"]' "$ESMPL"
      patch_xml -s $MIX '/mixer/ctl[@name="Sample Rate 3"]' "$ESMPL"
      patch_xml -s $MIX '/mixer/ctl[@name="ASYNC Sample Rate 2"]' "$ESMPL"
  	fi
  done
  for OSAPA in ${SAPA}; do
    SAP="$UNITY$(echo $OSAPA | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$SAP $SAP
    patch_xml -s $SAP '/feature/model[@name="support_powersaving_mode"]' "false"
    patch_xml -s $SAP '/feature/model[@name="support_samplerate_48000"]' "true"
    patch_xml -s $SAP '/feature/model[@name="support_samplerate_44100"]' "false"
    patch_xml -s $SAP '/feature/model[@name="support_low_latency"]' "true"
    patch_xml -s $SAP '/feature/model[@name="support_mid_latency"]' "false"
    patch_xml -s $SAP '/feature/model[@name="support_high_latency"]' "false"
  done
  for GMIX in ${MIXG}; do
    GAIN="$UNITY$(echo $GMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$GAIN $GAIN
    patch_xml -s $GAIN '/mixer/ctl[@name="HPOUT2L Impedance Volume"]' "117"
    patch_xml -s $GAIN '/mixer/ctl[@name="HPOUT2R Impedance Volume"]' "117"
  done
fi

if [ "$MTK" ]; then
  for OMIX in ${MIXA}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$OMIX $MIX
    if [ "$MIMPEDANCE" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Audio HP Impedance"]' "$MIMPEDANCE"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Audio HP Impedance Setting"]' "$MIMPEDANCE"
    fi
    if [ "$MHPF" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="DAC HPF Switch"]' "$MHPF"
    fi
  	if [ "$MGAIN" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Headset_PGAL_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Headset_PGAR_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Lineout_PGAR_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Lineout_PGAL_GAIN"]' "$MGAIN"
    fi
  done
fi

if [ "$KIR" ]; then
  # Patch odm files in boot img if kirin device
  sed -n "/^ *#ODMPATCHES/,/^ *#NON-ODMPATCHES/p" $INSTALLER/common/install.sh | sed '1d;$d' > $INSTALLER/tmp
  sed -i "/#ODMPATCHES/r $INSTALLER/tmp" $INSTALLER/common/ramdiskinstall.sh
  rm -f $INSTALLER/tmp
  for OMIX in ${MIXS}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    #ODMPATCHES
    patch_xml -s $MIX '/mixer/ctl[@name="HPHIGHLEVEL SWITCH SWITCH"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="CLASSD_VOLTAGE_CONFIG"]' "5100"
    patch_xml -s $MIX '/mixer/ctl[@name="CLASSD VIR_SWITCH CLASSD_EN"]' "On"
    patch_xml -u $MIX '/mixer/ctl[@name="PLAY48K SWITCH SWITCH"]' "1"
    patch_xml -u $MIX '/mixer/ctl[@name="PLAY96K SWITCH SWITCH"]' "1"
    patch_xml -u $MIX '/mixer/ctl[@name="PLAY192K SWITCH SWITCH"]' "1"
    #NON-ODMPATCHES
  done
fi

ui_print "   ! Mixer edits & patches by Ultram8 !"

if $MAGISK && ! $SYSOVERRIDE; then  
  for i in "ASP" "SHB" "FMAS" "AP" "OAP" "BIT" "COMP" "QCP" "CMPSR"; do
    sed -i "2i $i=$(eval echo \$$i)" $INSTALLER/common/aml.sh
  done
  cp_ch -n $INSTALLER/common/aml.sh $UNITY/.aml.sh
fi

ui_print " "
ui_print " "
ui_print "   This build is achieved with help of following people:"
ui_print " "
ui_print "   David Foresman, Rostislav Kaleta, Joseph Paige"
ui_print "   Holger Hartwig, John Fawkes, Egidio Loi"
ui_print "   Zach Bryan, Daniel Glid, Raik Siegert"
ui_print "   Jian Wen Lee, We are Techies, Daniel Tinjala"
ui_print "   Leo Van Baal, Janusz Rejniak, Martin Stolpe"
ui_print "   Amir Philos, Daveed, Robert Allison"
ui_print "   Vivek Chamoli, Michi, Noah Jaksch"
ui_print "   Alexander Preuss, Frank Koster, Dmitry Volkov"
ui_print "   Bruce Peterson, Arandip Singh, Ramli Izwan"
ui_print "   Houssem Djilani, Sultan Liwon, Maxim120777"
ui_print "   Gennadiy Shkarin, Erih Megribanov"
ui_print " "
ui_print "   Sorry if I forgot someone ;)"
ui_print " "
ui_print " "
sleep 6
