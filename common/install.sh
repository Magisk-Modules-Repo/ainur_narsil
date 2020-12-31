##########################################################################################
#
# Ainur Installation Script
#
##########################################################################################
##########################################################################################
# Functions
##########################################################################################

get_uo() {
  case "$1" in
    "-u") cat $AUO | sed 's/\r$//g' | tr '\r' '\n' > $AUO.tmp; mv -f $AUO.tmp $AUO
            for UO in $(grep "^[A-Za-z_]*=" $AUO | sed -e 's/=.*//g' -e 's/Version//g'); do
              eval "$UO=$(grep_prop "$UO" $AUO)"
              sed -i "s|^$UO=|$UO=$(eval echo \$$UO)|" $MODPATH/narsil_useroptions
            done;;
    *) . $AUO
       for UO in $(grep "^[A-Za-z_]*=" $AUO | sed -e 's/=.*//g' -e 's/UVER//g'); do
         case $UO in
           "BIT") case "$BIT" in
                    "S16_LE");;
                    "S24_3LE") echo -e 'persist.audio.format.24bit=true\naudio.offload.pcm.24bit.enable=true\npersist.vendor.audio_hal.dsp_bit_width_enforce_mode=1' >> $MODPATH/system.prop;;
                    "S32_LE") $QCNEW && echo -e 'persist.vendor.audio_hal.dsp_bit_width_enforce_mode=1\naudio.offload.pcm.32bit.enable=true' >> $MODPATH/system.prop || unset BIT;;
                    *) unset BIT;;
                  esac;;
           # Put non-boolean variables here
           "VSTP"|"RESAMPLE"|"QIMPEDANCE"|"BTSMPL"|"ESMPL"|"MIMPEDANCE"|"MGAIN") case "$(eval echo \$$UO | tr '[:upper:]' '[:lower:]')" in
                                                                                   " "*) eval "$UO=";;
                                                                                 esac;;
           *) case "$(eval echo \$$UO | tr '[:upper:]' '[:lower:]')" in
                "true") eval "$UO=true";;
                *) eval "$UO=false";;
              esac;;
         esac
      done;;
  esac
}

patch_xml() {
  case "$2" in
    *mixer_paths*.xml) [ $MIXNUM -gt 5 ] || sed -i "\$apatch_xml $1 \$MODPATH$(echo $2 | sed "s|$MODPATH||") '$3' \"$4\"" $MODPATH/.aml.sh;;
    *) sed -i "\$apatch_xml $1 \$MODPATH$(echo $2 | sed "s|$MODPATH||") '$3' \"$4\"" $MODPATH/.aml.sh;;
  esac
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
            xmlstarlet ed -L -s "$NP" -t elem -n "$SN-$MODID" -i "$SNP-$MODID" -t attr -n "$NAMEC" -v "$NAME" -i "$SNP-$MODID" -t attr -n "$VALC" -v "$VAL" -r "$SNP-$MODID" -v "$SN" $2
          fi;;
  esac
}

