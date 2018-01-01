TIMEOFEXEC=3

## Install logic by UltraM8 @XDA DO NOT MODIFY

if [ "$QCP" ]; then
  unity_prop_copy $INSTALLER/common/propsqcp.prop
  $CP_PRFX $VALAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX/libqcbassboost.so
  $CP_PRFX $VALAR/lib/soundfx/libqcreverb.so $UNITY$VSFX/libqcreverb.so
  $CP_PRFX $VALAR/lib/soundfx/libqcvirt.so $UNITY$VSFX/libqcvirt.so
  $CP_PRFX $MORG/modules/mpq-adapter.ko $UNITY$LIB/modules/mpq-adapter.ko
  $CP_PRFX $MORG/modules/mpq-dmx-hw-plugin.ko $UNITY$LIB/modules/mpq-dmx-hw-plugin.ko
  if [ ! -f "$ADSP/libc++.so.1" ] && [ ! -f "$ADSP/libc++abi.so.1" ]; then
  $CP_PRFX $MORG/hammer/libc++.so.1 $UNITY$ADSP/libc++.so.1
  $CP_PRFX $MORG/hammer/libc++abi.so.1 $UNITY$ADSP/libc++abi.so.1  
  fi
  if [ -d "$VLIB64" ]; then
    $CP_PRFX $MAIAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX64/libqcbassboost.so
    $CP_PRFX $MAIAR/lib/soundfx/libqcreverb.so $UNITY$VSFX64/libqcreverb.so
    $CP_PRFX $MAIAR/lib/soundfx/libqcvirt.so $UNITY$VSFX64/libqcvirt.so
  fi 
  if [ -f "$SYS/etc/htc_audio_effects.conf" ]; then
    unity_prop_copy $INSTALLER/common/propshtc.prop
    $CP_PRFX $SAU/files/default_vol_level.conf $UNITY$ETC/default_vol_level.conf
    $CP_PRFX $SAU/files/TFA_default_vol_level.conf $UNITY$ETC/TFA_default_vol_level.conf
    $CP_PRFX $SAU/files/NOTFA_default_vol_level.conf $UNITY$ETC/NOTFA_default_vol_level.conf
    $CP_PRFX $SAU/files/libhtcacoustic.so $UNITY$LIB/libhtcacoustic.so 
  fi  
  if [ "$M10" ] && [ "$BOLT" ]; then
    $CP_PRFX $SAU/lib/libaudio-ftm.so $UNITY$LIB/libaudio-ftm.so 
    $CP_PRFX $SAU/lib/libaudio-ftm2.so $UNITY$LIB64/libaudio-ftm.so    
  fi
  if [ "$M9" ]; then
    unity_prop_copy $INSTALLER/common/propsresample.prop
    $CP_PRFX $SAU/files/tfa/playback.drc $UNITY$ETC/tfa/playback.drc
    $CP_PRFX $SAU/files/tfa/playback.eq $UNITY$ETC/tfa/playback.eq
    $CP_PRFX $SAU/files/tfa/playback.preset $UNITY$ETC/tfa/playback.preset
    $CP_PRFX $SAU/files/tfa/playback_l.drc $UNITY$ETC/tfa/playback_l.drc
    $CP_PRFX $SAU/files/tfa/playback_l.eq $UNITY$ETC/tfa/playback_l.eq
    $CP_PRFX $SAU/files/tfa/playback_l.preset $UNITY$ETC/tfa/playback_l.preset
    $CP_PRFX $SAU/files/tfa/tfa9895.patch $UNITY$ETC/tfa/tfa9895.patch
    $CP_PRFX $SAU/files/tfa/tfa9895MFG.patch $UNITY$ETC/tfa/tfa9895MFG.patch
    $CP_PRFX $SAU/files/libtfa9895.so $UNITY$LIB/libtfa9895.so
    $CP_PRFX $SAU/files/libtfa98952.so $UNITY$LIB64/libtfa9895.so
    if [ $API -ge 24 ]; then
      $CP_PRFX $VALAR/libqcompostprocbundle.so $UNITY$SFX/libqcompostprocbundle.so
      $CP_PRFX $MAIAR/libqcompostprocbundle.so $UNITY$SFX64/libqcompostprocbundle.so
    fi
  fi  
  if [ "$M8" ]; then
  $CP_PRFX $SAU/files/audio/tfa9887_feature.config $UNITY$ETC/audio/tfa9887_feature.config
  $CP_PRFX $SAU/files/libtfa9887.so $UNITY$LIB/libtfa9887.so
  fi  
  if [ -f "$AMPA" ]; then
    unity_prop_copy $INSTALLER/common/propsresample.prop
    $CP_PRFX $SAU/files/TAS2557_A.ftcfg $UNITY$ETC/TAS2557_A.ftcfg
    $CP_PRFX $SAU/files/TAS2557_B.ftcfg $UNITY$ETC/TAS2557_B.ftcfg
    $CP_PRFX $SAU/files/fw/tas2557s_uCDSP_PG21.bin $UNITY$ETC/firmware/tas2557s_uCDSP_PG21.bin
	if [ -f "U11P" ]; then
    $CP_PRFX $SAU/files/fw/tas2557s_uCDSP_24bit.bin $UNITY$VETC/firmware/tas2557s_uCDSP_24bit.bin	
    $CP_PRFX $SAU/files/fw/tas2557s_uCDSP.bin $UNITY$VETC/firmware/tas2557s_uCDSP.bin
	fi
    $CP_PRFX $SAU/files/bin/ti_audio_s $UNITY$BIN/ti_audio_s
  fi
  if [ "$OP5" ]; then
