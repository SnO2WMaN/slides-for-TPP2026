#!/usr/bin/env bash
# スライドのビルドに必要なフォントを取得する．
#
#   scripts/install-fonts.sh [DIR]
#
# DIR（既定: ./fonts）に置く．`typst compile --font-path DIR` で使う．
# 取得元のリビジョンは固定しているので，CI と手元で同じフォントになる．
set -euo pipefail

dir="${1:-fonts}"
mkdir -p "$dir"

# "Shippori Antique", "Shippori Antique B1", "Geist"（Google Fonts, OFL）
GOOGLE_FONTS_REV=9710da1eacb3be272583c3224dcb70f9da6eadbb
base="https://raw.githubusercontent.com/google/fonts/$GOOGLE_FONTS_REV/ofl"
curl -fsSL -o "$dir/ShipporiAntique-Regular.ttf" "$base/shipporiantique/ShipporiAntique-Regular.ttf"
curl -fsSL -o "$dir/ShipporiAntiqueB1-Regular.ttf" "$base/shipporiantiqueb1/ShipporiAntiqueB1-Regular.ttf"
curl -fsSL -o "$dir/Geist[wght].ttf" "$base/geist/Geist%5Bwght%5D.ttf"

# "Juisee"（OFL）
JUISEE_VERSION=v0.2.0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/juisee.zip" "https://github.com/yuru7/juisee/releases/download/$JUISEE_VERSION/Juisee_$JUISEE_VERSION.zip"
unzip -q -o -j "$tmp/juisee.zip" "Juisee_$JUISEE_VERSION/Juisee-*.ttf" -d "$dir"

# "Material Symbols Outlined"（Apache-2.0）
MATERIAL_ICONS_REV=10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7
curl -fsSL -o "$dir/MaterialSymbolsOutlined[FILL,GRAD,opsz,wght].ttf" \
  "https://raw.githubusercontent.com/google/material-design-icons/$MATERIAL_ICONS_REV/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf"
