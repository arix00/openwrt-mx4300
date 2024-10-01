
#!/bin/sh

wget -qO- https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/config.buildinfo | grep -v CONFIG_TARGET_DEVICE_ | grep -v CONFIG_TARGET_ALL_PROFILES | grep -v CONFIG_TARGET_MULTI_PROFILE > .config
echo CONFIG_TARGET_ALL_PROFILES=n >> .config
echo CONFIG_TARGET_MULTI_PROFILE=n >> .config
echo CONFIG_IB=y >> .config
echo CONFIG_TARGET_qualcommax_ipq807x_DEVICE_linksys_mx4300=y >> .config
echo CONFIG_TARGET_DEVICE_qualcommax_ipq807x_DEVICE_linksys_mx4300=y >> .config
echo CONFIG_TARGET_DEVICE_PACKAGES_qualcommax_ipq807x_DEVICE_linksys_mx4300=\"\" >> .config
#add luci
echo CONFIG_PACKAGE_luci=y >> .config
make defconfig

#add libpam
#echo CONFIG_PACKAGE_libpam=y >> .config

#skip xdp
cat .config | grep -v "CONFIG_PACKAGE.*xdp" > .config.tmp
cp .config.tmp .config

