# Tell user aml is needed if applicable
if $MAGISK && ! $SYSOVERRIDE; then
  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" -o -name "*mixer_paths*.xml")
  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
    ui_print " "
    ui_print "   ! Conflicting audio mod found!"
    ui_print "   ! You will need to install !"
    ui_print "   ! Audio Modification Library !"
    sleep 3
  fi
fi

if $BOOTMODE; then AUO=/storage/emulated/0/sauron_useroptions; else AUO=/data/media/0/sauron_useroptions; fi
ui_print " "
ui_print "- Sauron User Options -"
[ -f $AUO ] && UVER=$(grep_prop Version $AUO)
if [ ! -f $AUO ] || [ -z $UVER ]; then
  if [ ! -f $AUO ]; then ui_print "   ! Sauron_useroptions not detected !"; else ui_print "   Deprecated version of sauron_useroptions detected!"; fi
  ui_print "   Creating $AUO with default options..."
  ui_print "   Using default options"
  cp -f $INSTALLER/sauron_useroptions $AUO
elif [ $UVER -lt $(grep_prop Version $INSTALLER/sauron_useroptions) ]; then
  ui_print "   Older version of sauron_useroptions detected!"
  ui_print "   Updating sauron_useroptions!"
  read_uo -u
  read_uo
  ui_print "   Using specified options"
else
  ui_print "   Up to date sauron_useroptions detected! "
  ui_print "   Using specified options"
fi
cp_ch_nb $AUO $UNITY$SYS/etc/sauron_useroptions
AUO=$UNITY$SYS/etc/sauron_useroptions
if ! $MAGISK || $SYSOVERRIDE; then sed -i "/^EOF/ i\\$AUO" $INSTALLER/common/unityfiles/addon.sh; fi
read_uo
ui_print " "

## Install logic by UltraM8 @XDA DO NOT MODIFY
mkdir -p $INSTALLER$ACDB $INSTALLER$BIN $INSTALLER$ETC/audio $INSTALLER$ETC/firmware $INSTALLER$ETC/permissions $INSTALLER$ETC/settings $INSTALLER$ETC/tfa $INSTALLER$SYS/framework $INSTALLER$LIB/modules $INSTALLER$SFX $INSTALLER$SFX64 $INSTALLER$VETC/firmware $INSTALLER$VETC/tfa $INSTALLER$VSFX $INSTALLER$VSFX64
cp -f $NAZ/libaudiopreprocessing.so $INSTALLER$SFX/libaudiopreprocessing.so
cp -f $NAZ/libbundlewrapper.so $INSTALLER$SFX/libbundlewrapper.so
cp -f $NAZ/libeffectproxy.so $INSTALLER$SFX/libeffectproxy.so
cp -f $NAZ/libaudiopreprocessing2.so $INSTALLER$SFX64/libaudiopreprocessing.so
cp -f $NAZ/libbundlewrapper2.so $INSTALLER$SFX64/libbundlewrapper.so
cp -f $NAZ/libeffectproxy2.so $INSTALLER$SFX64/libeffectproxy.so
if [ $API -ge 26 ]; then
  cp -f $SAU/lib/libeffectproxy4.so $INSTALLER$SFX/libeffectproxy.so
  cp -f $SAU/lib/libbundlewrapper4.so $INSTALLER$SFX/libbundlewrapper.so
  cp -f $SAU/lib/libbundlewrapper3.so $INSTALLER$SFX64/libbundlewrapper.so
fi

