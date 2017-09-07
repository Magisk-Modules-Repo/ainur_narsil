# v DO NOT MODIFY v
# See instructions file for predefined variables
# User defined custom rules
# Can have multiple ones based on when you want them to be run
# You can create copies of this file and name is the same as this but with the next number after it (ex: unity-customrules2.sh)
# See instructions for TIMEOFEXEC values, do not remove it
# Do not remove last 3 lines (the if statement). Add any files added in custom rules before the sed statement and uncomment the whole thing (ex: echo "$UNITY$SYS/lib/soundfx/libv4a_fx_ics.so" >> $INFO)
# ^ DO NOT MODIFY ^
TIMEOFEXEC=5
if [ "$QCP" ]; then
  unity_prop_removal $INSTALLER/common/propsqcp.prop
fi
if [ "$MTK" ]; then
  unity_prop_removal $INSTALLER/common/propsmtk.prop
fi
if [ -e "$HTC_CONFIG_FILE" ]; then
  unity_prop_removal $INSTALLER/common/propshtc.prop
fi

#if [ "$MAGISK" == false ]; then
#    sed -i 's/\/system\///g' $INFO
#fi
