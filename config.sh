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
# Uncomment DYNAMICOREO if you want apps and libs installed to vendor for oreo and newer and system for anything older
#MINAPI=21
#MAXAPI=25
DYNAMICOREO=true

# Custom Variables - Keep everything within this function
unity_custom() {
  if $MAGISK && $BOOTMODE; then ORIGDIR="/sbin/.core/mirror"; else ORIGDIR=""; fi
  if $BOOTMODE; then
    CFGS="$(find /system /vendor -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" | sed "s|^/vendor|/system/vendor|g")"
    POLS="$(find /system /vendor -type f -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml" | sed "s|^/vendor|/system/vendor|g")"
    MIXS="$(find /system /vendor -type f -name "*mixer_paths*.xml" | sed "s|^/vendor|/system/vendor|g")"
  else  
    CFGS="$(find -L /system -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml")"
    POLS="$(find -L /system -type f -name "*audio_*policy*.conf" -o -name "*audio_*policy*.xml")"
    MIXS="$(find -L /system -type f -name "*mixer_paths*.xml")"
  fi
  SAU=$INSTALLER/custom
  MAIAR=$SAU/manwe/maiar
  VALAR=$SAU/manwe/valar
  NAZ=$SAU/nazgul
  MORG=$SAU/morgoth
  ETC=$SYS/etc
  BIN=$SYS/bin
  XBIN=$SYS/xbin
  if [ $API -ge 26 ]; then
    LIB=$SYS/vendor/lib
    LIB64=$SYS/vendor/lib64
  else
    LIB=$SYS/lib
    LIB64=$SYS/lib64
  fi
  SFX=$LIB/soundfx
  SFX64=$LIB64/soundfx
  VLIB=$SYS/vendor/lib
  VLIB64=$SYS/vendor/lib64
  VSFX=$VLIB/soundfx
  VSFX64=$VLIB64/soundfx
  VETC=$SYS/vendor/etc
  HW=$LIB/hw
  ACDB=$ETC/acdbdata
  AMPA=$ETC/TAS2557_A.ftcfg
  HWDTS=/dsp/DTS_HPX_MODULE.so.1
  DTS=/data/misc/dts
  MTK=$(grep "ro.mediatek.version*" $SYS/build.prop)
  QCP=$(grep -E "ro.board.platform=apq*|ro.board.platform=msm*" $SYS/build.prop)
  EXY=$(grep "ro.chipname*" $SYS/build.prop)
  QC94=$(grep "ro.board.platform=msm8994" $SYS/build.prop)
  KIR=$(grep "ro.board.platform=hi*" $SYS/build.prop)
  SPEC=$(grep "ro.board.platform=sp*" $SYS/build.prop)
  MIUI=$(grep "ro.miui.ui.version*" $SYS/build.prop)
  QC8994=$(grep "ro.board.platform=msm8994" $SYS/build.prop)
  QC8996=$(grep "ro.board.platform=msm8996" $SYS/build.prop)
  QC8998=$(grep "ro.board.platform=msm8998" $SYS/build.prop)
  TMSM=$(grep "ro.board.platform=msm" $SYS/build.prop | sed 's/^.*=msm//')
  if [ ! -z $TMSM ]; then 
    if [ $TMSM -ge 8996 ]; then QCNEW=true; QCOLD=false; else QCNEW=false; QCOLD=true; fi; 
  else 
    QCNEW=false; QCOLD=true
  fi
  M9=$(grep "ro.aa.modelid=0PJA*" $SYS/build.prop)
  BOLT=$(grep "ro.aa.modelid=2PYB*" $SYS/build.prop)
  M10=$(grep "ro.aa.modelid=2PS6*" $SYS/build.prop)
  U11P=$(grep "ro.aa.modelid=2Q4D*" $SYS/build.prop)
  M8=$(grep "ro.aa.modelid=0P6B*" $SYS/build.prop)
  AX7=$(grep -E "ro.build.product=axon7|ro.build.product=ailsa_ii" $SYS/build.prop)
  V20=$(grep "ro.product.device=elsa" $SYS/build.prop)
  V30=$(grep "ro.product.device=joan" $SYS/build.prop)
  G6=$(grep "ro.product.device=lucye" $SYS/build.prop)
  Z9=$(grep "ro.product.model=NX508J" $SYS/build.prop)
  Z9M=$(grep -E "ro.product.model=NX510J|ro.product.model=NX518J" $SYS/build.prop)
  Z11=$(grep "ro.product.model=NX531J" $SYS/build.prop)
  LX3=$(grep -E "ro.build.product=X3c50|ro.build.product=X3c70|ro.build.product=x3_row" $SYS/build.prop)
  OP5=$(grep -E "ro.build.product=OnePlus5|ro.build.product=OnePlus5T" $SYS/build.prop)
  X9=$(grep "ro.product.model=X900*" $SYS/build.prop)
  P2XL=$(grep "ro.product.vendor.name=taimen|ro.product.vendor.device=taimen" $SYS/build.prop)
  P2=$(grep "ro.product.vendor.device=walleye|ro.product.vendor.name=walleye" $SYS/build.prop)
  P1XL=$(grep "ro.product.vendor.device=marlin|ro.product.vendor.name=marlin" $SYS/build.prop)
  P1=$(grep "ro.product.vendor.device=sailfish|ro.product.vendor.name=sailfish" $SYS/build.prop)
  NX9=$(grep "ro.product.name=volantis*|ro.product.board=flounder*" $SYS/build.prop)
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
  eval "$1=$(grep_prop "$2" $AUO)"
  if [ -z $(eval echo \$$1) ]; then
    eval "$1=false"
  else
    case $(eval echo \$$1) in
      "true"|"True"|"TRUE") eval "$1=true";;
      *) eval "$1=false";;
    esac
  fi
  if [ ! -z $3 ]; then
    test -z \$$3 && eval "$1=false"
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
  ui_print "                    M K II.II                  " 
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
