for FILE in ${CFGS}; do
  $ASP && sed -i "/audiosphere { #$MODID/,/} #$MODID/d" $AMLPATH$FILE
  $SHB && sed -i "/libshoebox { #$MODID/,/} #$MODID/d" $AMLPATH$FILE
  if $FMAS; then
    test "$QCP" -a "$CFG" == "$CONFIG_FILE" && continue
    if [ "$(grep "#$MODID *library bundle.*" $AMLPATH$FILE)" ] || [ "$(grep "#$MODID *library downmix.*" $AMLPATH$FILE)" ]; then
      sed -i -e "/library fmas #$MODID/d" -e "/uuid 36103c50-8514-11e2-9e96-0800200c9a66 #$MODID/d" $AMLPATH$FILE
    fi
    sed -i "/fmas { #$MODID/,/} #$MODID/d" $AMLPATH$FILE
    sed -ri -e "s|#$MODID(.*)|\1|g" $AMLPATH$FILE
  fi
done
for FILE in ${CFGSXML}; do
  sed -i "<!--$MODID-->/d" $AMLPATH$FILE
  if $FMAS; then
    sed -ri "/<!--(.*<effect name="virtualizer".*)$MODID-->/ s/\1/g" $AMLPATH$FILE
    sed -ri "/<!--(.*<effect name="downmix".*)$MODID-->/ s/\1/g" $AMLPATH$FILE
  fi
done

if $AP && [ -f $SYS/etc/audio_policy.conf ]; then
  for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
    if [ "$AUD" != "compress_offload" ]; then
      sed -i "/formats AUDIO_FORMAT_PCM_8_24_BIT #$MODID/d" $AMLPATH$SYS/etc/audio_policy.conf
    fi
    if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
      sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM #$MODID/d" $AMLPATH$SYS/etc/audio_policy.conf
    fi
    sed -i "/sampling_rates 8000|11025|16000|22050|32000|44100|48000|64000|88200|96000|176400|192000|352800|384000 #$MODID/d" $AMLPATH$SYS/etc/audio_policy.conf
    sed -ri -e "s|#$MODID(.*)|\1|g" $AMLPATH$SYS/etc/audio_policy.conf
  done
fi
if $OAP && [ -f $VEN/etc/audio_output_policy.conf ]; then
  for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
    if [[ "$AUD" != "compress_offload"* ]]; then
      sed -i "/formats AUDIO_FORMAT_PCM_16_BIT|AUDIO_FORMAT_PCM_24_BIT_PACKED|AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_32_BIT #$MODID/d" $AMLPATH$VEN/etc/audio_output_policy.conf
    fi
    if [ "$AUD" == "direct" ]; then
      if [ "$(grep "compress_offload" $VEN/etc/audio_output_policy.conf)" ]; then
        sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING #$MODID/d" $AMLPATH$VEN/etc/audio_output_policy.conf
      else
        sed -i "/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM #$MODID/d" $AMLPATH$VEN/etc/audio_output_policy.conf
      fi
    fi
    sed -i "/sampling_rates 44100|48000|96000|176400|192000|352800|384000 #$MODID/d" $AMLPATH$VEN/etc/audio_output_policy.conf
    test -z $BIT || sed -i "/bit_width $BIT #$MODID/d" $AMLPATH$VEN/etc/audio_output_policy.conf
    sed -ri -e "s|#$MODID(.*)|\1|g" $AMLPATH$VEN/etc/audio_output_policy.conf
  done
fi
if $AP && [ -f $SYS/etc/audio_policy_configuration.xml ]; then
  sed -i "/<!--BEG-$MODID-->/,/<!--END-$MODID-->/d" $AMLPATH$SYS/etc/audio_policy_configuration.xml
  sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $AMLPATH$SYS/etc/audio_policy_configuration.xml
fi
for MIX in ${MIXS}; do
  sed -i "/<!--$MODID-->/d" $AMLPATH$MIX
  sed -i -e "s|<!--$MODID\(.*\)|\1|g" -e "s|\(.*\)$MODID-->|\1|g" $AMLPATH$MIX
done
