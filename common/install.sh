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
get_uo "RPCM" "qc.install.pcm_reverb" "QCP"
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
mkdir -p $INSTALLER$ACDB $INSTALLER$BIN $INSTALLER$ETC/firmware $INSTALLER$ETC/permissions $INSTALLER$ETC/settings $INSTALLER$ETC/tfa $INSTALLER$SYS/framework $INSTALLER$LIB/modules $INSTALLER$SFX $INSTALLER$SFX64 $INSTALLER$VSFX $INSTALLER$VSFX64
cp -f $NAZ/libaudiopreprocessing.so $INSTALLER$SFX/libaudiopreprocessing.so
cp -f $NAZ/libbundlewrapper.so $INSTALLER$SFX/libbundlewrapper.so
cp -f $NAZ/libeffectproxy.so $INSTALLER$SFX/libeffectproxy.so
cp -f $NAZ/libldnhncr.so $INSTALLER$SFX/libldnhncr.so
cp -f $NAZ/libaudiopreprocessing2.so $INSTALLER$SFX64/libaudiopreprocessing.so
cp -f $NAZ/libbundlewrapper2.so $INSTALLER$SFX64/libbundlewrapper.so
cp -f $NAZ/libeffectproxy2.so $INSTALLER$SFX64/libeffectproxy.so
if [ $API -ge 26 ]; then
cp -f $NAZ/libeffectproxy3.so $INSTALLER$SFX/libeffectproxy.so
fi

