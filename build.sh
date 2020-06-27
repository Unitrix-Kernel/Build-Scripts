#! /bin/bash
# Copyright (C) 2020 StarLight5234
#

export DEVICE="Vince"
export CONFIG="vince-perf_defconfig"
export CHANNEL_ID="$ID"
export TELEGRAM_TOKEN="$BOT_API_KEY"
export TC_PATH="$HOME/toolchains"
export ZIP_DIR="$HOME/Zipper"
export IS_MIUI="no"
export KERNEL_DIR=$(pwd)
export KBUILD_BUILD_USER="Starlight"
export KBUILD_BUILD_HOST="Cosmic-Horizon"

#==============================================================
#===================== Function Definition ====================
#==============================================================
#======================= Telegram Start =======================
#==============================================================

# Upload buildlog to group
tg_erlog()
{
	ERLOG=$HOME/build/build${BUILD}.txt
	curl -F document=@"$ERLOG"  "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
			-F chat_id=$CHANNEL_ID \
			-F caption="Build ran into errors after $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds, plox check logs"
}

# Upload zip to channel
tg_pushzip() 
{
	FZIP=$ZIP_DIR/$ZIP
	curl -F document=@"$FZIP"  "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendDocument" \
			-F chat_id=$CHANNEL_ID \
			-F caption="Build Finished after $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds"
}

# Send Updates
function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
		-d "parse_mode=html" \
		-d text="${1}" \
		-d chat_id="${CHANNEL_ID}" \
		-d "disable_web_page_preview=true"
}

# Send a sticker
function start_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker" \
        -d sticker="CAACAgUAAxkBAAMPXvdff5azEK_7peNplS4ywWcagh4AAgwBAALQuClVMBjhY-CopowaBA" \
        -d chat_id=$CHANNEL_ID
}

function error_sticker() {
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendSticker" \
        -d sticker="CAACAgUAAxkBAAMQXvdgEdkCuvPzzQeXML3J6srMN4gAAvIAA3PMoVfqdoREJO6DahoE" \
        -d chat_id=$CHANNEL_ID
}

#==============================================================
#======================= Telegram End =========================
#==============================================================
#========================= Clone TC ===========================
#======================== & AnyKernel =========================
#==============================================================

function clone_tc() {
[ -d ${TC_PATH} ] || mkdir ${TC_PATH}
[ -d ${TC_PATH}/clang ] || git clone --depth=1 https://github.com/Unitrix-Kernel/unitrix-clang.git ${TC_PATH}/clang
export PATH="${TC_PATH}/clang/bin:$PATH"
export STRIP="${TC_PATH}/clang/aarch64-linux-gnu/bin/strip"
rm -rf $ZIP_DIR && git clone https://github.com/Unitrix-Kernel/AnyKernel3.git -b vince $ZIP_DIR
}

#==============================================================
#=========================== Make =============================
#========================== Kernel ============================
#==============================================================

build_kernel() {
DATE=`date`
BUILD_START=$(date +"%s")
make O=out ARCH=arm64 "$CONFIG"
make -j$(nproc --all) O=out \
		      ARCH=arm64 \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
		      OBJDUMP=llvm-objdump \
		      STRIP=llvm-strip \
		      CC=clang \
		      CROSS_COMPILE=aarch64-linux-gnu- \
		      CROSS_COMPILE_ARM32=arm-linux-gnueabi- |& tee -a $HOME/build/build${BUILD}.txt
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
}

#==============================================================
#==================== Make Flashable Zip ======================
#==============================================================

function make_flashable() {

if [ "$IS_MIUI" == "yes" ]; then
# credit @adekmaulana
    for MODULES in $(find "$KERNEL_DIR/out" -name '*.ko'); do
        "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
        "$KERNEL_DIR/scripts/sign-file" sha512 \
                "$KERNEL_DIR/out/signing_key.priv" \
                "$KERNEL_DIR/out/signing_key.x509" \
                "${MODULES}"
        case ${MODULES} in
                */wlan.ko)
		cp "${MODULES}" "${VENDOR_MODULEDIR}/pronto_wlan.ko"
            ;;
        esac
    done
    echo -e "(i) Done moving wifi modules"
fi

cd $ZIP_DIR
make clean &>/dev/null
cp $KERN_IMG $ZIP_DIR/zImage
if [ "$BRANCH" == "stable" ]; then
	make stable &>/dev/null
elif [ "$BRANCH" == "beta" ]; then
	make beta &>/dev/null
else
	make test &>/dev/null
fi
ZIP=$(echo *.zip)
tg_pushzip

}

#==============================================================
#========================= Build Log ==========================
#==============================================================

# Credits: @madeofgreat
BTXT="$HOME/build/buildno.txt" #BTXT is Build number TeXT
if ! [ -a "$BTXT" ]; then
	mkdir $HOME/build
	touch $HOME/build/buildno.txt
	echo 1 > $BTXT
fi

BUILD=$(cat $BTXT)
BUILD=$(($BUILD + 1))
echo ${BUILD} > $BTXT

#==============================================================
#===================== End of function ========================
#======================= definition ===========================
#==============================================================

clone_tc
COMMIT=$(git log --pretty=format:'"%h : %s"' -1)
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
KERNEL_DIR=$(pwd)
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
CONFIG_PATH=$KERNEL_DIR/arch/arm64/configs/$CONFIG
VENDOR_MODULEDIR="$ZIP_DIR/modules/vendor/lib/modules"
export KERN_VER=$(echo "$(make kernelversion)")

# Cleaning source
make mrproper && rm -rf out

start_sticker
tg_sendinfo "$(echo -e "======= <b>$DEVICE</b> =======\n
Build-Host   :- <b>$KBUILD_BUILD_HOST</b>
Build-User   :- <b>$KBUILD_BUILD_USER</b>\n 
Version        :- <u><b>$KERN_VER</b></u>\n
on Branch   :- <b>$BRANCH</b>
Commit       :- <b>$COMMIT</b>\n")"

build_kernel

# Check if kernel img is there or not and make flashable accordingly

if ! [ -a "$KERN_IMG" ]; then
	tg_erlog && error_sticker
	exit 1
else
	make_flashable
fi