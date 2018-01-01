<SHEBANG>
SH=${0%/*}
SEINJECT=<SEINJECT>
AMLPATH=<AMLPATH>
MAGISK=<MAGISK>
ROOT=<ROOT>
SYS=<SYS>
VEN=<VEN>
SOURCE=<SOURCE>
LIBDIR=<LIBDIR>
MODIDS=""
### FILE LOCATIONS ###
CFGS="<CFGS>"
CFGSXML="<CFGSXML>"
POLS="<POLS>"
POLSXML="<POLSXML>"
MIXS="<MIXS>"
# MOD PATCHES

if [ "$MAGISK" == true ]; then
  for MOD in ${MODIDS}; do
    sed -i "/^#$MOD/,/fi #$MOD/d" $SH/post-fs-data.sh
  done
  test ! "$(sed -n '/# MOD PATCHES/{n;p}' $AMLPATH/post-fs-data.sh)" && rm -rf $AMLPATH
fi
