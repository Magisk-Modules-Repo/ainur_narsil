#!/system/bin/sh
alias xmlstarlet="$mod/tools/xmlstarlet"
alias sed="$mod/tools/sed"

patch_xml() {
  local NAME=$(echo "$3" | sed -r "s|^.*/.*\[@.*=\"(.*)\".*$|\1|")
  local NAMEC=$(echo "$3" | sed -r "s|^.*/.*\[@(.*)=\".*\".*$|\1|")
  local VAL=$(echo "$4" | sed "s|.*=||")
  [ "$(echo $4 | grep '=')" ] && local VALC=$(echo "$4" | sed "s|=.*||") || local VALC="value"
  case "$1" in
    "-d") xmlstarlet ed -L -d "$3" $2;;
    "-u") xmlstarlet ed -L -u "$3/@$VALC" -v "$VAL" $2;;
    "-s") if [ "$(xmlstarlet sel -t -m "$3" -c . $2)" ]; then
            xmlstarlet ed -L -u "$3/@$VALC" -v "$VAL" $2
          else
            local SNP=$(echo "$3" | sed "s|\[.*$||")
            local NP=$(dirname "$SNP")
            local SN=$(basename "$SNP")
            xmlstarlet ed -L -s "$NP" -t elem -n "$SN-ainur_narsil" -i "$SNP-ainur_narsil" -t attr -n "$NAMEC" -v "$NAME" -i "$SNP-ainur_narsil" -t attr -n "$VALC" -v "$VAL" -r "$SNP-ainur_narsil" -v "$SN" $2
          fi;;
  esac
}

process_effects() {
  case $1 in
    *.conf) local REMLIBS="$(sed -n "/^libraries {/,/^}/ {/^ *path / {s|.*/\(.*.so\)|\1|g;p}}" $1)"
    local LIBRS="$(sed -n "/^libraries {/,/^}/ {/^libraries {/d;/^ *#/d;/^ *.*{/{s/^ *//;s/ {.*//;p}}" $1)"
    for i in ${KEEPLIBS}; do
      REMLIBS="$(echo $REMLIBS | sed "s| *$i.so *| |")"
      local TMP=$(sed -n "/^libraries {/,/^}/ {/^ *path .*\/$i.so/=}" $1)
      TMP=$((TMP-1))
      [ "$TMP" == "-1" ] && continue
      TMP="$(sed -n "$TMP p" $1 | sed -e "s|^ *||" -e "s| {||")"
      LIBRS="$(echo $LIBRS | sed "s| *$TMP *| |")"
    done
    for i in ${LIBRS}; do
      local SP="$(sed -n "/^libraries {/,/^}/ {/^ *$i/p}" $1 | sed -r "s/( *).*/\1/")"
      sed -i "/^libraries {/,/^}/ {/^$SP$i {/,/^$SP}/d}" $1
      sed -n "/^effects {/,/^}/p" $1 | while read j; do
        case $j in
          "#"*) ;;
          *" {")
            [ "$(sed -n "/^effects {/,/^}/ {/$SP$j/{p; :loop n; p; /^$SP}/q; b loop}}" $1 | sed -n "/library $i/p")" ] && {
            local LN=$(sed -n "/^effects {/,/^}/ {/^$SP$j/=}" $1)
            local TMP="$(sed -n "/^effects {/,/^}/ {/^$SP$j/{:loop n; /^$SP}/=; b loop}}" $1)"
            TMP="$(echo $TMP | sed -r "s/^([0-9]*).*/\1/")"
            [ "$LN" ] && sed -i "$LN,$TMP d" $1; }
          ;;
        esac
      done
    done
    ;;
    *.xml) local REMLIBS="$(sed -n "/<libraries>/,/<\/libraries>/p" $1 | grep "path=" | awk '{gsub("path=\"|\"/>","",$3); print $3}')"
    local LIBRS="$(sed -n "/<libraries>/,/<\/libraries>/p" $1 | grep "name=" | awk '{gsub("name=\"|\"","",$2); print $2}')"
    for i in ${KEEPLIBS}; do
      REMLIBS="$(echo $REMLIBS | sed "s| *[^ ]*$i.so *| |")"
      local TMP="$(sed -n "/<libraries>/,/<\/libraries>/ {/path=\"$i.so/ {s|.* name=\"\(.*\)\" .*|\1|g;p}}" $1)"
      [ -z "$TMP" ] || LIBRS="$(echo $LIBRS | sed "s| *[^ ]*$TMP *| |")"
    done
    for i in ${LIBRS}; do
      sed -i "/<libraries>/,/<\/libraries>/ {\|^ *.*name=\"$i\" path.*|d}" $1
      local TMP="$(sed -n "/<effects>/,/<\/effects>/{s/ *//;s/$/~/;p}" $1 | grep "library=\"$i\" uuid")"
      local OIFS=$IFS IFS='~'
      for j in $TMP; do
        local IFS=$OIFS
        j="$(echo $j | sed "s|~$||")"
        local LN=$(sed -n "\|$j|=" $1)
        case "$j" in
          "<!--"*|*"-->") ;;
          "<effectProxy"*"library=\"$i"*) local LN2=$((LN+1)); sed -i "$LN,$LN2 d" $1;;
          "<libsw library=\"$i"*) local LN=$((LN-1)) LN2="$((LN+2))"; sed -i "$LN,$LN2 d" $1;;
          "<libhw library=\"$i"*) local LN=$((LN-2)) LN2="$((LN+1))"; sed -i "$LN,$LN2 d" $1;;
          "<effect"*"library=\"$i"*) sed -i "$LN d" $1;;
        esac
        local IFS='~'
      done
      local IFS=$OIFS
    done
    ;;
  esac
}