if [ "$QCP" ]; then
  prop_process $INSTALLER/common/propsqcp.prop
  if [ $API -ge 26 ] && [ ! "$OP3" ] && [ ! "$OP5" ]; then
    prop_process $INSTALLER/common/propsqcporeo.prop
  fi
  if [ "$OP3" ]; then
    sed -i 's/audio.offload.multiple.enabled(.?)true/'d $INSTALLER/common/system.prop
    sed -i 's/audio.offload.pcm.enable(.?)true/'d $INSTALLER/common/system.prop
    sed -i 's/audio.playback.mch.downsample(.?)false/'d $INSTALLER/common/system.prop
  fi
  cp -f $SAU/lib/libreverbwrapper5.so $INSTALLER$SFX/libreverbwrapper.so
  cp -f $SAU/lib/libdownmix5.so $INSTALLER$SFX/libdownmix.so
  cp -f $SAU/lib/libreverbwrapper6.so $INSTALLER$SFX64/libreverbwrapper.so
  if $RPCM; then
    cp -f $SAU/lib/libreverbwrapper.so $INSTALLER$SFX/libreverbwrapper.so
    cp -f $SAU/lib/libreverbwrapper1.so $INSTALLER$SFX64/libreverbwrapper.so
    #mkdir -p /data/mediaserver/audio_dump
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
  if [ -f "$SYS/etc/htc_audio_effects.conf" ] || [ -f "$VEN/etc/htc_audio_effects.conf" ]; then
    prop_process $INSTALLER/common/propshtc.prop
    cp -f $SAU/files/default_vol_level.conf $INSTALLER$ETC/default_vol_level.conf
    cp -f $SAU/files/TFA_default_vol_level.conf $INSTALLER$ETC/TFA_default_vol_level.conf
    cp -f $SAU/files/NOTFA_default_vol_level.conf $INSTALLER$ETC/NOTFA_default_vol_level.conf
    [ "$NX9" -o "$M10" -o "$BOLT" -o -f "$AMPA" ] || { cp -f $SAU/files/RT5506 $INSTALLER$ETC/RT5506;
                                                       cp -f $SAU/files/libhtcacoustic.so $INSTALLER$LIB/libhtcacoustic.so;
                                                       cp -f $SAU/files/libhtcacoustic2.so $INSTALLER$LIB64/libhtcacoustic.so; }
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
  fi
  if [ "$M8" ]; then
    cp -f $SAU/files/audio/tfa9887_feature.config $INSTALLER$ETC/audio/tfa9887_feature.config
    cp -f $SAU/files/libtfa9887.so $INSTALLER$LIB/libtfa9887.so
  fi
  if [ -f "AMPA" ]; then
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
    if $MAGISK && ! $SYSOVERRIDE; then
      mktouch $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin
      mktouch $UNITY$VEN/firmware/tas2557s_uCDSP.bin
      mktouch $UNITY$VEN/firmware/tas2557_cal.bin
    else
      mv -f $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin $UNITY$VEN/firmware/tas2557s_PG21_uCDSP.bin.bak
      mv -f $UNITY$VEN/firmware/tas2557s_uCDSP.bin $UNITY$VEN/firmware/tas2557s_uCDSP.bin.bak
      mv -f $UNITY$VEN/firmware/tas2557_cal.bin $UNITY$VEN/firmware/tas2557_cal.bin.bak
    fi
    cp -f $SAU/files/fw/tas2557s_uCDSP_PG21.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_PG21.bin
    cp -f $SAU/files/fw/tas2557s_uCDSP_24bit.bin $INSTALLER$VETC/firmware/tas2557s_uCDSP_24bit.bi
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
  if [ "$X5P" ]; then
    if $MAGISK && ! $SYSOVERRIDE; then
      mktouch $UNITY$ETC/firmware/tas2557_uCDSP.bin
    else
      mv -f $UNITY$ETC/firmware/tas2557_uCDSP.bin $UNITY$VEN/firmware/tas2557_uCDSP.bin.bak
    fi
    cp -f $SAU/files/fw/tas2557s_uCDSP.bin $INSTALLER$ETC/firmware/tas2557s_uCDSP.bin
    cp -f $SAU/files/TAS2557_A.ftcfg $INSTALLER$ETC/TAS2557_A.ftcfg
    cp -f $SAU/files/TAS2557_B.ftcfg $INSTALLER$ETC/TAS2557_B.ftcfg
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
    if [ ! -f "$SYS/etc/acdbdata/adsp_avs_config.acdb" ] && [ ! -f "$VEN/etc/acdbdata/adsp_avs_config.acdb" ]; then
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
      cp -f $SAU/lib/libelda.so $INSTALLER$LIB/libldacBT_enc.so
      cp -f $SAU/lib/libelda2.so $INSTALLER$LIB64/libldacBT_enc.so
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

if [ "$KIR" ]; then
  cp -f $NAZ/libbundlewrapper1.so $INSTALLER$SFX/ibbundlewrapper.so
  cp -f $NAZ/libbundlewrapper2.so $INSTALLER$SFX64/ibbundlewrapper.so
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
  #cp -f $SAU/files/fmas_eq.dat $INSTALLER$ETC/fmas_eq.dat
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

