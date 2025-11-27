#!/bin/bash
#=================================================
# DaoDao's script
#=================================================
##添加自己的插件库
rm -rf ./package/lean/k3screenctrl
               
#sed -i '1i src-git 2305ipk https://github.com/xiangfeidexiaohuo/2305-ipk' feeds.conf.default
sed -i '1i src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default

