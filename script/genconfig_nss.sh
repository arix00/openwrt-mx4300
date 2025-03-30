#!/bin/sh

ver="snapshot" #snapshot or release#
buildkmod="y"

[ ! -z $1 ] && ver=$1
[ ! -z $2 ] && buildkmod=$2

echo > .config

if [ "$ver" = "snapshot" ]; then
  mainpath="https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x"
else
  mainpath="https://downloads.openwrt.org/releases/$ver/targets/qualcommax/ipq807x"
fi

count=0
if [ "${buildkmod}" != "n" ]; then
  jsonpath=$(wget ${mainpath}/sha256sums -O - | grep kmods.*index.json | tail -n 1 | cut -d '*' -f 2 | xargs)
  kmods=$(wget ${mainpath}/${jsonpath} -O - | jq '.packages' | grep \"kmod | cut -d '"' -f 2)
  #fix dependency for 24.10 branch
  if [ "$ver" != "${ver#24.10}" ]; then
    kmods=$(echo "$kmods" | grep -v ath | grep -v kmod-bonding | grep -v vxlan | grep -v kmod-nat46)
  else
    kmods=$(echo "$kmods" | grep -v ath)
  fi
  count=$(echo $kmods | wc -w)
  echo extra kmods: $count
  if [ $count -lt 500 ]; then exit 1; fi
fi

cat nss-setup/config-nss.seed |  grep -v CONFIG_PACKAGE_luci >> .config
echo "
CONFIG_TARGET_qualcommax_ipq807x_DEVICE_linksys_mx4300=y
CONFIG_PACKAGE_luci=y
CONFIG_FEED_nss_packages=n
" >> .config
make defconfig

for k in $kmods; do grep -q $k=y .config || echo CONFIG_PACKAGE_$k=m >> .config; done
#nss patch has some dependency issue on 24.10 + kmods
#to fix:
#kmod-vxlan and kmod-nat46 must be compiled as y to keep kmod-qca-nss-ecm as y
#must skip kmod-bonding or compile fail
#no problem in snapshot as they all set to y
[ "$ver" != "${ver#24.10}" ] && for i in vxlan nat46; do echo "CONFIG_PACKAGE_kmod-$i=y" >> .config; done

make defconfig

cat .config | grep kmod-qca | grep -v "not set"
