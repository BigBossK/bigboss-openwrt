#!/bin/bash
#=================================================
# DaoDao's script
#=================================================             

####
echo -e "\nmsgid \"Control\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"控制\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"NAS\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"网络存储\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"VPN\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"魔法网络\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

##配置IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate


## 24.10-fw4-turboacc
## curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh


##取消bootstrap为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

## rust
rm -rf feeds/packages/lang/rust && git clone https://github.com/openwrt/packages.git extra-others && mv extra-others/lang/rust feeds/packages/lang/ && rm -rf extra-others

## 批量修复 kenzo 和 small 源中含连字符的版本号，兼容 APK
for f in $(grep -rl "^PKG_VERSION:=.*-" feeds/kenzo/ feeds/small/); do
    # 提取当前版本号，确认含有连字符才处理
    PKG_VER=$(grep "^PKG_VERSION:=" "$f" | head -1 | cut -d= -f2)
    if echo "$PKG_VER" | grep -q "-"; then
        echo "Fixing: $f (version: $PKG_VER)"
        # 1. 把 PKG_VERSION:=x.x-x 替换为 PKG_REAL_VERSION + PKG_VERSION
        sed -i "s|^PKG_VERSION:=${PKG_VER}|PKG_REAL_VERSION:=${PKG_VER}\nPKG_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|" "$f"
        # 2. PKG_SOURCE、PKG_SOURCE_URL、PKG_BUILD_DIR 里的 $(PKG_VERSION) 换成 $(PKG_REAL_VERSION)
        sed -i 's|\$(PKG_VERSION)|\$(PKG_REAL_VERSION)|g' "$f"
        # 3. 把刚写入的 PKG_VERSION 那行恢复（避免 subst 行也被替换）
        sed -i 's|PKG_REAL_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|PKG_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|' "$f"
        # 4. 如果没有 PKG_BUILD_DIR 则补上
        if ! grep -q "^PKG_BUILD_DIR" "$f"; then
            sed -i '/^PKG_HASH/a PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_REAL_VERSION)' "$f"
        fi
    fi
done
