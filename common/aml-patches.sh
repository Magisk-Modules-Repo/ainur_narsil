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
  if $ASP; then
    sed -i "s/^effects {/effects {\n  audiosphere { #$MODID\n    library audiosphere\n    uuid 184e62ab-2d19-4364-9d1b-c0a40733866c\n  } #$MODID/g" $AMLPATH$FILE
    sed -i "s/^libraries {/libraries {\n  audiosphere { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libasphere.so\n  } #$MODID/g" $AMLPATH$FILE
  fi
  if $SHB; then
    sed -i "s/^effects {/effects {\n  shoebox { #$MODID\n    library shoebox\n    uuid 1eab784c-1a36-4b2a-b7fc-e34c44cab89e\n  } #$MODID/g" $AMLPATH$FILE
    sed -i "s/^libraries {/libraries {\n  shoebox { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libshoebox.so\n  } #$MODID/g" $AMLPATH$FILE
  fi  
  if $FMAS; then
    test "$QCP" -a "$FILE" == "$SYS/etc/audio_effects.conf" && continue
    backup_and_patch "virtualizer" "library bundle" "library fmas" "uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $AMLPATH$FILE
    backup_and_patch "downmix" "library downmix" "library fmas" "uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f" "uuid 36103c50-8514-11e2-9e96-0800200c9a66" $AMLPATH$FILE
    sed -i "s/^libraries {/libraries {\n  fmas { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libfmas.so\n  } #$MODID/g" $AMLPATH$FILE
  fi
done
for FILE in ${CFGSXML}; do
  if $ASP && [ ! "$(grep "audiosphere" $AMLPATH$FILE)" ]; then
    sed -i "/<libraries>/ a\        <library name=\"audiosphere\" path=\"libasphere.so\"\/><!--$MODID-->" $AMLPATH$FILE
    sed -i "/<effects>/ a\        <effect name=\"audiosphere\" library=\"audiosphere\" uuid=\"184e62ab-2d19-4364-9d1b-c0a40733866c\"\/><!--$MODID-->" $AMLPATH$FILE
  fi
  if $SHB && [ ! "$(grep "shoebox" $AMLPATH$FILE)" ]; then
    sed -i "/<libraries>/ a\        <library name=\"shoebox\" path=\"libshoebox.so\"\/><!--$MODID-->" $AMLPATH$FILE
    sed -i "/<effects>/ a\        <effect name=\"shoebox\" library=\"shoebox\" uuid=\"1eab784c-1a36-4b2a-b7fc-e34c44cab89e\"\/><!--$MODID-->" $AMLPATH$FILE
  fi  
  if $FMAS && [ ! "$(grep "fmas" $AMLPATH$FILE)" ]; then
    sed -ri "/<effect name="virtualizer"/ s/<!--(.*)$MODID-->/\1/g" $AMLPATH$FILE
    sed -ri "/<effect name="downmix" / s/<!--(.*)$MODID-->/\1/g" $AMLPATH$FILE
    sed -i "/<effects>/ a\        <effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $AMLPATH$FILE
    sed -i "/<effects>/ a\        <effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/><!--$MODID-->" $AMLPATH$FILE
    sed -i "/<libraries>/ a\        <library name=\"fmas\" path=\"libfmas.so\"\/><!--$MODID-->" $AMLPATH$FILE
  fi
done

##                    POLICY CONFIGS EDITS BY ULTRAM8                           ##
ui_print "   Patching audio policy"
if $AP && [ -f $SYS/etc/audio_policy.conf ]; then
  for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
    if [ "$AUD" != "compress_offload" ]; then
      backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_8_24_BIT" $AMLPATH$SYS/etc/audio_policy.conf
    fi
    if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
      backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $AMLPATH$SYS/etc/audio_policy.conf
    fi
    backup_and_patch "$AUD" "sampling_rates" "sampling_rates 8000|11025|16000|22050|32000|44100|48000|64000|88200|96000|176400|192000|352800|384000" $AMLPATH$SYS/etc/audio_policy.conf
  done
