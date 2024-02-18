#!/bin/bash

function ctrl_c(){
  echo -e "[+] Saliendo...\n"
  exit 1
}

#CTRL_C
trap ctrl_c INT

function helpPanel(){
  echo -e "\nSe muestra el panel de ayuda:"
  echo -e "\t[+] -h: Muestra el panel de ayuda."
  echo -e "\t[+] -m: Muestra la información de la máquina indicada."
  echo
}

function searchMachine(){
  checkMachine="$(cat bundle-temporal.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "sku:|id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/ //g')"
  if [ "$checkMachine" ]; then
    echo -e "\nMostrando los datos de la máquina $machineName:"
    cat bundle-temporal.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "sku:|id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/ //g'
  else
    echo -e "\nNo se encontró la máquina $machineName"
  fi
  echo
}

#Variables
declare -i parameter=0

while getopts "m:h" opt; do
  case $opt in
    m) machineName="$OPTARG"; parameter=1;;
    h);;
  esac
done

if [ $parameter -eq 0 ]; then
  helpPanel
elif [ $parameter -eq 1 ]; then
  searchMachine $machineName
fi