ui_print "   Patching audio_effects configs"
for OFILE in ${CFGS}; do
  FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch_nb $ORIGDIR$OFILE $FILE 0644 false
  case $FILE in
    *.conf) if $ASP; then
              sed -i "/audiosphere {/,/} /d" $FILE
              sed -i "s/^effects {/effects {\n  audiosphere { #$MODID\n    library audiosphere\n    uuid 184e62ab-2d19-4364-9d1b-c0a40733866c\n  } #$MODID/g" $FILE
              sed -i "s/^libraries {/libraries {\n  audiosphere { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libasphere.so\n  } #$MODID/g" $FILE
            fi
            if $SHB; then
              sed -i "/libshoebox {/,/}/d" $FILE
              sed -i "s/^effects {/effects {\n  shoebox { #$MODID\n    library shoebox\n    uuid 1eab784c-1a36-4b2a-b7fc-e34c44cab89e\n  } #$MODID/g" $FILE
              sed -i "s/^libraries {/libraries {\n  shoebox { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libshoebox.so\n  } #$MODID/g" $FILE
            fi
            if $FMAS; then
              [ "$QCP" -a "$FILE" == "$SYS/etc/audio_effects.conf" ] && continue
              backup_and_patch "virtualizer" "library bundle" "library fmas" "uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $FILE
              backup_and_patch "downmix" "library downmix" "library fmas" "uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $FILE
              sed -i "s/^libraries {/libraries {\n  fmas { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libfmas.so\n  } #$MODID/g" $FILE
            fi;;
    *.xml) if $ASP && [ ! "$(grep "audiosphere" $FILE)" ]; then
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
             sed -i "/<effects>/ a\        <effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $FILE
             sed -i "/<libraries>/ a\        <library name=\"fmas\" path=\"libfmas.so\"\/><!--$MODID-->" $FILE
           fi
  esac
done

