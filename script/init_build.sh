#!/bin/sh

type="foss"  #foss nss
ver="snapshot" #snapshot or release#
sync="n" #sync with latest??
tag="" #commit hash

[ ! -z $1 ] && type=$1
[ ! -z $2 ] && ver=$2
[ ! -z $3 ] && sync=$3
[ ! -z $4 ] && tag=$4

if [ $type = "foss" ]; then    
    #official MX4300 PR from testuser7
    #https://github.com/openwrt/openwrt/pull/16070
    PATCH="https://github.com/openwrt/openwrt/pull/16070.diff"
elif [ $type = "nss" ]; then
    #qosmio NSS patch
    #https://github.com/qosmio/openwrt-ipq
    case $ver in
        "snapshot")   
            PATCH="https://github.com/openwrt/openwrt/compare/main...qosmio:openwrt-ipq:main-nss-mx4300.diff"
            ;;
        "24.10"*)
            PATCH="https://github.com/openwrt/openwrt/compare/openwrt-24.10...qosmio:openwrt-ipq:24.10-nss-mx4300.diff"
            ;;
    esac
fi

[ -z $PATCH ] && echo "Unsupported $type $ver" && exit 1

if [ "$ver" = "snapshot" ]; then
  buildinfo="https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/version.buildinfo"
else
  buildinfo="https://downloads.openwrt.org/releases/$ver/targets/qualcommax/ipq807x/version.buildinfo"
fi

    
if [ ! -z $tag ]; then
    git reset --hard $tag
    sync="n"
fi    

if [ $sync = "y" ]; then
    #use published build version instead.
    git reset --hard $(wget $buildinfo -O - | cut -d '-' -f 2)
fi


wget $PATCH -O mx4300.diff
patch -p1 < mx4300.diff

#fix for nss patch to handle both 24.10-snapshot and (tagged) release
[ -f feeds.conf.default.rej ] && [ $type = "nss" ] && echo "src-git nss_packages https://github.com/qosmio/nss-packages.git;NSS-12.5-K6.x
src-git sqm_scripts_nss https://github.com/qosmio/sqm-scripts-nss.git" >> feeds.conf.default && cat feeds.conf.default

sed -i -e 's,git.openwrt.org/feed,github.com/openwrt,g; s,git.openwrt.org/project,github.com/openwrt,g' feeds.conf.default