if [ "$QCP" ]; then
  prop_process $INSTALLER/common/propsqcp.prop
  [ $API -ge 26 ] && prop_process $INSTALLER/common/propsqcporeo.prop
  cp -f $SAU/lib/libreverbwrapper5.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $SAU/lib/libdownmix5.so $INSTALLER$SFX/libdownmix.so
  cp -f $SAU/lib/libreverbwrapper6.so $INSTALLER$SFX64/libreverbwrapper.so
  if $RPCM; then
    cp -f $SAU/lib/libreverbwrapper.so $INSTALLER$SFX/libreverbwrapper.so
    cp -f $SAU/lib/libreverbwrapper1.so $INSTALLER$SFX64/libreverbwrapper.so
    mkdir -p /data/mediaserver/audio_dump
    cp -f $SAU/lib/libaudioutils.so $INSTALLER$LIB/libaudioutils.so
    cp -f $SAU/lib/libaudioutils2.so $INSTALLER$LIB64/libaudioutils.so
    cp -f $SAU/lib/libeffectproxy.so $INSTALLER$SFX/libeffectproxy.so
    cp -f $SAU/lib/libeffectproxy2.so $INSTALLER$SFX64/libeffectproxy.so
  fi
  cp -f $SAU/lib/libdownmix6.so $INSTALLER$SFX64/libdownmix.so
  if [ $API -ge 26 ]; then
    cp -f $SAU/lib/libdownmix1.so $INSTALLER$SFX/libdownmix.so
    cp -f $SAU/lib/libdownmix4.so $INSTALLER$SFX64/libdownmix.so
  fi
  cp -f $VALAR/lib/soundfx/libqcbassboost.so $INSTALLER$VSFX/libqcbassboost.so
  cp -f $VALAR/lib/soundfx/libqcreverb.so $INSTALLER$VSFX/libqcreverb.so
  cp -f $VALAR/lib/soundfx/libqcvirt.so $INSTALLER$VSFX/libqcvirt.so
  cp -f $MORG/modules/mpq-adapter.ko $INSTALLER$LIB/modules/mpq-adapter.ko
  cp -f $MORG/modules/mpq-dmx-hw-plugin.ko $INSTALLER$LIB/modules/mpq-dmx-hw-plugin.ko
  cp_ch $MORG/hammer/libAudienceAZA.so $ADSP2/libAudienceAZA.so
  if [ ! -f "$ADSP/libc++.so.1" ] && [ ! -f "$ADSP/libc++abi.so.1" ]; then
    cp_ch $MORG/hammer/libc++.so.1 $ADSP2/libc++.so.1
    cp_ch $MORG/hammer/libc++abi.so.1 $ADSP2/libc++abi.so.1  
  fi
  cp -f $MAIAR/lib/soundfx/libqcbassboost.so $INSTALLER$VSFX64/libqcbassboost.so
  cp -f $MAIAR/lib/soundfx/libqcreverb.so $INSTALLER$VSFX64/libqcreverb.so
  cp -f $MAIAR/lib/soundfx/libqcvirt.so $INSTALLER$VSFX64/libqcvirt.so
  if [ -f "$SYS/etc/htc_audio_effects.conf" ]; then
    prop_process $INSTALLER/common/propshtc.prop
    cp -f $SAU/files/default_vol_level.conf $INSTALLER$ETC/default_vol_level.conf
    cp -f $SAU/files/TFA_default_vol_level.conf $INSTALLER$ETC/TFA_default_vol_level.conf
    cp -f $SAU/files/NOTFA_default_vol_level.conf $INSTALLER$ETC/NOTFA_default_vol_level.conf
	if [ ! -f "$NX9" ]; then
	  cp -f $SAU/files/RT5501 $INSTALLER$ETC/RT5501
	  cp -f $SAU/files/RT5506 $INSTALLER$ETC/RT5506
      cp -f $SAU/files/libhtcacoustic.so $INSTALLER$LIB/libhtcacoustic.so
      cp -f $SAU/files/libhtcacoustic2.so $INSTALLER$LIB64/libhtcacoustic.so
    fi	
  fi  
  if [ "$M10" ] || [ "$BOLT" ]; then
    cp -f $SAU/lib/libaudio-ftm.so $INSTALLER$LIB/libaudio-ftm.so 
    cp -f $SAU/lib/libaudio-ftm2.so $INSTALLER$LIB64/libaudio-ftm.so 
  fi
  if [ "$M9" ]; then
    prop_process $INSTALLER/common/propsresample.prop
    cp -f $SAU/files/tfa/playback.drc $INSTALLER$ETC/tfa/playback.drc
    cp -f $SAU/files/tfa/playback.eq $INSTALLER$ETC/tfa/playback.eq
    cp -f $SAU/files/tfa/playback.preset $INSTALLER$ETC/tfa/playback.preset
    cp -f $SAU/files/tfa/playback_l.drc $INSTALLER$ETC/tfa/playback_l.drc
    cp -f $SAU/files/tfa/playback_l.eq $INSTALLER$ETC/tfa/playback_l.eq
    cp -f $SAU/files/tfa/playback_l.preset $INSTALLER$ETC/tfa/playback_l.preset
    cp -f $SAU/files/tfa/tfa9895.patch $INSTALLER$ETC/tfa/tfa9895.patch
    cp -f $SAU/files/tfa/tfa9895MFG.patch $INSTALLER$ETC/tfa/tfa9895MFG.patch
	mkdir -p $INSTALLER/system/vendor/etc/tfa
    cp -f $SAU/files/tfa2/playback.drc $INSTALLER/system/vendor/etc/tfa/playback.drc
    cp -f $SAU/files/tfa2/playback.eq $INSTALLER/system/vendor/etc/tfa/playback.eq
    cp -f $SAU/files/tfa2/playback.preset $INSTALLER/system/vendor/etc/tfa/playback.preset
    cp -f $SAU/files/tfa2/playback_l.preset $INSTALLER/system/vendor/etc/tfa/playback_l.preset
    cp -f $SAU/files/tfa2/playback_l.drc $INSTALLER/system/vendor/etc/tfa/playback_l.drc
    cp -f $SAU/files/tfa2/playback_l.eq $INSTALLER/system/vendor/etc/tfa/playback_l.eq
    cp -f $SAU/files/tfa2/playbackMFG.config $INSTALLER/system/vendor/etc/tfa/playbackMFG.config
    cp -f $SAU/files/tfa2/playbackMFG.drc $INSTALLER/system/vendor/etc/tfa/playbackMFG.drc
    cp -f $SAU/files/tfa2/playbackMFG.eq $INSTALLER/system/vendor/etc/tfa/playbackMFG.eq
    cp -f $SAU/files/tfa2/playbackMFG.preset $INSTALLER/system/vendor/etc/tfa/playbackMFG.preset
    cp -f $SAU/files/tfa2/playbackMFG_l.config $INSTALLER/system/vendor/etc/tfa/playbackMFG_l.config
    cp -f $SAU/files/tfa2/playbackMFG_l.eq $INSTALLER/system/vendor/etc/tfa/playbackMFG_l.eq
    cp -f $SAU/files/tfa2/playbackMFG_l.preset $INSTALLER/system/vendor/etc/tfa/playback_l.eq
    cp -f $SAU/files/tfa2/playback_l.preset $INSTALLER/system/vendor/etc/tfa/playbackMFG_l.preset
    cp -f $SAU/files/tfa2/tfa9895.config $INSTALLER/system/vendor/etc/tfa/tfa9895.config
    cp -f $SAU/files/tfa2/tfa9895.patch $INSTALLER/system/vendor/etc/tfa/tfa9895.patch
    cp -f $SAU/files/tfa2/tfa9895MFG.patch $INSTALLER/system/vendor/etc/tfa/tfa9895MFG.patch	 	
    if [ $API -ge 24 ]; then
      cp -f $VALAR/libqcompostprocbundle.so $INSTALLER$SFX/libqcompostprocbundle.so
      cp -f $MAIAR/libqcompostprocbundle.so $INSTALLER$SFX64/libqcompostprocbundle.so
    fi
  fi  
  if [ "$M8" ]; then
    mkdir -p $INSTALLER$ETC/audio
    cp -f $SAU/files/audio/tfa9887_feature.config $INSTALLER$ETC/audio/tfa9887_feature.config
    cp -f $SAU/files/libtfa9887.so $INSTALLER$LIB/libtfa9887.so
  fi  
  if [ -f "$SYS/etc/TAS2557_A.ftcfg" ]; then
    prop_process $INSTALLER/common/propsresample.prop
    cp -f $SAU/files/TAS2557_A.ftcfg $INSTALLER$ETC/TAS2557_A.ftcfg
    cp -f $SAU/files/TAS2557_B.ftcfg $INSTALLER$ETC/TAS2557_B.ftcfg
    cp -f $SAU/files/fw/tas2557s_uCDSP_PG21.bin $INSTALLER$ETC/firmware/tas2557s_uCDSP_PG21.bin
    if [ -f "U11P" ]; then
      cp -f $SAU/files/fw/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin	
      cp -f $SAU/files/fw/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    fi
    cp -f $SAU/files/bin/ti_audio_s $INSTALLER$BIN/ti_audio_s
  fi
  if [ "$OP5" ]; then
    cp -f $SAU/files/settings/90_Sambo.parms $INSTALLER$ETC/settings/90_Sambo.parms
    cp -f $SAU/files/settings/coldboot.patch $INSTALLER$ETC/settings/coldboot.patch
    cp -f $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq $INSTALLER$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq
    cp -f $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset $INSTALLER$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset	
    cp -f $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq $INSTALLER$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq
    cp -f $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset $INSTALLER$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset	
    cp -f $SAU/files/settings/SPK_Knowles_bottom0417.speaker $INSTALLER$ETC/settings/SPK_Knowles_bottom0417.speaker
    cp -f $SAU/files/settings/TFA9890_N1B12_N1C3_v3.config $INSTALLER$ETC/settings/TFA9890_N1B12_N1C3_v3.config
    cp -f $SAU/files/settings/TFA9890_N1C3_2_1_1.patch $INSTALLER$ETC/settings/TFA9890_N1C3_2_1_1.patch	
    cp -f $SAU/files/libtfa9890.so $INSTALLER$LIB/libtfa9890.so	
    cp -f $SAU/files/libtfa98902.so $INSTALLER$LIB64/libtfa9890.so
  fi
  if [ "$P2XL" ] || [ "$P2" ]; then
    cp -f $SAU/files/bin/ti_audio_s $INSTALLER$BIN/ti_audio_s
	cp -f $INSTALLER$VETC/firmware/tas2557s_PG21_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_PG21_uCDSP.bin.bak
	cp -f $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin.bak
	cp -f $INSTALLER$VETC/firmware/tas2557_cal.bin $INSTALLER$VETC/firmware/tas2557_cal.bin.bak
    cp -f $SAU/files/fw/tas2557s_uCDSP_PG21.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_PG21.bin
    cp -f $SAU/files/fw/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bin	
    cp -f $SAU/files/fw/tas2557s_uCDSP.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP.bin
    cp -f $SAU/files/TAS2557_A.ftcfg $INSTALLER$ETC/TAS2557_A.ftcfg
    cp -f $SAU/files/TAS2557_B.ftcfg $INSTALLER$ETC/TAS2557_B.ftcfg
    if 	[ "$P2" ]; then
	cp -f $SAU/files/fw/tfa98xx.cnt $INSTALLER$VETC/firmware/tfa98xx.cnt
	fi
  fi
  if [ "$P1XL" ] || [ "$P1" ]; then
  	cp -f $SAU/files/fw/tfa98xx.cnt $INSTALLER$VETC/firmware/tfa98xx.cnt
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
    cp -f $SAU/audiosphere/audiosphere.jar $INSTALLER$SYS/framework/audiosphere.jar
    cp -f $SAU/audiosphere/audiosphere.xml $INSTALLER$SYS/etc/permissions/audiosphere.xml
    cp -f $SAU/audiosphere/libasphere.so $INSTALLER$SFX/libasphere.so
    cp -f $SAU/audiosphere/libasphere2.so $INSTALLER$SFX64/libasphere.so
    cp_ch $MORG/hammer/AudioSphereModule.so.1 $ADSP2/AudioSphereModule.so.1  
    if [ ! -f "$VEN/lib/libqtigef.so" ]; then
      cp -f $SAU/lib/libqtigef.so $INSTALLER$VLIB/libqtigef.so
      cp -f $SAU/lib/libqtigef2.so $INSTALLER$VLIB64/libqtigef.so 
    fi   
  fi
  if $SHB; then
    cp -f $SAU/lib/libshoebox.so $INSTALLER$SFX/libshoebox.so
    cp -f $SAU/lib/libshoebox2.so $INSTALLER$SFX64/libshoebox.so
    if [ ! -f "$VEN/lib/libqtigef.so" ]; then
      cp -f $SAU/lib/libqtigef.so $INSTALLER$VLIB/libqtigef.so
      cp -f $SAU/lib/libqtigef2.so $INSTALLER$VLIB64/libqtigef.so 
    fi  
  fi
  if $APTX; then
    prop_process $INSTALLER/common/propsaptx.prop
    if [ ! -f "$SYS/etc/acdbdata/adsp_avs_config.acdb" ]; then
      cp -f $MORG/hammer/adsp_avs_config.acdb $INSTALLER$ACDB/adsp_avs_config.acdb
    fi
    cp_ch $MORG/hammer/capi_v2_aptX_Classic.so $ADSP2/capi_v2_aptX_Classic.so
    cp_ch $MORG/hammer/capi_v2_aptX_HD.so $ADSP2/capi_v2_aptX_HD.so   
    if [ $API -ge 25 ]; then  
      [ -f "$VLIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" ] && cp -f $SAU/lib/libaptX-1.0.0-rel-Android21-ARMv7A.so $INSTALLER$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" -o -f "$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" ] && cp -f $SAU/lib/libaptXHD-1.0.0-rel-Android21-ARMv7A.so $INSTALLER$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so
      [ -f "$VLIB/libaptXScheduler.so" -o -f "$LIB/libaptXScheduler.so" ] && cp -f $SAU/lib/libaptXScheduler.so $INSTALLER$LIB/libaptXScheduler.so
      [ -f "$VLIB/libbt-aptX-ARM-4.2.2.so" -o -f "$LIB/libbt-aptX-ARM-4.2.2.so" ] && cp -f $SAU/lib/libbt-aptX-ARM-4.2.2.so $INSTALLER$LIB/libbt-aptX-ARM-4.2.2.so
      [ -f "$VLIB/libbt-codec_aptx.so" -o -f "$LIB/libbt-codec_aptx.so" ] && cp -f $SAU/lib/libbt-codec_aptx.so $INSTALLER$LIB/libbt-codec_aptx.so
      [ -f "$VLIB/libbt-codec_aptxhd.so" -o -f "$LIB/libbt-codec_aptxhd.so" ] && cp -f $SAU/lib/libbt-codec_aptxhd.so $INSTALLER$LIB/libbt-codec_aptxhd.so  
    fi
	#Oreo+ Aptx/HD by Lazerl0rd
    if [ $API -ge 26 ]; then 
      cp -f $SAU/lib/libldacBT_enc.so $INSTALLER$LIB/libldacBT_enc.so
      cp -f $SAU/lib/libldacBT_enc64.so $INSTALLER$LIB64/libldacBT_enc.so
      cp -f $SAU/lib/libaptXHD_encoder.so $INSTALLER$LIB/libaptXHD_encoder.so
      cp -f $SAU/lib/libaptXHD_encoder64.so $INSTALLER$LIB64/libaptXHD_encoder.so
      cp -f $SAU/lib/libaptX_encoder.so $INSTALLER$LIB/libaptX_encoder.so
      cp -f $SAU/lib/libaptX_encoder64.so $INSTALLER$LIB64/libaptX_encoder.so
    fi	
  fi  
