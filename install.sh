##########################################################################################
#
# Unity Config Script
# by topjohnwu, modified by Zackptg5
#
##########################################################################################

##########################################################################################
# Unity Logic - Don't change/move this section
##########################################################################################

if [ -z $UF ]; then
  UF=$TMPDIR/common/unityfiles
  unzip -oq "$ZIPFILE" 'common/unityfiles/util_functions.sh' -d $TMPDIR >&2
  [ -f "$UF/util_functions.sh" ] || { ui_print "! Unable to extract zip file !"; exit 1; }
  . $UF/util_functions.sh
fi

comp_check

##########################################################################################
# Config Flags
##########################################################################################

# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maximum android version for your mod
# Uncomment DYNLIB if you want libs installed to vendor for oreo+ and system for anything older
# Uncomment SYSOVER if you want the mod to always be installed to system (even on magisk) - note that this can still be set to true by the user by adding 'sysover' to the zipname
# Uncomment DIRSEPOL if you want sepolicy patches applied to the boot img directly (not recommended) - THIS REQUIRES THE RAMDISK PATCHER ADDON (this addon requires minimum api of 17)
# Uncomment DEBUG if you want full debug logs (saved to /sdcard in magisk manager and the zip directory in twrp) - note that this can still be set to true by the user by adding 'debug' to the zipname
#MINAPI=21
#MAXAPI=25
DYNLIB=true
#SYSOVER=true
#DIRSEPOL=true
DEBUG=true

# Uncomment if you do *NOT* want Magisk to mount any files for you. Most modules would NOT want to set this flag to true
# This is obviously irrelevant for system installs. This will be set to true automatically if your module has no files in system
#SKIPMOUNT=true

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Custom Logic
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print " "
  ui_print "                                               "
  ui_print "                    A I N U R                  "
  ui_print "                   S A U R O N                 "
  ui_print "                      MK III                   "
  ui_print "                                               "
  ui_print "          by: UltraM8, Zackptg5, Ahrion,       "
  ui_print "                James34602, Laster K.,         "
  ui_print "                 John Fawkes, Michi            "
  ui_print "                                               "
  ui_print " "
  unity_main # Don't change this line
}

set_permissions() {
  # Add data/dsp fallback removal script
  if $MAGISK && [ -f "$INFO" ]; then
    if [ "$DSPBLOCK" ]; then sed -i "s|<DSPBLOCK>|$DSPBLOCK|" $TMPDIR/common/sauron.sh; else sed -i 's|<DSPBLOCK>|""|' $TMPDIR/common/sauron.sh; fi
    cp_ch -n $TMPDIR/common/sauron.sh $NVBASE/post-fs-data.d/sauron.sh 0755
    cp_ch -n $INFO $NVBASE/post-fs-data.d/sauron-files
  fi

  # Unmount dsp partition if applicable
  if [ "$DSPBLOCK" ]; then
    if $BOOTMODE; then mount -o remount,ro /dsp; else umount -l /dsp 2>/dev/null; rm -rf /dsp; fi
  fi

  if $MAGISK && ! $SYSOVER; then
    set_perm_recursive $UNITY/system/bin 0 2000 0755 0777
  else
    set_perm $UNITY/system/bin/xmlstarlet 0 2000 0755
    set_perm $UNITY/system/bin/tinymix 0 2000 0755
    [ -f "$UNITY/system/bin/ti_audio_s" ] && set_perm $UNITY/system/bin/ti_audio_s 0 2000 0755
  fi

  # Note that all files/folders have the $UNITY prefix - keep this prefix on all of your files/folders
  # Also note the lack of '/' between variables - preceding slashes are already included in the variables
  # Use $VEN for vendor (Do not use /system$VEN, the $VEN is set to proper vendor path already - could be /vendor, /system/vendor, etc.)

  # Some examples:
  
  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm_recursive $UNITY/system/lib 0 0 0755 0644
  # set_perm_recursive $UNITY$VEN/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm $UNITY/system/lib/libart.so 0 0 0644
}

