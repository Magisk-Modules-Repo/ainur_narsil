# v DO NOT MODIFY v
# User defined audmodlib variables
# Add any variables here
# Uncomment and change 'MINAPI' to the minimum android version for your mod (note that magisk has it's own minimum api: 21 (lollipop))
# ^ DO NOT MODIFY ^
#MINAPI=21
SAU=$INSTALLER/custom
MAIAR=$SAU/manwe/maiar
VALAR=$SAU/manwe/valar
MORG=$SAU/morgoth
ETC=$SYS/etc
BIN=$SYS/bin
XBIN=$SYS/xbin
LIB=$SYS/lib
LIB64=$SYS/lib64
SFX=$LIB/soundfx
SFX64=$LIB64/soundfx
VLIB=$VEN/lib
VLIB64=$VEN/lib64
VSFX=$VLIB/soundfx
VSFX64=$VLIB64/soundfx
VETC=$VEN/etc
ALSA=$SYS/usr/share/alsa
ALSAC=$ALSA/cards
ALSAP=$ALSA/pcm
HW=$LIB/hw
SUD=$SYS/su.d
ADSP=$VEN/rfsa/adsp
ACDBDATA=$ETC/acdbdata
AMPA=$ETC/TAS2557_A.ftcfg
MTK=$(cat $SYS/build.prop | grep "ro.mediatek.version*")
QCP=$(cat $SYS/build.prop | grep "ro.board.platform=apq*\|ro.board.platform=msm*")
EXY=$(cat $SYS/build.prop | grep "ro.chipname*")
M9=$(cat $SYS/build.prop | grep "ro.aa.modelid=0PJA10000|ro.aa.modelid=0PJA11000|ro.aa.modelid=0PJA12000|ro.aa.modelid=0PJA13000|ro.aa.modelid=0PJA20000|ro.aa.modelid=0PJA30000")
QC94=$(cat $SYS/build.prop | grep "ro.product.board=msm8994")
KIR=$(cat $SYS/build.prop | grep "ro.board.platform=hi*")
SPEC=$(cat $SYS/build.prop | grep "ro.board.platform=sp*")
MIUI=$(cat $SYS/build.prop | grep "ro.miui.ui.version*")
#QC8920=$(cat $SYS/build.prop | grep "ro.product.board=msm8920")
#QC8226=$(cat $SYS/build.prop | grep "ro.product.board=msm8226")
#QC8996=$(cat $SYS/build.prop | grep "ro.product.board=msm8996")