FILES=$(find $MODPATH/system -type f)
for FILE in $FILES; do
  OFILE="$amldir/ainur_narsil$(echo $FILE | sed "s|^$MODPATH||")"
  case $FILE in
    *audio_policy.conf) if $AP; then
                          for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                            [ "$AUD" != "compress_offload" ] && sed -i "/$AUD {/,/}/ s/^\( *\)formats.*/\1formats AUDIO_FORMAT_PCM_8_24_BIT/g" $FILE
                            [ "$AUD" == "direct_pcm" -o "$AUD" == "direct" -o "$AUD" == "raw" ] && sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $FILE
                            sed -i "/$AUD {/,/}/ s/^\( *\)sampling_rates.*/\1sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000/g" $FILE
                          done
                        fi;;
    *audio_output_policy.conf) if $OAP; then
                                 for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                   [[ "$AUD" != "compress_offload"* ]] && sed -i "/$AUD {/,/}/ s/^\( *\)formats.*/\1formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT/g" $FILE
                                   if [ "$AUD" == "direct" ]; then
                                     if [ "$(grep "compress_offload" $FILE)" ]; then
                                       sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g" $FILE
                                     else
                                       sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $FILE
                                     fi
                                   fi
                                   sed -i "/$AUD {/,/}/ s/^\( *\)sampling_rates.*/\1sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000/g" $FILE
                                   [ -z "$BIT" ] || sed -i "/$AUD {/,/}/ s/^\( *\)bit_width.*/\1bit_width $BIT/g" $FILE
                                 done
                               fi;;
    *audio_policy_configuration.xml) if $AP; then
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"primary output\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/}}" $FILE
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"raw\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/}}" $FILE
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"deep_buffer\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"192000\1/}}" $FILE
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"multichannel\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/}}" $FILE
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"direct_pcm\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/; s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $FILE
                                       sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"compress_offload\"/,/<\/mixPort>/ {s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $FILE
                                     fi;;
    *audio_effects*) process_effects $FILE;;
    *mixer_paths*.xml) cp -f $OFILE $FILE;;
  esac
done
