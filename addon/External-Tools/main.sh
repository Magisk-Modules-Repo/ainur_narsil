# External Tools

chmod -R 0755 $TMPDIR/addon/External-Tools
cp -R $TMPDIR/addon/External-Tools/tools $UF 2>/dev/null
[ -d "$UF/tools/other" ] && PATH=$UF/tools/other:$PATH
