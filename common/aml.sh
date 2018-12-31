[ -f "$MOUNTPATH/ainur_sauron/system/bin/xmlstarlet" ] && alias xmlstarlet=$MOUNTPATH/ainur_sauron/system/bin/xmlstarlet

$CMPSR && { case $NAME in
  *.conf) sed -i "/^effects {/,/^}/ {/loudness_enhancer {/,/}/d}" $MODPATH/$NAME;;
  *.xml) sed -i "/^ *<effects>/,/^ *<\/effects>/ {/<effect name=\"loudness_enhancer\"/d}" $MODPATH/$NAME;;
esac; }
$ASP && patch_cfgs audiosphere 184e62ab-2d19-4364-9d1b-c0a40733866c audiosphere $LIBDIR/libasphere.so
$SHB && patch_cfgs shoebox 1eab784c-1a36-4b2a-b7fc-e34c44cab89e shoebox $LIBDIR/libshoebox.so
$FMAS && { case $NAME in
             *.conf) if [ -z "$QCP" -o "$NAME" != "system/etc/audio_effects.conf" ]; then
                       patch_cfgs -l fmas $LIBDIR/libfmas.so
                       [ ! "$(sed -n "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ s/library bundle.*/library fmas/; s/uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b.*/uuid 36103c50-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME
                       [ ! "$(sed -n "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ s/library cm.*/library fmas/; s/uuid 7c6cc5f8-6f34-4449-a282-bed84f1a5b5a.*/uuid 36103c50-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME
                       [ ! "$(sed -n "/^effects {/,/^}/ {/^  downmix {/,/^  }/ {/uuid 36103c51-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  downmix {/,/^  }/ s/library downmix.*/library fmas/; s/uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f.*/uuid 36103c51-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME
                     fi;;
            *.xml) patch_cfgs -l fmas $LIBDIR/libfmas.so
                    [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"virtualizer\".*/>/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME
                    [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c51-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"downmix\".*/>/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME;;
           esac; }

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
    *mixer_paths*.xml) VAR1=ctl; VAR2=mixer;;
    *sapa_feature*.xml) VAR1=feature; VAR2=model;;
    *mixer_gains*.xml) VAR1=ctl; VAR2=mixer;;
    *audio_device*.xml) VAR1=kctl; VAR2=mixercontrol;;
    *audio_platform_info*.xml) VAR1=param; VAR2=config_params;;
  esac
  if [ "$1" == "-t" -o "$1" == "-ut" -o "$1" == "-tu" ] && [ "$VAR1" ]; then
    if [ "$(grep "<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" />" $2)" ]; then
      sed -i "0,/<$VAR1 $NAMEC=\"$NAME\" $VALC=\".*\" \/>/ s/\(<$VAR1 $NAMEC=\"$NAME\" $VALC=\"\).*\(\" \/>\)/\1$VAL\2/" $2
    elif [ "$1" == "-t" ]; then
      sed -i "/<$VAR2>/ a\    <$VAR1 $NAMEC=\"$NAME\" $VALC=\"$VAL\" \/>" $2
    fi
  elif [ "$(xmlstarlet sel -t -m "$3" -c . $2)" ]; then
    [ "$(xmlstarlet sel -t -m "$3" -c . $2 | sed -r "s/.*$VALC=\"(.*)\".*/\1/")" == "$VAL" ] && return
    case "$1" in
      "-u"|"-s") xmlstarlet ed -L -u "$3/@$VALC" -v "$VAL" $2;;
      "-d") xmlstarlet ed -L -d "$3" $2;;
    esac
  elif [ "$1" == "-s" ]; then
    local NP=$(echo "$3" | sed -r "s|(^.*)/.*$|\1|")
    local SNP=$(echo "$3" | sed -r "s|(^.*)\[.*$|\1|")
    local SN=$(echo "$3" | sed -r "s|^.*/.*/(.*)\[.*$|\1|")
    xmlstarlet ed -L -s "$NP" -t elem -n "$SN-ainur_sauron" -i "$SNP-ainur_sauron" -t attr -n "$NAMEC" -v "$NAME" -i "$SNP-ainur_sauron" -t attr -n "$VALC" -v "$VAL" $2
    xmlstarlet ed -L -r "$SNP-ainur_sauron" -v "$SN" $2
  fi
}

[ $COUNT -gt 1 ] && return
for FILE in ${FILES}; do
  NAME=$(echo "$FILE" | sed "s|$MOD|system|")
  case $NAME in
    *audio_policy.conf) if $AP; then
                          for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                            [ "$AUD" != "compress_offload" ] && sed -i "/$AUD {/,/}/ s/^\( *\)formats.*/\1formats AUDIO_FORMAT_PCM_8_24_BIT/g" $MODPATH/$NAME
                            [ "$AUD" == "direct_pcm" -o "$AUD" == "direct" -o "$AUD" == "raw" ] && sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/$NAME
                            sed -i "/$AUD {/,/}/ s/^\( *\)sampling_rates.*/\1sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/$NAME
                          done
                        fi;;
    *audio_output_policy.conf) if $OAP; then
                                 for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                   [[ "$AUD" != "compress_offload"* ]] && sed -i "/$AUD {/,/}/ s/^\( *\)formats.*/\1formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT/g" $MODPATH/$NAME
                                   if [ "$AUD" == "direct" ]; then
                                     if [ "$(grep "compress_offload" $MODPATH/$NAME)" ]; then
                                       sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g" $MODPATH/$NAME
                                     else
                                       sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/$NAME
                                     fi
                                   fi
                                   sed -i "/$AUD {/,/}/ s/^\( *\)sampling_rates.*/\1sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/$NAME
                                   [ -z $BIT ] || sed -i "/$AUD {/,/}/ s/^\( *\)bit_width.*/\1bit_width $BIT/g" $MODPATH/$NAME
                                 done
                               fi;;
    *audio_policy_configuration.xml) if $AP; then
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"primary output\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/}}" $MODPATH/$NAME
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"raw\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/}}" $MODPATH/$NAME
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"deep_buffer\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"192000\1/}}" $MODPATH/$NAME
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"multichannel\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/}}" $MODPATH/$NAME
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"direct_pcm\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/; s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $MODPATH/$NAME
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"compress_offload\"/,/<\/mixPort>/ {s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $MODPATH/$NAME
                                     fi;;
    *mixer_paths*.xml) #MIXERPATCHES
                       ;;
    *mixer_gains*.xml) #GAINPATCHES
                       ;;
    *audio_device*.xml) #ADPATCHES
                        ;;
    *sapa_feature*.xml) #SAPAPATCHES
                        ;;
    *audio_platform_info*.xml) #APLIPATCHES
                               ;;
  esac
done