# Makes sure REMLIBS contains all libs (on actual device) to be removed
# while KEEPLIBS contains general whitelist
keep_lib() {
  for i in ${1}; do
    REMLIBS="$(echo $REMLIBS | sed "s| *[^ ]*$i.so *| |g")"
  done
  [ -z "$KEEPLIBS" ] && KEEPLIBS="$1" || KEEPLIBS="$KEEPLIBS $1"
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

##########################################################################################
# Variables
##########################################################################################

if [ -d $NVBASE/modules/ainur_sauron ]; then
  ui_print " "
  ui_print "! AINUR SAURON detected!"
  abort "! Uninstall Sauron first with Sauron Zip!"
fi
[ -f /system/vendor/build.prop ] && BUILDS="/system/build.prop /system/vendor/build.prop" || BUILDS="/system/build.prop"
# HTC=$(grep "????" $BUILDS)
MTK=$(grep -E "ro.mediatek.version.*|ro.hardware=mt*" $BUILDS)
EXY=$(grep -E "ro.chipname=exynos*|ro.board.platform=exynos*" $BUILDS)
KIR=$(grep -E "ro.board.platform=hi.*|ro.board.platform=kirin*" $BUILDS)
KIR970=$(grep "ro.board.platform=kirin970" $BUILDS)
# SONY additions by Laster K.
SONY=$(grep "ro.semc.*" $BUILDS)
SPEC=$(grep "ro.board.platform=sp.*" $BUILDS)
MIUI=$(grep "ro.miui.ui.version.*|ro.product.brand=Xiaomi*" $BUILDS)
TMSM=$(grep "ro.board.platform=msm" $BUILDS | sed 's/^.*=msm//')
QC94=$(grep "ro.board.platform=msm8994" $BUILDS)
QCP=$(grep -E "ro.board.platform=apq.*|ro.board.platform=msm.*|ro.board.platform=sdm.*" $BUILDS)
[ -z $QCP ] && QCP="$(cat /proc/cpuinfo | grep 'Qualcomm')"
QC8996=$(grep "ro.board.platform=msm8996" $BUILDS)
QC8998=$(grep "ro.board.platform=msm8998" $BUILDS)
SD625=$(grep "ro.board.platform=msm8953" $BUILDS)
SD650=$(grep "ro.board.platform=msm8952" $BUILDS)
SD845=$(grep "ro.board.platform=sdm845" $BUILDS)
SD660=$(grep "ro.board.platform=sdm660" $BUILDS)
SD670=$(grep "ro.board.platform=sdm670" $BUILDS)
SD710=$(grep "ro.board.platform=sdm710" $BUILDS)
SD855=$(grep "ro.board.platform=msmnile" $BUILDS)
if [ "$SD650" ] || [ "$SD625" ] || [ "$SD660" ] || [ "$SD670" ] || [ "$SD710" ] || [ "$SD845" ] || [ "$SD855" ]; then QCNEW=true; else QCNEW=false; fi
M9=$(grep -E "ro.aa.modelid=0PJA.*|ro.product.device=himaul*" $BUILDS)
BOLT=$(grep "ro.aa.modelid=2PYB.*" $BUILDS)
M10=$(grep "ro.aa.modelid=2PS6.*" $BUILDS)
U11P=$(grep "ro.aa.modelid=2Q4D.*" $BUILDS)
M8=$(grep "ro.aa.modelid=0P6B.*" $BUILDS)
LG=$(grep "ro.product.brand=lge" $BUILDS)
AX7=$(grep -E "ro.build.product=axon7|ro.build.product=ailsa_ii" $BUILDS)
V20=$(grep "ro.product.device=elsa" $BUILDS)
V30=$(grep "ro.product.device=joan" $BUILDS)
G6=$(grep "ro.product.device=lucye" $BUILDS)
G7=$(grep "ro.product.device=judyln" $BUILDS)
Z9=$(grep "ro.product.model=NX508J" $BUILDS)
Z9M=$(grep -E "ro.product.model=NX510J|ro.product.model=NX518J" $BUILDS)
Z11=$(grep "ro.product.model=NX531J" $BUILDS)
LX3=$(grep -E "ro.build.product=X3c50|ro.build.product=X3c70|ro.build.product=x3_row" $BUILDS)
OP5=$(grep -E "ro.build.product=OnePlus5.*|ro.build.product=cheeseburger|ro.build.product=Cheeseburger|ro.build.product=dumpling|ro.build.product=Dumpling" $BUILDS)
X9=$(grep "ro.product.model=X900.*" $BUILDS)
PX1=$(grep -E "ro.vendor.product.device=sailfish|ro.vendor.product.name=sailfish|ro.product.device=sailfish|ro.product.model=Pixel|ro.product.name=sailfish" $BUILDS)
PX1XL=$(grep -E "ro.vendor.product.device=marlin|ro.vendor.product.name=marlin|ro.product.model=Pixel XL|ro.product.device=marlin|ro.product.name=marlin" $BUILDS)
PX2=$(grep -E "ro.vendor.product.device=walleye|ro.vendor.product.name=walleye|ro.product.model=Pixel 2|ro.product.name=walleye|ro.product.device=walleye" $BUILDS)
PX2XL=$(grep -E "ro.vendor.product.name=taimen|ro.vendor.product.device=taimen|ro.product.model=Pixel 2 XL|ro.product.name=taimen|ro.product.device=taimen" $BUILDS)
PX3=$(grep -E "ro.vendor.product.device=blueline|ro.vendor.product.name=blueline|ro.product.model=Pixel 3|ro.product.name=blueline|ro.product.device=blueline" $BUILDS)
PX3XL=$(grep -E "ro.vendor.product.device=crosshatch|ro.vendor.product.name=crosshatch|ro.product.model=Pixel 3 XL|ro.product.name=crosshatch|ro.product.device=crosshatch" $BUILDS)
NX9=$(grep -E "ro.product.name=volantis.*|ro.product.board=flounder.*" $BUILDS)
OP3=$(grep -E "ro.build.product=OnePlus3.*|ro.build.product=oneplus3.*|ro.vendor.product.device=oneplus3.*|ro.vendor.product.device=OnePlus3.*" $BUILDS)
X5P=$(grep -E "ro.product.name=vince.*|ro.product.device=vince.*" $BUILDS)
MNPRO=$(grep "ro.product.device=virgo" $BUILDS)
RN5PRO=$(grep "ro.vendor.product.device=whyred" $BUILDS)
MI8SE=$(grep "ro.vendor.product.name=sirius.*" $BUILDS)
MI8EE=$(grep "ro.vendor.product.name=ursa.*" $BUILDS)
MI8UD=$(grep "ro.vendor.product.name=equuleus.*" $BUILDS)
MIA2=$(grep "ro.vendor.product.name=jasmine.*" $BUILDS)
POC=$(grep -E "ro.product.vendor.name=beryllium.*|ro.product.name=beryllium.*" $BUILDS)
MI9=$(grep -E "ro.product.vendor.name=cepheus.*|ro.product.name=cepheus.*" $BUILDS)
CFGS="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
MIXS="$(find /system /vendor -type f -name "mixer_paths*.xml")"
POLS="$(find /system /vendor -type f -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml")"
SAPA="$(find /system /vendor -type f -name "*sapa_feature*.xml")"
MIXG="$(find /system /vendor -type f -name "*mixer_gains*.xml")"
MIXA="$(find /system /vendor -type f -name "*audio_device*.xml")"
MODA="$(find /system /vendor -type f -name "modules.alias")"
MODD="$(find /system /vendor -type f -name "modules.dep")"
APLIS="$(find /system /vendor -type f -name "audio_platform_info*.xml")"
TUNES="$(find /system /vendor -type f -name "*audio_effects_tune*.xml")"
ACONF="$(find /system /vendor -type f -name "audio_configs*.xml")"
REMLIBS="$(find /system/lib*/soundfx /vendor/lib*/soundfx -type f -name "lib*.so")"
VNDK=$(find /system/lib /vendor/lib -type d -iname "*vndk*")
VNDK64=$(find /system/lib64 /vendor/lib64 -type d -iname "*vndk*")
VNDKQ=$(find /system/lib /vendor/lib -type d -iname "vndk*-Q")
[ "$POC" ] && ADSP=/system/vendor/dsp/adsp || ADSP=/system/vendor/lib/rfsa/adsp
MINAS=$MODPATH/common/minas-tirith
ETC=/system/etc
VETC=/system/vendor/etc
AET=$VETC/audio_effects_tune.xml
if [ $API -ge 26 ]; then
  LIB=/system/vendor/lib
  LIB64=/system/vendor/lib64
  # fix acdb for htc - they have it in /etc
  ACDB=$VETC/acdbdata
  AMPA=$VETC/TAS2557_A.ftcfg
else
  LIB=/system/lib
  LIB64=/system/lib64
  ACDB=$ETC/acdbdata
  AMPA=$ETC/TAS2557_A.ftcfg
