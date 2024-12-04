#!/bin/bash -ex -o pipefail

mkdir kmods

if grep -q "CONFIG_USE_APK=y" .config ; then
  mdfile="${BUILD_TYPE}-kmod-apk.md"
  warning="APK package manager"
  cp bin/targets/qualcommax/ipq807x/packages/packages* kmods
else
  mdfile="${BUILD_TYPE}-kmod-opkg.md"
  warning="OPKG package manager"
  cp bin/targets/qualcommax/ipq807x/packages/Packages* kmods
fi

cp bin/targets/qualcommax/ipq807x/packages/kmod-* kmods
tar cfz kmods.tar.gz kmods/

MD="note.md"
mkdir release
cp bin/targets/qualcommax/ipq807x/openwrt-*-ipq807x-linksys_mx4300-* release/
cp bin/targets/qualcommax/ipq807x/openwrt-*-ipq807x-linksys_mx4300.manifest release/
cp kmods.tar.gz release/

kernel=$(cat release/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest | grep ^kernel | cut -d '~' -f 1)
checksum=$(sha256sum release/* | sed 's/release\///')
#echo $checksum

echo "- $warning

- $kernel

- sha256sum
\`\`\`
$checksum
\`\`\`

- [use kmods](https://github.com/${GITHUB_REPOSITORY}/blob/build/doc/$mdfile)" > $MD


