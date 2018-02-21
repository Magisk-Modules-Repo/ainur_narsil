if $BOOTMODE; then AUO=/storage/emulated/0/sauron_useroptions; else AUO=/data/media/0/sauron_useroptions; fi
ui_print " "
ui_print "- Sauron User Options -"
if [ ! -f $AUO ]; then
  ui_print "   ! sauron_useroptions not detected !"
  ui_print "   Creating $AUO with default options..."
  ui_print "   Using default options"
  cp -f $INSTALLER/sauron_useroptions $AUO
else
  ui_print "   sauron_useroptions detected"
  ui_print "   Using specified options"
fi
cp_ch_nb $AUO $UNITY$SYS/etc/sauron_useroptions
AUO=$UNITY$SYS/etc/sauron_useroptions
$MAGISK || sed -i "/^EOF/ i\\$AUO" $INSTALLER/common/unityfiles/addon.sh
get_uo "AP" "audpol"
get_uo "FMAS" "install.fmas"
get_uo "SHB" "qc.install.shoebox" "QCP"
get_uo "OAP" "qc.out.audpol" "QCP"
get_uo "ASP" "qc.install.asp" "QCP"
get_uo "APTX" "qc.install.aptx" "QCP"
get_uo "COMP" "qc.remove.compander" "QCP"
if [ "$QCP" ]; then
  IMPEDANCE=$(grep_prop "qc.impedance" $AUO)
  RESAMPLE=$(grep_prop "qc.resample.khz" $AUO)
  BTRESAMPLE=$(grep_prop "qc.bt.resample.khz" $AUO)    
  case $(grep_prop "qc.bitsize" $AUO) in
    16) BIT=S16_LE;;
    24) BIT=S24_LE;;
    32) $QCNEW && BIT=S32_LE || BIT="";;
    *) BIT="";;
  esac
fi

## Install logic by UltraM8 @XDA DO NOT MODIFY
cp_ch $NAZ/libaudiopreprocessing.so $INSTALLER$SFX/libaudiopreprocessing.so
cp_ch $NAZ/libbundlewrapper.so $INSTALLER$SFX/libbundlewrapper.so
cp_ch $NAZ/libeffectproxy.so $INSTALLER$SFX/libeffectproxy.so
if [ -d "$LIB64" ]; then
   cp_ch $NAZ/libaudiopreprocessing2.so $INSTALLER$SFX64/libaudiopreprocessing.so
   cp_ch $NAZ/libbundlewrapper2.so $INSTALLER$SFX64/libbundlewrapper.so
   cp_ch $NAZ/libeffectproxy2.so $INSTALLER$SFX64/libeffectproxy.so
fi

