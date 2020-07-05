-------------------------------------------
# Unitrix Build Scripts #
-------------------------------------------

### !!! Attention !!! ###

1. Mention your device in DEVICE var e.g. $DEVICE="vince"
2. Mention your defconfig in CONFIG var e.g. $CONFIG="vince-perf_defconfig"
3. Mention your telegram channel id in ID var e.g. $CHANNEL_ID="abcxyz"
4. Mention your telegram bot api in TELEGRAM_TOKEN var e.g. $TELEGRAM_TOKEN="1453yt3esg23r"
5. Mention where your toolchain should be cloned in TC_PATH var e.g. $TC_PATH="$HOME/toolchains"
6. Mention where your AnyKernel source should be cloned in ZIP_DIR var e.g. $ZIP_DIR="$HOME/Zipper"
7. Mention if your kernel is building kernel for miui since it uses Wi-Fi driver as a module ( also change the entry according to your wlan driver [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L118) ) 
8. KBUILD_BUILD_USER & KBUILD_BUILD_HOST is your choice it is used in [telegram message](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L193) 
9. Change your toolchain git defined [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L73) also you might wanna change the make command [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L88)
10. Change your AnyKernel git defined [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L76) watchout for the branch too
11. Note that the zip is made using [Makefile](https://github.com/Unitrix-Kernel/AnyKernel3/blob/vince/Makefile) in AnyKernel Source in this script and will be named according to the [branch](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L128) mentioned 
12. If you want to remove the build error log to be sent you can remove it entirely [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L140)
13. I use random sticker spam with error cuz why not you can remove it from [here](https://github.com/Unitrix-Kernel/Build-Scripts/blob/9e438c032d1dc1a047a62f59bf02a6a0eed2dff5/build.sh#L156)( if you don't like it )


-------------------------------------------
