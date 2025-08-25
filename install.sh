#!/bin/bash

if [[ ${UID} -eq 0 ]]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="${HOME}/.local/share/icons"
fi

declare SRC_DIR
SRC_DIR=$(cd "$(dirname "${0}")" && pwd)

declare -r COLOR_VARIANTS=("standard" "amber" "amethyst" "axinite" "beryl" "doder" "ruby" "jade" "black" "white")
declare -r BRIGHT_VARIANTS=("" "dark")

function usage {
  printf "%s\n" "Usage: $0 [OPTIONS...] [COLOR VARIANTS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-a" "Install all color folder versions"
  printf "  %-25s%s\n" "-d DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n NAME" "Specify theme name (Default: Vimix)"
  printf "  %-25s%s\n" "-h" "Show this help"
  printf "\n%s\n" "COLOR VARIANTS:"
  printf "  %-25s%s\n" "standard" "Standard color folder version"
  printf "  %-25s%s\n" "amber" "Orange color folder version"
  printf "  %-25s%s\n" "amethyst" "Purple color folder version"
  printf "  %-25s%s\n" "axinite" "Brown color folder version"
  printf "  %-25s%s\n" "beryl" "Teal color folder version"
  printf "  %-25s%s\n" "doder" "Blue color folder version"
  printf "  %-25s%s\n" "ruby" "Red color folder version"
  printf "  %-25s%s\n" "jade" "Green color folder version"
  printf "  %-25s%s\n" "black" "Black color folder version"
  printf "  %-25s%s\n" "white" "White color folder version"
  printf "\n  %s\n" "By default, only the standard one is selected."
}

function install_folder_colors {
    echo "Copying available folder color variants..."
    local THEME_DIR="${1}"
    local SRC_DIR=$(cd "$(dirname "${0}")" && pwd)

    declare -A COLOR_MAP
    COLOR_MAP=(
        ["amber"]="orange"
        ["amethyst"]="violet"
        ["axinite"]="brown"
        ["beryl"]="cyan"
        ["doder"]="blue"
        ["jade"]="green"
        ["ruby"]="red"
        ["black"]="grey"
        ["white"]="white"
    )

    for color_variant in "${!COLOR_MAP[@]}"; do
        local src_file="${SRC_DIR}/src/colors/color-${color_variant}/default-folder.svg"

        if [[ -f "${src_file}" ]]; then
            for dolphin_color_name in ${COLOR_MAP[${color_variant}]}; do
                local dest_file="${THEME_DIR}/scalable/places/folder-${dolphin_color_name}.svg"
                cp -f "${src_file}" "${dest_file}"
            done
        else
            echo "  -> Warning: Source file not found for ${color_variant}: ${src_file}"
        fi
    done

    local src_file_standard="${SRC_DIR}/src/scalable/places/default-folder.svg"
    local dest_file_standard="${THEME_DIR}/scalable/places/folder-yellow.svg"
    if [[ -f "${src_file_standard}" ]]; then
        cp -f "${src_file_standard}" "${dest_file_standard}"
    fi
}

