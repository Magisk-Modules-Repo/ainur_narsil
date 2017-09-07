# v DO NOT MODIFY v
# See instructions file for predefined variables
# User defined custom rules
# Can have multiple ones based on when you want them to be run
# You can create copies of this file and name is the same as this but with the next number after it (ex: unity-customrules2.sh)
# See instructions for TIMEOFEXEC values, do not remove it
# Do not remove last 3 lines (the if statement). Add any files added in custom rules before the sed statement and uncomment the whole thing (ex: echo "$UNITY$SYS/lib/soundfx/libv4a_fx_ics.so" >> $INFO)
# ^ DO NOT MODIFY ^
TIMEOFEXEC=3
case "$ABILONG" in
  arm64*) ;;
  arm*) $MAGISK && $CP_PRFX $SAU/sauron_alsa $UNITY/sauron_alsa$CP_SFFX || { sys_cp_ch $SAU/sauron_alsa $SH/sauron_alsa$EXT 0700; echo "$SH/sauron_alsa$EXT" >> $INFO; } ;;
esac

if [ "$QCP" ]; then
  unity_prop_copy $INSTALLER/common/propsqcp.prop
  $CP_PRFX $VALAR/libbundlewrapper.so $UNITY$SFX/libbundlewrapper.so$CP_SFFX
  $CP_PRFX $VALAR/libreverbwrapper.so $UNITY$SFX/libreverbwrapper.so$CP_SFFX
  $CP_PRFX $VALAR/libeffectproxy.so $UNITY$SFX/libeffectproxy.so$CP_SFFX
  $CP_PRFX $VALAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX/libqcbassboost.so$CP_SFFX
  $CP_PRFX $VALAR/lib/soundfx/libqcreverb.so $UNITY$VSFX/libqcreverb.so$CP_SFFX
  $CP_PRFX $VALAR/lib/soundfx/libqcvirt.so $UNITY$VSFX/libqcvirt.so$CP_SFFX
  if [ -d "$VLIB64" ]; then
	$CP_PRFX $MAIAR/lib/soundfx/libqcbassboost.so $UNITY$VSFX64/libqcbassboost.so$CP_SFFX
	$CP_PRFX $MAIAR/lib/soundfx/libqcreverb.so $UNITY$VSFX64/libqcreverb.so$CP_SFFX
	$CP_PRFX $MAIAR/lib/soundfx/libqcvirt.so $UNITY$VSFX64/libqcvirt.so$CP_SFFX
  fi
  if [ -d "$ACDBDATA" ]; then
	  $CP_PRFX $SAU/acdb/Codec_cal.acdb $UNITY$ETC/acdbdata/Codec_cal.acdb$CP_SFFX
  fi
  if [ "$M9" ]; then
	  # $CP_PRFX $SAU/htc/firmware/ $UNITY$ETC/firmware/$CP_SFFX
	  $CP_PRFX $SAU/htc/libaudioflinger.so $UNITY$LIB/libaudioflinger.so$CP_SFFX
	  $CP_PRFX $SAU/htc/libaudiopolicyenginedefault.so $UNITY$LIB/libaudiopolicyenginedefault.so$CP_SFFX
	  $CP_PRFX $SAU/htc/libaudiopolicymanager.so $UNITY$LIB/libaudiopolicymanager.so$CP_SFFX
	  $CP_PRFX $SAU/htc/libaudiopolicymanagerdefault.so $UNITY$LIB/libaudiopolicymanagerdefault.so$CP_SFFX
	  $CP_PRFX $SAU/htc/libaudiopolicyservice.so $UNITY$LIB/libaudiopolicyservice.so$CP_SFFX
	  if [ -d "$LIB64" ]; then
		$CP_PRFX $SAU/htc/libaudioflinger2.so $UNITY$LIB64/libaudioflinger.so$CP_SFFX
		$CP_PRFX $SAU/htc/libaudioresampler.so $UNITY$LIB64/libaudioresampler.so$CP_SFFX
	  fi
	  if [ "$API" -ge "24" ]; then
		$CP_PRFX $VALAR/libqcompostprocbundle.so $UNITY$SFX/libqcompostprocbundle.so$CP_SFFX
		if [ -d "$SFX64" ]; then
		  $CP_PRFX $MAIAR/libqcompostprocbundle.so $UNITY$SFX64/libqcompostprocbundle.so$CP_SFFX
		fi
	  fi
  fi  
  if [ -e "$HTC_CONFIG_FILE" ]; then
	unity_prop_copy $INSTALLER/common/propshtc.prop
	$CP_PRFX $SAU/htc/default_vol_level.conf $UNITY$ETC/default_vol_level.conf$CP_SFFX
	$CP_PRFX $SAU/htc/TFA_default_vol_level.conf $UNITY$ETC/TFA_default_vol_level.conf$CP_SFFX
	$CP_PRFX $SAU/htc/NOTFA_default_vol_level.conf $UNITY$ETC/NOTFA_default_vol_level.conf$CP_SFFX
	$CP_PRFX $SAU/htc/libhtc_acoustic.so $UNITY$LIB/libhtc_acoustic.so$CP_SFFX
	$CP_PRFX $SAU/acdb/Codec_cal.acdb $UNITY$ETC/Codec_cal.acdb$CP_SFFX	
  fi
  if [ -f "$AMPA" ]; then
	$CP_PRFX $SAU/htc/TAS2557_A.ftcfg $UNITY$ETC/TAS2557_A.ftcfg$CP_SFFX 
    $CP_PRFX $SAU/htc/TAS2557_B.ftcfg $UNITY$ETC/TAS2557_B.ftcfg$CP_SFFX
  fi
  $CP_PRFX $MORG/libadsp_default_listener.so $UNITY$VLIB/libadsp_default_listener.so$CP_SFFX
  $CP_PRFX $MORG/libadsp_hvx_callback_skel.so $UNITY$VLIB/libadsp_hvx_callback_skel.so$CP_SFFX
  $CP_PRFX $MORG/libadsprpc.so $UNITY$VLIB/libadsprpc.so$CP_SFFX
  $CP_PRFX $MORG/libadsp_hvx_stub.so $UNITY$VLIB/libadsp_hvx_stub.so$CP_SFFX
  $CP_PRFX $MORG/modules/mpq-adapter.ko $UNITY$LIB/modules/mpq-adapter.ko$CP_SFFX
  $CP_PRFX $MORG/modules/mpq-dmx-hw-plugin.ko $UNITY$LIB/modules/mpq-dmx-hw-plugin.ko$CP_SFFX
  $CP_PRFX $MORG/hammer/DTS_HPX_MODULE.so.1 $UNITY$ADSP/DTS_HPX_MODULE.so.1$CP_SFFX
  $CP_PRFX $MORG/hammer/SrsTruMediaModule.so.1 $UNITY$ADSP/SrsTruMediaModule.so.1$CP_SFFX
  ## unstable #
  $CP_PRFX $MORG/hammer/AudioSphereModule.so.1 $UNITY$ADSP/AudioSphereModule.so.1$CP_SFFX
  $CP_PRFX $MORG/hammer/CFCMModule.so.1 $UNITY$ADSP/CFCMModule.so.1$CP_SFFX	
  $CP_PRFX $MORG/hammer/capi_v2_aptX_Classic.so $UNITY$ADSP/capi_v2_aptX_Classic.so$CP_SFFX
  $CP_PRFX $MORG/hammer/capi_v2_aptX_HD.so $UNITY$ADSP/capi_v2_aptX_HD.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libadsp_fd_skel.so $UNITY$ADSP/libadsp_fd_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libadsp_hvx_add_constant.so $UNITY$ADSP/libadsp_hvx_add_constant.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libadsp_hvx_skel.so $UNITY$ADSP/libadsp_hvx_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libapps_mem_heap.so $UNITY$ADSP/libapps_mem_heap.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libAudienceAZA.so $UNITY$ADSP/libAudienceAZA.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libdspCV_skel.so $UNITY$ADSP/libdspCV_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libfastcvadsp.so $UNITY$ADSP/libfastcvadsp.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libfastcvadsp_skel.so $UNITY$ADSP/libfastcvadsp_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libsysmon_skel.so $UNITY$ADSP/libsysmon_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/libsysmondomain_skel.so $UNITY$ADSP/libsysmondomain_skel.so$CP_SFFX
  $CP_PRFX $MORG/hammer/fastrpc_shell_0 $UNITY$ADSP/fastrpc_shell_0$CP_SFFX
  # unstable ##
  $CP_PRFX $MORG/adsprpcd $UNITY$BIN/adsprpcd$CP_SFFX
  if [ -d "$VLIB64" ]; then
	$CP_PRFX $MORG/libadsp_default_listener2.so $UNITY$VLIB64/libadsp_default_listener.so$CP_SFFX
	$CP_PRFX $MORG/libadsprpc2.so $UNITY$VLIB64/libadsprpc.so$CP_SFFX
  fi
  if [ "$MAGISK" == false ]; then
	set_perm $UNITY$BIN/adsprpcd 0 2000 0755
  fi
