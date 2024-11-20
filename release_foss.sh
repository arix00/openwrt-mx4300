#!/bin/sh

#run locally
[ -z $GITHUB_ENV ] && GITHUB_ENV=/tmp/GITHUB_ENV.txt

MD="note.md"
mkdir release
cp bin/targets/qualcommax/ipq807x/openwrt-qualcommax-ipq807x-linksys_mx4300-* release/
cp bin/targets/qualcommax/ipq807x/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest release/
cp bin/targets/qualcommax/ipq807x/openwrt-imagebuilder* release/
kernel=$(cat release/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest | grep ^kernel)
checksum=$(sha256sum release/* | sed 's/release\///')
#echo $checksum

if grep -q "CONFIG_USE_APK=y" .config ; then
    errmsg="ERROR: unable to select packages"
    mdfile="foss-kmod-apk.md"
    warning="APK package manager"
    echo "pkg=apk" >> $GITHUB_ENV
else
    errmsg="pkg_hash_check_unresolved: cannot find dependency kernel"
    mdfile="foss-kmod-opkg.md"
    warning="OPKG package manager"
    echo "pkg=opkg" >> $GITHUB_ENV
fi

echo "- $warning

- $kernel

- sha256sum
\`\`\`
$checksum
\`\`\`" > $MD

if [ "$1" = "snapshot" ]; then
    echo "
- \"$errmsg\" [fix](https://github.com/arix00/openwrt-mx4300/blob/doc/$mdfile)" >> $MD
fi

