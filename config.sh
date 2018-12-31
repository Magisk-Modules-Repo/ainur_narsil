##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Defines
##########################################################################################

# NOTE: This part has to be adjusted to fit your own needs

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

# Unity Variables
# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maxium android version for your mod (note that unity's minapi is 21 (lollipop) due to bash and magisk binaries)
# Uncomment SEPOLICY if you have sepolicy patches in common/sepolicy.sh. Unity will take care of the rest
# Uncomment DYNAMICOREO if you want libs installed to vendor for oreo and newer and system for anything older
# Uncomment DYNAMICAPP if you want anything in $INSTALLER/system/app to be installed to the optimal app directory (/system/priv-app if it exists, /system/app otherwise)
# Uncomment SYSOVERRIDE if you want the mod to always be installed to system (even on magisk)
# Uncomment RAMDISK if you have ramdisk modifications. If you only want ramdisk patching as part of a conditional, just keep this commented out and set RAMDISK=true in that conditional.
# Uncomment DEBUG if you want full debug logs (saved to SDCARD if in twrp, part of regular log if in magisk manager (user will need to save log after flashing)
#MINAPI=21
#MAXAPI=25
SEPOLICY=true
#SYSOVERRIDE=true
DYNAMICOREO=true
#DYNAMICAPP=true
#RAMDISK=true
DEBUG=true