if [ "$QCP" ]; then
  prop_process $INSTALLER/common/propsqcp.prop
  [ $API -ge 26 ] && prop_process $INSTALLER/common/propsqcporeo.prop
  cp_ch $SAU/lib/libreverbwrapper.so $INSTALLER$SFX/libreverbwrapper.so
  cp_ch $SAU/lib/libdownmix1.so $INSTALLER$SFX/libdownmix.so
  if [ -d "$LIB64" ]; then
    cp_ch $SAU/lib/libreverbwrapper1.so $INSTALLER$SFX64/libreverbwrapper.so
	cp_ch $SAU/lib/libdownmix4.so $INSTALLER$SFX64/libdownmix.so
  fi
  cp_ch $VALAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX/libqcbassboost.so
  cp_ch $VALAR/lib/soundfx/libqcreverb.so $UNITY$VSFX/libqcreverb.so
  cp_ch $VALAR/lib/soundfx/libqcvirt.so $UNITY$VSFX/libqcvirt.so
  cp_ch $MORG/modules/mpq-adapter.ko $UNITY$LIB/modules/mpq-adapter.ko
  cp_ch $MORG/modules/mpq-dmx-hw-plugin.ko $UNITY$LIB/modules/mpq-dmx-hw-plugin.ko
  if [ ! -f "$ADSP/libc++.so.1" ] && [ ! -f "$ADSP/libc++abi.so.1" ]; then
    cp_ch $MORG/hammer/libc++.so.1 $ADSP2/libc++.so.1
    cp_ch $MORG/hammer/libc++abi.so.1 $ADSP2/libc++abi.so.1  
  fi
  if [ -d "$VLIB64" ]; then
    cp_ch $MAIAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX64/libqcbassboost.so
    cp_ch $MAIAR/lib/soundfx/libqcreverb.so $UNITY$VSFX64/libqcreverb.so
    cp_ch $MAIAR/lib/soundfx/libqcvirt.so $UNITY$VSFX64/libqcvirt.so
  fi 
  if [ -f "$SYS/etc/htc_audio_effects.conf" ]; then
    prop_process $INSTALLER/common/propshtc.prop
    cp_ch $SAU/files/default_vol_level.conf $UNITY$ETC/default_vol_level.conf
    cp_ch $SAU/files/TFA_default_vol_level.conf $UNITY$ETC/TFA_default_vol_level.conf
    cp_ch $SAU/files/NOTFA_default_vol_level.conf $UNITY$ETC/NOTFA_default_vol_level.conf
    cp_ch $SAU/files/libhtcacoustic.so $UNITY$LIB/libhtcacoustic.so 
  fi  
  if [ "$M10" ] || [ "$BOLT" ]; then
    cp_ch $SAU/lib/libaudio-ftm.so $UNITY$LIB/libaudio-ftm.so 
    cp_ch $SAU/lib/libaudio-ftm2.so $UNITY$LIB64/libaudio-ftm.so    
  fi
  if [ "$M9" ]; then
    prop_process $INSTALLER/common/propsresample.prop
    cp_ch $SAU/files/tfa/playback.drc $UNITY$ETC/tfa/playback.drc
    cp_ch $SAU/files/tfa/playback.eq $UNITY$ETC/tfa/playback.eq
    cp_ch $SAU/files/tfa/playback.preset $UNITY$ETC/tfa/playback.preset
    cp_ch $SAU/files/tfa/playback_l.drc $UNITY$ETC/tfa/playback_l.drc
    cp_ch $SAU/files/tfa/playback_l.eq $UNITY$ETC/tfa/playback_l.eq
    cp_ch $SAU/files/tfa/playback_l.preset $UNITY$ETC/tfa/playback_l.preset
    cp_ch $SAU/files/tfa/tfa9895.patch $UNITY$ETC/tfa/tfa9895.patch
    cp_ch $SAU/files/tfa/tfa9895MFG.patch $UNITY$ETC/tfa/tfa9895MFG.patch
    cp_ch $SAU/files/libtfa9895.so $UNITY$LIB/libtfa9895.so
    cp_ch $SAU/files/libtfa98952.so $UNITY$LIB64/libtfa9895.so
    if [ $API -ge 24 ]; then
      cp_ch $VALAR/libqcompostprocbundle.so $UNITY$SFX/libqcompostprocbundle.so
      cp_ch $MAIAR/libqcompostprocbundle.so $UNITY$SFX64/libqcompostprocbundle.so
    fi
  fi  
  if [ "$M8" ]; then
    cp_ch $SAU/files/audio/tfa9887_feature.config $UNITY$ETC/audio/tfa9887_feature.config
    cp_ch $SAU/files/libtfa9887.so $UNITY$LIB/libtfa9887.so
  fi  
  if [ -f "$AMPA" ]; then
    prop_process $INSTALLER/common/propsresample.prop
    cp_ch $SAU/files/TAS2557_A.ftcfg $UNITY$ETC/TAS2557_A.ftcfg
    cp_ch $SAU/files/TAS2557_B.ftcfg $UNITY$ETC/TAS2557_B.ftcfg
    cp_ch $SAU/files/fw/tas2557s_uCDSP_PG21.bin $UNITY$ETC/firmware/tas2557s_uCDSP_PG21.bin
    if [ -f "U11P" ]; then
      cp_ch $SAU/files/fw/tas2557s_uCDSP_24bit.bin $UNITY$VETC/firmware/tas2557s_uCDSP_24bit.bin	
      cp_ch $SAU/files/fw/tas2557s_uCDSP.bin $UNITY$VETC/firmware/tas2557s_uCDSP.bin
    fi
    cp_ch $SAU/files/bin/ti_audio_s $UNITY$BIN/ti_audio_s
  fi
  if [ "$OP5" ]; then
    cp_ch $SAU/files/settings/90_Sambo.parms $UNITY$ETC/settings/90_Sambo.parms
    cp_ch $SAU/files/settings/coldboot.patch $UNITY$ETC/settings/coldboot.patch
    cp_ch $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq $UNITY$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq
    cp_ch $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset $UNITY$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset	
    cp_ch $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq $UNITY$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq
    cp_ch $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset $UNITY$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset	
    cp_ch $SAU/files/settings/SPK_Knowles_bottom0417.speaker $UNITY$ETC/settings/SPK_Knowles_bottom0417.speaker
    cp_ch $SAU/files/settings/TFA9890_N1B12_N1C3_v3.config $UNITY$ETC/settings/TFA9890_N1B12_N1C3_v3.config
    cp_ch $SAU/files/settings/TFA9890_N1C3_2_1_1.patch $UNITY$ETC/settings/TFA9890_N1C3_2_1_1.patch	
    cp_ch $SAU/files/libtfa9890.so $UNITY$LIB/libtfa9890.so	
    cp_ch $SAU/files/libtfa98902.so $UNITY$LIB64/libtfa9890.so
  fi  
  if [ ! -f "$HWDTS" ]; then
    cp_ch $MORG/hammer/DTS_HPX_MODULE.so.1 $ADSP2/DTS_HPX_MODULE.so.1
    cp_ch $MORG/hammer/SrsTruMediaModule.so.1 $ADSP2/SrsTruMediaModule.so.1
    cp_ch $SAU/data/effect /data/misc/dts/effect
    cp_ch $SAU/data/effect9 /data/misc/dts/effect9
    cp_ch $SAU/data/effect13 /data/misc/dts/effect13
    cp_ch $SAU/data/effect17 /data/misc/dts/effect17
    cp_ch $SAU/data/effect21 /data/misc/dts/effect21
    cp_ch $SAU/data/effect24 /data/misc/dts/effect24
    cp_ch $SAU/data/effect25 /data/misc/dts/effect25
    cp_ch $SAU/data/effect33 /data/misc/dts/effect33
    cp_ch_nb $SAU/data/origeffect.bak /data/misc/dts/origeffect.bak
  fi
  if $ASP; then
    sed -i -r "s/audio.pp.asphere.enabled(.?)false/audio.pp.asphere.enabled\1true/" $INSTALLER/common/system.prop
    [ $API -ge 26 ] && echo "vendor.audio.pp.asphere.enabled=1" >> $INSTALLER/common/system.prop
    cp_ch $SAU/audiosphere/audiosphere.jar $UNITY$SYS/framework/audiosphere.jar
    cp_ch $SAU/audiosphere/audiosphere.xml $UNITY$SYS/etc/permissions/audiosphere.xml
    cp_ch $SAU/audiosphere/libasphere.so $UNITY$SFX/libasphere.so
    cp_ch $SAU/audiosphere/libasphere2.so $UNITY$SFX64/libasphere.so
    cp_ch $MORG/hammer/AudioSphereModule.so.1 $ADSP2/AudioSphereModule.so.1  
    if [ ! -f "$VLIB/libqtigef.so" ]; then
      cp_ch $SAU/lib/libqtigef.so $UNITY$VLIB/libqtigef.so
      cp_ch $SAU/lib/libqtigef2.so $UNITY$VLIB64/libqtigef.so 
    fi   
  fi
  if $SHB; then
    cp_ch $SAU/lib/libshoebox.so $UNITY$SFX/libshoebox.so
    cp_ch $SAU/lib/libshoebox2.so $UNITY$SFX64/libshoebox.so
    if [ ! -f "$VLIB/libqtigef.so" ]; then
      cp_ch $SAU/lib/libqtigef.so $UNITY$VLIB/libqtigef.so
      cp_ch $SAU/lib/libqtigef2.so $UNITY$VLIB64/libqtigef.so 
    fi  
  fi
  if $APTX; then
    prop_process $INSTALLER/common/propsaptx.prop
    if [ ! -f "$ACDB/adsp_avs_config.acdb" ]; then
      cp_ch $MORG/hammer/adsp_avs_config.acdb $UNITY$ACDB/adsp_avs_config.acdb
    fi
    cp_ch $MORG/hammer/capi_v2_aptX_Classic.so $ADSP2/capi_v2_aptX_Classic.so
    cp_ch $MORG/hammer/capi_v2_aptX_HD.so $ADSP2/capi_v2_aptX_HD.so   
    if [ $API -ge 25 ]; then  
      [ -f "$VLIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" ] && cp_ch $SAU/lib/libaptX-1.0.0-rel-Android21-ARMv7A.so $UNITY$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" ] && cp_ch $SAU/lib/libaptXHD-1.0.0-rel-Android21-ARMv7A.so $UNITY$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXScheduler.so" -o -f "$LIB/libaptXScheduler.so" ] && cp_ch $SAU/lib/libaptXScheduler.so $UNITY$LIB/libaptXScheduler.so
      [ -f "$VLIB/libbt-aptX-ARM-4.2.2.so" -o -f "$LIB/libbt-aptX-ARM-4.2.2.so" ] && cp_ch $SAU/lib/libbt-aptX-ARM-4.2.2.so $UNITY$LIB/libbt-aptX-ARM-4.2.2.so
      [ -f "$VLIB/libbt-codec_aptx.so" -o -f "$LIB/libbt-codec_aptx.so" ] && cp_ch $SAU/lib/libbt-codec_aptx.so $UNITY$LIB/libbt-codec_aptx.so
      [ -f "$VLIB/libbt-codec_aptxhd.so" -o -f "$LIB/libbt-codec_aptxhd.so" ] && cp_ch $SAU/lib/libbt-codec_aptxhd.so $UNITY$LIB/libbt-codec_aptxhd.so  
    fi
  fi  
