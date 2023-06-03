#!/bin/bash

# Run Retro Software On Wine
# Sergei Korneev, 2022


## Exit if root

[ "$EUID" == 0 ] && echo "Do not run this script as root!" &&  exit

# Directories

export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"
cd "$DIR"


#Check if Wine is present

if !  WINE_VERSION="$(wine --version)"; then
	echo "There is no Wine available in your system!"
	exit 
fi

# win32/win64

export WINEARCH="win32"

export WINEPREFIX="$DIR/prefix_"$WINEARCH
export WINEDEBUG="-all"
export HOME="$WINEPREFIX/Home"
mkdir -p "$HOME"

#export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree,mshtml="
#LD_PRELOAD="/usr/lib/libGL.so.1"
# disable disks

#export WINEDLLOVERRIDES="winedevice.exe=d"

# Virtual Desktop

#export VIRTUAL_DESKTOP="explorer /desktop=Wine,1920x1080"

# vulkan/gl/gdi
# To use vulkan you should install dxvk into your prefix first

export RENDERER="gl"

# Driver

# Workaround for Buffer overrun error

export MESA_EXTENSION_MAX_YEAR=2008
export __GL_ExtensionStringVersion=17700

#echo yourrootpass |  sudo -S  sysctl dev.i915.perf_stream_paranoid=0  1>/dev/null

#export MESA_LOADER_DRIVER_OVERRIDE=i915
export LIBGL_DEBUG=full
#export LIBGL_DRIVERS_PATH=/usr/lib/dri
#export LIBGL_ALWAYS_SOFTWARE=1 

#export __NV_PRIME_RENDER_OFFLOAD=1 
#export __GLX_VENDOR_LIBRARY_NAME="nvidia"
#export __VK_LAYER_NV_optimus="NVIDIA_only" 
#export WLR_NO_HARDWARE_CURSORS=1
#export WLR_RENDERER=vulkan
#export DXVK_HUD=1


# Help function
Help (){
echo '
Use:
'
declare -F | awk '{print $3}'

}

#List video drivers
lsdrv (){
	echo '

	Drivers [x86]:

	'
	ls  /usr/lib/dri


	echo '

	Drivers [64]:

	'
	ls  /usr/lib64/dri
}




installwinetricks () {
          mkdir -p "$DIR/scripts"
          rm -f "$DIR/scripts/winetricks.tmp"
          wget  "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -O "$DIR/scripts/winetricks.tmp"           
          mv "$DIR/scripts/winetricks.tmp" "$DIR/scripts/winetricks"
          chmod +x "$DIR/scripts/winetricks"
}


#Run anything in your wine prefix
run (){
dirlinux=$(dirname "$1")

	echo "
  ------
  Wine version: $WINE_VERSION
  Prefix: "$WINEPREFIX"
  Running: "$@"
  In dir: $dirlinux
  -------
	"
    cd "$dirlinux" && \
    WINEPREFIX="$WINEPREFIX" WINEDEBUG="$WINEDEBUG" WINEARCH="$WINEARCH" wine $VIRTUAL_DESKTOP "$@"


}

#Add some settings to prefix registry
regadd () {
# Graphics
	run cmd /k  REG ADD "HKCU\Software\Wine\Direct3D" /v "csmt" /t REG_DWORD /d 1 /f "&&" \
							REG ADD "HKCU\Software\Wine\Direct3D" /v "renderer" /t REG_SZ /d "$RENDERER" /f "&&" \
							exit
							
	#1>/dev/null
}


winecfg (){
   run winecfg 
}

runwinetricks (){

       [ ! -f "$DIR/scripts/winetricks" ] && installwinetricks
       [  -f "$DIR/scripts/winetricks" ] && WINEPREFIX="$WINEPREFIX" WINEDEBUG="$WINEDEBUG" WINEARCH="$WINEARCH" winetricks
}

#Search for lnk files and run one
runlnk (){

[ ! -d "$WINEPREFIX"  ] && echo 'Prefix does not exist '  && exit 
	echo '
	Searching for .lnk files...

	'

	arr=()

	while read -r line ; do
	    arr+=("${line}")
	done < <(find  "$WINEPREFIX" -type f -iname *.lnk  | while read F;do echo "$F" | sed -e "s/.*drive_//g" -e 's/./&:/1' -e 's/\//\/\//g'; done)
	c=0
	for i in "${arr[@]}"
	do
		echo "$c - "$i""
		echo 
		((c=$c+1))
	done
echo '

	(Enter the number to run one in wine)

'
	read  l  
	if [ ! -z $l ] ; then
		echo "${arr[$l]}"
		regadd
		run cmd /k start /b "" "${arr[$l]}" "&&" exit
	fi
}

if [ "$#" -eq 0 ]; then
    Help;
    exit;
fi


# Run whatewer you want  
"$@"
