OPENWRT_TARGET_VER=19.07.7
OPENWRT_TARGET_DIR=$PWD/openwrt-vh-opizero
OPENWRT_BUILD_DIR=`mktemp --directory --suffix -openwrt-buildenv`

#apt-get update
#apt-get install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python
cd ${OPENWRT_BUILD_DIR}

echo "Prange Pi Zero VirtualHere image builder (0646)"
echo "Downloading OpenWrt ImageBuilder ..."
mkdir --parent ${OPENWRT_BUILD_DIR}/ib
wget --quiet --show-progress --progress=bar:force --output-document ${OPENWRT_BUILD_DIR}/ib.tar.xz https://downloads.openwrt.org/releases/${OPENWRT_TARGET_VER}/targets/sunxi/cortexa7/openwrt-imagebuilder-${OPENWRT_TARGET_VER}-sunxi-cortexa7.Linux-x86_64.tar.xz
echo "Extracting OpenWrt ImageBuilder ..."
tar --extract --strip-components=1 --directory ${OPENWRT_BUILD_DIR}/ib --file ${OPENWRT_BUILD_DIR}/ib.tar.xz
echo "Removing OpenWrt ImageBuilder archive"
rm ${OPENWRT_BUILD_DIR}/ib.tar.xz


echo "Downloading patches"
mkdir --parent ${OPENWRT_BUILD_DIR}/p
git clone --quiet https://github.com/filimonic/virtualhere-openwrt-opangepi-zero.git ${OPENWRT_BUILD_DIR}/p

echo "Applying patches"
cp --recursive --force --target-directory ${OPENWRT_BUILD_DIR}/ib  ${OPENWRT_BUILD_DIR}/p/files
echo "CONFIG_SUNXI_SD_BOOT_PARTSIZE=5"  >> ${OPENWRT_BUILD_DIR}/ib/.config 
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=32" >> ${OPENWRT_BUILD_DIR}/ib/.config 

cd ${OPENWRT_BUILD_DIR}/ib
echo "Downloading VirtualHere server (unoptimized) ..."
wget --quiet --show-progress --progress=bar:force --output-document ${OPENWRT_BUILD_DIR}/ib/files/usr/bin/vhusbd           https://virtualhere.com/sites/default/files/usbserver/vhusbdarm
echo "Downloading VirtualHere server (optimized) ..."
wget --quiet --show-progress --progress=bar:force --output-document ${OPENWRT_BUILD_DIR}/ib/files/usr/bin/vhusbd-optimized https://virtualhere.com/sites/default/files/usbserver/vhusbdarmpi2

echo "Applying permissions"
chmod +x ${OPENWRT_BUILD_DIR}/ib/files/usr/bin/vhusbd*
chmod +x ${OPENWRT_BUILD_DIR}/ib/files/etc/init.d/vhusbd*

echo "Adding external configurations"
ln -s -f /vfat0/hostname.txt ${OPENWRT_BUILD_DIR}/ib/files/etc/sysctl.d/99-hostname.conf

echo "Applying build patches"
patch ${OPENWRT_BUILD_DIR}/ib/target/linux/sunxi/image/Makefile ${OPENWRT_BUILD_DIR}/p/patches/vh-vfat-patch.patch

mkdir --parent ${OPENWRT_TARGET_DIR}

echo "Building ..."
make --silent image PROFILE=sun8i-h2-plus-orangepi-zero PACKAGES="block-mount -mtd -logd -uboot-envtools  -dnsmasq -iptables -ip6tables -ppp -ppp-mod-pppoe -firewall -odhcpd-ipv6only -odhcp6c -kmod-ipt-offload -dropbear" FILES=files/ BIN_DIR=${OPENWRT_TARGET_DIR}
cd ${OPENWRT_TARGET_DIR}/..
echo "Removing downloaded data ..."
rm -fr ${OPENWRT_BUILD_DIR}

echo "Your SD card images are here: ${OPENWRT_TARGET_DIR}"

unset OPENWRT_TMP
unset OPENWRT_TARGET_VER
unset OPENWRT_TARGET_DIR
unset OPENWRT_BUILD_DIR

