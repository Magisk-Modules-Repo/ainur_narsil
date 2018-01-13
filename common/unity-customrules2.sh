TIMEOFEXEC=4

get_uo() {
  eval "$1=$(grep_prop "$2" $AUO)"
  if [ -z $(eval echo \$$1) ]; then
    eval "$1=false"
  else
    case $(eval echo \$$1) in
      "true"|"True"|"TRUE") eval "$1=true";;
      *) eval "$1=false";;
    esac
  fi
  if [ ! -z $3 ]; then
    test -z \$$3 && eval "$1=false"
  fi
}

AUO=$UNITY$SYS/etc/sauron_useroptions
get_uo "AP" "audpol"
get_uo "FMAS" "install.fmas"
get_uo "SHB" "qc.install.shoebox" "QCP"
get_uo "OAP" "qc.out.audpol" "QCP"
get_uo "ASP" "qc.install.asp" "QCP"
get_uo "APTX" "qc.install.aptx" "QCP"
#get_uo "HWD" "qc.install.hw.dolby" "QCP"
get_uo "COMP" "qc.remove.compander" "QCP"
if [ "$QCP" ]; then
  IMPEDANCE=$(grep_prop "qc.impedance" $AUO)
  RESAMPLE=$(grep_prop "qc.resample.khz" $AUO)
  BTRESAMPLE=$(grep_prop "qc.bt.resample.khz" $AUO)     
  case $(grep_prop "qc.bitsize" $AUO) in
    16) BIT=S16_LE;;
    24) BIT=S24_LE;;
    32) $QCNEW && BIT=S32_LE || BIT="";;
    *) BIT="";;
  esac
fi
rm -f $AUO

# Unmount dsp partition if applicable
if [ "$DSPBLOCK" ]; then
  if $BOOTMODE; then mount -o remount,ro $DSPBLOCK /dsp; else umount -l /dsp 2>/dev/null; rm -rf /dsp; fi
fi