fi
SFX=$LIB/soundfx
SFX64=$LIB64/soundfx
VLIB=/system/vendor/lib
VLIB64=/system/vendor/lib64
VSFX=$VLIB/soundfx
VSFX64=$VLIB64/soundfx
if [ -d "/system/lib/modules" ]; then
  MODU=$MODPATH/system/lib
else
  MODU=$MODPATH/system/vendor/lib
fi

##########################################################################################
# Pre-installation
##########################################################################################

mkdir -p $MODPATH/tools
cp -f $MODPATH/common/addon/External-Tools/tools/$ARCH32/* $MODPATH/tools/

FILES=$(find $NVBASE/modules/*/system $MODULEROOT/*/system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
  ui_print " "
  ui_print "   ! Conflicting audio mod found!"
  ui_print "   ! You will need to install !"
  ui_print "   ! Audio Modification Library !"
  sleep 3
fi

AUO=/storage/emulated/0/narsil_useroptions
[ -f "$AUO" ] && UVER=$(grep_prop UVER $AUO)
ui_print " "
if [ -z "$UVER" ]; then
  [ -f $AUO ] && ui_print "   Deprecated version of narsil_useroptions detected!" || ui_print "   ! Narsil_useroptions not detected !"
  ui_print "   Creating /sdcard/narsil_useroptions with default options..."
  ui_print "   Using default options"
  cp -f $MODPATH/narsil_useroptions $AUO
elif [ $UVER -lt $(grep_prop UVER $MODPATH/narsil_useroptions) ]; then
  ui_print "   Older version of narsil_useroptions detected!"
  ui_print "   Updating narsil_useroptions!"
  get_uo -u
  ui_print "   Using specified options"
else
  ui_print "   Up to date narsil_useroptions detected! "
  ui_print "   Using specified options"
fi
# Make sure EOL is unix
cat $AUO | sed 's/\r$//g' | tr '\r' '\n' > $AUO.tmp; mv -f $AUO.tmp $AUO
get_uo
ui_print " "

##########################################################################################
# Main installation (by UltraM8, Zackptg5, and JohnFawkes)
#
# ! DO NOT modify any of the below.
##########################################################################################

# AML Supported Mods
keep_lib "libam3daudioenhancement libv4a_fx libv4a_fx_ics libv4a_xhifi_ics libhwdax libswdax libswdap libhwdap libdseffect libswvlldp libicepower libarkamys libjamesdsp libmaxxeffect-cembedded libbassboostMz libsonysweffect libatmos libdtsaudio"
keep_lib "libsamsungSoundbooster_plus libaudiosa libswdap_legacy libaudioeffectoffload libhaptic_effect libqcomvisualizer libvisualizer libdynproc libqcompostprocbundle libqcomvoiceprocessing libeffectproxy libadaptsoundse libadaptsoundsehw liblimitercopp liblimitercopphw libeagle libspeakerbundle libgearvr libznrwrapper libplaybackrecorder"
[ -f "$SFX/libspeakerbundle.so" ] && $MOTO_KEEPEFF && keep_lib "libmmieffectswrapper"
if ([ "$QCP" ] || [ "$EXY" ]) && $SAMS_KEEPEFF; then
  keep_lib "libmyspaceplus libaudiosaplus_sec_legacy libmysound_legacy libsamsungSoundbooster_tdm_legacy libaudiosaplus_sec libmysound libmyspace libsamsungSoundbooster_plus"
elif [ "$SONY" ] && $SONY_KEEPEFF; then
  keep_lib "libsonysweffect libsonypostprocbundle"
elif $DIRAC_KEEPEFF; then
  keep_lib "libdirac libmisoundfx libdirac_gef"
elif ([ "$PX3" ] || [ "$PX3XL" ]) && $PIXEL3_KEEPEFF; then
  keep_lib "libmalistener"
elif [ "$KIR" ] && $HUAWEI_KEEPEFF; then
  keep_lib "libhuaweiprocessing"
elif [ "$LG" ] && $LG_KEEPEFF; then  
  keep_lib "liblgeffectwrapper"
fi
ui_print "   Removing libs..."
for LIB in ${REMLIBS}; do
  mktouch "$MODPATH$(echo $LIB | sed "s|^/vendor|/system/vendor|g")"
done
ui_print "   Removing audio effects..."
for OFILE in ${CFGS}; do
  FILE="$MODPATH$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch $ORIGDIR$OFILE $FILE
  process_effects $FILE
done

ui_print "   Copying files..."
if [ "$QCP" ]; then
  prop_process $MODPATH/common/propsqcp.prop
  if $QCNEW && [ "$BTSMPL" ] && [ $API -ge 28 ]; then
     echo -e 'persist.vendor.bt.soc.scram_freqs=$BTSMPL.\npersist.vendor.bt.soc.scram_freqs=$BTSMPL' >> $MODPATH/system.prop
  fi
  if [ $API -ge 26 ] && [ ! "$OP3" ] && [ ! "$OP5" ]; then
    prop_process $MODPATH/common/propsqcporeo.prop
  fi
  [ "$OP3" ] && sed -i -e 's/audio.offload.multiple.enabled(.?)true/d' -e 's/audio.offload.pcm.enable(.?)true/d' -e 's/audio.playback.mch.downsample(.?)false/d' $MODPATH/system.prop 
  if [ -f "/system/etc/htc_audio_effects.conf" ] || [ -f "/system/vendor/etc/htc_audio_effects.conf" ]; then
    prop_process $MODPATH/common/propshtc.prop
    cp_ch $MINAS/default_vol_level.conf $MODPATH$ETC/default_vol_level.conf
    cp_ch $MINAS/TFA_default_vol_level.conf $MODPATH$ETC/TFA_default_vol_level.conf
    cp_ch $MINAS/NOTFA_default_vol_level.conf $MODPATH$ETC/NOTFA_default_vol_level.conf
  elif [ "$M9" ]; then
    sed -i 's/audio.offload.pcm.enable(.?)true/'d $MODPATH/system.prop
    sed -i 's/audio.offload.multiple.enabled(.?)true/'d $MODPATH/system.prop
  fi
  if [ -f "$AMPA" ]; then
    cp_ch $MINAS/TAS2557_A.ftcfg $MODPATH$VETC/TAS2557_A.ftcfg
    cp_ch $MINAS/TAS2557_B.ftcfg $MODPATH$VETC/TAS2557_B.ftcfg
    cp_ch $MINAS/tas2557s_uCDSP_PG21.bin $MODPATH/system/firmware/tas2557s_uCDSP_PG21.bin
    if [ -f "$U11P" ]; then
      cp_ch $MINAS/tas2557s_uCDSP_24bit.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_24bit.bin
      cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
    fi
  fi
  if [ "$MI8SE" ]; then
    cp_ch $MINAS/ti_audio_s $MODPATH/system/bin/ti_audio_s
    cp_ch $MINAS/TAS2557_A.ftcfg $MODPATH$VETC/tas2557_aac.ftcfg
    cp_ch $MINAS/TAS2557_B.ftcfg $MODPATH$VETC/tas2557_goer.ftcfg
    cp_ch $MINAS/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    # test
    cp_ch $MINAS/tas2557_uCDSP $MODPATH/system/vendor/firmware/tas2557_uCDSP
    cp_ch $MINAS/tas2557s_uCDSP_24bit.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_24bit.bin
    cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
  elif [ "$MI8EE" ] || [ "$MI8UD" ]; then
    cp_ch $MINAS/ti_audio_s $MODPATH/system/bin/ti_audio_s
    cp_ch $MINAS/TAS2557_A.ftcfg $MODPATH$VETC/tas2557.ftcfg
    cp_ch $MINAS/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp_ch $MINAS/tas2557_uCDSP $MODPATH/system/vendor/firmware/tas2557_uCDSP
    cp_ch $MINAS/tas2557s_uCDSP_24bit.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_24bit.bin
    cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
  elif [ "$MIA2" ]; then
    cp_ch $MINAS/TAS2557_A.ftcfg $MODPATH$VETC/speaker.ftcfg
    cp_ch $MINAS/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    cp_ch $MINAS/tas2557_uCDSP $MODPATH/system/vendor/firmware/tas2557_uCDSP
    cp_ch $MINAS/tas2557s_uCDSP_24bit.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_24bit.bin
    cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
  elif [ "$POC" ]; then
   cp_ch $MINAS/tas2559_l.ftcfg $MODPATH$VETC/tas2559_l.ftcfg
   cp_ch $MINAS/tas2559_r.ftcfg $MODPATH$VETC/tas2559_r.ftcfg
  fi
  if [ "$OP5" ]; then
    cp_ch $MINAS/TFA9890_N1B12_N1C3_v3.config $MODPATH$ETC/settings/TFA9890_N1C3_2_1_1.patch
  elif [ "$P2XL" ] || [ "$P2" ]; then
    cp_ch $SAU/files/bin/ti_audio_s $MODPATH/system/bin/ti_audio_s
    mktouch $MODPATH/system/vendor/firmware/tas2557s_PG21_uCDSP.bin
    mktouch $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
    mktouch $MODPATH/system/vendor/firmware/tas2557_cal.bin
    cp_ch $MINAS/tas2557s_uCDSP_PG21.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_PG21.bin
    cp_ch $MINAS/tas2557s_uCDSP_24bit.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP_24bit.bin
    cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/vendor/firmware/tas2557s_uCDSP.bin
    cp_ch $MINAS/TAS2557_A.ftcfg $MODPATH$VETC/TAS2557_A.ftcfg
    cp_ch $MINAS/TAS2557_B.ftcfg $MODPATH$VETC/TAS2557_B.ftcfg
    cp_ch $MINAS/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    [ "$MI9" ] || cp_ch $MINAS/capi_v2_smartAmp_TAS25xx.so.1 $MODPATH$ADSP/capi_v2_smartAmp_TAS25xx.so.1
    [ "$P2" ] && cp_ch $MINAS/tfa98xx.cnt $MODPATH/system/vendor/firmware/tfa98xx.cnt
  elif [ "$P1XL" ] || [ "$P1" ]; then
    cp_ch $MINAS/tfa98xx.cnt $MODPATH/system/vendor/firmware/tfa98xx.cnt
  elif [ "$X5P" ]; then
    mktouch $MODPATH/system/firmware/tas2557_uCDSP.bin
    cp_ch $MINAS/tas2557s_uCDSP.bin $MODPATH/system/firmware/tas2557s_uCDSP.bin
    cp_ch $MINAS/files/TAS2557_A.ftcfg $MODPATH$VETC/TAS2557_A.ftcfg
    cp_ch $MINAS/files/TAS2557_B.ftcfg $MODPATH$VETC/TAS2557_B.ftcfg
    cp_ch $MINAS/audio_snd-soc-tas2557.ko $MODU/modules/audio_snd-soc-tas2557.ko
    [ "$MI9" ] || cp_ch $MINAS/capi_v2_smartAmp_TAS25xx.so.1 $MODPATH$ADSP/capi_v2_smartAmp_TAS25xx.so.1
  fi
  if $QCNEW && $ACDBP; then
    if [ -f "$ACDB/Codec_cal.acdb" ]; then
      cp_ch $MINAS/Codec_cal.acdb $MODPATH$ACDB/Codec_cal.acdb
      if [ "$SD845" ]; then
        cp_ch $MINAS/Headset_cal.acdb $MODPATH$ACDB/Headset_cal.acdb
        cp_ch $MINAS/General_cal.acdb $MODPATH$ACDB/General_cal.acdb
        cp_ch $MINAS/Global_cal.acdb $MODPATH$ACDB/Global_cal.acdb
      fi
    fi
  elif [ "$QC94" ] && $ACDBP && [ ! "$M9" ]; then
    cp_ch $MINAS/Headset_cal2.acdb $MODPATH$ACDB/Headset_cal.acdb
    cp_ch $MINAS/General_cal2.acdb $MODPATH$ACDB/General_cal.acdb
    cp_ch $MINAS/Global_cal2.acdb $MODPATH$ACDB/Global_cal.acdb
  fi
  if $DISABLE_OFFLOAD; then
   echo "audio.offload.disable=1" >> $MODPATH/system.prop
   echo "audio.offload.pcm.enable=false" >> $MODPATH/system.prop
   echo "audio.offload.pcm.16bit.enable=false" >> $MODPATH/system.prop
   echo "audio.offload.track.enable=false" >> $MODPATH/system.prop
   sed -i 's/audio.offload.pcm.24bit.enable(.?)true/'d $MODPATH/system.prop
    if [ $API -ge 26 ]; then
     echo "vendor.audio.offload.track.enable=false" >> $MODPATH/system.prop
     echo "vendor.audio.offload.multiple.enabled=false" >> $MODPATH/system.prop
     echo "vendor.audio.offload.passthrough=false" >> $MODPATH/system.prop
    fi
  fi
fi

if [ "$MTK" ]; then
  prop_process $MODPATH/common/propsmtk.prop
elif [ "$EXY" ]; then
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $MODPATH/system.prop
elif [ "$MIUI" ]; then
  sed -i 's/persist.audio.hifi(.?)true/'d $MODPATH/system.prop
  sed -i 's/alsa.mixer.playback.master(.?)DAC1/'d $MODPATH/system.prop
  sed -i 's/persist.audio.hifi.volume(.?)1/'d $MODPATH/system.prop
elif [ "$SONY" ]; then
  # Hex props by UltraM8
  echo "persist.vendor.audio.latency_deep_buffer_speaker=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_headset=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_usb=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_deep_buffer_a2dp=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_compress_offload_speaker=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_compress_offload_headset=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_compress_offload_usb=0" >> $MODPATH/system.prop
  echo "persist.vendor.audio.latency_compress_offload_a2dp=0" >> $MODPATH/system.prop
elif [ "$LG" ]; then
  prop_process $MODPATH/common/propslg.prop
fi

if [ "$VSTP" ]; then
  echo "ro.config.media_vol_steps=$VSTP" >> $MODPATH/system.prop
fi

$CPGD && echo -e 'for i in $(find /sys/module -name "*collapse_enable"); do\n  echo 0 > $i\ndone\n' >> $MODPATH/post-fs-data.sh

for i in "AX7" "V20" "V30" "G6" "Z9" "Z9M" "Z11" "LX3" "X9"; do
  sed -i "2i $i=$(eval echo \$$i)" $MODPATH/service.sh
done

# Policy config patches by UltraM8 and Oreo policy XML patches by Laster K.
if $AP || $OAP; then
  ui_print "   Patching audio policies"
  for OFILE in ${POLS}; do
    FILE="$MODPATH$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
    case $FILE in
      *audio_policy.conf) if $AP; then
                            cp_ch $ORIGDIR$OFILE $FILE
                            sed -i 's/\t/  /g' $FILE
                            for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                              [ "$AUD" != "compress_offload" ] && sed -i "/$AUD {/,/}/ s/^\( *\)formats.*/\1formats AUDIO_FORMAT_PCM_8_24_BIT/g" $FILE
                              [ "$AUD" == "direct_pcm" -o "$AUD" == "direct" -o "$AUD" == "raw" ] && sed -i "/$AUD {/,/}/ s/^\( *\)flags.*/\1flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $FILE
                              sed -i "/$AUD {/,/}/ s/^\( *\)sampling_rates.*/\1sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000/g" $FILE
                            done
                          fi;;
      *audio_output_policy.conf) if $OAP; then
                                   cp_ch $ORIGDIR$OFILE $FILE
                                   sed -i 's/\t/  /g' $FILE
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
                                         cp_ch $ORIGDIR$OFILE $FILE
                                         sed -i 's/\t/  /g' $FILE
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"primary output\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"48000,96000,192000\1/}}" $FILE
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"raw\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/}}" $FILE
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"deep_buffer\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"192000\1/}}" $FILE
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"multichannel\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/}}" $FILE
                                         # Use 'channel_masks' for conf files and 'channelMasks' for xml files
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"direct_pcm\"/,/<\/mixPort>/ {s/format=\"[^\"]*\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\1/; s/samplingRates=\"[^\"]*\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\1/; s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $FILE
                                         sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"compress_offload\"/,/<\/mixPort>/ {s/channelMasks=\"[^\"]*\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\1/}}" $FILE
                                       fi;;
    esac
  done
