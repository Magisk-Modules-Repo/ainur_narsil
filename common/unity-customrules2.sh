# v DO NOT MODIFY v
# See instructions file for predefined variables
# User defined custom rules
# Can have multiple ones based on when you want them to be run
# You can create copies of this file and name is the same as this but with the next number after it (ex: unity-customrules2.sh)
# See instructions for TIMEOFEXEC values, do not remove it
# Do not remove last 3 lines (the if statement). Add any files added in custom rules before the sed statement and uncomment the whole thing (ex: echo "$UNITY$SYS/lib/soundfx/libv4a_fx_ics.so" >> $INFO)
# ^ DO NOT MODIFY ^
TIMEOFEXEC=2
if [ "$QCP" ]; then
  $MK_PRFX $UNITY$SFX$MK_SFFX
  $MK_PRFX $UNITY$VSFX$MK_SFFX
  if [ -d "$VLIB64" ]; then
	$MK_PRFX $UNITY$VSFX64$MK_SFFX
  fi
  if [ -d "$ACDBDATA" ]; then
	  $MK_PRFX $UNITY$ACDBDATA$MK_SFFX
  fi
  if [ "$M9" ]; then
	  $MK_PRFX $UNITY$ETC$MK_SFFX
	  $MK_PRFX $UNITY$LIB$MK_SFFX
	  if [ -d "$LIB64" ]; then
		$MK_PRFX $UNITY$LIB64$MK_SFFX
	  fi
	  if [ $API -ge 24 ] && [ -d "$SFX64" ]; then
		$MK_PRFX $UNITY$SFX64$MK_SFFX
	  fi
  fi  
  if [ -e "$HTC_CONFIG_FILE" ]; then
	  $MK_PRFX $UNITY$ETC$MK_SFFX
	  $MK_PRFX $UNITY$LIB$MK_SFFX
  fi
  $MK_PRFX $UNITY$VLIB$MK_SFFX
  $MK_PRFX $UNITY$LIB/modules$MK_SFFX
  $MK_PRFX $UNITY$ADSP$MK_SFFX
  $MK_PRFX $UNITY$BIN$MK_SFFX
  if [ -d "$VLIB64" ]; then
	$MK_PRFX $UNITY$VLIB64$MK_SFFX
  fi
fi
if [ -d "$LIB64" ]; then
  $MK_PRFX $UNITY$SFX64$MK_SFFX
fi
if [ "$XML" == true ]; then
  $MK_PRFX $UNITY$XBIN
fi

#if [ "$MAGISK" == false ]; then
#    sed -i 's/\/system\///g' $INFO
#fi
