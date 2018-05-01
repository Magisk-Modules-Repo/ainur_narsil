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
# 3. Configure the settings in this file (common/config.sh)
# 4. For advanced features, add shell commands into the script files under common:
#    post-fs-data.sh, service.sh
# 5. For changing props, add your additional/modified props into common/system.prop
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
# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maxium android version for your mod (note that magisk has it's own minimum api: 21 (lollipop))
# Uncomment DYNAMICOREO if you want libs installed to vendor for oreo and newer and system for anything older
# Uncomment DYNAMICAPP if you want anything in $INSTALLER/system/app to be installed to the optimal app directory (/system/priv-app if it exists, /system/app otherwise)
# Uncomment SYSOVERRIDE if you want the mod to always be installed to system (even on magisk)
#MINAPI=21
#MAXAPI=25
#SYSOVERRIDE=true
DYNAMICOREO=true
#DYNAMICAPP=true

# Custom Variables - Keep everything within this function
unity_custom() {
  if $MAGISK && $BOOTMODE; then ORIGDIR="/sbin/.core/mirror"; else ORIGDIR=""; fi
  if $BOOTMODE; then
    CFGS="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
    MIXS="$(find /system /vendor -type f -name "*mixer_paths*.xml")"
  else
    CFGS="$(find -L /system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
    MIXS="$(find -L /system -type f -name "*mixer_paths*.xml")"
  fi
  if [ -f $VEN/build.prop ]; then BUILDS="/system/build.prop $VEN/build.prop"; else BUILDS="/system/build.prop"; fi
  SAU=$INSTALLER/custom
  MAIAR=$SAU/manwe/maiar
  VALAR=$SAU/manwe/valar
  NAZ=$SAU/nazgul
  MORG=$SAU/morgoth
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
  HWDTS=/dsp/DTS_HPX_MODULE.so.1
  DTS=/data/misc/dts
  TREBLE=$(grep "ro.treble.enabled=true" $BUILDS)
  NEXUS=$(grep "ro.product.device=bullhead|ro.product.device=angler" $BUILDS)
  MTK=$(grep "ro.mediatek.version.*" $BUILDS)
  QCP=$(grep -E "ro.board.platform=apq.*|ro.board.platform=msm.*" $BUILDS)
  EXY=$(grep "ro.chipname.*" $BUILDS)
  QC94=$(grep "ro.board.platform=msm8994" $BUILDS)
  KIR=$(grep "ro.board.platform=hi.*|ro.board.platform=kirin*" $BUILDS)
  SPEC=$(grep "ro.board.platform=sp.*" $BUILDS)
  MIUI=$(grep "ro.miui.ui.version.*" $BUILDS)
  QC8996=$(grep "ro.board.platform=msm8996" $BUILDS)
  QC8998=$(grep "ro.board.platform=msm8998" $BUILDS)
  TMSM=$(grep "ro.board.platform=msm" $BUILDS | sed 's/^.*=msm//')
  QCNEW=false
  [ ! -z $TMSM ] && { [ $TMSM -ge 8996 ] && QCNEW=true; }
  M9=$(grep "ro.aa.modelid=0PJA.*" $BUILDS)
  BOLT=$(grep "ro.aa.modelid=2PYB.*" $BUILDS)
  M10=$(grep "ro.aa.modelid=2PS6.*" $BUILDS)
  U11P=$(grep "ro.aa.modelid=2Q4D.*" $BUILDS)
  M8=$(grep "ro.aa.modelid=0P6B.*" $BUILDS)
  AX7=$(grep -E "ro.build.product=axon7|ro.build.product=ailsa_ii" $BUILDS)
  V20=$(grep "ro.product.device=elsa" $BUILDS)
  V30=$(grep "ro.product.device=joan" $BUILDS)
  G6=$(grep "ro.product.device=lucye" $BUILDS)
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
  NX9=$(grep -E "ro.product.name=volantis.*|ro.product.board=flounder.*" $BUILDS)
  OP3=$(grep -E "ro.build.product=OnePlus3.*|ro.build.product=oneplus3.*|ro.vendor.product.device=oneplus3.*|ro.vendor.product.device=OnePlus3.*" $BUILDS)
  X5P=$(grep -E "ro.product.name=vince.*|ro.product.device=vince.*" $BUILDS)
  [ "$QCP" ] && DSPBLOCK=$(find /dev/block -iname dsp | head -n 1)
  if [ -z $DSPBLOCK ]; then
    ADSP=$VEN/lib/rfsa/adsp
    ADSP2=$UNITY$ADSP
  else
    ADSP=/dsp
    ADSP2=$ADSP
    mkdir /dsp
    if is_mounted /dsp; then mount -o remount,rw /dsp; else mount -o rw $DSPBLOCK /dsp; fi
    is_mounted /dsp || abort "! Cannot mount /dsp"
  fi
}
get_uo() {
  [ "$2" != "NONBOOL" ] && FAL=false
  eval "$1=$(grep_prop "$1" $AUO)"
  eval "$1=$FAL"
  case $(eval echo \$$1) in
    16) [ "$1" == "BIT" ] && BIT=S16_LE;;
    24) [ "$1" == "BIT" ] && BIT=S24_LE;;
    32) [ "$1" == "BIT" ] && $QCNEW && BIT=S32_LE;;
    "true"|"True"|"TRUE") [ "$2" != "NONBOOL" ] && eval "$1=true";;
  esac
}
read_uo() {
  if [ "$1" == "-u" ]; then
    for UO in "FMAS" "ASP" "SHB" "RPCM" "APTX" "COMP" "RESAMPLE" "BTRESAMPLE" "IMPEDANCE" "BIT"; do
      eval "$UO=$(grep_prop "$UO" $AUO)"
    done
  else
    get_uo "FMAS"
    if [ "$QCP" ]; then
      for UO in "ASP" "SHB" "RPCM" "APTX" "COMP"; do
        get_uo "$UO"
      done
      for UO in "RESAMPLE" "BTRESAMPLE" "IMPEDANCE" "BIT"; do
        get_uo "$UO" "NONBOOL"
      done
    else
      for UO in "ASP" "SHB" "RPCM" "APTX" "COMP"; do
        eval "$UO=false"
      done
    fi
  fi
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
  ui_print "              James34602, LazerL0rd            "
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
    cp_ch_nb $INSTALLER/common/sauron.sh $MOUNTPATH/.core/post-fs-data.d/sauron.sh 0755
    cp_ch_nb $INFO $MOUNTPATH/.core/post-fs-data.d/sauron-files
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
  $MAGISK && set_perm_recursive $UNITY$SYS/bin 0 0 0755 0777

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm $UNITY$SYS/lib/libart.so 0 0 0644
}
