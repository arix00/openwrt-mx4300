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
    #only necessary in 24.10 atm.
    #PATCH="https://github.com/openwrt/openwrt/pull/16070.diff"
    case $ver in
        "snapshot")
            PATCH="  "
            ;;
        "24.10"*)
            PATCH="https://github.com/openwrt/openwrt/pull/16070.diff"
            ;;
    esac
elif [ $type = "nss" ]; then
    #qosmio NSS patch
    #https://github.com/qosmio/openwrt-ipq
    #for snapshot, apply "main-nss" 
    #for 24.10, apply "24.10-nss" as MX4300 support is added in 24.10
    case $ver in
        "snapshot")   
            PATCH="https://github.com/openwrt/openwrt/compare/main...qosmio:openwrt-ipq:main-nss.diff"
            NSSBRANCH="main-nss"
            ;;
        "24.10"*)
            PATCH="https://github.com/openwrt/openwrt/compare/openwrt-24.10...qosmio:openwrt-ipq:24.10-nss.diff"
            #PATCH="https://github.com/openwrt/openwrt/compare/openwrt-24.10...qosmio:openwrt-ipq:24.10-nss.diff https://github.com/openwrt/openwrt/pull/16070.diff"
            NSSBRANCH="24.10-nss"
            ;;
    esac
fi

[ "$PATCH" = "" ] && echo "Unsupported $type $ver" && exit 1

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

echo $PATCH
for p in $PATCH; do curl -L $p | patch -p1; done

#1. support both 24.10-snapshot and (tagged) release
#2. Handle package/firmware/ipq-wifi/Makefile in *possible* patch failure.
if [ $type = "nss" ]; then
  if [ -f "feeds.conf.default.rej" ]; then
    echo "##append qosmio's src-git to feeds.conf.default"
    curl -L "https://raw.githubusercontent.com/qosmio/openwrt-ipq/refs/heads/${NSSBRANCH}/feeds.conf.default" | grep qosmio >> feeds.conf.default
    rm feeds.conf.default.rej
    cat feeds.conf.default
  fi
  if [ -f "package/firmware/ipq-wifi/Makefile.rej" ]; then
    echo "##use package/firmware/ipq-wifi/Makefile from qosmio"
    curl -L https://raw.githubusercontent.com/qosmio/openwrt-ipq/refs/heads/${NSSBRANCH}/package/firmware/ipq-wifi/Makefile -o package/firmware/ipq-wifi/Makefile
    rm package/firmware/ipq-wifi/Makefile.rej
    #cat package/firmware/ipq-wifi/Makefile
  fi
  if [ -f "include/kernel-6.6.rej" ]; then
      echo "##keep upstream include/kernel-6.6"
      rm include/kernel-6.6.rej
  fi
  if [ -f "package/kernel/nat46/Makefile.rej" ]; then
      echo "##ignore version mismatch"
      rm package/kernel/nat46/Makefile.rej
  fi
fi

#err exit with unhandled failed patch
rej=$(find . -name "*.rej"  | wc -l)
if [ ! $rej = "0" ]; then
    exit 1
fi