fi

if [ "$MTK" ]; then
  prop_process $INSTALLER/common/propsmtk.prop
  cp_ch $NAZ/libdownmix.so $INSTALLER$SFX/libdownmix.so
  cp_ch $NAZ/libreverbwrapper.so $INSTALLER$SFX/libreverbwrapper.so
  if [ -d "$LIB64" ]; then
    cp_ch $NAZ/libdownmix2.so $INSTALLER$SFX64/libdownmix.so
    cp_ch $NAZ/libreverbwrapper2.so $INSTALLER$SFX64/libreverbwrapper.so
  fi
fi

if [ "$EXY" ]; then
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  cp_ch $SAU/lib/libdownmix2.so $INSTALLER$SFX/libdownmix.so
  cp_ch $SAU/lib/libreverbwrapper2.so $INSTALLER$SFX/libreverbwrapper.so
  if [ -d "$LIB64" ]; then
    cp_ch $SAU/lib/libreverbwrapper3.so $INSTALLER$SFX64/libreverbwrapper.so
    cp_ch $SAU/lib/libdownmix3.so $INSTALLER$SFX64/libdownmix.so  
  fi
fi

if [ "$MIUI" ]; then
  sed -i 's/persist.audio.hifi(.?)true/'d $INSTALLER/common/system.prop
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  sed -i 's/persist.audio.hifi.volume(.?)1/'d $INSTALLER/common/system.prop
fi