# Custom Variables for Install AND Uninstall - Keep everything within this function - runs before uninstall/install
unity_custom() {
  if [ -f "$(echo $MOD_VER | sed "s|$MODID|ainur_narsil|")" ]; then
    ui_print " "
    ui_print "! AINUR NARSIL detected!"
    abort "! Uninstall Narsil first with Narsil Zip!"
  fi
  if $BOOTMODE; then SDCARD=/storage/emulated/0; else SDCARD=/data/media/0; fi
  if [ -f $VEN/build.prop ]; then BUILDS="/system/build.prop $VEN/build.prop"; else BUILDS="/system/build.prop"; fi
  SAU=$TMPDIR/custom
  BAR=$SAU/barad-dur
  CIRU=$SAU/cirith-ungol
  TORU=$SAU/cirith-ungol/torech-ungol
  MOR=$SAU/morgul
  GOR=$SAU/gorgoroth
  CAR=$SAU/carach-angren
  ETC=$SYS/etc
  VETC=$SYS/vendor/etc
  AET=$VETC/audio_effects_tune.xml
  if [ $API -ge 26 ]; then
    LIB=$SYS/vendor/lib
    LIB64=$SYS/vendor/lib64
	#fix acdb for htc - they have it in /etc
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
    MODU=$TMPDIR/system/lib
  else
    MODU=$TMPDIR/system/vendor/lib
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
    TUNES="$(find /system /vendor -type f -name "*audio_effects_tune*.xml")"
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
    TUNES="$(find -L /system -type f -name "*audio_effects_tune*.xml")"
  fi
  VNDK=$(find /system/lib /vendor/lib -type d -iname "*vndk*")
  VNDK64=$(find /system/lib64 /vendor/lib64 -type d -iname "*vndk*")
  [ "$QCP" ] && DSPBLOCK=$(find /dev/block -iname dsp | head -n 1)
  if [ -z $DSPBLOCK ] || [ "$MI9" ]; then
    if [ "$POC" ]; then ADSP=$VEN/dsp/adsp; else ADSP=$VEN/lib/rfsa/adsp; fi
    ADSP2=$UNITY$ADSP
  else
    ADSP=/dsp
    ADSP2=$ADSP
    mkdir /dsp
    if is_mounted /dsp; then mount -o remount,rw /dsp; else mount_part dsp; fi
  fi
  # Patch ramdisk only if KIR
  [ "$KIR" ] || rm -rf $TMPDIR/addon/Ramdisk-Patcher
}

# Custom Functions for Install AND Uninstall - You can put them here
get_uo() {
  case "$1" in
    "-u") cat $AUO | sed 's/\r$//g' | tr '\r' '\n' > $AUO.tmp; mv -f $AUO.tmp $AUO
          for UO in $(grep "^[A-Za-z_]*=" $AUO | sed -e 's/=.*//g' -e 's/Version//g'); do
            eval "$UO=$(grep_prop "$UO" $AUO)"
            sed -i "s|^$UO=|$UO=$(eval echo \$$UO)|" $TMPDIR/sauron_useroptions
          done
          cp -f $TMPDIR/sauron_useroptions $AUO;;
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
                     24) BIT=S24_3LE; echo 'persist.audio.format.24bit=true' >> $TMPDIR/common/system.prop; echo 'audio.offload.pcm.24bit.enable=true' >> $TMPDIR/common/system.prop; echo 'persist.vendor.audio_hal.dsp_bit_width_enforce_mode=1' >> $TMPDIR/common/system.prop; patch_xml -s $APLI '/audio_platform_info/bit_width_configs/device[@name="SND_DEVICE_OUT_HEADPHONES"]' 24;;
                     32) if $QCNEW; then BIT=S32_LE; echo 'persist.vendor.audio_hal.dsp_bit_width_enforce_mode=1' >> $TMPDIR/common/system.prop; echo 'audio.offload.pcm.32bit.enable=true' >> $TMPDIR/common/system.prop; else eval "$UO="; fi;;
                     *) eval "$UO=";;
                   esac
                 elif [ "$UO" == "BTSMPL" ]; then
                   [ $API -ge 26 ] || $QCNEW || break
                   case $(eval echo \$$UO) in
                     44.1) echo 'persist.vendor.bt.soc.scram_freqs=441.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=441' >> $TMPDIR/common/system.prop;;
                     48) echo 'persist.vendor.bt.soc.scram_freqs=48.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=48' >> $TMPDIR/common/system.prop;;
                     88.2) echo 'persist.vendor.bt.soc.scram_freqs=882.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=882' >> $TMPDIR/common/system.prop;;
                     96) echo 'persist.vendor.bt.soc.scram_freqs=96.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=96' >> $TMPDIR/common/system.prop;;
                     176.4) echo 'persist.vendor.bt.soc.scram_freqs=1764.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=1764' >> $TMPDIR/common/system.prop;;
                     192) echo 'persist.vendor.bt.soc.scram_freqs=192.' >> $TMPDIR/common/system.prop; echo 'persist.vendor.bt.soc.scram_freqs=192' >> $TMPDIR/common/system.prop;; 
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
