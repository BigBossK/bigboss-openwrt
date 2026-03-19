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

## 批量修复 kenzo 和 small 源中版本号含 -rN 后缀的包（如 0.12.6-r1）
for f in $(grep -rl "^PKG_VERSION:=.*-r[0-9]" feeds/kenzo/ feeds/small/); do
    PKG_VER=$(grep "^PKG_VERSION:=" "$f" | head -1 | cut -d= -f2)
    VER_MAIN=$(echo "$PKG_VER" | sed 's/-r[0-9]*//')
    VER_REL=$(echo "$PKG_VER" | grep -o 'r[0-9]*' | tr -d 'r')
    echo "Fixing -rN version: $f (version: $PKG_VER)"
    sed -i "s|^PKG_VERSION:=${PKG_VER}|PKG_VERSION:=${VER_MAIN}\nPKG_RELEASE:=${VER_REL}|" "$f"
done

## 批量修复 kenzo 和 small 源中版本号含日期或其他连字符的包（如 5.8.0-20240106、1.2-1）
for f in $(grep -rl "^PKG_VERSION:=.*-" feeds/kenzo/ feeds/small/); do
    PKG_VER=$(grep "^PKG_VERSION:=" "$f" | head -1 | cut -d= -f2)
    if echo "$PKG_VER" | grep -q "-"; then
        echo "Fixing version: $f (version: $PKG_VER)"
        sed -i "s|^PKG_VERSION:=${PKG_VER}|PKG_REAL_VERSION:=${PKG_VER}\nPKG_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|" "$f"
        sed -i 's|\$(PKG_VERSION)|\$(PKG_REAL_VERSION)|g' "$f"
        sed -i 's|PKG_REAL_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|PKG_VERSION:=\$(subst -,.,\$(PKG_REAL_VERSION))|' "$f"
        if ! grep -q "^PKG_BUILD_DIR" "$f"; then
            sed -i '/^PKG_HASH/a PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_REAL_VERSION)' "$f"
        fi
    fi
done