if $FMAS; then
  prop_process $INSTALLER/common/propfmas.prop
  cp_ch $SAU/lib/libfmas.so $UNITY$SFX/libfmas.so
fi

if [ "$AX7" ] || [ "$V20" ] || [ "$G6" ] || [ "$Z9" ] || [ "$Z9M" ] || [ "$Z11" ] || [ "$LX3" ] || [ "$X9" ]; then
  sed -i -r "s/persist.audio.hifi.int_codec(.?)true/persist.audio.hifi.int_codec\1false/" $INSTALLER/common/system.prop
  sed -i -r "s/audio.nat.codec.enabled(.?)1/audio.nat.codec.enabled\10/" $INSTALLER/common/system.prop  
fi

## FUNCTIONS
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
patch_mixer_toplevel() {
  if [ "$(grep "<ctl name=\"$1\" value=\".*\" />" $3)" ]; then
    sed -i "0,/<ctl name=\"$1\" value=\".*\" \/>/ {/<ctl name=\"$1\" value=\".*\" \/>/p; s/\(<ctl name=\"$1\" value=\".*\" \/>\)/<!--$MODID\1$MODID-->/}" $3
    sed -i "0,/<ctl name=\"$1\" value=\".*\" \/>/ s/\(<ctl name=\"$1\" value=\"\).*\(\" \/>\)/\1$2\2<!--$MODID-->/" $3
  elif [ -z $4 ]; then
    sed -i "/<mixer>/ a\    <ctl name=\"$1\" value=\"$2\" \/><!--$MODID-->" $3
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

ui_print "   Patching audio_effects configs"
for FILE in ${CFGS}; do
  if $MAGISK; then
    cp_ch $ORIGDIR$FILE $UNITY$FILE
  else
    [ ! -f $ORIGDIR$FILE.bak ] && cp_ch $ORIGDIR$FILE $UNITY$FILE.bak
  fi
  case $FILE in
    *.conf) if $ASP; then
              sed -i "/audiosphere {/,/} /d" $UNITY$FILE
              sed -i "s/^effects {/effects {\n  audiosphere { #$MODID\n    library audiosphere\n    uuid 184e62ab-2d19-4364-9d1b-c0a40733866c\n  } #$MODID/g" $UNITY$FILE
              sed -i "s/^libraries {/libraries {\n  audiosphere { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libasphere.so\n  } #$MODID/g" $UNITY$FILE
            fi
            if $SHB; then
              sed -i "/libshoebox {/,/}/d" $UNITY$FILE
              sed -i "s/^effects {/effects {\n  shoebox { #$MODID\n    library shoebox\n    uuid 1eab784c-1a36-4b2a-b7fc-e34c44cab89e\n  } #$MODID/g" $UNITY$FILE
              sed -i "s/^libraries {/libraries {\n  shoebox { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libshoebox.so\n  } #$MODID/g" $UNITY$FILE
            fi  
            if $FMAS; then
              [ "$QCP" -a "$FILE" == "$SYS/etc/audio_effects.conf" ] && continue
              backup_and_patch "virtualizer" "library bundle" "library fmas" "uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $UNITY$FILE
              backup_and_patch "downmix" "library downmix" "library fmas" "uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $UNITY$FILE
              sed -i "s/^libraries {/libraries {\n  fmas { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libfmas.so\n  } #$MODID/g" $UNITY$FILE
            fi;;
    *.xml) if $ASP && [ ! "$(grep "audiosphere" $UNITY$FILE)" ]; then
             sed -i "/audiosphere/d" $UNITY$FILE
             sed -i "/<libraries>/ a\        <library name=\"audiosphere\" path=\"libasphere.so\"\/><!--$MODID-->" $UNITY$FILE
             sed -i "/<effects>/ a\        <effect name=\"audiosphere\" library=\"audiosphere\" uuid=\"184e62ab-2d19-4364-9d1b-c0a40733866c\"\/><!--$MODID-->" $UNITY$FILE
           fi
           if $SHB && [ ! "$(grep "shoebox" $UNITY$FILE)" ]; then
             sed -i "/libshoebox/d" $UNITY$FILE
             sed -i "/<libraries>/ a\        <library name=\"shoebox\" path=\"libshoebox.so\"\/><!--$MODID-->" $UNITY$FILE
             sed -i "/<effects>/ a\        <effect name=\"shoebox\" library=\"shoebox\" uuid=\"1eab784c-1a36-4b2a-b7fc-e34c44cab89e\"\/><!--$MODID-->" $UNITY$FILE
           fi  
           if $FMAS && [ ! "$(grep "fmas" $UNITY$FILE)" ]; then
             sed -ri "/<effect name=\"virtualizer\"/ s/<!--(.*)$MODID-->/\1/g" $UNITY$FILE
             sed -ri "/<effect name=\"downmix\" / s/<!--(.*)$MODID-->/\1/g" $UNITY$FILE
             sed -i "/<effects>/ a\        <effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $UNITY$FILE
             sed -i "/<effects>/ a\        <effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $UNITY$FILE
             sed -i "/<libraries>/ a\        <library name=\"fmas\" path=\"libfmas.so\"\/><!--$MODID-->" $UNITY$FILE
           fi
  esac
