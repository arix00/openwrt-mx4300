#!/bin/bash -ex -o pipefail


MD="note.md"
mkdir release
cp bin/targets/qualcommax/ipq807x/openwrt-*-ipq807x-linksys_mx4300-* release/
cp bin/targets/qualcommax/ipq807x/openwrt-*-ipq807x-linksys_mx4300.manifest release/
cp bin/targets/qualcommax/ipq807x/openwrt-imagebuilder* release/
kernel=$(cat release/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest | grep ^kernel)
checksum=$(sha256sum release/* | sed 's/release\///')
#echo $checksum

if grep -q "CONFIG_USE_APK=y" .config ; then
    errmsg="ERROR: unable to select packages"
    mdfile="${BUILD_TYPE}-kmod-apk.md"
    warning="APK package manager"
else
    errmsg="pkg_hash_check_unresolved: cannot find dependency kernel"
    mdfile="${BUILD_TYPE}-kmod-opkg.md"
    warning="OPKG package manager"
fi

echo "- $warning

- $kernel

- sha256sum
\`\`\`
$checksum
\`\`\`" > $MD

#if [ "$1" = "snapshot" ]; then
#    echo "
#- \"$errmsg\" [fix](https://github.com/${GITHUB_REPOSITORY}/blob/build/doc/$mdfile)" >> $MD
#fi

