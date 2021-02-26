OPENWRT_TARGET_VER=19.07.7
OPENWRT_TARGET_DIR=$PWD/openwrt-vh-opizero
OPENWRT_BUILD_DIR=`mktemp --directory --suffix -openwrt-buildenv`

#apt-get update
#apt-get install build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python
mkdir --parent ${OPENWRT_BUILD_DIR}/ib
echo "Downloading OpenWrt ImageBuilder ..."
wget --quiet --show-progress --progress=bar:force --output-document ${OPENWRT_BUILD_DIR}/ib.tar.xz https://downloads.openwrt.org/releases/${OPENWRT_TARGET_VER}/targets/sunxi/cortexa7/openwrt-imagebuilder-${OPENWRT_TARGET_VER}-sunxi-cortexa7.Linux-x86_64.tar.xz
echo "Extracting OpenWrt ImageBuilder ..."
tar --extract --strip-components=1 --directory ${OPENWRT_BUILD_DIR}/ib --file ${OPENWRT_BUILD_DIR}/ib.tar.xz
echo "Removing OpenWrt ImageBuilder archive"
rm ${OPENWRT_BUILD_DIR}/ib.tar.xz
cd ${OPENWRT_BUILD_DIR}/ib



echo "Downloading VirtualHere server (unoptimized) ..."
wget --quiet --show-progress --progress=bar:force --output-document ./files/usr/bin/vhusbd           https://virtualhere.com/sites/default/files/usbserver/vhusbdarm
echo "Downloading VirtualHere server (optimized) ..."
wget --quiet --show-progress --progress=bar:force --output-document ./files/usr/bin/vhusbd-optimized https://virtualhere.com/sites/default/files/usbserver/vhusbdarmpi2
chmod +x ./files/usr/bin/vhusbd*
chmod +x ./files/etc/init.d/vhusbd*

mkdir --parent ${OPENWRT_TARGET_DIR}

echo "Building ..."
make --silent image PROFILE=sun8i-h2-plus-orangepi-zero PACKAGES="-fstools -mtd -logd -uboot-envtools -opkg -partx-utils -mkf2fs -e2fsprogs -dnsmasq -iptables -ip6tables -ppp -ppp-mod-pppoe -firewall -odhcpd-ipv6only -odhcp6c -kmod-ipt-offload -dropbear" FILES=files/ BIN_DIR=${OPENWRT_TARGET_DIR}
cd ${OPENWRT_TARGET_DIR}/..
echo "Removing downloaded data ..."
rm -fr ${OPENWRT_BUILD_DIR}

echo "Your SD card images are here: ${OPENWRT_TARGET_DIR}"

unset OPENWRT_TMP
unset OPENWRT_TARGET_VER
unset OPENWRT_TARGET_DIR
unset OPENWRT_BUILD_DIR

