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
MODID=<MODID>
### FILE LOCATIONS ###
CFGS="<CFGS>"
CFGSXML="<CFGSXML>"
POLS="<POLS>"
POLSXML="<POLSXML>"
MIXS="<MIXS>"
# SEPOLICY SETTING FUNCTION
set_sepolicy() {
  if [ "$(basename $SEINJECT)" == "sepolicy-inject" ]; then
	  if [ -z $2 ]; then $SEINJECT -Z $1 -l; else $SEINJECT -s $1 -t $2 -c $3 -p $4 -l; fi
  else
    if [ -z $2 ]; then $SEINJECT --live "permissive $(echo $1 | sed 's/,/ /g')"; else $SEINJECT --live "allow $1 $2 $3 { $(echo $4 | sed 's/,/ /g') }"; fi
  fi
}

# CUSTOM USER SCRIPT
