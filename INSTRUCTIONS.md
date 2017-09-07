To create your own audmodlib mod, all of the files you need to modify are located in the common folder of this zip
NOTE: MAKE SURE YOU LEAVE A BLANK LINE AT THE END OF EACH FILE
Instructions are contained in each file

1. Add your mod info to module.prop
2. Place your files in their respective directories in the system folder (where they will be installed to)
2a. For apps, place in system/app/APPNAME/APPNAME.apk
3. Place any files that need conditionals (only installed in some circumstances) in the custom folder (can be placed however you want)
4. Add your min android version and other variables to common/unity-uservariables.sh (more instructions are in the file)
5. Add any scripts you want run at boot to common/unity-scripts.sh
6. Modify the post-fs-data.sh and service.sh files in common as you would with any other magisk module (you probably won't need to do this - unity-scripts runs as a service script)
6a. If post-fs-data and/or service are going to be used, set their values to true in config.sh (THESE WILL BE INSTALLED AS REGULAR BOOT SCRIPTS IF NOT A MAGISK INSTALL)
7. Add any build props you want added into the unity-props.prop
8. Add any build props you want removed into the unity-props-remove.prop
9. Add any possibly conflicting files you want removed/wiped before install into the unity-file-wipe.sh
10. Add any config/policy/mixer patches you want added into the unity-patches.sh
11. Add the removal of your patches in unity_patches into the unity-patches-remove.sh
12. Add any other config/policy/mixer patches you want removed before install into the unity-patches-wipe.sh
13. Add any custom permissions needed into config.sh (this will apply to both magisk and system installs) (default permissions is 755 for folders and 644 for files)
14. Add any custom install/uninstall logic to unity-customrules1.sh (follow the instructions inside)
14a. This is where you would put your stuff for any custom files and whatever else isn't taken care of already
________________________________________________________________________________________________________________________________________________________________________

AUDMODLIB VARIABLES (for reference)

AUDIO EFFECTS

CONFIG_FILE=$SYS/etc/audio_effects.conf
HTC_CONFIG_FILE=$SYS/etc/htc_audio_effects.conf
OTHER_V_FILE=$SYS/etc/audio_effects_vendor.conf
OFFLOAD_CONFIG=$SYS/etc/audio_effects_offload.conf
V_CONFIG_FILE=$VEN/etc/audio_effects.conf

AUDIO POLICY

A2DP_AUD_POL=$SYS/etc/a2dp_audio_policy_configuration.xml
AUD_POL=$SYS/etc/audio_policy.conf
AUD_POL_CONF=$SYS/etc/audio_policy_configuration.xml
AUD_POL_VOL=$SYS/etc/audio_policy_volumes.xml
SUB_AUD_POL=$SYS/etc/r_submix_audio_policy_configuration.xml
USB_AUD_POL=$SYS/etc/usb_audio_policy_configuration.xml
V_AUD_OUT_POL=$VEN/etc/audio_output_policy.conf
V_AUD_POL=$VEN/etc/audio_policy.conf

MIXER PATHS

MIX_PATH=$SYS/etc/mixer_paths.xml
MIX_PATH_DTP=$SYS/etc/mixer_paths_dtp.xml
MIX_PATH_i2s=$SYS/etc/mixer_paths_i2s.xml
MIX_PATH_TASH=$SYS/etc/mixer_paths_tasha.xml
STRIGG_MIX_PATH=$SYS/sound_trigger_mixer_paths.xml
STRIGG_MIX_PATH_9330=$SYS/sound_trigger_mixer_paths_wcd9330.xml
V_MIX_PATH=$VEN/etc/mixer_paths.xml
________________________________________________________________________________________________________________________________________________________________________

SYSTEM AND VENDOR VARIABLES

SYS -> location of system folder
VEN -> location of vendor folder

**$SYS and $VEN are dynamic variables for system and vendor depending on device
OTHER DYNAMIC VARIABLES

INFO -> (System installs only) corresponds to a file that will save the list of installed files and is how aml knows what needs removed during uninstall
INSTALLER -> Location of installer files (needed for customrules only)
MODID -> The name of your mod - you set this in the config.sh
MK_PRFX -> Contains the proper mkdir command regardless of install method. Always use this instead of a manual mkdir command
MK_SFFX -> Contains proper permissions for mkdir command regardless of install method. Always put this at end of any mkdir command
CP_PRFX -> Contains the proper copy command regardless of install method. Always use this instead of a manual cp command
CP_SFFX -> Contains proper permissions for cp command regardless of install method. Always put this at end of any cp command
RM_PRFX -> Contains the proper rm command for files regardless of install method. Always use this instead of a manual rm command
RMFOL_PRFX -> Contains the proper rm command for folders regardless of install method. Always use this instead of a manual rm -r command
RMFOL_SFFX -> Contains proper suffix (.replace for magisk installs) for rm -r command regardless of install method. Always put this at end of any rm -r command
UNITY -> Conatins proper location for mod regardless of install method (MODPATH for magisk installs)
AMLPATH -> The destination path to aml files (see the AUDMODLIB variables above)

**These are set dynamically based on device some examples of use:
$CP_PRFX $INSTALLER/system/lib/example.so $UNITY$SYS/lib/example.so$CP_SFFX
$MK_SFFX $UNITY$SYS/lib/example.so$MK_SFFX

*NOTE ABOUT THE INFO VARIABLE:
Any files you copy over in a customrule needs to be echoed to the INFO file in that rule as well in the if statement in order for uninstallation to proceed correctly.
See instructions in the customrules files for reference
Example: echo "$UNITY$SYS/lib/soundfx/libv4a_fx_ics.so" >> $INFO
________________________________________________________________________________________________________________________________________________________________________

MAIN AUDMODLIB FUNCTIONS

unity_prop_remove: removes all props in specified file from a common aml prop file. Example usage: unity_prop_remove $INSTALLER/common/props.prop
unity_prop_copy: adds all props in specified file to a common aml prop file. Example usage: unity_prop_copy $INSTALLER/common/props.prop
unity_mod_wipe: removes all specified folders/files/patches that may conflict with install.
unity_mod_directory: creates directories (folders) for files to be installed
unity_mod_copy: copies/installs the files
magisk_audmodlib: a magical function that enables all config/policy/mixer files to be shared between all aml mods. You will have no need to call this function
unity_mod_patch: patches specificed config/policy/mixer files
unity_uninstall: uninstalls mod (removes applicable files/folders/patches). The uninstallation process is handled automatically so you probably won't need to call this function.
________________________________________________________________________________________________________________________________________________________________________

TIMEOFEXEC VALUES - when the customrules file will execute in the (un)installer script

0=File will not be run (default)
1=unity_mod_wipe
2=unity_mod_directory
3=unity_mod_copy
4=unity_mod_patch
5=unity_uninstall

*HINT: If you have props you want set under certain conditions, have that customrule's TIMEOFEXEC=3. Example: unity_prop_copy $INSTALLER/common/props.prop
If you have props you want removed under certain conditions, have that customrule's TIMEOFEXEC=1. Example: unity_prop_remove $INSTALLER/common/props.prop