#    $CP_PRFX $SAU/files/fw/tfa9890.cnt $UNITY$ETC/firmware/tfa9890.cnt
#	   $CP_PRFX $SAU/files/fw/tfa98xx.cnt $UNITY$ETC/firmware/tfa98xx.cnt
    $CP_PRFX $SAU/files/settings/90_Sambo.parms $UNITY$ETC/settings/90_Sambo.parms
    $CP_PRFX $SAU/files/settings/coldboot.patch $UNITY$ETC/settings/coldboot.patch
    $CP_PRFX $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq $UNITY$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.eq
    $CP_PRFX $SAU/files/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset $UNITY$ETC/settings/HQ_knowles_bottom0417_0_0_SPK_Knowles_bottom0417.preset	
    $CP_PRFX $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq $UNITY$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.eq
    $CP_PRFX $SAU/files/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset $UNITY$ETC/settings/Speech_BYD_DOWN_0_0_HQ_BYD_S4_1222.preset	
    $CP_PRFX $SAU/files/settings/SPK_Knowles_bottom0417.speaker $UNITY$ETC/settings/SPK_Knowles_bottom0417.speaker
    $CP_PRFX $SAU/files/settings/TFA9890_N1B12_N1C3_v3.config $UNITY$ETC/settings/TFA9890_N1B12_N1C3_v3.config
    $CP_PRFX $SAU/files/settings/TFA9890_N1C3_2_1_1.patch $UNITY$ETC/settings/TFA9890_N1C3_2_1_1.patch	
    $CP_PRFX $SAU/files/libtfa9890.so $UNITY$LIB/libtfa9890.so	
    $CP_PRFX $SAU/files/libtfa98902.so $UNITY$LIB64/libtfa9890.so
  fi  
  if [ ! -f "$HWDTS" ]; then
    $CP_PRFX $MORG/hammer/DTS_HPX_MODULE.so.1 $UNITY$ADSP/DTS_HPX_MODULE.so.1
    $CP_PRFX $MORG/hammer/SrsTruMediaModule.so.1 $UNITY$ADSP/SrsTruMediaModule.so.1
    $CP_PRFX $SAU/data/effect /data/misc/dts/effect 
    $CP_PRFX $SAU/data/effect9 /data/misc/dts/effect9
    $CP_PRFX $SAU/data/effect13 /data/misc/dts/effect13 	
    $CP_PRFX $SAU/data/effect17 /data/misc/dts/effect17   
    $CP_PRFX $SAU/data/effect21 /data/misc/dts/effect21
    $CP_PRFX $SAU/data/effect24 /data/misc/dts/effect24 	
    $CP_PRFX $SAU/data/effect25 /data/misc/dts/effect25 
    $CP_PRFX $SAU/data/effect33 /data/misc/dts/effect33  
  fi
  if $ASP; then
    sed -i -r "s/audio.pp.asphere.enabled(.?)false/audio.pp.asphere.enabled\1true/" $PROPFILE
	if [ $API -ge 26 ]; then  
    echo "vendor.audio.pp.asphere.enabled=1" >> $PROPFILE
	fi
    $CP_PRFX $SAU/audiosphere/audiosphere.jar $UNITY$SYS/framework/audiosphere.jar
    $CP_PRFX $SAU/audiosphere/audiosphere.xml $UNITY$SYS/etc/permissions/audiosphere.xml
    $CP_PRFX $SAU/audiosphere/libasphere.so $UNITY$SFX/libasphere.so
    $CP_PRFX $SAU/audiosphere/libasphere2.so $UNITY$SFX64/libasphere.so
    $CP_PRFX $MORG/hammer/AudioSphereModule.so.1 $UNITY$ADSP/AudioSphereModule.so.1  
    if [ ! -f "$VLIB/libqtigef.so" ]; then
      $CP_PRFX $SAU/lib/libqtigef.so $UNITY$VLIB/libqtigef.so
      $CP_PRFX $SAU/lib/libqtigef2.so $UNITY$VLIB64/libqtigef.so 
    fi   
  fi
  if $SHB; then
    $CP_PRFX $SAU/lib/libshoebox.so $UNITY$SFX/libshoebox.so
    $CP_PRFX $SAU/lib/libshoebox2.so $UNITY$SFX64/libshoebox.so
    if [ ! -f "$VLIB/libqtigef.so" ]; then
      $CP_PRFX $SAU/lib/libqtigef.so $UNITY$VLIB/libqtigef.so
      $CP_PRFX $SAU/lib/libqtigef2.so $UNITY$VLIB64/libqtigef.so 
    fi  
  fi  
  if $HWD; then
    unity_prop_copy $INSTALLER/common/propsdolby.prop 
    $CP_PRFX $MORG/hammer/DolbyMobileModule.so.1 $UNITY$ADSP/DolbyMobileModule.so.1
    $CP_PRFX $MORG/hammer/DolbySurroundModule.so.1 $UNITY$ADSP/DolbySurroundModule.so.1
    if [ ! -f "$VLIB/libhwdaphal.so" ]; then
	  $CP_PRFX $SAU/lib/libhwdaphal.so $UNITY$VLIB/libhwdaphal.so
    fi	
  fi  
  if $APTX; then
    unity_prop_copy $INSTALLER/common/propsaptx.prop
    if [ ! -f "$ACDB/adsp_avs_config.acdb" ]; then
      $CP_PRFX $MORG/hammer/adsp_avs_config.acdb $UNITY$ACDB/adsp_avs_config.acdb
    fi
    $CP_PRFX $MORG/hammer/capi_v2_aptX_Classic.so $UNITY$ADSP/capi_v2_aptX_Classic.so
    $CP_PRFX $MORG/hammer/capi_v2_aptX_HD.so $UNITY$ADSP/capi_v2_aptX_HD.so   
    if [ $API -ge 25 ]; then  
      if [ -f "$VLIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" ] || [ -f "$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so" ]; then
        $CP_PRFX $SAU/lib/libaptX-1.0.0-rel-Android21-ARMv7A.so $UNITY$LIB/libaptX-1.0.0-rel-Android21-ARMv7A.so
      fi
      if [ -f "$VLIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" ] || [ -f "$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so" ]; then
        $CP_PRFX $SAU/lib/libaptXHD-1.0.0-rel-Android21-ARMv7A.so $UNITY$LIB/libaptXHD-1.0.0-rel-Android21-ARMv7A.so
      fi 
      if [ -f "$VLIB/libaptXScheduler.so" ] || [ -f "$LIB/libaptXScheduler.so" ]; then
        $CP_PRFX $SAU/lib/libaptXScheduler.so $UNITY$LIB/libaptXScheduler.so
      fi
      if [ -f "$VLIB/libbt-aptX-ARM-4.2.2.so" ] || [ -f "$LIB/libbt-aptX-ARM-4.2.2.so" ]; then
        $CP_PRFX $SAU/lib/libbt-aptX-ARM-4.2.2.so $UNITY$LIB/libbt-aptX-ARM-4.2.2.so
      fi
      if [ -f "$VLIB/libbt-codec_aptx.so" ] || [ -f "$LIB/libbt-codec_aptx.so" ]; then
        $CP_PRFX $SAU/lib/libbt-codec_aptx.so $UNITY$LIB/libbt-codec_aptx.so
      fi
      if [ -f "$VLIB/libbt-codec_aptxhd.so" ] || [ -f "$LIB/libbt-codec_aptxhd.so" ]; then
        $CP_PRFX $SAU/lib/libbt-codec_aptxhd.so $UNITY$LIB/libbt-codec_aptxhd.so
      fi	  
    fi
  fi  
