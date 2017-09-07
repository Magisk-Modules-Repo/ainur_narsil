# v DO NOT MODIFY v
# See instructions file for predefined variables
# Add patches (such as audio config) here
# NOTE: Destination variable must have '$AMLPATH' in front of it
# Patch Ex: sed -i '/v4a_standard_fx {/,/}/d' $AMLPATH$CONFIG_FILE
# ^ DO NOT MODIFY ^
if [ -f $SYS/xbin/xmlstarlet ] && [ "TXMLINSTALL" != true ]; then
  XML=true
  XML_PRFX=xmlstarlet
fi
########## !!! XMLSTARTLET PORTED BY James34602 & LazerL0rd and remains their & team AINUR property !!! ##########
if [ "$XML" == true ]; then
 $TXMLINSTALL && ui_print "   Patching mixer"
 for MIX in $MIX_PATH; do
   if [ -f $MIX ]; then
## MAIN DAC patches
     if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SLIM_0_RX Format"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/path[@name='headphones']/ctl[@name='SLIM_0_RX Format']/@value" -v "S24_LE" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SLIM_0_RX SampleRate"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/path[@name='headphones']/ctl[@name='SLIM_0_RX SampleRate']/@value" -v "unchanged" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi         
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SLIM_5_RX Format"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/path[@name='headphones']/ctl[@name='SLIM_5_RX Format']/@value" -v "S24_LE" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SLIM_5_RX SampleRate"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/path[@name='headphones']/ctl[@name='SLIM_5_RX SampleRate']/@value" -v "unchanged" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi          
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="DAC1 Switch"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='DAC1 Switch']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "DAC1 Switch" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HPHR DAC Switch"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HPHR DAC Switch']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HPHR DAC Switch" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HPHL DAC Switch"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HPHL DAC Switch']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HPHL DAC Switch" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="RX HPH Mode"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='RX HPH Mode']/@value" -v "CLS_H_HIFI" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "RX HPH Mode" -i "/mixer/ctlTMP" -t attr -n "value" -v "CLS_H_HIFI" -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi         
# IMPEDANCE     
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HPHR Impedance"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HPHR Impedance']/@value" -v 32 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HPHR Impedance" -i "/mixer/ctlTMP" -t attr -n "value" -v 32 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HPHL Impedance"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HPHL Impedance']/@value" -v 32 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HPHL Impedance" -i "/mixer/ctlTMP" -t attr -n "value" -v 32 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
# IMPEDANCE ##
### MAIN DAC patches  ##
# Custom Stereo    
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="Set Custom Stereo OnOff"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='Set Custom Stereo OnOff']/@value" -v Off $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "Set Custom Stereo OnOff" -i "/mixer/ctlTMP" -t attr -n "value" -v "Off" -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
# Custom Stereo ##
# APTX Dec License    
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="APTX Dec License"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='APTX Dec License']/@value" -v 21 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "APTX Dec License" -i "/mixer/ctlTMP" -t attr -n "value" -v 21 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
# APTX Dec License ##
# HPH Type    
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HPH Type"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HPH Type']/@value" -v "HQ" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HPH Type" -i "/mixer/ctlTMP" -t attr -n "value" -v "HQ" -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
# HPH Type ##
# Audiosphere Enable    
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="Audiosphere Enable"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='Audiosphere Enable']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "Audiosphere Enable" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
# Audiosphere Enable ##
# TFA amp patch    
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="TFA98XX Profile"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='TFA98XX Profile']/@value" -v "hq" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "TFA98XX Profile" -i "/mixer/ctlTMP" -t attr -n "value" -v "hq" -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="TFA98XX Playback Volume"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='TFA98XX Playback Volume']/@value" -v 255 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "TFA98XX Playback Volume" -i "/mixer/ctlTMP" -t attr -n "value" -v 255 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi         
# TFA amp patch   ##  
# HW  DTS HPX edits
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="Set HPX OnOff"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='Set HPX OnOff']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "Set HPX OnOff" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="Set HPX ActiveBe"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='Set HPX ActiveBe']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "Set HPX ActiveBe" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi         
# HW  DTS HPX edits  ##
# HW  SRS Trumedia edits (consider non-working for all QC, left in users testing purposes)
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SRS Trumedia"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='SRS Trumedia']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "SRS Trumedia" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SRS Trumedia HDMI"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='SRS Trumedia HDMI']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "SRS Trumedia HDMI" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SRS Trumedia I2S"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='SRS Trumedia I2S']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "SRS Trumedia I2S" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="SRS Trumedia MI2S"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='SRS Trumedia MI2S']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "SRS Trumedia MI2S" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi         
# HW  SRS Trumedia edits  ##
# 8920 amp
	#if [ "$QC8920" ]; then
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="Lineout_1 amp"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='Lineout_1 amp']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "Lineout_1 amp" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="headset amp"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='headset amp']/@value" -v 1 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "headset amp" -i "/mixer/ctlTMP" -t attr -n "value" -v 1 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	#fi
# 8920 amp  ##
# 8226 patch
	#if [ "$QC8226" ]; then
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HIFI2 RX Volume"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HIFI2 RX Volume']/@value" -v 84 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HIFI2 RX Volume" -i "/mixer/ctlTMP" -t attr -n "value" -v 84 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HIFI3 RX Volume"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HIFI3 RX Volume']/@value" -v 84 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HIFI3 RX Volume" -i "/mixer/ctlTMP" -t attr -n "value" -v 84 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 ### TEST
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HIFI0 RX Volume"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HIFI0 RX Volume']/@value" -v 84 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HIFI0 RX Volume" -i "/mixer/ctlTMP" -t attr -n "value" -v 84 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HIFI5 RX Volume"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HIFI5 RX Volume']/@value" -v 84 $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HIFI5 RX Volume" -i "/mixer/ctlTMP" -t attr -n "value" -v 84 -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	#fi
# 8226 patch  ##
# 8996
	#if [ "$QC8996" ]; then
	 if [ "$($XML_PRFX sel -t -m '/mixer/ctl[@name="HiFi Function"]' -c . $AMLPATH$MIX)" ]; then
		$XML_PRFX ed -u "/mixer/ctl[@name='HiFi Function']/@value" -v On $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 else
		$XML_PRFX ed -s "/mixer" -t elem -n "ctlTMP" -v "" -i "/mixer/ctlTMP" -t attr -n "name" -v "HiFi Function" -i "/mixer/ctlTMP" -t attr -n "value" -v On -r "/mixer/ctlTMP" -v "ctl" $AMLPATH$MIX > $AMLPATH$MIX.temp
		mv -f $AMLPATH$MIX.temp $AMLPATH$MIX
	 fi
	#fi
