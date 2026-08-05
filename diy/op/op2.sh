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
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate

# 设置 Argon 为首次启动时的默认主题
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-set-argon <<'EOF'
#!/bin/sh
uci -q set luci.main.mediaurlbase='/luci-static/argon'
uci -q commit luci
exit 0
EOF

chmod +x files/etc/uci-defaults/99-set-argon

##更改主机名
sed -i "s/hostname='.*'/hostname='X86Wrt'/g" package/base-files/files/bin/config_generate

## 批量修复 kenzo 源中版本号含 -rN 后缀的包（如 0.12.6-r1）
for f in $(grep -rl "^PKG_VERSION:=.*-r[0-9]" feeds/kenzo/); do
    PKG_VER=$(grep "^PKG_VERSION:=" "$f" | head -1 | cut -d= -f2)
    VER_MAIN=$(echo "$PKG_VER" | sed 's/-r[0-9]*//')
    VER_REL=$(echo "$PKG_VER" | grep -o 'r[0-9]*' | tr -d 'r')
    echo "Fixing -rN version: $f (version: $PKG_VER)"
    sed -i "s|^PKG_VERSION:=${PKG_VER}|PKG_VERSION:=${VER_MAIN}\nPKG_RELEASE:=${VER_REL}|" "$f"
done

## 批量修复 kenzo 源中版本号含日期或其他连字符的包（如 5.8.0-20240106、1.2-1）
for f in $(grep -rl "^PKG_VERSION:=.*-" feeds/kenzo/); do
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
