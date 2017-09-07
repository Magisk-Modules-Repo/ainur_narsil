# v DO NOT MODIFY v
# See instructions file for predefined variables
# User defined custom rules
# Can have multiple ones based on when you want them to be run
# You can create copies of this file and name is the same as this but with the next number after it (ex: unity-customrules2.sh)
# See instructions for TIMEOFEXEC values, do not remove it
# Do not remove last 3 lines (the if statement). Add any files added in custom rules before the sed statement and uncomment the whole thing (ex: echo "$UNITY$SYS/lib/soundfx/libv4a_fx_ics.so" >> $INFO)
# ^ DO NOT MODIFY ^
TIMEOFEXEC=1
xml_install() {
	XML=true
	XML_PRFX="$SAU/xmlstarlet/$XMLPATH/xmlstarlet"
	chmod 777 $XML_PRFX
}

XML=false
case $ABILONG in
  arm64*) XMLPATH="arm64"
  			xml_install
          ;;
  arm*) XMLPATH="arm"
  			xml_install
        ;;
  x86*) XMLPATH="x86"
  			xml_install
        ;;
  *)  ui_print "   ! Only arm, arm64, and x86 devices are compatible for xml patching"
      ui_print "   ! XML Patching will be skipped"
      ;;
esac

#if [ "$MAGISK" == false ]; then
#    sed -i 's/\/system\///g' $INFO
#fi
