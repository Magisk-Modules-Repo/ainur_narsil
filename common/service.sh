# Hexagon DTS script by UltraM8
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
set_sepolicy audioserver dts_data_file dir open,getattr,search,read,execute,associate
set_sepolicy mediaserver dts_data_file dir open,getattr,search,read,execute,associate