fi

if [ "$MTK" ]; then
  prop_process $INSTALLER/common/propsmtk.prop
  cp -f $NAZ/libdownmix.so $INSTALLER$SFX/libdownmix.so
  cp -f $NAZ/libreverbwrapper.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $NAZ/libdownmix2.so $INSTALLER$SFX64/libdownmix.so
  cp -f $NAZ/libreverbwrapper2.so $INSTALLER$SFX64/libreverbwrapper.so
fi

if [ "$EXY" ]; then
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  cp -f $SAU/lib/libdownmix2.so $INSTALLER$SFX/libdownmix.so
  cp -f $SAU/lib/libreverbwrapper2.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $SAU/lib/libreverbwrapper3.so $INSTALLER$SFX64/libreverbwrapper.so
  cp -f $SAU/lib/libdownmix3.so $INSTALLER$SFX64/libdownmix.so  
fi

if [ "$MIUI" ]; then
  sed -i 's/persist.audio.hifi(.?)true/'d $INSTALLER/common/system.prop
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $INSTALLER/common/system.prop
  sed -i 's/persist.audio.hifi.volume(.?)1/'d $INSTALLER/common/system.prop
fi

if $FMAS; then
  prop_process $INSTALLER/common/propfmas.prop
  cp -f $SAU/lib/libfmas.so $INSTALLER$SFX/libfmas.so
  cp -f $SAU/files/fmas_eq.dat $INSTALLER$ETC/fmas_eq.dat
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
  cp_ch $ORIGDIR$FILE $UNITY$FILE
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
for FILE in ${POLS}; do
  case $FILE in
    *audio_policy.conf) if $AP; then
                          cp_ch $ORIGDIR$FILE $UNITY$FILE
                          for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                            if [ "$AUD" != "compress_offload" ]; then
                              backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_8_24_BIT" $UNITY$FILE
                            fi
                            if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
                              backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $UNITY$FILE
                            fi
                            backup_and_patch "$AUD" "sampling_rates" "sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000" $UNITY$FILE
                          done
                        fi;;
    *audio_output_policy.conf) if $OAP; then
                                 cp_ch $ORIGDIR$FILE $UNITY$FILE
                                 for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                   if [[ "$AUD" != "compress_offload"* ]]; then
                                     backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT" $UNITY$FILE
                                   fi
                                   if [ "$AUD" == "direct" ]; then
                                     if [ "$(grep "compress_offload" $FILE)" ]; then
                                       backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING" $UNITY$FILE
                                     else
                                       backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $UNITY$FILE
                                     fi
                                   fi
                                   backup_and_patch "$AUD" "sampling_rates" "sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000" $UNITY$FILE
                                   [ -z $BIT ] || backup_and_patch "$AUD" "bit_width" "bit_width $BIT" $UNITY$FILE
                                 done
                               fi;;
    *audio_policy_configuration.xml) if $AP; then
                                       cp_ch $ORIGDIR$FILE $UNITY$FILE
                                       ui_print "   Patching audio policy configuration"
                                       patch_audpol "primary output" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"48000,96000,192000\"\1/" $UNITY$FILE
                                       patch_audpol "raw" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/" $UNITY$SYS/etc/audio_policy_configuration.xml
                                       patch_audpol "deep_buffer" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"192000\"\1/" $UNITY$FILE
                                       patch_audpol "multichannel" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\"\1/" $UNITY$FILE
                                       # Use 'channel_masks' for conf files and 'channelMasks' for xml files
                                       patch_audpol "direct_pcm" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\"\1/; s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $UNITY$FILE
                                       patch_audpol "compress_offload" "s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $UNITY$FILE
                                     fi;;
  esac
done

##                        MIXER EDITS BY ULTRAM8                             ##
##                  SPECIAL DEVICE'S EDITS BY SKREM339                       ##
## ! MAKE SURE YOU CREDIT PEOPLE MENTIONED HERE WHEN USING THESE XML EDITS ! ##
ui_print "   Patching mixer"
if [ "$QCP" ]; then
  for MIX in ${MIXS}; do
    cp_ch $ORIGDIR$MIX $UNITY$MIX
    ## MAIN DAC patches
    # BETA FEATURES
    if [ "$BIT" ]; then
      patch_mixer_toplevel "SLIM_0_RX Format" "$BIT" $UNITY$MIX
      patch_mixer_toplevel "SLIM_5_RX Format" "$BIT" $UNITY$MIX
      [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT" $UNITY$MIX
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
      [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE" $UNITY$MIX
      patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE" $UNITY$MIX  
    fi
    if [ "$BTRESAMPLE" ]; then
      patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE" $UNITY$MIX
    fi
    if [ "$AX7" ]; then
      patch_mixer_toplevel "Smart PA Init Switch" "On" $UNITY$MIX 
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
	patch_mixer_toplevel "RX HPH Mode" "CLS_H_HIFI" $UNITY$MIX
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