fi

# Mixer modifications by UltraM8
ui_print "   Patching mixers..."
if [ "$QCP" ]; then
  for OMIX in ${MIXS}; do
    MIX="$MODPATH$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$OMIX $MIX
    sed -i 's/\t/  /g' $MIX
    if [ "$BIT" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_0_RX Format"]' "$BIT"
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_5_RX Format"]' "$BIT"
      if [ ! $LG ]; then
        patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX Format"]' "$BIT"
      fi
      [ $QC8996 -o $QC8998 -o $SD660 -o $SD670 -o $SD710 -o $SD845 ] && { patch_xml -s $MIX '/mixer/ctl[@name="SLIM_6_RX Format"]' "$BIT"; patch_xml -s $MIX '/mixer/ctl[@name="SLIM_2_RX Format"]' "$BIT"; patch_xml -s $MIX '/mixer/ctl[@name="ASM Bit Width"]' "$BIT"; }
      patch_xml -s $MIX '/mixer/ctl[@name="USB_AUDIO_RX Format"]' "$BIT"
      patch_xml -s $MIX '/mixer/ctl[@name="HDMI_RX Bit Format"]' "$BIT"
      if [ "$V30" ] || [ "$G7" ]; then
        patch_xml -s $MIX '/mixer/ctl[@name="TERT_MI2S_RX Format"]' "$BIT"
      fi
    fi
    if [ "$QIMPEDANCE" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="HPHR Impedance"]' "$QIMPEDANCE"
      patch_xml -s $MIX '/mixer/ctl[@name="HPHL Impedance"]' "$QIMPEDANCE"
    fi
    if [ "$RESAMPLE" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_0_RX SampleRate"]' "$RESAMPLE"
      patch_xml -s $MIX '/mixer/ctl[@name="SLIM_5_RX SampleRate"]' "$RESAMPLE"
      if [ ! "$LG" ]; then
        patch_xml -s $MIX '/mixer/ctl[@name="QUAT_MI2S_RX SampleRate"]' "$RESAMPLE"
      fi
      $QCNEW && { patch_xml -s $MIX '/mixer/ctl[@name="SLIM_6_RX SampleRate"]' "$RESAMPLE"; patch_xml -s $MIX '/mixer/ctl[@name="SLIM_2_RX SampleRate"]' "$RESAMPLE"; }
      patch_xml -s $MIX '/mixer/ctl[@name="USB_AUDIO_RX SampleRate"]' "$RESAMPLE"
      patch_xml -s $MIX '/mixer/ctl[@name="HDMI_RX SampleRate"]' "$RESAMPLE"
      if [ "$V30" ] || [ "$G7" ]; then
       patch_xml -s $MIX '/mixer/ctl[@name="TERT_MI2S_RX SampleRate"]' "$RESAMPLE"
      fi
    fi
    if [ "$QC8996" ] || $QCNEW; then
      patch_xml -s $MIX '/mixer/ctl[@name="VBoost Ctrl"]' "AlwaysOn"
    fi
    patch_xml -s $MIX '/mixer/ctl[@name="Set Custom Stereo OnOff"]' "Off"
    patch_xml -s $MIX '/mixer/ctl[@name="Set HPX OnOff"]' "0"
    patch_xml -s $MIX '/mixer/ctl[@name="Set HPX ActiveBe"]' "0"
    patch_xml -s $MIX '/mixer/ctl[@name="DS2 OnOff"]' "Off"
    patch_xml -s $MIX '/mixer/ctl[@name="Codec Wideband"]' "1"
    patch_xml -s $MIX '/mixer/ctl[@name="HPH Type"]' "1"
	  if $QCNEW; then
      patch_xml -u $MIX '/mixer/ctl[@name="RX HPH Mode"]' "CLS_AB_HIFI"
  	else
	    patch_xml -u $MIX '/mixer/ctl[@name="RX HPH Mode"]' "CLS_H_AB"
    fi
    patch_xml -s $MIX '/mixer/ctl[@name="HiFi Function"]' "On"
    patch_xml -s $MIX '/mixer/ctl[@name="App Type Gain"]' "8192"
    patch_xml -s $MIX '/mixer/ctl[@name="Audiosphere Enable"]' "Off"
    patch_xml -s $MIX '/mixer/ctl[@name="MSM ASphere Set Param"]' "0"
    patch_xml -u $MIX '/mixer/ctl[@name="HPHL Volume"]' "20"
    if $COMP; then
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP1"]' 0
      patch_xml -u $MIX '/mixer/path[@name="true-native-mode"]/ctl[@name="COMP2"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-generic"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-generic"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-44.1"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones-44.1"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP0 RX1"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP0 RX2"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-fb-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voice-anc-fb-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="tty-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="tty-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="aac-initial"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="aac-initial"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-on"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-on"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc2-on"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc2-on"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphones"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphones"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphone-combo"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="anc-off-headphone-combo"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voiceanc-headphone"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="voiceanc-headphone"]/ctl[@name="COMP2 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="handset"]/ctl[@name="COMP1 Switch"]' 0
      patch_xml -u $MIX '/mixer/path[@name="handset"]/ctl[@name="COMP2 Switch"]' 0 
    fi
    if [ "$AX7" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="AK4490 Super Slow Roll-off Filter"]' "On"
  	fi
    if [ "$LX3" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 CLK Divider"]' "DIV4"
      patch_xml -s $MIX '/mixer/ctl[@name="ESS_HEADPHONE Off"]' "On"
  	fi  
    if [ "$X9" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 CLK Divider"]' "DIV4"
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 Hifi Switch"]' "1"
  	fi
    if [ "$Z9" ] || [ "$Z9M" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="HP Out Volume"]' "22"
      patch_xml -s $MIX '/mixer/ctl[@name="ADC1 Digital Filter"]' "sharp_roll_off_88"
      patch_xml -s $MIX '/mixer/ctl[@name="ADC2 Digital Filter"]' "sharp_roll_off_88"
  	fi  
    if [ "$Z11" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 DAC Digital Filter Mode"]' "Slow Roll-Off"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HPL Power-down Resistor"]' "Hi-Z"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HPR Power-down Resistor"]' "Hi-Z"
      patch_xml -s $MIX '/mixer/ctl[@name="AK4376 HP-Amp Analog Volume"]' "15"
    fi	  
    if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TFA9895 Profile"]' "hq"
      patch_xml -s $MIX '/mixer/ctl[@name="TFA9895 Playback Volume"]' "255"
      patch_xml -s $MIX '/mixer/ctl[@name="SmartPA Switch"]' "1"
    fi
    if [ -f "$AMPA" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2557 Volume"]' "30"
	    patch_xml -s $MIX '/mixer/ctl[@name="HTC_AS20_VOL Index"]' "Twelve"
    fi
    if [ -f "$MNPRO" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Custom Filter"]' "ON"
      patch_xml -s $MIX '/mixer/ctl[@name="Filter Shape"]' "Slow Rolloff"
      patch_xml -s $MIX '/mixer/ctl[@name="THD3 Compensation"]' "0"
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2552 Volume"]' "27"
  	fi  
    if [ -f "$RN5PRO" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="TAS2557 ClassD Edge"]' "7"
    fi
    if ([ "$V20" ] || [ "$V30" ] || [ "$G6" ] || [ "$G7" ]) && $LG_HIM; then
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 AVC Volume"]' "0"
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 Master Volume"]' "0"
      patch_xml -s $MIX '/mixer/path[@name="headphones-hifi-dac"]/ctl[@name="Es9018 HEADSET TYPE"]' "2" 
      patch_xml -u $MIX '/mixer/ctl[@name="HIFI Custom Filter"]' "6"
  	fi  
    if ([ "$V20" ] || [ "$V30" ] || [ "$G6" ]) && [ ! "$G7" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Es9018 State"]' "Hifi"
    fi	
  done

  for OAPLI in ${APLIS}; do
    APLI="$MODPATH$(echo $OAPLI | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$OAPLI $APLI
    sed -i 's/\t/  /g' $APLI
    if [ ! "$OP5" ]; then
     patch_xml -s $APLI '/audio_platform_info/config_params/param[@key="native_audio_mode"]' 'src'
    fi
    if [ "$BIT" == "S24_3LE" ]; then
      patch_xml -s $APLI '/audio_platform_info/bit_width_configs/device[@name="SND_DEVICE_OUT_HEADPHONES"]' 24
      patch_xml -u $APLI '/audio_platform_info/app_types/app[@mode="default"]' 'bit_width=24'
      patch_xml -u $APLI '/audio_platform_info/app_types/app[@mode="default"]' 'max_rate=192000'
      if [ ! "$P1" ] && [ ! "$P1XL" ] && [ ! "$P2XL" ] && [ ! "$P2" ] && [ ! "$PXL3XL" ]; then
        if [ ! "$(grep '<app_types>' $APLI)" ]; then
          sed -i "s/<\/audio_platform_info>/  <app_types><!--$MODID-->\n    <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"69936\" max_rate=\"192000\" \/><!--$MODID-->\n    <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"69940\" max_rate=\"192000\" \/><!--$MODID-->\n  <app_types><!--$MODID-->\n<\/audio_platform_info>/" $APLI        
        else
          for i in 69936 69940; do
            [ "$(xmlstarlet sel -t -m "/audio_platform_info/app_types/app[@uc_type=\"PCM_PLAYBACK\"][@mode=\"default\"][@id=\"$i\"]" -c . $APLI)" ] || sed -i "/<audio_platform_info>/,/<\/audio_platform_info>/ {/<app_types>/,/<\/app_types>/ s/\(^ *\)\(<\/app_types>\)/\1  <app uc_type=\"PCM_PLAYBACK\" mode=\"default\" bit_width=\"24\" id=\"$i\" max_rate=\"192000\" \/><!--$MODID-->\n\1\2/}" $APLI              
          done
        fi
      fi
    fi
  done

  if [ -f "$VNDKQ" ]; then
    ui_print "   Patching Q HAL config... "
    for OACONF in ${ACONF}; do
      ACONF="$MODPATH$(echo $OACONF | sed "s|^/vendor|/system/vendor|g")"
      cp_ch $ORIGDIR$OACONF $ACONF
      sed -i 's/\t/  /g' $ACONF
      if $ASP; then
        patch_xml -u $ACONF '/configs/flag[@name="audiosphere_enabled"]' "true"
      else
        patch_xml -u $ACONF '/configs/flag[@name="audiosphere_enabled"]' "false"
      fi
      # <flag name="custom_stereo_enabled" value="true" />
      patch_xml -u $ACONF '/configs/flag[@name="ext_qdsp_enabled"]' "true"
      patch_xml -u $ACONF '/configs/flag[@name="maxx_audio_enabled"]' "true"
      # patch_xml -u $ACONF '/configs/flag[@name="wsa_enabled"]' 'value="true"'
      # <flag name="spkr_prot_enabled" value="true" />
      patch_xml -u $ACONF '/configs/flag[@name="hifi_audio_enabled"]' "true"
      patch_xml -u $ACONF '/configs/flag[@name="kpi_optimize_enabled"]' "false"
      patch_xml -u $ACONF '/configs/flag[@name="usb_offload_enabled"]' "true"
    done
  fi
elif [ "$EXY" ]; then
  for OMIX in ${MIXS}; do
    MIX="$MODPATH$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$OMIX $MIX
    sed -i 's/\t/  /g' $MIX
    patch_xml -s $MIX '/mixer/ctl[@name="Output Ramp Up"]' "0ms/6dB"
    patch_xml -s $MIX '/mixer/ctl[@name="Output Ramp Down"]' "0ms/6dB"
    patch_xml -s $MIX '/mixer/ctl[@name="Virtual Bass Boost"]' "Off"
    patch_xml -s $MIX '/mixer/ctl[@name="Speaker Gain"]' "25"
    if [ "$ESMPL" ]; then
      patch_xml -s $MIX '/mixer/ctl[@name="Sample Rate 2"]' "$ESMPL"
      patch_xml -s $MIX '/mixer/ctl[@name="Sample Rate 3"]' "$ESMPL"
      patch_xml -s $MIX '/mixer/ctl[@name="ASYNC Sample Rate 2"]' "$ESMPL"
    fi
  done
  for OSAPA in ${SAPA}; do
    SAP="$MODPATH$(echo $OSAPA | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$SAP $SAP
    sed -i 's/\t/  /g' $SAP
    patch_xml -s $SAP '/feed/feature[@name="support_powersaving_mode"]' "false"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_48000"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_44100"]' "false"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_96000"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_192000"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_352000"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_samplerate_384000"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_low_latency"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_mid_latency"]' "false"
    patch_xml -s $SAP '/feed/feature[@name="support_high_latency"]' "false"
    patch_xml -s $SAP '/feed/feature[@name="support_playback_device"]' "true"
    patch_xml -s $SAP '/feed/feature[@name="support_boost_mode"]' "true"
  done
  for GMIX in ${MIXG}; do
    GAIN="$MODPATH$(echo $GMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$GAIN $GAIN
    sed -i 's/\t/  /g' $GAIN
    patch_xml -s $GAIN '/mixer/ctl[@name="HPOUT2L Impedance Volume"]' "117"
    patch_xml -s $GAIN '/mixer/ctl[@name="HPOUT2R Impedance Volume"]' "117"
  done
elif [ "$MTK" ]; then
  for OMIX in ${MIXA}; do
    MIX="$MODPATH$(echo $OMIX | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$OMIX $MIX
    sed -i 's/\t/  /g' $MIX
    if [ "$MIMPEDANCE" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Audio HP Impedance"]' "$MIMPEDANCE"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Audio HP Impedance Setting"]' "$MIMPEDANCE"
    fi
    if [ "$MHPF" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="DAC HPF Switch"]' "$MHPF"
    fi
    if [ "$MGAIN" ]; then
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Headset_PGAL_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Headset_PGAR_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Lineout_PGAR_GAIN"]' "$MGAIN"
      patch_xml -s $MIX '/mixercontrol/kctl[@name="Lineout_PGAL_GAIN"]' "$MGAIN"
    fi
  done
fi
ui_print "   ! Mixer edits & patches by Ultram8 !"

# LG DTS Tuning by JohnFawkes
if [ "$LG" ] && [ -f "$AET" ]; then
  ui_print "   Patching DTS Tune XML... "
  for OTUNE in ${TUNES}; do
    TUNE="$MODPATH$(echo $OTUNE | sed "s|^/vendor|/system/vendor|g")"
    cp_ch $ORIGDIR$OTUNE $TUNE
    sed -i 's/\t/  /g' $TUNE
    # Absolute value: default LL preset is Light mode 0, other values can be 1 for Medium and 2 for Aggressive -DEFAULT(0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_LL_PRESET"]' "Gain=2"
    # Additive value: default LL target gain is -14dB, LL_TARGET_GAIN is additive so if we put -3.0 here final value will be -17.0 -->-DEFAULT 0 (SPK) DEFAULT-(HEADSET 3.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_LL_TARGET_GAIN_SPK"]' "Gain=0.0"
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_LL_TARGET_GAIN_HEADSET"]' "Gain=3.0"
    # Additive value: default VS gain is +1dB, VS_GAIN is additive so if we put -3.0 here final value will be -2.0--> -DEFAULT (SPK 0) (HEADSET 0.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VS_GAIN_SPK"]' "Gain=0.0"
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VS_GAIN_HEADSET"]' "Gain=3.0"
    # CE safety -->
    # Absolute value: dBSPL when device master volume is set to default level, Range 0 - 100 --> -DEAFULT (76.8)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VOL_DEF_SPL"]' "Gain=100"
    # Absolute value: dBFS master volume level for this model, corresponding to DTS_VOL_DEF_SPL, Range -96 to 0 -->-DEFAULT(-17.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VOL_DEF_DB"]' "Gain=-10.0"
    # Absolute value: Level at which limits should begin to be imposed, Range 0 - 100 -->-DEFAULT(79.3)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_SPL_THRESH"]' "Gain=80.2"
    # Absolute value: Maximum desired output level, Range 0 - 100 -->-DEFAULT(96.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_SPL_LIMIT"]' "Gain=100"
    # Absolute value: The graphic EQ will self normalize by this ratio and indicate how much level is not being accounted for through its own normalization Range 0.0 to 1.0 -->-DEFAULT(0.5)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_GEQ_RATIO"]' "Gain=1.0"
    # Absolute value: Geq power factor for energy impact calculation -->-DEFAULT(20.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_GEQ_POWER"]' "Gain=25.0"
    # Absolute value: Required dB compensation when user Bass Enhancement slider position is set to min 0 -->-DEFAULT(0.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_BE_RANGE_DB_MIN"]' "Gain=0.0"
    # Absolute value: Required dB compensation when user Bass Enhancement slider position is set to max 100 -->-DEFAULT(10.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_BE_RANGE_DB_MAX"]' "Gain=15.0"
    # Absolute value: Required dB compensation when user Dialog Enhancement slider position is set to min 0 -->-DEFAULT(0.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_DE_RANGE_DB_MIN"]' "Gain=0.0"
    # Absolute value: Required dB compensation when user Dialog Enhancement slider position is set to max 100 -->-DEFAULT(8.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_DE_RANGE_DB_MAX"]' "Gain=10.0"
    # Absolute value: Required dB compensation when Virtualizer selection is set to Off -->-DEFAULT(0.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VIRT_RANGE_DB_VAL0"]' "Gain=0.0"
    # Absolute value: Required dB compensation when Virtualizer selection is set to Wide -->-DEFAULT(2.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VIRT_RANGE_DB_VAL1"]' "Gain=5.0"
    # Absolute value: Required dB compensation when Virtualizer selection is set to Front -->-DEFAULT(1.25)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VIRT_RANGE_DB_VAL2"]' "Gain=2.0"
    # Absolute value: Required dB compensation when Virtualizer selection is set to S2S -->-DEFAULT(2.0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VIRT_RANGE_DB_VAL3"]' "Gain=4.0"
    # Absolute value: 0 selects New CE safety algo. 1 selects Legacy CE safety algo. Default CE safety preset is 0 -->-DEFAULT(0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_CE_SAFETY_PRESET"]' "Gain=1"
    # Absolute value: 0 disables VS for speaker route. 1 enables VS for speaker route. Default is 0 which disables VS for speaker -->-DEFAULT(0)
    patch_xml -u $TUNE '/config/DTS-GAIN[@Type="DTS_VS_ON_SPEAKER"]' "Gain=0"
  done
fi

for i in "AP" "OAP" "BIT"; do
  sed -i "2i $i=$(eval echo \$$i)" $MODPATH/.aml.sh
done
sed -i "2i KEEPLIBS=\"$KEEPLIBS\"" $MODPATH/.aml.sh
