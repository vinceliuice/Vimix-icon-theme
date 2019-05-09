#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=Vimix
COLOR_VARIANTS=('-Doder' '-Beryl' '-Ruby' '-Black' '-White')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}

  local THEME_DIR=${dest}/${name}${color}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  mkdir -p                                                                           ${THEME_DIR}/scalable
  cp -ur ${SRC_DIR}/COPYING                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/AUTHORS                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/Vimix-Paper/index.theme                                          ${THEME_DIR}

  cd ${dest}
  ln -s ../Vimix-Paper/16 ${name}${color}/16
  ln -s ../Vimix-Paper/22 ${name}${color}/22
  ln -s ../Vimix-Paper/24 ${name}${color}/24
  ln -s ../Vimix-Paper/other ${name}${color}/other
  ln -s ../Vimix-Paper/symbolic ${name}${color}/symbolic
  ln -s ../../Vimix-Paper/scalable/actions ${name}${color}/scalable/actions
  ln -s ../../Vimix-Paper/scalable/apps ${name}${color}/scalable/apps
  ln -s ../../Vimix-Paper/scalable/categories ${name}${color}/scalable/categories
  ln -s ../../Vimix-Paper/scalable/devices ${name}${color}/scalable/devices
  ln -s ../../Vimix-Paper/scalable/emotes ${name}${color}/scalable/emotes
  ln -s ../../Vimix-Paper/scalable/mimetypes ${name}${color}/scalable/mimetypes
  ln -s ../../Vimix-Paper/scalable/web ${name}${color}/scalable/web

  cp -ur ${SRC_DIR}/Places-color/places${color}                                      ${THEME_DIR}/scalable/places

  cd ${THEME_DIR}
  sed -i "s/-Paper/${color}/g" index.theme

  cd ${dest}
  gtk-update-icon-cache ${name}${color}
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

install_base() {
  local dest=${1}

  [[ -d ${dest}/Vimix-Paper ]] && rm -rf ${dest}/Vimix-Paper
  [[ -d ${dest}/Vimix-Old ]] && rm -rf ${dest}/Vimix-Old

  cp -ur ${SRC_DIR}/Vimix-Paper ${dest}
  cp -ur ${SRC_DIR}/Vimix-Old   ${dest}

  cd ${dest}
  gtk-update-icon-cache Vimix-Paper
  gtk-update-icon-cache Vimix-Old
}

install_base "${dest:-${DEST_DIR}}"

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
done

echo
echo Done.