##                        MIXER EDITS BY ULTRAM8                             ##
##                  SPECIAL DEVICE'S EDITS BY SKREM339                       ##
## ! MAKE SURE YOU CREDIT PEOPLE MENTIONED HERE WHEN USING THESE XML EDITS ! ##
ui_print "   Patching mixer"
if [ "$QCP" ]; then
  for OMIX in ${MIXS}; do
    MIX="$UNITY$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch_nb $ORIGDIR$OMIX $MIX 0644 false
    ## MAIN DAC patches
    # BETA FEATURES
    if [ "$BIT" ]; then
      patch_mixer_toplevel "SLIM_0_RX Format" "$BIT" $MIX
      patch_mixer_toplevel "SLIM_5_RX Format" "$BIT" $MIX
      [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT" $MIX
      patch_mixer_toplevel "USB_AUDIO_RX Format" "$BIT" $MIX
      patch_mixer_toplevel "HDMI_RX Bit Format" "$BIT" $MIX
    fi
    if [ "$IMPEDANCE" ]; then
      patch_mixer_toplevel "HPHR Impedance" "$IMPEDANCE" $MIX
      patch_mixer_toplevel "HPHL Impedance" "$IMPEDANCE" $MIX
    fi
    if [ "$RESAMPLE" ]; then
      patch_mixer_toplevel "SLIM_0_RX SampleRate" "$RESAMPLE" $MIX
      patch_mixer_toplevel "SLIM_5_RX SampleRate" "$RESAMPLE" $MIX
      [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE" $MIX
      patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE" $MIX
      patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE" $MIX
    fi
    if [ "$BTRESAMPLE" ]; then
      patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE" $MIX
    fi
    if [ "$AX7" ]; then
      patch_mixer_toplevel "Smart PA Init Switch" "On" $MIX
      patch_mixer_toplevel "AK4490 Super Slow Roll-off Filter" "On" $MIX
      patch_mixer_toplevel "AKM HIFI Switch Sel" "On" $MIX
      #patch_mixer_toplevel "AK4490 Sound control" "" $MIX
    fi
    if [ "$LX3" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $MIX
      patch_mixer_toplevel "ESS_HEADPHONE Off" "On" $MIX
    fi
    if [ "$X9" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $MIX
      patch_mixer_toplevel "Es9018 Hifi Switch" "1" $MIX
    fi
    if [ "$Z9" ] || [ "$Z9M" ]; then
      patch_mixer_toplevel "HP Out Volume" "22" $MIX
      patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $MIX
      patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $MIX
    fi
    if [ "$Z11" ]; then
      patch_mixer_toplevel "AK4376 DAC Digital Filter Mode" "Slow Roll-Off" $MIX
      patch_mixer_toplevel "AK4376 HPL Power-down Resistor" "Hi-Z" $MIX
      patch_mixer_toplevel "AK4376 HPR Power-down Resistor" "Hi-Z" $MIX
      patch_mixer_toplevel "AK4376 HP-Amp Analog Volume" "15" $MIX
    fi
    if [ "$V20" ] || [ "$V30" ] || [ "$G6" ]; then
      patch_mixer_toplevel "Es9018 AVC Volume" "14" $MIX
      patch_mixer_toplevel "Es9018 HEADSET TYPE" "1" $MIX
      patch_mixer_toplevel "Es9018 State" "Hifi" $MIX
      # patch_mixer_toplevel "Es9018 Master Volume" "1" $MIX
      patch_mixer_toplevel "HIFI Custom Filter" "6" $MIX
      if [ "$V30" ]; then
        patch_mixer_toplevel "Es9218 Bypass" "0" $MIX
      fi
    fi
    if [ -f "$AMPA" ]; then
      patch_mixer_toplevel "HTC_AS20_VOL Index" "Twelve" $MIX
    fi
    if [ "$QC8996" ] || [ "$QC8998" ]; then
      patch_mixer_toplevel "VBoost Ctrl" "AlwaysOn" $MIX
      patch_mixer_toplevel "VBoost Volt" "8.6V" $MIX
    fi
    ### MAIN DAC patches  ##
    # Custom Stereo
    patch_mixer_toplevel "Set Custom Stereo OnOff" "Off" $MIX
    # patch_mixer_toplevel "Set Custom Stereo" "1" $MIX
    # Custom Stereo ##
    # APTX Dec License
    if $APTX; then
      patch_mixer_toplevel "APTX Dec License" "21" $MIX
    fi
    # HW  DTS HPX edits
    patch_mixer_toplevel "Set HPX OnOff" "1" $MIX
    patch_mixer_toplevel "Set HPX ActiveBe" "1" $MIX
    patch_mixer_toplevel "PCM_Dev Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 9 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 13 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 17 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 21 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 24 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 15 Topology" "DTS" $MIX
    patch_mixer_toplevel "PCM_Dev 33 Topology" "DTS" $MIX
    if [ ! "$M10" ]; then
      patch_mixer_toplevel "DS2 OnOff" "Off" $MIX
    fi
    # APTX Dec License ##
    # Codec Bandwith Expansion
    patch_mixer_toplevel "Codec Wideband" "1" $MIX
    # Codec Bandwith Expansion ##
    # HPH Type
    patch_mixer_toplevel "HPH Type" "1" $MIX
    patch_mixer_toplevel "RX HPH Mode" "CLS_H_HIFI" $MIX
    # HPH Type ##
    # Audiosphere Enable
    if $ASP; then
      patch_mixer_toplevel "Audiosphere Enable" "On" $MIX
      patch_mixer_toplevel "MSM ASphere Set Param" "1" $MIX
    fi
    # Audiosphere Enable ##
    # TFA amp patch
    if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
      patch_mixer_toplevel "TFA9895 Profile" "hq" $MIX
      patch_mixer_toplevel "TFA9895 Playback Volume" "255" $MIX
      patch_mixer_toplevel "SmartPA Switch" "1" $MIX
    fi
    # TFA amp patch   ##
    ###  v v v  TAS amp Patch  v v v
    patch_mixer_toplevel "TAS2552 Volume" "125" $MIX "updateonly"
    if [ -f "$AMPA" ]; then
      patch_mixer_toplevel "TAS2557 Volume" "30" $MIX
    fi
    # HW  SRS Trumedia edits (consider non-working for all QC, may break HDMI on some rare devices, needs custom kernel support)
    patch_mixer_toplevel "SRS Trumedia" "1" $MIX
    patch_mixer_toplevel "SRS Trumedia HDMI" "1" $MIX
    patch_mixer_toplevel "SRS Trumedia I2S" "1" $MIX
    patch_mixer_toplevel "SRS Trumedia MI2S" "1" $MIX
    # HW  SRS Trumedia edits  ##
    # if [ "$QC8226" ]; then
      # patch_mixer_toplevel "HIFI2 RX Volume" "84" $MIX
      # patch_mixer_toplevel "HIFI3 RX Volume" "84" $MIX
      # patch_mixer_toplevel "HIFI0 RX Volume" "84" $MIX
      # patch_mixer_toplevel "HIFI5 RX Volume" "84" $MIX
    # fi
    # 8226 patch  ##
    # 8996
    # if [ "$QC8996" ]; then
    patch_mixer_toplevel "HiFi Function" "On" $MIX
    # fi
    # 8996  ##
    if $COMP; then
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/p" $MIX
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ { s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/><!--$MODID-->/; n; s/\( *\)\(.*\)/\1<!--$MODID\2$MODID-->/}" $MIX
    fi
  done
fi
ui_print "   ! Mixer edits & patches by Ultram8 !"

if $MAGISK && ! $SYSOVERRIDE; then
  # Add aml script variables
  add_var() {
    if [ "$(eval echo \$$1)" ]; then
      sed -i "s|^$1=$|$1=$(eval echo \$$1)|" $INSTALLER/common/aml.sh
    else
      sed -i "/^$1=$/d" $INSTALLER/common/aml.sh
    fi
  }
  add_var "QCP"
  add_var "FMAS"
  add_var "SHB"
  add_var "ASP"
  add_var "TMSM"
  add_var "QCNEW"
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