function install_theme {
  case "$1" in
    standard)
      local -r theme_color='#F4BE70'
      ;;
    amber)
      local -r theme_color='#F89406'
      ;;
    amethyst)
      local -r theme_color='#AB47BC'
      ;;
    axinite)
      local -r theme_color='#8B6039'
      ;;
    beryl)
      local -r theme_color='#2EB398'
      ;;
    black)
      local -r theme_color='#686868'
      ;;
    doder)
      local -r theme_color='#4285F4'
      ;;
    jade)
      local -r theme_color='#86BE43'
      ;;
    ruby)
      local -r theme_color='#F0544C'
      ;;
    white)
      local -r theme_color='#AAAAAA'
      ;;
  esac

  # Appends a dash if the variables are not empty
  if [[ "${1}" != "standard" ]]; then
    local -r colorprefix="-${1}"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${NAME}${colorprefix}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [[ -d "${THEME_DIR}" ]]; then
    rm -rf "${THEME_DIR}"
  fi

  echo "Installing '${THEME_NAME}'..."

  install -d "${THEME_DIR}"

  install -m644 "${SRC_DIR}/src/index.theme" "${THEME_DIR}"

  # Update the name in index.theme
  sed -i "s/%NAME%/${THEME_NAME}/g" "${THEME_DIR}/index.theme"

  if [[ -z "${brightprefix}" ]]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,scalable,symbolic} "${THEME_DIR}"
    sed -i "s/#5294e2/$theme_color/g" "${THEME_DIR}"/16/places/*
    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic} "${THEME_DIR}"
    if [[ -n "${colorprefix}" ]]; then
      install -m644 "${SRC_DIR}"/src/colors/color"${colorprefix}"/*.svg "${THEME_DIR}/scalable/places"
    fi
  else
    local -r STD_THEME_DIR="${THEME_DIR%-dark}"

    install -d "${THEME_DIR}"/{16,22,24}

    cp -r "${SRC_DIR}"/src/16/{actions,devices,places} "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/src/22/{actions,devices,places} "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/src/24/{actions,devices,places} "${THEME_DIR}/24"

    # Change icon color for dark theme
    sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*
    sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*
    sed -i "s/#5294e2/$theme_color/g" "${THEME_DIR}"/16/places/*

    cp -r "${SRC_DIR}"/links/16/{actions,devices,places} "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/links/22/{actions,devices,places} "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/links/24/{actions,devices,places} "${THEME_DIR}/24"

    # Link the common icons
    ln -sr "${STD_THEME_DIR}/scalable" "${THEME_DIR}/scalable"
    ln -sr "${STD_THEME_DIR}/symbolic" "${THEME_DIR}/symbolic"
    ln -sr "${STD_THEME_DIR}/32" "${THEME_DIR}/32"
    ln -sr "${STD_THEME_DIR}/16/mimetypes" "${THEME_DIR}/16/mimetypes"
    ln -sr "${STD_THEME_DIR}/16/panel" "${THEME_DIR}/16/panel"
    ln -sr "${STD_THEME_DIR}/16/status" "${THEME_DIR}/16/status"
    ln -sr "${STD_THEME_DIR}/22/categories" "${THEME_DIR}/22/categories"
    ln -sr "${STD_THEME_DIR}/22/emblems" "${THEME_DIR}/22/emblems"
    ln -sr "${STD_THEME_DIR}/22/mimetypes" "${THEME_DIR}/22/mimetypes"
    ln -sr "${STD_THEME_DIR}/22/panel" "${THEME_DIR}/22/panel"
    ln -sr "${STD_THEME_DIR}/24/animations" "${THEME_DIR}/24/animations"
    ln -sr "${STD_THEME_DIR}/24/panel" "${THEME_DIR}/24/panel"
  fi

  ln -sr "${THEME_DIR}/16" "${THEME_DIR}/16@2x"
  ln -sr "${THEME_DIR}/22" "${THEME_DIR}/22@2x"
  ln -sr "${THEME_DIR}/24" "${THEME_DIR}/24@2x"
  ln -sr "${THEME_DIR}/32" "${THEME_DIR}/32@2x"
  ln -sr "${THEME_DIR}/scalable" "${THEME_DIR}/scalable@2x"

  install_folder_colors "${THEME_DIR}"

  cp -r "${SRC_DIR}/src/cursors/dist${brightprefix}" "${THEME_DIR}/cursors"
  gtk-update-icon-cache "${THEME_DIR}"
}

function clean_old_theme {
  rm -rf "${DEST_DIR}"/Vimix{'-Amber','-Amethyst','-Axinite','-Beryl','-Doder','-Ruby','-Jade','-Black','-White'}{'','-dark'}
}

while [[ $# -gt 0 ]]; do
  if [[ "${1}" = "-a" ]]; then
    colors=("${COLOR_VARIANTS[@]}")
  elif [[ "${1}" = "-d" ]]; then
    DEST_DIR="${2}"
    shift 2
  elif [[ "${1}" = "-n" ]]; then
    NAME="${2}"
    shift 2
  elif [[ "${1}" = "-h" ]]; then
    usage
    exit 0
  # If the argument is a color variant, append it to the colors to be installed
  elif [[ " ${COLOR_VARIANTS[*]} " = *" ${1} "* ]] &&
    [[ "${colors[*]}" != *${1}* ]]; then
    colors+=("${1}")
  else
    echo "ERROR: Unrecognized installation option '${1}'."
    echo "Try '$0 -h' for more information."
    exit 1
  fi

  shift
done

# Default name is 'Vimix'
: "${NAME:=Vimix}"

clean_old_theme

# By default, only the standard color variant is selected
for color in "${colors[@]:-standard}"; do
  for bright in "${BRIGHT_VARIANTS[@]}"; do
    install_theme "${color}" "${bright}"
  done
done

# EOF