done

##                    POLICY CONFIGS EDITS BY ULTRAM8                           ##
ui_print "   Patching audio policy"
if $AP && [ -f $SYS/etc/audio_policy.conf ]; then
  if $MAGISK; then
    cp_ch $ORIGDIR$SYS/etc/audio_policy.conf $UNITY$SYS/etc/audio_policy.conf
  else
    [ ! -f $ORIGDIR$SYS/etc/audio_policy.conf.bak ] && cp_ch $ORIGDIR$SYS/etc/audio_policy.conf $UNITY$SYS/etc/audio_policy.conf.bak
  fi
  for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
    if [ "$AUD" != "compress_offload" ]; then
      backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_8_24_BIT" $UNITY$SYS/etc/audio_policy.conf
    fi
    if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
      backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $UNITY$SYS/etc/audio_policy.conf
    fi
    backup_and_patch "$AUD" "sampling_rates" "sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000" $UNITY$SYS/etc/audio_policy.conf
  done
fi
if $OAP && [ -f $VEN/etc/audio_output_policy.conf ]; then
  if $MAGISK; then
    cp_ch $ORIGDIR$VEN/etc/audio_output_policy.conf $UNITY$VEN/etc/audio_output_policy.conf
  else
    [ ! -f $ORIGDIR$VEN/etc/audio_output_policy.conf.bak ] && cp_ch $ORIGDIR$VEN/etc/audio_output_policy.conf $UNITY$VEN/etc/audio_output_policy.conf.bak
  fi
  for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
    if [[ "$AUD" != "compress_offload"* ]]; then
      backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT" $UNITY$VEN/etc/audio_output_policy.conf
    fi
    if [ "$AUD" == "direct" ]; then
      if [ "$(grep "compress_offload" $VEN/etc/audio_output_policy.conf)" ]; then
        backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING" $UNITY$VEN/etc/audio_output_policy.conf
      else
        backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $UNITY$VEN/etc/audio_output_policy.conf
      fi
    fi
    backup_and_patch "$AUD" "sampling_rates" "sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000" $UNITY$VEN/etc/audio_output_policy.conf
    [ -z $BIT ] || backup_and_patch "$AUD" "bit_width" "bit_width $BIT" $UNITY$VEN/etc/audio_output_policy.conf
  done
