#! /bin/bash

THEME_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Vimix

_THEME_VARIANTS=("" "-amber" "-amethyst" "-axinite" "-beryl" "-doder" "-ruby" "-jade" "-black" "-white")

if [ ! -z "${THEME_VARIANTS:-}" ]; then
  IFS=', ' read -r -a _THEME_VARIANTS <<< "${THEME_VARIANTS:-}"
fi

Tar_themes() {
for theme in "${_THEME_VARIANTS[@]}"; do
  rm -rf "${THEME_NAME}${theme}.tar.xz"
done

rm -rf "01-${THEME_NAME}-doder.tar.xz"

for theme in "${_THEME_VARIANTS[@]}"; do
  tar -Jcvf "${THEME_NAME}${theme}.tar.xz" "${THEME_NAME}${theme}"{'','-dark'}
done

mv "${THEME_NAME}-doder.tar.xz" "01-${THEME_NAME}-doder.tar.xz"
}

Clear_theme() {
for theme in "${_THEME_VARIANTS[@]}"; do
  rm -rf "${THEME_NAME}${theme}"{'','-dark'}
done
}

cd .. && ./install.sh -d "$THEME_DIR" -a

cd "$THEME_DIR" && Tar_themes && Clear_theme