# Custom Variables - Keep everything within this function
unity_custom() {
  # Setup xmlstarlet and add to path
  tar -xf $INSTALLER/common/xmlstarlet.tar.xz -C $INSTALLER/common 2>/dev/null
  chmod -R 755 $INSTALLER/common/xmlstarlet/$ARCH32
  echo $PATH | grep -q "^$INSTALLER/common/xmlstarlet/$ARCH32" || export PATH=$INSTALLER/common/xmlstarlet/$ARCH32:$PATH
  #
  if $BOOTMODE; then SDCARD=/storage/emulated/0; else SDCARD=/data/media/0; fi
  if [ -f $VEN/build.prop ]; then BUILDS="/system/build.prop $VEN/build.prop"; else BUILDS="/system/build.prop"; fi
  SAU=$INSTALLER/custom
  BAR=$SAU/barad-dur
  CIRU=$SAU/cirith-ungol
  TORU=$SAU/cirith-ungol/torech-ungol
  MOR=$SAU/morgul
  GOR=$SAU/gorgoroth
  CAR=$SAU/carach-angren
  ETC=$SYS/etc
  VETC=$SYS/vendor/etc
  BIN=$SYS/bin
  XBIN=$SYS/xbin
  if [ $API -ge 26 ]; then
    LIB=$SYS/vendor/lib
    LIB64=$SYS/vendor/lib64
    ACDB=$VETC/acdbdata
    AMPA=$VETC/TAS2557_A.ftcfg
  else
    LIB=$SYS/lib
    LIB64=$SYS/lib64
    ACDB=$ETC/acdbdata
    AMPA=$ETC/TAS2557_A.ftcfg
  fi
  SFX=$LIB/soundfx
  SFX64=$LIB64/soundfx
  VLIB=$SYS/vendor/lib
  VLIB64=$SYS/vendor/lib64
  VSFX=$VLIB/soundfx
  VSFX64=$VLIB64/soundfx
  HW=$LIB/hw
  HWDTS=$ADSP/DTS_HPX_MODULE.so.1
  DTS=/data/misc/dts
  if [ -d "/system/lib/modules" ]; then
    MODU=$INSTALLER/system/lib
  else
    MODU=$INSTALLER/system/vendor/lib
  fi
  #HTC=$(grep "????" $BUILDS)
  MTK=$(grep -E "ro.mediatek.version.*|ro.hardware=mt*" $BUILDS)
  EXY=$(grep -E "ro.chipname=exynos*|ro.board.platform=exynos*" $BUILDS)
  KIR=$(grep -E "ro.board.platform=hi.*|ro.board.platform=kirin*" $BUILDS)
  KIR970=$(grep "ro.board.platform=kirin970" $BUILDS)
  #SONY additions by Laster K.
  SONY=$(grep "ro.semc.*" $BUILDS)
  SPEC=$(grep "ro.board.platform=sp.*" $BUILDS)
  MIUI=$(grep "ro.miui.ui.version.*|ro.product.brand=Xiaomi*" $BUILDS)
  QC94=$(grep "ro.board.platform=msm8994" $BUILDS)
  QCP=$(grep -E "ro.board.platform=apq.*|ro.board.platform=msm.*|ro.board.platform=sdm.*" $BUILDS)
  QC8996=$(grep "ro.board.platform=msm8996" $BUILDS)
  QC8998=$(grep "ro.board.platform=msm8998" $BUILDS)
  SD625=$(grep "ro.board.platform=msm8953" $BUILDS)
  SD650=$(grep "ro.board.platform=msm8952" $BUILDS)
  SD845=$(grep "ro.board.platform=sdm845" $BUILDS)
  SD660=$(grep "ro.board.platform=sdm660" $BUILDS)
  SD670=$(grep "ro.board.platform=sdm670" $BUILDS)
  SD710=$(grep "ro.board.platform=sdm710" $BUILDS)
  TMSM=$(grep "ro.board.platform=msm" $BUILDS | sed 's/^.*=msm//')
  if [ "$QC8996" ] || [ "$QC8998" ] || [ "$SD650" ] || [ "$SD625" ] || [ "$SD660" ] || [ "$SD670" ] || [ "$SD710" ] || [ "$SD845" ]; then QCNEW=true; else QCNEW=false; fi
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
  P2XL=$(grep -E "ro.vendor.product.name=taimen|ro.vendor.product.device=taimen" $BUILDS)
  P2=$(grep -E "ro.vendor.product.device=walleye|ro.vendor.product.name=walleye" $BUILDS)
  P1XL=$(grep -E "ro.vendor.product.device=marlin|ro.vendor.product.name=marlin" $BUILDS)
  P1=$(grep -E "ro.vendor.product.device=sailfish|ro.vendor.product.name=sailfish" $BUILDS)
  PXL3XL=$(grep -E "ro.vendor.product.device=crosshatch|ro.vendor.product.name=crosshatch" $BUILDS)
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
  if $BOOTMODE; then
    CFGS="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
    MIXS="$(find /system /vendor -type f -name "*mixer_paths*.xml")"
    POLS="$(find /system /vendor -type f -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml")"
    SAPA="$(find /system /vendor -type f -name "*sapa_feature*.xml")"
    MIXG="$(find /system /vendor -type f -name "*mixer_gains*.xml")"
    MIXA="$(find /system /vendor -type f -name "*audio_device*.xml")"
    MODA="$(find /system /vendor -type f -name "modules.alias")"
    MODD="$(find /system /vendor -type f -name "modules.dep")"
    APLIS="$(find /system /vendor -type f -name "*audio_platform_info*.xml")"
  else
    CFGS="$(find -L /system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
    MIXS="$(find -L /system -type f -name "*mixer_paths*.xml")"
    POLS="$(find -L /system -type f -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml")"
    SAPA="$(find -L /system -type f -name "*sapa_feature*.xml")"
    MIXG="$(find -L /system -type f -name "*mixer_gains*.xml")"
    MIXA="$(find -L /system -type f -name "*audio_device*.xml")"
    MODA="$(find -L /system -type f -name "modules.alias")"
    MODD="$(find -L /system -type f -name "modules.dep")"
    APLIS="$(find -L /system -type f -name "*audio_platform_info*.xml")"
  fi
  [ "$QCP" ] && DSPBLOCK=$(find /dev/block -iname dsp | head -n 1)
  if [ -z $DSPBLOCK ]; then
    if [ "$POC" ]; then ADSP=$VEN/dsp/adsp; else ADSP=$VEN/lib/rfsa/adsp; fi
    ADSP2=$UNITY$ADSP
  else
    ADSP=/dsp
    ADSP2=$ADSP
    mkdir /dsp
    if is_mounted /dsp; then mount -o remount,rw /dsp; else mount -o rw $DSPBLOCK /dsp; fi
    is_mounted /dsp || abort "! Cannot mount /dsp"
  fi
  # Patch ramdisk if KIR
  [ "$KIR" ] && RAMDISK=true
}
get_uo() {
  case "$1" in
    "-u") cat $AUO | sed 's/\r$//g' | tr '\r' '\n' > $AUO.tmp; mv -f $AUO.tmp $AUO
          for UO in $(grep "^[A-Za-z_]*=" $AUO | sed -e 's/=.*//g' -e 's/Version//g'); do
            eval "$UO=$(grep_prop "$UO" $AUO)"
            sed -i "s|^$UO=|$UO=$(eval echo \$$UO)|" $INSTALLER/sauron_useroptions
          done
          cp -f $INSTALLER/sauron_useroptions $AUO;;
    *) local UOS="$(sed -rn '/UNIVERSAL OPTIONS/,/\+=+/ {/^[A-Za-z_]*=/p}' $AUO | sed 's/=[^ ]*//g')"
       [ "$QCP" ] && UOS="$UOS $(sed -rn '/QUALCOMM ONLY OPTIONS/,/\+=+/ {/^[A-Za-z_]*=/p}' $AUO | sed 's/=[^ ]*//g')"
       [ "$EXY" ] && UOS="$UOS $(sed -rn '/EXYNOS OPTIONS/,/\+=+/ {/^[A-Za-z_]*=/p}' $AUO | sed 's/=[^ ]*//g')"
       [ "$MTK" ] && UOS="$UOS $(sed -rn '/MTK OPTIONS/,/\+=+/ {/^[A-Za-z_]*=/p}' $AUO | sed 's/=[^ ]*//g')"
       for UO in ${UOS}; do
         case $UO in
          "N_"*) UO=$(echo $UO | sed 's/^N_//')
                 eval "$UO=$(grep_prop "N_$UO" $AUO)"
                 if [ "$UO" == "BIT" ]; then
                   case $(eval echo \$$UO) in
                     16) BIT=S16_LE;;
                     24) BIT=S24_3LE; echo 'persist.vendor.audio_hal.dsp_bit_width_enforce_mode=1' >> $INSTALLER/common/system.prop; patch_xml -s $APLI '/audio_platform_info/bit_width_configs/device[@name="SND_DEVICE_OUT_HEADPHONES"]' 24;;
                     32) if $QCNEW; then BIT=S32_LE; echo 'persist.vendor.audio_hal.dsp_bit_width_enforce_mode=1' >> $INSTALLER/common/system.prop; else eval "$UO="; fi;;
                     *) eval "$UO=";;
                   esac
                 elif [ "$UO" == "BTSMPL" ]; then
                   [ $API -ge 26 ] || $QCNEW || break
                   case $(eval echo \$$UO) in
                     44.1) echo 'persist.vendor.bt.soc.scram_freqs=441.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=441' >> $INSTALLER/common/system.prop;;
                     48) echo 'persist.vendor.bt.soc.scram_freqs=48.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=48' >> $INSTALLER/common/system.prop;;
                     88.2) echo 'persist.vendor.bt.soc.scram_freqs=882.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=882' >> $INSTALLER/common/system.prop;;
                     96) echo 'persist.vendor.bt.soc.scram_freqs=96.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=96' >> $INSTALLER/common/system.prop;;
                     176.4) echo 'persist.vendor.bt.soc.scram_freqs=1764.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=1764' >> $INSTALLER/common/system.prop;;
                     192) echo 'persist.vendor.bt.soc.scram_freqs=192.' >> $INSTALLER/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=192' >> $INSTALLER/common/system.prop;; 
                     *) eval "$UO=";;
                   esac
                 fi;;
          *) eval "$UO=$(grep_prop "$UO" $AUO)"
             case $(eval echo \$$UO) in
               "true"|"True"|"TRUE") eval "$UO=true";;
               "on"|"On"|"ON") eval "$UO=true";;
               *) eval "$UO=false";;
             esac
         esac
       done;;
  esac
}

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print " "
  ui_print "                                               "
  ui_print "                    A I N U R                  "
  ui_print "                   S A U R O N                 "
  ui_print "    <version>"
  ui_print "                                               "
  ui_print "          by: UltraM8, Zackptg5, Ahrion,       "
  ui_print "                James34602, Laster K.,         "
  ui_print "                 John Fawkes, Michi            "
  ui_print "                                               "
  ui_print " "
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# By default Magisk will merge your files with the original system
# Directories listed here however, will be directly mounted to the correspond directory in the system