fi
if $AP && [ -f $SYS/etc/audio_policy_configuration.xml ]; then
  if $MAGISK; then
    cp_ch $ORIGDIR$SYS/etc/audio_policy_configuration.xml $UNITY$SYS/etc/audio_policy_configuration.xml
  else
    [ ! -f $ORIGDIR$SYS/etc/audio_policy_configuration.xml.bak ] && cp_ch $ORIGDIR$SYS/etc/audio_policy_configuration.xml $UNITY$SYS/etc/audio_policy_configuration.xml.bak
  fi
  ui_print "   Patching audio policy configuration"
  patch_audpol "primary output" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"48000,96000,192000\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
  patch_audpol "raw" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
  patch_audpol "deep_buffer" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"192000\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
  patch_audpol "multichannel" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
  # Use 'channel_masks' for conf files and 'channelMasks' for xml files
  patch_audpol "direct_pcm" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\"\1/; s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
  patch_audpol "compress_offload" "s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
fi

##                        MIXER EDITS BY ULTRAM8                             ##
##                  SPECIAL DEVICE'S EDITS BY SKREM339                       ##
## ! MAKE SURE YOU CREDIT PEOPLE MENTIONED HERE WHEN USING THESE XML EDITS ! ##
ui_print "   Patching mixer"
if [ "$QCP" ]; then
  for MIX in ${MIXS}; do
    if $MAGISK; then
      cp_ch $ORIGDIR$MIX $UNITY$MIX
    else
      [ ! -f $ORIGDIR$MIX.bak ] && cp_ch $ORIGDIR$MIX $UNITY$MIX.bak
    fi
    ## MAIN DAC patches
    # BETA FEATURES
    if [ "$BIT" ]; then
      patch_mixer_toplevel "SLIM_0_RX Format" "$BIT" $UNITY$MIX
      patch_mixer_toplevel "SLIM_5_RX Format" "$BIT" $UNITY$MIX
      [ ! -z $QC8996 -o ! -z $QC8998 ] && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT" $UNITY$MIX
      patch_mixer_toplevel "USB_AUDIO_RX Format" "$BIT" $UNITY$MIX
      patch_mixer_toplevel "HDMI_RX Bit Format" "$BIT" $UNITY$MIX 
    fi
    if [ "$IMPEDANCE" ]; then
      patch_mixer_toplevel "HPHR Impedance" "$IMPEDANCE" $UNITY$MIX
      patch_mixer_toplevel "HPHL Impedance" "$IMPEDANCE" $UNITY$MIX
    fi
    if [ "$RESAMPLE" ]; then
      patch_mixer_toplevel "SLIM_0_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      patch_mixer_toplevel "SLIM_5_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      [ ! -z $QC8996 -o ! -z $QC8998 ] && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE" $UNITY$MIX  
    fi
    if [ "$BTRESAMPLE" ]; then
      patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE" $UNITY$MIX
    fi
    if [ "$AX7" ]; then
      ###  v v v  Special Axon7 AKM patches by SKREM339  v v v
      patch_mixer_toplevel "AKM HIFI Switch Sel" "ak4490" $UNITY$MIX "updateonly"
      patch_mixer_toplevel "Smart PA Init Switch" "On" $UNITY$MIX 
      patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $UNITY$MIX 
      patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $UNITY$MIX 
    fi
    ###  ^ ^ ^  Special Axon7 AKM patches by SKREM339  ^ ^ ^  ###
    if [ "$LX3" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $UNITY$MIX
      patch_mixer_toplevel "ESS_HEADPHONE Off" "On" $UNITY$MIX
    fi
    if [ "$X9" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $UNITY$MIX
      patch_mixer_toplevel "Es9018 Hifi Switch" "1" $UNITY$MIX
    fi   
    if [ "$Z9" ] || [ "$Z9M" ]; then
      patch_mixer_toplevel "HP Out Volume" "22" $UNITY$MIX
      patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $UNITY$MIX
      patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $UNITY$MIX
    fi
    if [ "$Z11" ]; then
      patch_mixer_toplevel "AK4376 DAC Digital Filter Mode" "Slow Roll-Off" $UNITY$MIX
      patch_mixer_toplevel "AK4376 HPL Power-down Resistor" "Hi-Z" $UNITY$MIX
      patch_mixer_toplevel "AK4376 HPR Power-down Resistor" "Hi-Z" $UNITY$MIX
      patch_mixer_toplevel "AK4376 HP-Amp Analog Volume" "15" $UNITY$MIX
    fi
    if [ "$V20" ] || [ "$V30" ] || [ "$G6" ]; then
      patch_mixer_toplevel "Es9018 AVC Volume" "14" $UNITY$MIX
      patch_mixer_toplevel "Es9018 HEADSET TYPE" "1" $UNITY$MIX
      patch_mixer_toplevel "Es9018 State" "Hifi" $UNITY$MIX
      # patch_mixer_toplevel "Es9018 Master Volume" "1" $UNITY$MIX
      patch_mixer_toplevel "HIFI Custom Filter" "6" $UNITY$MIX
    fi  
    if [ -f $AMPA ]; then 
      patch_mixer_toplevel "HTC_AS20_VOL Index" "Eleven" $UNITY$MIX
    fi 
    if [ "$QC8996" ] || [ "$QC8998" ]; then 
      patch_mixer_toplevel "VBoost Ctrl" "AlwaysOn" $UNITY$MIX
      patch_mixer_toplevel "VBoost Volt" "8.6V" $UNITY$MIX
    fi
    
    ### MAIN DAC patches  ##
    # Custom Stereo
    patch_mixer_toplevel "Set Custom Stereo OnOff" "Off" $UNITY$MIX
    # patch_mixer_toplevel "Set Custom Stereo" "1" $UNITY$MIX
    # Custom Stereo ##
    # APTX Dec License
    if $APTX; then  
      patch_mixer_toplevel "APTX Dec License" "21" $UNITY$MIX
    fi
    # HW  DTS HPX edits
    patch_mixer_toplevel "Set HPX OnOff" "1" $UNITY$MIX
    patch_mixer_toplevel "Set HPX ActiveBe" "1" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 9 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 13 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 17 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 21 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 24 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 15 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "PCM_Dev 33 Topology" "DTS" $UNITY$MIX
    patch_mixer_toplevel "DS2 OnOff" "Off" $UNITY$MIX	
    # APTX Dec License ##
    # Codec Bandwith Expansion
    patch_mixer_toplevel "Codec Wideband" "1" $UNITY$MIX
    # Codec Bandwith Expansion ##
    # HPH Type
    patch_mixer_toplevel "HPH Type" "1" $UNITY$MIX
    # HPH Type ##
    # Audiosphere Enable    
    if $ASP; then
      patch_mixer_toplevel "Audiosphere Enable" "On" $UNITY$MIX
      patch_mixer_toplevel "MSM ASphere Set Param" "1" $UNITY$MIX
    fi   
    # Audiosphere Enable ##
    # TFA amp patch
    if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
      patch_mixer_toplevel "TFA9895 Profile" "hq" $UNITY$MIX
      patch_mixer_toplevel "TFA9895 Playback Volume" "255" $UNITY$MIX
      patch_mixer_toplevel "SmartPA Switch" "1" $UNITY$MIX
    fi	 
    # TFA amp patch   ##
    ###  v v v  TAS amp Patch  v v v
    patch_mixer_toplevel "TAS2552 Volume" "125" $UNITY$MIX "updateonly"
    if [ -f "$AMPA" ]; then
      patch_mixer_toplevel "TAS2557 Volume" "30" $UNITY$MIX
    fi 
    # HW  SRS Trumedia edits (consider non-working for all QC, may break HDMI on some rare devices, needs custom kernel support)
    patch_mixer_toplevel "SRS Trumedia" "1" $UNITY$MIX
    patch_mixer_toplevel "SRS Trumedia HDMI" "1" $UNITY$MIX
    patch_mixer_toplevel "SRS Trumedia I2S" "1" $UNITY$MIX
    patch_mixer_toplevel "SRS Trumedia MI2S" "1" $UNITY$MIX       
    # HW  SRS Trumedia edits  ##
    # if [ "$QC8226" ]; then
      # patch_mixer_toplevel "HIFI2 RX Volume" "84" $UNITY$MIX 
      # patch_mixer_toplevel "HIFI3 RX Volume" "84" $UNITY$MIX
      # patch_mixer_toplevel "HIFI0 RX Volume" "84" $UNITY$MIX
      # patch_mixer_toplevel "HIFI5 RX Volume" "84" $UNITY$MIX
    # fi
    # 8226 patch  ##
    # 8996
    # if [ "$QC8996" ]; then
    patch_mixer_toplevel "HiFi Function" "On" $UNITY$MIX 
    # fi
    # 8996  ##
    if $COMP; then
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/p" $UNITY$MIX
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ { s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/><!--$MODID-->/; n; s/\( *\)\(.*\)/\1<!--$MODID\2$MODID-->/}" $UNITY$MIX
    fi 
  done
fi
ui_print "   ! Mixer edits & patches by Ultram8 !"
ui_print "   ! Axon7 patch by Skrem339 !"

if $MAGISK; then
  # Add aml script variables
  add_var() {
    if [ "$(eval echo \$$1)" ]; then
      sed -i "s|^$1=$|$1=$(eval echo \$$1)|" $INSTALLER/common/aml.sh
    else
      sed -i "/^$1=$/d" $INSTALLER/common/aml.sh
    fi
  }
  add_var "QCP"
  add_var "AP"
  add_var "FMAS"
  add_var "SHB"
  add_var "OAP"
  add_var "ASP"
  add_var "TMSM"
  add_var "QCNEW"
  add_var "QCOLD"
  add_var "BIT"
  add_var "IMPEDANCE"
  add_var "RESAMPLE"
  add_var "BTRESAMPLE"
  add_var "AX7"
  add_var "LX3"
  add_var "X9"
  add_var "Z9"
  add_var "Z9M"
  add_var "Z11"
  add_var "V20"
  add_var "V30"
  add_var "G6"
  add_var "QC8996"
  add_var "QC8998"
  add_var "APTX"
  add_var "M8"
  add_var "M9"
  add_var "M10"
  add_var "COMP"
  cp_ch_nb $INSTALLER/common/aml.sh $UNITY/.aml.sh
fi
