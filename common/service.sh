# QC Hexagon DTS script by UltraM8 & Zackptg5
set_metadata() {
  file="$1"
  if [ -e "$file" ]; then
    shift
    until [ ! "$2" ]; do
    case $1 in
      uid) chown "$2" "$file";;
      gid) chown :"$2" "$file";;
      mode) chmod "$2" "$file";;
      capabilities) ;;
      selabel)
      chcon -h "$2" "$file"
      chcon "$2" "$file"
      ;;
      *) ;;
    esac
    shift 2
    done
  fi
}
chcon 'u:object_r:dts_data_file:s0' /data/misc/dts/*
set_metadata /data/misc/dts/effect uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect9 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect13 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect17 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect21 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect24 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect25 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
set_metadata /data/misc/dts/effect33 uid 0 gid 0 mode 0644 capabilities 0x0 selabel u:object_r:audioserver:s0
if [ "$SEINJECT" != "/sbin/sepolicy-inject" ]; then
  $SEINJECT --live "allow { audioserver mediaserver } dts_data_file dir { read execute open search getattr associate }"
else
  $SEINJECT -s audioserver -t dts_data_file -c dir -p open,getattr,search,read,execute,associate -l
  $SEINJECT -s mediaserver -t dts_data_file -c dir -p open,getattr,search,read,execute,associate -l
fi
