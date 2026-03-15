#!/bin/bash
#=================================================
# DaoDao's script
#=================================================
##添加自己的插件库
sed -i 's/git.openwrt.org\/feed/github.com\/openwrt/g' feeds.conf.default
sed -i 's/git.openwrt.org\/project/github.com\/openwrt/g' feeds.conf.default

echo "src-git kenzo https://github.com/kenzok8/openwrt-packages" >> feeds.conf.default
echo "src-git small https://github.com/kenzok8/small" >> feeds.conf.default