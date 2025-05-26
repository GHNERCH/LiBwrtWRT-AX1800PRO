#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='Asia\/Shanghai'/g" $CFG_FILE
#修改UPnP 菜单名
sed -i "s/UPnP IGD & PCP\/NAT-PMP/UPnP/g" feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
#修改jdc ax1800 pro 的内核大小为12M
sed -i "/^define Device\/jdcloud_ax1800-pro/,/^endef/ { /KERNEL_SIZE := 6144k/s//KERNEL_SIZE := 12288k/ }" target/linux/qualcommax/image/ipq60xx.mk
#删除官方的默认插件
rm -rf feeds/luci/applications/luci-app-{passwall,mosdns,dockerman,dae*,bypass*}
rm -rf feeds/packages/net/{shadowsocks-rust,shadowsocksr-libev,xray*,v2ray*,dae*}
git clone https://github.com/davidtall/small package/small
#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config
cat >> ./.config <<EOF
CONFIG_IPQ_MEM_PROFILE_1024=n
CONFIG_IPQ_MEM_PROFILE_512=y
CONFIG_ATH11K_MEM_PROFILE_1G=n
CONFIG_ATH11K_MEM_PROFILE_512M=y

CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_kmod-tcp-bbr=y
CONFIG_DEFAULT_tcp_bbr=y
EOF
#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi


