RUNONCE=true
patch_mixer_toplevel() {
  if [ "$(grep "<ctl name=\"$1\" value=\".*\" />" $MODPATH/$NAME)" ]; then
    sed -i "0,/<ctl name=\"$1\" value=\".*\" \/>/ s/\(<ctl name=\"$1\" value=\"\).*\(\" \/>\)/\1$2\2/" $MODPATH/$NAME
  elif [ -z $3 ]; then
    sed -i "/<mixer>/ a\    <ctl name=\"$1\" value=\"$2\" \/>" $MODPATH/$NAME
  fi
}
QCP=
FMAS=
SHB=
ASP=
TMSM=
QCNEW=
BIT=
IMPEDANCE=
RESAMPLE=
BTRESAMPLE=
AX7=
LX3=
X9=
Z9=
Z9M=
Z11=
V20=
V30=
G6=
QC8996=
QC8998=
APTX=
M8=
M9=
M10=
COMP=
for FILE in ${FILES}; do
  NAME=$(echo "$FILE" | sed "s|$MOD|system|")
  case $NAME in
    *audio_effects*) $ASP && patch_cfgs $MODPATH/$NAME audiosphere 184e62ab-2d19-4364-9d1b-c0a40733866c audiosphere $LIBDIR/libasphere.so
                     $SHB && patch_cfgs $MODPATH/$NAME shoebox 1eab784c-1a36-4b2a-b7fc-e34c44cab89e shoebox $LIBDIR/libshoebox.so
                     $FMAS || continue
                     case $NAME in
                       "system/etc"*) ;;
                       *) patch_cfgs -l $MODPATH/$NAME fmas $LIBDIR/libfmas.so
                          case $FILE in
                            *.conf) [ ! "$(sed -n "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ s/library bundle.*/library fmas/; s/uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b.*/uuid 36103c50-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME
                                    [ ! "$(sed -n "/^effects {/,/^}/ {/^  downmix {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  downmix {/,/^  }/ s/library downmix.*/library fmas/; s/uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f.*/uuid 36103c51-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME;;
                            *) [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"virtualizer\".*/>/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME
                               [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"downmix\".*/>/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME;;
                          esac;;
                     esac;;
    *audio_policy.conf) $AP || continue
                                    for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                                      if [ "$AUD" != "compress_offload" ]; then
                                        sed -i "/$AUD {/,/}/ s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g" $MODPATH/$NAME
                                      fi
                                      if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
                                        sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/$NAME
                                      fi
                                      sed -i "/$AUD {/,/}/ s/sampling_rates.*/sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/$NAME
                                    done;;
    *audio_output_policy.conf) $OAP || continue
                                           for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                             if [[ "$AUD" != "compress_offload"* ]]; then
                                               sed -i "/$AUD {/,/}/ s/formats.*/formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT/g" $MODPATH/$NAME
                                             fi
                                             if [ "$AUD" == "direct" ]; then
                                               if [ "$(grep "compress_offload" $NAME)" ]; then
                                                 sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g" $MODPATH/$NAME
                                               else
                                                 sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/$NAME
                                               fi
                                             fi
                                             sed -i "/$AUD {/,/}/ s/sampling_rates.*/sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/$NAME
                                             [ -z $BIT ] || sed -i "/$AUD {/,/}/ s/bit_width.*/bit_width $BIT/g" $MODPATH/$NAME
                                           done;;            
    *audio_policy_configuration.xml) $AP || continue
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"primary output\"/,/ ^*<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/}}" $MODPATH/$NAME
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"raw\"/,/<\/mixPort>/ s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/}" $MODPATH/$NAME
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"deep_buffer\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"192000\1/}}" $MODPATH/$NAME
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"multichannel\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/}}" $MODPATH/$NAME
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"direct_pcm\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/}}" $MODPATH/$NAME
                                                 sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"compress_offload\"/,/<\/mixPort>/ s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}" $MODPATH/$NAME;;
    *mixer_paths*.xml) if [ "$QCP" ]; then
                         if [ "$BIT" ]; then
                           patch_mixer_toplevel "SLIM_0_RX Format" "$BIT"
                           patch_mixer_toplevel "SLIM_5_RX Format" "$BIT"
                           [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT"
                           patch_mixer_toplevel "USB_AUDIO_RX Format" "$BIT"
                           patch_mixer_toplevel "HDMI_RX Bit Format" "$BIT" 
                         fi
                         if [ "$IMPEDANCE" ]; then
                           patch_mixer_toplevel "HPHR Impedance" "$IMPEDANCE"
                           patch_mixer_toplevel "HPHL Impedance" "$IMPEDANCE"
                         fi
                         if [ "$RESAMPLE" ]; then
                           patch_mixer_toplevel "SLIM_0_RX SampleRate" "$RESAMPLE"
                           patch_mixer_toplevel "SLIM_5_RX SampleRate" "$RESAMPLE"
                           [ "$QC8996" -o "$QC8998" ] && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE"
                           patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE"
                           patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE"  
                         fi
                         if [ "$BTRESAMPLE" ]; then
                           patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE"
                         fi
                         if [ "$AX7" ]; then
                           patch_mixer_toplevel "Smart PA Init Switch" "On" 
                         fi
                         if [ "$LX3" ]; then
                           patch_mixer_toplevel "Es9018 CLK Divider" "DIV4"
                           patch_mixer_toplevel "ESS_HEADPHONE Off" "On"
                         fi
                         if [ "$X9" ]; then
                           patch_mixer_toplevel "Es9018 CLK Divider" "DIV4"
                           patch_mixer_toplevel "Es9018 Hifi Switch" "1"
                         fi   
                         if [ "$Z9" ] || [ "$Z9M" ]; then
                           patch_mixer_toplevel "HP Out Volume" "22"
                           patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88"
                           patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88"
                         fi
                         if [ "$Z11" ]; then
                           patch_mixer_toplevel "AK4376 DAC Digital Filter Mode" "Slow Roll-Off"
                           patch_mixer_toplevel "AK4376 HPL Power-down Resistor" "Hi-Z"
                           patch_mixer_toplevel "AK4376 HPR Power-down Resistor" "Hi-Z"
                           patch_mixer_toplevel "AK4376 HP-Amp Analog Volume" "15"
                         fi
                         if [ "$V20" ] || [ "$V30" ] || [ "$G6" ]; then
                           patch_mixer_toplevel "Es9018 AVC Volume" "14"
                           patch_mixer_toplevel "Es9018 HEADSET TYPE" "1"
                           patch_mixer_toplevel "Es9018 State" "Hifi"
                           patch_mixer_toplevel "HIFI Custom Filter" "6"
                           if [ "$V30" ]; then
                             patch_mixer_toplevel "Es9218 Bypass" "0"
                           fi
                         fi  
                         if [ -f "/system/etc/TAS2557_A.ftcfg" ]; then 
                           patch_mixer_toplevel "HTC_AS20_VOL Index" "Twelve"
                         fi 
                         if [ "$QC8996" ] || [ "$QC8998" ]; then 
                           patch_mixer_toplevel "VBoost Ctrl" "AlwaysOn"
                           patch_mixer_toplevel "VBoost Volt" "8.6V"
                         fi
                         patch_mixer_toplevel "Set Custom Stereo OnOff" "Off"
                         if $APTX; then  
                           patch_mixer_toplevel "APTX Dec License" "21"
                         fi
                         patch_mixer_toplevel "Set HPX OnOff" "1"
                         patch_mixer_toplevel "Set HPX ActiveBe" "1"
                         patch_mixer_toplevel "PCM_Dev Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 9 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 13 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 17 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 21 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 24 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 15 Topology" "DTS"
                         patch_mixer_toplevel "PCM_Dev 33 Topology" "DTS"
                         if [ ! "$M10" ]; then
                           patch_mixer_toplevel "DS2 OnOff" "Off"
                         fi
                         patch_mixer_toplevel "Codec Wideband" "1"
                         patch_mixer_toplevel "HPH Type" "1"
                         patch_mixer_toplevel "RX HPH Mode" "CLS_H_HIFI"		 
                         if $ASP; then
                           patch_mixer_toplevel "Audiosphere Enable" "On"
                           patch_mixer_toplevel "MSM ASphere Set Param" "1"
                        fi   
                         if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
                           patch_mixer_toplevel "TFA9895 Profile" "hq"
                           patch_mixer_toplevel "TFA9895 Playback Volume" "255"
                           patch_mixer_toplevel "SmartPA Switch" "1"
                         fi	 
                         patch_mixer_toplevel "TAS2552 Volume" "125" "updateonly"
                         if [ -f "/system/etc/TAS2557_A.ftcfg" ] || [ -f "/system/vendor/etc/TAS2557_A.ftcfg" ]; then
                           patch_mixer_toplevel "TAS2557 Volume" "30"
                         fi 
                         patch_mixer_toplevel "SRS Trumedia" "1"
                         patch_mixer_toplevel "SRS Trumedia HDMI" "1"
                         patch_mixer_toplevel "SRS Trumedia I2S" "1"
                         patch_mixer_toplevel "SRS Trumedia MI2S" "1"       
                         patch_mixer_toplevel "HiFi Function" "On" 
                         if $COMP; then
                           sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/>/" $MODPATH/$NAME
                         fi
                       fi;;
  esac
done
