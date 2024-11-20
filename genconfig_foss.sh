#!/bin/sh

#run locally
[ -z $GITHUB_ENV ] && GITHUB_ENV=/tmp/GITHUB_ENV.txt

if [ ! -z "$1" ] && [ "$1" != "snapshot" ]; then
  buildinfo="https://downloads.openwrt.org/releases/$1/targets/qualcommax/ipq807x/config.buildinfo"
  echo "ver=$1" >> $GITHUB_ENV
else
  buildinfo="https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/config.buildinfo"
  echo "ver=snapshot" >> $GITHUB_ENV
fi

wget -qO- $buildinfo | grep -v CONFIG_TARGET_DEVICE_ | grep -v CONFIG_TARGET_ALL_PROFILES | grep -v CONFIG_TARGET_MULTI_PROFILE > .config
echo CONFIG_TARGET_ALL_PROFILES=n >> .config
echo CONFIG_TARGET_MULTI_PROFILE=n >> .config
echo CONFIG_TARGET_qualcommax_ipq807x_DEVICE_linksys_mx4300=y >> .config
echo CONFIG_TARGET_DEVICE_qualcommax_ipq807x_DEVICE_linksys_mx4300=y >> .config
echo CONFIG_TARGET_DEVICE_PACKAGES_qualcommax_ipq807x_DEVICE_linksys_mx4300=\"\" >> .config
#add luci
echo CONFIG_PACKAGE_luci=y >> .config
make defconfig

#add libpam
#echo CONFIG_PACKAGE_libpam=y >> .config

#skip xdp compile
#cat .config | grep -v "CONFIG_PACKAGE.*xdp" > .config.tmp
#cp .config.tmp .config