# 8996  ##
   fi
 done
 
 $TXMLINSTALL && ui_print "   Patching audio policy"
 if [ -f $AUD_POL ]; then
	sed -i '/primary {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_16_BIT/g' $AMLPATH$AUD_POL
	sed -i '/direct_pcm {/,/}/s/channel_masks.*/channel_masks AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1/g' $AMLPATH$AUD_POL
	sed -i '/direct_pcm {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$AUD_POL
	sed -i '/direct_pcm {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g' $AMLPATH$AUD_POL
	sed -i '/direct {/,/}/s/channel_masks.*/channel_masks AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1/g' $AMLPATH$AUD_POL
	sed -i '/direct {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$AUD_POL
	sed -i '/direct {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g' $AMLPATH$AUD_POL
	sed -i '/raw {/,/}/s/channel_masks.*/channel_masks AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1/g' $AMLPATH$AUD_POL
	sed -i '/raw {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$AUD_POL
	sed -i '/raw {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g' $AMLPATH$AUD_POL    
	sed -i '/multichannel {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$AUD_POL
	sed -i '/compress_offload {/,/}/s/channel_masks.*/channel_masks AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1/g' $AMLPATH$AUD_POL
	sed -i '/high_res_audio {/,/}/s/channel_masks.*/channel_masks AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1/g' $AMLPATH$AUD_POL
	sed -i '/high_res_audio {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$AUD_POL
 fi
 if [ -f $V_AUD_OUT_POL ]; then
	sed -i '/default {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/default {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct_pcm {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct_pcm {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	#sed -i '/compress_offload_16 {/,/}/s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/compress_offload_16 {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/compress_offload_24 {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/compress_offload_HD {/,/}/s/bit_width.*/bit_width 24/g' $AMLPATH$V_AUD_OUT_POL
	sed -i '/direct {/,/}/s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT|AUDIO_OUTPUT_FLAG_DIRECT_PCM|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g' $AMLPATH$V_AUD_OUT_POL
 fi  
  
 if [ -f $AUD_POL_CONF ]; then
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="primary output"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='primary output']/profile/@format" -v "AUDIO_FORMAT_PCM_8_24_BIT|AUDIO_FORMAT_PCM_16_BIT" -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='primary output']/profile/@samplingRates" -v "48000,96000,192000" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="raw"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='raw']/profile/@format" -v "AUDIO_FORMAT_PCM_8_24_BIT" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="deep_buffer"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='deep_buffer']/profile/@format" -v "AUDIO_FORMAT_PCM_8_24_BIT" -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='deep_buffer']/profile/@samplingRates" -v "192000" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi
  ###
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="multichannel"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='multichannel']/profile/@format" -v "AUDIO_FORMAT_PCM_8_24_BIT" -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='multichannel']/profile/@samplingRates" -v "44100|48000|64000|88200|96000|128000|176400|192000" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="direct_pcm"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='direct_pcm']/profile/@format" -v "AUDIO_FORMAT_PCM_8_24_BIT" -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='direct_pcm']/profile/@samplingRates" -v "44100|48000|64000|88200|96000|128000|176400|192000" -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='direct_pcm']/profile/@channel_masks" -v "AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi
  if [ "$($XML_PRFX sel -t -m '/audioPolicyConfiguration/modules/module[@name="primary"]/mixPorts/mixPort[@name="compress_offload"]/profile' -c . $AMLPATH$POL)"  ]; then
   $XML_PRFX ed -u "/audioPolicyConfiguration/modules/module[@name='primary']/mixPorts/mixPort[@name='compress_offload']/profile/@channel_masks" -v "AUDIO_CHANNEL_OUT_PENTA|AUDIO_CHANNEL_OUT_5POINT1|AUDIO_CHANNEL_OUT_6POINT1|AUDIO_CHANNEL_OUT_7POINT1" $AMLPATH$POL > $AMLPATH$POL.temp
   mv -f $AMLPATH$POL.temp $AMLPATH$POL
  fi		 
 fi
fi
