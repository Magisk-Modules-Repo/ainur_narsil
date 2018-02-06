AUO=$UNITY$SYS/etc/sauron_useroptions
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
rm -f $AUO

if $MAGISK; then
  rm -f $MOUNTPATH/.core/post-fs-data.d/sauron.sh $MOUNTPATH/.core/post-fs-data.d/sauron-files
else
  for FILE in ${CFGS}; do
    case $FILE in
      *.conf) $ASP && sed -i "/audiosphere { #$MODID/,/} #$MODID/d" $UNITY$FILE
              $SHB && sed -i "/libshoebox { #$MODID/,/} #$MODID/d" $UNITY$FILE
              if $FMAS; then
                [ "$QCP" -a "$CFG" == "$SYS/etc/audio_effects.conf" ] && continue
                if [ "$(grep "#$MODID *library bundle.*" $UNITY$FILE)" ] || [ "$(grep "#$MODID *library downmix.*" $UNITY$FILE)" ]; then
                  sed -i -e "/library fmas #$MODID/d" -e "/uuid 36103c50-8514-11e2-9e96-0800200c9a66 #$MODID/d" $UNITY$FILE
                fi
                sed -i "/fmas { #$MODID/,/} #$MODID/d" $UNITY$FILE
                sed -ri -e "s|#$MODID(.*)|\1|g" $UNITY$FILE
              fi;;
      *.xml) sed -i "/<!--$MODID-->/d" $UNITY$FILE
             if $FMAS; then
               sed -ri "/<!--(.*<effect name=\"virtualizer\".*)$MODID-->/ s/\1/g" $UNITY$FILE
               sed -ri "/<!--(.*<effect name=\"downmix\".*)$MODID-->/ s/\1/g" $UNITY$FILE
             fi;;
    esac  
  done
  if $AP && [ -f $SYS/etc/audio_policy.conf ]; then
    for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
      if [ "$AUD" != "compress_offload" ]; then
        sed -i "/formats AUDIO_FORMAT_PCM_8_24_BIT #$MODID/d" $UNITY$SYS/etc/audio_policy.conf
      fi
      if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
        sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM #$MODID/d" $UNITY$SYS/etc/audio_policy.conf
      fi
      sed -i "/sampling_rates 8000|11025|16000|22050|32000|44100|48000|64000|88200|96000|176400|192000|352800|384000 #$MODID/d" $UNITY$SYS/etc/audio_policy.conf
      sed -ri -e "s|#$MODID(.*)|\1|g" $UNITY$SYS/etc/audio_policy.conf
    done
  fi
  if $OAP && [ -f $VEN/etc/audio_output_policy.conf ]; then
    for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
      if [[ "$AUD" != "compress_offload"* ]]; then
        sed -i "/formats AUDIO_FORMAT_PCM_16_BIT|AUDIO_FORMAT_PCM_24_BIT_PACKED|AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_32_BIT #$MODID/d" $UNITY$VEN/etc/audio_output_policy.conf
      fi
      if [ "$AUD" == "direct" ]; then
        if [ "$(grep "compress_offload" $VEN/etc/audio_output_policy.conf)" ]; then
          sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING #$MODID/d" $UNITY$VEN/etc/audio_output_policy.conf
        else
          sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM #$MODID/d" $UNITY$VEN/etc/audio_output_policy.conf
        fi
      fi
      sed -i "/sampling_rates 44100|48000|96000|176400|192000|352800|384000 #$MODID/d" $UNITY$VEN/etc/audio_output_policy.conf
      [ -z $BIT ] || sed -i "/bit_width $BIT #$MODID/d" $UNITY$VEN/etc/audio_output_policy.conf
      sed -ri -e "s|#$MODID(.*)|\1|g" $UNITY$VEN/etc/audio_output_policy.conf
    done
  fi
  if $AP && [ -f $SYS/etc/audio_policy_configuration.xml ]; then
    sed -i "/<!--BEG-$MODID-->/,/<!--END-$MODID-->/d" $UNITY$SYS/etc/audio_policy_configuration.xml
    sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $UNITY$SYS/etc/audio_policy_configuration.xml
  fi
  for MIX in ${MIXS}; do
    sed -i "/<!--$MODID-->/d" $UNITY$MIX
    sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $UNITY$MIX
  done
fi
