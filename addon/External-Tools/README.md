# External Tools - Addon where external (not already included in unity) tools can be added. Typical use for this will be binaries.
## Note that bash is included if you wish to use it in your install.sh and uninstall.sh scripts

## Instructions:
* Delete bash if not using it in your install/uninstall scripts
* Place arm and x86 compiled binaries into their respective folders inside tools directory and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)
* Place other cpu architecture independent tools into the other folder and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)

## Notes:
* If you want to include a binary into your module itself (like for a boot script), the binaries are located at: $UF/tools during the (un)install process
* To use binary with an .aml.sh script (to be used with audio modification library), make sure you make a proper alias in the .aml.sh script. If it's in system/bin of your mod for example: alias xmlstarlet="$(dirname $MOD)/system/bin/xmlstarlet"
* For bash, you will need to export the current environment to it before calling it (since it'll start a fresh one)

## Included Binaries/Credits:
* sesearch by [xmikos @Github ](https://github.com/xmikos/setools-android)
* xmlstarlet compiled by [james34602 @Github](https://github.com/james34602/)
