#!/bin/sh

. ./setenv.sh

setenv ver snapshot

echo > .config

cat nss-setup/config-nss.seed |  grep -v CONFIG_PACKAGE_luci >> .config
echo "
CONFIG_TARGET_qualcommax_ipq807x_DEVICE_linksys_mx4300=y
CONFIG_PACKAGE_luci=y
CONFIG_FEED_nss_packages=n" >> .config
make defconfig

if [ "$1" = "full" ]; then
    kmods=$(wget -qO- https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/packages/Packages.manifest | grep "Package: kmod"  | cut -d ' '  -f 2)
    if [ -z $kmods ]; then
        kmods=$(wget -qO- https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/packages/index.json | jq '.packages' | grep \"kmod | cut -d '"' -f 2)
    fi
    kmods=$(echo "$kmods" | grep -v ath | grep -v kmod-bonding | grep -v vxlan | grep -v kmod-nat46)
    for k in $kmods; do grep -q $k=y .config || echo CONFIG_PACKAGE_$k=m >> .config; done
    make defconfig
fi
