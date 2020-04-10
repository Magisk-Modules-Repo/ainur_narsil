## Mixer controller script by UltraM8
[ -d $MODDIR/tools/tinymix ] && alias tinymix="$MODDIR/tools/tinymix"
if [ "$AX7" ]; then
 tinymix 'AKM HIFI Switch Sel' 'ak4490'
 tinymix 'Smart PA Init Switch' 'On'
 tinymix 'ADC1 Digital Filter' 'sharp_roll_off_88'
 tinymix 'ADC2 Digital Filter' 'sharp_roll_off_88'
fi
if [ "$LX3" ]; then
 tinymix 'Es9018 CLK Divider' 'DIV4'
 tinymix 'ESS_HEADPHONE Off' 'On'
fi
if [ "$X9" ]; then
 tinymix 'Es9018 CLK Divider' 'DIV4'
 tinymix 'Es9018 Hifi Switch' 1
fi   
if [ "$Z9" ] || [ "$Z9M" ]; then
 tinymix 'HP Out Volume' 22 
 tinymix 'ADC1 Digital Filter' 'sharp_roll_off_88'
 tinymix '"ADC2 Digital Filter' 'sharp_roll_off_88'
fi
if [ "$Z11" ]; then
 tinymix 'AK4376 DAC Digital Filter Mode' 'Slow Roll-Off'
 tinymix 'AK4376 HPL Power-down Resistor' 'Hi-Z'
 tinymix 'AK4376 HPR Power-down Resistor' 'Hi-Z'
 tinymix 'AK4376 HP-Amp Analog Volume' 15
fi
if [ "$V20" ] || [ "$V30" ] || [ "$G6" ]; then
# tinymix 'Es9018 AVC Volume' 14
# tinymix 'Es9018 HEADSET TYPE' 2
 tinymix 'Es9018 State' 'Hifi'
 tinymix 'HIFI Custom Filter' 6
 tinymix 'LGE ESS DIGITAL FILTER SETTING' 6
 tinymix 'Es9218 Bypass' 0
fi

if [ "$(pidof audioserver)" ]; then
  kill $(pidof audioserver)
fi;