fi
if $OAP && [ -f $VEN/etc/audio_output_policy.conf ]; then
  for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
    if [[ "$AUD" != "compress_offload"* ]]; then
      backup_and_patch "$AUD" "formats" "formats AUDIO_FORMAT_PCM_16_BIT|AUDIO_FORMAT_PCM_24_BIT_PACKED|AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_32_BIT" $AMLPATH$VEN/etc/audio_output_policy.conf
    fi
    if [ "$AUD" == "direct" ]; then
      if [ "$(grep "compress_offload" $VEN/etc/audio_output_policy.conf)" ]; then
        backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING" $AMLPATH$VEN/etc/audio_output_policy.conf
      else
        backup_and_patch "$AUD" "flags" "flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM" $AMLPATH$VEN/etc/audio_output_policy.conf
      fi
    fi
    backup_and_patch "$AUD" "sampling_rates" "sampling_rates 44100|48000|96000|176400|192000|352800|384000" $AMLPATH$VEN/etc/audio_output_policy.conf
    test -z $BIT || backup_and_patch "$AUD" "bit_width" "bit_width $BIT" $AMLPATH$VEN/etc/audio_output_policy.conf
  done
fi
if $AP && [ -f $SYS/etc/audio_policy_configuration.xml ]; then
  ui_print "   Patching audio policy configuration"
  patch_audpol "primary output" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_16_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"48000,96000,192000\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  patch_audpol "raw" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  patch_audpol "deep_buffer" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"192000\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  patch_audpol "multichannel" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100|48000|64000|88200|96000|128000|176400|192000\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  # Use 'channel_masks' for conf files and 'channelMasks' for xml files
  patch_audpol "direct_pcm" "s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100|48000|64000|88200|96000|128000|176400|192000\"\1/; s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  patch_audpol "compress_offload" "s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1\"\1/" $AMLPATH$SYS/etc/audio_policy_configuration.xml
fi

##                        MIXER EDITS BY ULTRAM8                             ##
##                  SPECIAL DEVICE'S EDITS BY SKREM339                       ##
## ! MAKE SURE YOU CREDIT PEOPLE MENTIONED HERE WHEN USING THESE XML EDITS ! ##
ui_print "   Patching mixer"
if [ "$QCP" ]; then
  for MIX in ${MIXS}; do
    ## MAIN DAC patches
    # BETA FEATURES
    if [ "$BIT" ]; then
      patch_mixer_toplevel "SLIM_0_RX Format" "$BIT" $AMLPATH$MIX
      patch_mixer_toplevel "SLIM_5_RX Format" "$BIT" $AMLPATH$MIX
      test ! -z $QC8996 -o ! -z $QC8998 && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT" $AMLPATH$MIX
      patch_mixer_toplevel "USB_AUDIO_RX Format" "$BIT" $AMLPATH$MIX
      patch_mixer_toplevel "HDMI_RX Bit Format" "$BIT" $AMLPATH$MIX
#      patch_mixer_toplevel "QUAT_MI2S BitWidth" "$BIT" $AMLPATH$MIX	  
    fi
    if [ "$IMPEDANCE" ]; then
      patch_mixer_toplevel "HPHR Impedance" "$IMPEDANCE" $AMLPATH$MIX
      patch_mixer_toplevel "HPHL Impedance" "$IMPEDANCE" $AMLPATH$MIX
    fi
    if [ "$RESAMPLE" ]; then
      patch_mixer_toplevel "SLIM_0_RX SampleRate" "$RESAMPLE" $AMLPATH$MIX
      patch_mixer_toplevel "SLIM_5_RX SampleRate" "$RESAMPLE" $AMLPATH$MIX
      test ! -z $QC8996 -o ! -z $QC8998 && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE" $AMLPATH$MIX
      patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE" $AMLPATH$MIX
      patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE" $AMLPATH$MIX