fi

if [ "$MTK" ]; then
  unity_prop_copy $INSTALLER/common/propsmtk.prop
fi

if [ "$MIUI" ]; then
  sed -i -r "s/persist.audio.hifi(.?)true/persist.audio.hifi\1false/" $AMLPROP
  sed -i -r "s/alsa.mixer.playback.master(.?)DAC1/alsa.mixer.playback.master\1Speaker/" $AMLPROP
fi

case "$ABILONG" in
arm64*) ;;
arm*) $CP_PRFX $INSTALLER/system/bin/alsa_ctl $UNITY$BIN/alsa_ctl$CP_SFFX
	  if [ "$MAGISK" == false ]; then
		set_perm $UNITY$BIN/alsa_ctl 0 0 077
	  fi ;;
esac

$CP_PRFX $VALAR/libaudiopreprocessing.so $UNITY$SFX/libaudiopreprocessing.so$CP_SFFX
$CP_PRFX $VALAR/libbundlewrapper.so $UNITY$SFX/libbundlewrapper.so$CP_SFFX
$CP_PRFX $VALAR/libreverbwrapper.so $UNITY$SFX/libreverbwrapper.so$CP_SFFX
$CP_PRFX $VALAR/libeffectproxy.so $UNITY$SFX/libeffectproxy.so$CP_SFFX
if [ -d "$LIB64" ]; then
  $CP_PRFX $MAIAR/libreverbwrapper.so $UNITY$SFX64/libreverbwrapper.so$CP_SFFX
  $CP_PRFX $MAIAR/libbundlewrapper.so $UNITY$SFX64/libbundlewrapper.so$CP_SFFX
fi

if [ "$XML" == true ]; then
  TXMLINSTALL=true
  $CP_PRFX $XML_PRFX $UNITY$XBIN/xmlstarlet$CP_SFFX
  if [ "$MAGISK" == false ]; then
	set_perm $UNITY$XBIN/xmlstarlet 0 0 0777
  fi
fi

if [ "$MAGISK" == false ]; then
	set_perm $UNITY$BIN/alsa_amixer 0 0 0777
    set_perm $UNITY$BIN/alsa_aplay 0 0 0777
    set_perm $UNITY$BIN/aplay 0 0 0777
    set_perm $UNITY$BIN/asound 0 0 0777
    sed -i 's/\/system\///g' $INFO
fi