# You don't need to remove the example below, these values will be overwritten by your own list
# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will overwrite the example
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

# NOTE: This part has to be adjusted to fit your own needs

set_permissions() {
  # Add data/dsp fallback removal script
  if $MAGISK && [ -f "$INFO" ]; then
    if [ "$DSPBLOCK" ]; then sed -i "s|<DSPBLOCK>|$DSPBLOCK|" $INSTALLER/common/sauron.sh; else sed -i 's|<DSPBLOCK>|""|' $INSTALLER/common/sauron.sh; fi
    cp_ch -np 0755 $INSTALLER/common/sauron.sh $MOUNTPATH/.core/post-fs-data.d/sauron.sh
    cp_ch -n $INFO $MOUNTPATH/.core/post-fs-data.d/sauron-files
  fi

  # Unmount dsp partition if applicable
  if [ "$DSPBLOCK" ]; then
    if $BOOTMODE; then mount -o remount,ro /dsp; else umount -l /dsp 2>/dev/null; rm -rf /dsp; fi
  fi

  # DEFAULT PERMISSIONS, DON'T REMOVE THEM
  $MAGISK && set_perm_recursive $MODPATH 0 0 0755 0644

  # CUSTOM PERMISSIONS

  # Some templates if you have no idea what to do:
  # Note that all files/folders have the $UNITY prefix - keep this prefix on all of your files/folders
  # Also note the lack of '/' between variables - preceding slashes are already included in the variables
  # Use $SYS for system and $VEN for vendor (Do not use $SYS$VEN, the $VEN is set to proper vendor path already - could be /vendor, /system/vendor, etc.)

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive $UNITY$SYS/lib 0 0 0755 0644
  # set_perm_recursive $UNITY$VEN/lib/soundfx 0 0 0755 0644
  if $MAGISK && ! $SYSOVERRIDE; then
    set_perm_recursive $UNITY$BIN 0 2000 0755 0777
  else
    set_perm $UNITY$BIN/xmlstarlet 0 2000 0755
    set_perm $UNITY$BIN/tinymix 0 2000 0755
    [ -f "$UNITY$BIN/ti_audio_s" ] && set_perm $UNITY$BIN/ti_audio_s 0 2000 0755
  fi
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm $UNITY$SYS/lib/libart.so 0 0 0644
  
  if $DEBUG; then
    echo "---Variables---" > $SDCARD/$MODID-debug-formatted.log
    ( set -o posix ; set ) >> $SDCARD/$MODID-debug-formatted.log
    echo -e "\n---Installed Files---" >> $SDCARD/$MODID-debug-formatted.log
    grep "^+* cp_ch" $SDCARD/$MODID-debug.log | sed 's/.* //g' >> $SDCARD/$MODID-debug-formatted.log
    echo -e "\n---Applied Mixer Patches---" >> $SDCARD/$MODID-debug-formatted.log
    grep "^+* patch_xml" $SDCARD/$MODID-debug.log | sed 's/^+* //g' >> $SDCARD/$MODID-debug-formatted.log
    echo -e "\n---Installed Prop Files---" >> $SDCARD/$MODID-debug-formatted.log
    grep "^+* prop_process" $SDCARD/$MODID-debug.log | sed 's/.* //g' >> $SDCARD/$MODID-debug-formatted.log
    $MAGISK && echo -e "\n---Magisk Version---\n$MAGISK_VER_CODE" >> $SDCARD/$MODID-debug-formatted.log    
  fi
}