#      patch_mixer_toplevel "QUAT_MI2S SampleRate" "$RESAMPLE" $AMLPATH$MIX	  
    fi
    if [ "$BTRESAMPLE" ]; then
      patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE" $AMLPATH$MIX
    fi
    if [ "$AX7" ]; then
      ###  v v v  Special Axon7 AKM patches by SKREM339  v v v
      patch_mixer_toplevel "AKM HIFI Switch Sel" "ak4490" $AMLPATH$MIX "updateonly"
      patch_mixer_toplevel "Smart PA Init Switch" "On" $AMLPATH$MIX 
      patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $AMLPATH$MIX 
      patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $AMLPATH$MIX 
    fi
    ###  ^ ^ ^  Special Axon7 AKM patches by SKREM339  ^ ^ ^  ###
    if [ "$LX3" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $AMLPATH$MIX
      patch_mixer_toplevel "ESS_HEADPHONE Off" "On" $AMLPATH$MIX
    fi
    if [ "$X9" ]; then
      patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $AMLPATH$MIX
      patch_mixer_toplevel "Es9018 Hifi Switch" "1" $AMLPATH$MIX
    fi   
    if [ "$Z9" ] && [ "$Z9M" ]; then
      patch_mixer_toplevel "HP Out Volume" "22" $AMLPATH$MIX
      patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $AMLPATH$MIX
      patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $AMLPATH$MIX
    fi
    if [ "$Z11" ]; then
      patch_mixer_toplevel "AK4376 DAC Digital Filter Mode" "Slow Roll-Off" $AMLPATH$MIX
      patch_mixer_toplevel "AK4376 HPL Power-down Resistor" "Hi-Z" $AMLPATH$MIX
      patch_mixer_toplevel "AK4376 HPR Power-down Resistor" "Hi-Z" $AMLPATH$MIX
      patch_mixer_toplevel "AK4376 HP-Amp Analog Volume" "15" $AMLPATH$MIX
    fi
    if [ "$V20" ] && [ "$V30" ] && [ "$G6" ]; then
      patch_mixer_toplevel "Es9018 AVC Volume" "14" $AMLPATH$MIX
      patch_mixer_toplevel "Es9018 HEADSET TYPE" "1" $AMLPATH$MIX
      patch_mixer_toplevel "Es9018 State" "Hifi" $AMLPATH$MIX
      # patch_mixer_toplevel "Es9018 Master Volume" "1" $AMLPATH$MIX
      patch_mixer_toplevel "HIFI Custom Filter" "6" $AMLPATH$MIX
    fi  
    if [ -f $AMPA ]; then 
      patch_mixer_toplevel "HTC_AS20_VOL Index" "Fourteen" $AMLPATH$MIX
    fi 
    if [ "$QC8996" ] && [ "$QC8998" ]; then 
      patch_mixer_toplevel "VBoost Ctrl" "AlwaysOn" $AMLPATH$MIX
      patch_mixer_toplevel "VBoost Volt" "8.6V" $AMLPATH$MIX
    fi
    # patch_mixer_toplevel "DAC1 Switch" "1" $AMLPATH$MIX
    # patch_mixer_toplevel "HPHR DAC Switch" "1" $AMLPATH$MIX
    # patch_mixer_toplevel "HPHL DAC Switch" "1" $AMLPATH$MIX
    
    ### MAIN DAC patches  ##
    # Custom Stereo
    patch_mixer_toplevel "Set Custom Stereo OnOff" "Off" $AMLPATH$MIX
    # patch_mixer_toplevel "Set Custom Stereo" "1" $AMLPATH$MIX
    # Custom Stereo ##
    # APTX Dec License
    if $APTX; then  
      patch_mixer_toplevel "APTX Dec License" "21" $AMLPATH$MIX
      # patch_mixer_toplevel "BT SOC status" "On" $AMLPATH$MIX
    fi
    # HW  DTS HPX edits
    patch_mixer_toplevel "Set HPX OnOff" "1" $AMLPATH$MIX
    patch_mixer_toplevel "Set HPX ActiveBe" "1" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 9 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 13 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 17 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 21 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 24 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 15 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "PCM_Dev 33 Topology" "DTS" $AMLPATH$MIX
    patch_mixer_toplevel "DS2 OnOff" "Off" $AMLPATH$MIX	
    # HW  DTS HPX edits  ##	
    if $HWD; then
      patch_mixer_toplevel "DS2 OnOff" "On" $AMLPATH$MIX
      patch_mixer_toplevel "Set HPX OnOff" "0" $AMLPATH$MIX
      patch_mixer_toplevel "Set HPX ActiveBe" "0" $AMLPATH$MIX	  
    fi  
    # APTX Dec License ##
    # Codec Bandwith Expansion
    patch_mixer_toplevel "Codec Wideband" "1" $AMLPATH$MIX
    # Codec Bandwith Expansion ##
    # HPH Type
    patch_mixer_toplevel "HPH Type" "1" $AMLPATH$MIX
    # HPH Type ##
    # Audiosphere Enable    
    if $ASP; then
      patch_mixer_toplevel "Audiosphere Enable" "On" $AMLPATH$MIX
      patch_mixer_toplevel "MSM ASphere Set Param" "1" $AMLPATH$MIX
    fi   
    # Audiosphere Enable ##
    # TFA amp patch
    if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
      patch_mixer_toplevel "TFA9895 Profile" "hq" $AMLPATH$MIX
      patch_mixer_toplevel "TFA9895 Playback Volume" "255" $AMLPATH$MIX
      patch_mixer_toplevel "SmartPA Switch" "1" $AMLPATH$MIX
    fi	 
    # TFA amp patch   ##
    ###  v v v  TAS amp Patch  v v v
    patch_mixer_toplevel "TAS2552 Volume" "125" $AMLPATH$MIX "updateonly"
    if [ -f "$AMPA" ]; then
      patch_mixer_toplevel "TAS2557 Volume" "30" $AMLPATH$MIX
    fi 
    # HW  SRS Trumedia edits (consider non-working for all QC, may break HDMI on some rare devices, needs custom kernel support)
    patch_mixer_toplevel "SRS Trumedia" "1" $AMLPATH$MIX
    patch_mixer_toplevel "SRS Trumedia HDMI" "1" $AMLPATH$MIX
    patch_mixer_toplevel "SRS Trumedia I2S" "1" $AMLPATH$MIX
    patch_mixer_toplevel "SRS Trumedia MI2S" "1" $AMLPATH$MIX       
    # HW  SRS Trumedia edits  ##
    # if [ "$QC8226" ]; then
      # patch_mixer_toplevel "HIFI2 RX Volume" "84" $AMLPATH$MIX 
      # patch_mixer_toplevel "HIFI3 RX Volume" "84" $AMLPATH$MIX
      # patch_mixer_toplevel "HIFI0 RX Volume" "84" $AMLPATH$MIX
      # patch_mixer_toplevel "HIFI5 RX Volume" "84" $AMLPATH$MIX
    # fi
    # 8226 patch  ##
    # 8996
    # if [ "$QC8996" ]; then
    patch_mixer_toplevel "HiFi Function" "On" $AMLPATH$MIX 
    # fi
    # 8996  ##
    if $COMP; then
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/p" $AMLPATH$MIX
      sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ { s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/><!--$MODID-->/; n; s/\( *\)\(.*\)/\1<!--$MODID\2$MODID-->/}" $AMLPATH$MIX
    fi 
  done
fi
ui_print "   ! Mixer edits & patches by Ultram8 !"
ui_print "   ! Axon7 patch by Skrem339 !"
