#!/bin/bash

function ctrl_c(){
  echo -e "[+] Saliendo...\n"
  tput cnorm && exit 1
}

#CTRL_C
trap ctrl_c INT

function helpPanel(){
  echo -e "\nSe muestra el panel de ayuda:"
  echo -e "\t[+] -h: Muestra el panel de ayuda."
  echo -e "\t[+] -u: Actualiza o Descarga los archivos necesarios para el script."
  echo -e "\t[+] -m: Muestra la información de la máquina indicada."
  echo
}

function updateFile(){
  if [ ! -f "bundle.js" ]; then
    tput civis
    echo -e "\n[+] Descargando el archivo bundle.js..."
    curl -s $url > bundle.js && js-beautify bundle.js | sponge bundle.js
    echo -e "[+] Descarga completa.\n"
    tput cnorm
  else
    curl -s $url > bundle-temp.js && js-beautify bundle-temp.js | sponge bundle-temp.js
    hash_temp="$(md5sum bundle-temp.js | awk '{print $1}')"
    hash_orig="$(md5sum bundle.js | awk '{print $1}')"
    if [ "$hash_temp" != "$hash_orig" ]; then
      echo -e "[+] Se detectaron actualizaciones"
      echo -e "[+] Se actualizará el archivo bundle.js..."
      rm bundle.js && mv bundle-temp.js bundle.js
      echo -e "[+] Se actualizó el archivo bundle.js."
    else
      echo -e "[+] No se detectaron actualizaciones."
      rm bundle-temp.js
    fi 
  fi
}

function searchMachine(){
  checkMachine="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "sku:|id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/ //g')"
  if [ "$checkMachine" ]; then
    echo -e "\nMostrando los datos de la máquina $machineName:\n"
    cat bundle-temporal.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "sku:|id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/ //g'
  else
    echo -e "\nNo se encontró la máquina $machineName"
  fi
  echo
}

#Variables
url="https://htbmachines.github.io/bundle.js"
declare -i parameter=0

while getopts "m:uh" opt; do
  case $opt in
    m) machineName="$OPTARG"; parameter=1;;
    u) parameter=2;;
    h);;
  esac
done

if [ $parameter -eq 0 ]; then
  helpPanel
elif [ $parameter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter -eq 2 ]; then
  updateFile $url
fi