fi

if [ "$MTK" ]; then
  unity_prop_copy $INSTALLER/common/propsmtk.prop
fi

if [ "$EXY" ]; then
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $PROPFILE
  $CP_PRFX $SAU/lib/libdownmix2.so $UNITY$SFX/libdownmix.so
  $CP_PRFX $SAU/lib/libreverbwrapper2.so $UNITY$SFX/libreverbwrapper.so   
fi

if [ "$MIUI" ]; then
  sed -i 's/persist.audio.hifi(.?)true/'d $PROPFILE  
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $PROPFILE
  sed -i 's/persist.audio.hifi.volume(.?)1/'d $PROPFILE     
fi

if $FMAS; then
  unity_prop_copy $INSTALLER/common/propfmas.prop
  $CP_PRFX $SAU/lib/libfmas.so $UNITY$SFX/libfmas.so
fi

if [ "$AX7" ] && [ "$V20" ] && [ "$G6" ] && [ "$Z9" ] && [ "$Z9M" ] && [ "$Z11" ] && [ "$LX3" ] && [ "$X9" ]; then
  sed -i -r "s/persist.audio.hifi.int_codec(.?)true/persist.audio.hifi.int_codec\1false/" $PROPFILE
  sed -i -r "s/audio.nat.codec.enabled(.?)1/audio.nat.codec.enabled\10/" $PROPFILE  
fi
