# v DO NOT MODIFY v
# Uncomment AUDMODLIB=true if using audio modifcation library (if you're using a sound module). Otherwise, keep it commented
# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maxium android version for your mod (note that magisk has it's own minimum api: 21 (lollipop))
# ^ DO NOT MODIFY ^
#MINAPI=21
#MAXAPI=25
AUDMODLIB=true

if $BOOTMODE; then AUO=/storage/emulated/0/sauron_useroptions; else AUO=/data/media/0/sauron_useroptions; fi
SAU=$INSTALLER/custom
MAIAR=$SAU/manwe/maiar
VALAR=$SAU/manwe/valar
MORG=$SAU/morgoth
ETC=$SYS/etc
BIN=$SYS/bin
XBIN=$SYS/xbin
LIB=$LIBDIR/lib
LIB64=$LIBDIR/lib64
SFX=$LIB/soundfx
SFX64=$LIB64/soundfx
VLIB=$VEN/lib
VLIB64=$VEN/lib64
VSFX=$VLIB/soundfx
VSFX64=$VLIB64/soundfx
VETC=$VEN/etc
HW=$LIB/hw
SUD=$SYS/su.d
ADSP=$VEN/lib/rfsa/adsp
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
LX3=$(grep "ro.build.product=X3c50" $SYS/build.prop)
OP5=$(grep -E "ro.build.product=OnePlus5|ro.build.product=OnePlus5T" $SYS/build.prop)
X9=$(grep "ro.product.model=X900*" $SYS/build.prop)
