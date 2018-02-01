#! /bin/bash

show_question() {
  echo -e "\033[1;34m$@\033[0m"
}

show_dir() {
  echo -e "\033[1;32m$@\033[0m"
}

show_error() {
  echo -e "\033[1;31m$@\033[0m"
}

end() {
  echo -e "\nExiting...\n"
  exit 0
}

continue() {
  show_question "\nDo you want to continue? (Y)es, (N)o : \n"
  read INPUT
  case $INPUT in
    [Yy]* ) ;;
    [Nn]* ) end;;
    * ) show_error "\nSorry, try again."; continue;;
  esac
}

replace() {
  show_question "\nFound an existing installation. Replace it? (Y)es, (N)o :\n" 
  read INPUT
  case $INPUT in
    [Yy]* ) rm -rf $DEST_DIR/*Vimix;;
    [Nn]* ) ;;
    * ) show_error "\nSorry, try again."; replace $@;;
  esac
}

setup() {
  show_question "\nDo you want to set the theme now? (Y)es, (N)o : \n"
  read INPUT
  case $INPUT in
    [Yy]* ) themes;;
    [Nn]* ) end;;
    * ) show_error "\nSorry, try again."; setup;;
  esac
}

themes() {
  show_question "\n+------------------------------------------------------------------+

              (1)  Vimix
              (2)  Paper-Vimix

+------------------------------------------------------------------+\n"
  read INPUT
  case $INPUT in
    [1]* )  Vimix;;
    [2]* )  Paper-Vimix;;
    * ) show_error "\nSorry, try again."; themes;;
  esac
}

Vimix() {

# Set Vimix Icon Theme
  echo "Setting Vimix..."
  gsettings set org.gnome.desktop.interface icon-theme Vimix
  echo "Done!"

}

Paper-Vimix() {

# Set Vimix-Dark Icon Theme
  echo "Setting Paper-Vimix..."
  gsettings set org.gnome.desktop.interface icon-theme Paper-Vimix
  echo "Done!"

}

install() {

  # PREVIEW

  # Show destination directory
  echo -e "\nVimix Gtk Theme will be installed in:\n"
  show_dir "\t$DEST_DIR"
  if [ "$UID" -eq "$ROOT_UID" ]; then
    echo -e "\nIt will be available to all users."
  else
    echo -e "\nIf you want to make them available to all users, run this script as root."
  fi

  continue

  # INSTALL

  # Check destination directory
  if [ ! -d $DEST_DIR ]; then
    mkdir -p $DEST_DIR
  elif [[ -d $DEST_DIR/Vimix && -d $DEST_DIR/Paper-Vimix ]]; then
    replace $DEST_DIR
  fi

  echo -e "\nInstalling Vimix..."
  
  # Copying files

  cp -a Vimix Paper-Vimix $DEST_DIR

  # update icon caches

  update-icon-cache $DEST_DIR/Vimix $DEST_DIR/Paper-Vimix

  echo -e "\nInstallation complete!"

  setup

}

remove() {

  # PREVIEW

  # Show installation directory
  if [[ -d $DEST_DIR/Vimix && -d $DEST_DIR/Paper-Vimix ]]; then
    echo -e "\nVimix Icon Theme installed in:\n"
    show_dir "\t$DEST_DIR"
    if [ "$UID" -eq "$ROOT_UID" ]; then
      echo -e "\nIt will remove for all users."
    else
      echo -e "\nIt will remove only for current user."
    fi

    continue
  
  else
    show_error "\nVimix Icon Theme is not installed in:\n"
    show_dir "\t$DEST_DIR\n"
    end
  fi

  # REMOVE

  echo -e "\nRemoving Vimix ..."

  # Removing files

  rm -rf $DEST_DIR/*Vimix

  echo "Removing complete!"
  echo "I hope to see you soon."
}

main() {
  show_question "What you want to do: (I)nstall, (R)emove : \n"
  read INPUT
  case $INPUT in
    [Ii]* ) install;;
    [Rr]* ) remove;;
    * ) show_error "\nSorry, try again."; main;;
  esac
}

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.icons"
fi

echo -e "\e[1m\n+----------------------------------------------+"
echo -e "|      Vimix Icon Theme Installer Script       |"
echo -e "+----------------------------------------------+\n\e[0m"

main
