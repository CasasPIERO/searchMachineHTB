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
  echo -e "\t[+] -m: Muestra la información de la máquina indicada."
  echo -e "\t[+] -i: Muestra el nombre la máquina según la IP proporcionada."
  echo -e "\t[+] -d: Filtra por nivel de dificultad mostrando un listado de máquinas."
  echo -e "\t[+] -o: Filtra por el tipo de sistema operativo mostrando un listado de máquinas"
  echo -e "\t[+] -s: Filtra por la skill y muestra un listado de máquinas"
  echo -e "\t[+] -u: Actualiza o Descarga los archivos necesarios para el script."
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
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "sku:|id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/ //g'
  else
    echo -e "\nNo se encontró la máquina $machineName"
  fi
  echo
}

function filterMachine_IpAddres(){
  checkIpAddres="$(cat bundle.js | grep "ip: \"$ipAddres\"" -B 3 | grep "name:" | tr -d '"' | tr -d ',' | awk '{print $NF}')"
  if [ "$checkIpAddres" ]; then
    echo -e "La dirección IP $ipAddres pertenece a la máquina $checkIpAddres"
  else
    echo -e "La dirección IP $ipAddres no pertenece a ninguna máquina"
  fi
}

function filterMachines_LvlDifficulty(){
  checkDifficulty="$(grep "dificultad: \"$lvlDifficulty\"" -i -B 5 bundle.js | grep "name:" | tr -d '"' | tr -d ',' | awk '{print $NF}' | column)"
  if [ "$checkDifficulty" ]; then
    echo -e "\nMostrando las máquinas con dificultad $lvlDifficulty:\n"
    echo -e "$checkDifficulty"
    echo
  else
    echo -e "\nEl nivel de dificultad $lvlDifficulty no existe\n"
  fi
}

function filterMachines_OperatingSystem(){
  checkOperatingSystem="$(grep "so: \"$operatingSystem\"" -i -B 4 bundle.js | grep "name:" | tr -d '"' | tr -d ',' | awk '{print $NF}' | column)"
  if [ "$checkOperatingSystem" ]; then
    echo -e "\nMostrando las máquinas con sistema operativo $operatingSystem:\n"
    echo -e "$checkOperatingSystem"
    echo
  else
    echo -e "\nEl sistema operativo $operatingSystem no existe\n"
  fi
}

function filterMachines_Skills(){
  checkSkills="$(grep "$skillsMachine" -i -B 6 bundle.js | grep "name:" | tr -d '"' | tr -d "," | awk '{print $NF}' | column)"
  if [ "$checkSkills" ]; then
    echo -e "\nMostrando las máquinas donde se aplican la skill $skillsMachine:\n"
    echo -e "$checkSkills"
    echo
  else
    echo -e "\nNo hay máquinas donde se apliquen la skill $skillsMachine\n"
  fi
}

function filterMachines_OSandDifficulty(){
  checkOSandDifficulty="$(grep "so: \"$operatingSystem\"" -i -C 4 bundle.js | grep "dificultad: \"$lvlDifficulty\"" -i -B 5 | grep "name:" | tr -d '"' | tr -d ',' | awk '{print $NF}' | column)"
  if [ "$checkOSandDifficulty" ]; then
    echo -e "\nMostrando las máquinas con dificultad $lvlDifficulty y sistema operativo $operatingSystem:\n"
    echo -e "$checkOSandDifficulty"
    echo
  else
    echo -e "\nNo hay máquinas con dificultad $lvlDifficulty y sistema operativo $operatingSystem\n"
  fi
}

#Variables
url="https://htbmachines.github.io/bundle.js"
declare -i parameter=0

#flags
declare -i flag_d=0
declare -i flag_o=0

while getopts "m:ui:d:o:s:h" opt; do
  case $opt in
    m) machineName="$OPTARG"; parameter=1;;
    u) parameter=2;;
    i) ipAddres="$OPTARG"; parameter=3;;
    d) lvlDifficulty="$OPTARG"; flag_d=1; let parameter+=4;;
    o) operatingSystem="$OPTARG"; flag_o=1; let parameter+=5;;
    s) skillsMachine="$OPTARG"; parameter=6;;
    h);;
  esac
done

if [ $parameter -eq 0 ]; then
  helpPanel
elif [ $parameter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter -eq 2 ]; then
  updateFile $url
elif [ $parameter -eq 3 ]; then
  filterMachine_IpAddres $ipAddres
elif [ $parameter -eq 4 ]; then
  filterMachines_LvlDifficulty $lvlDifficulty
elif [ $parameter -eq 5 ]; then
  filterMachines_OperatingSystem $operatingSystem
elif [ $parameter -eq 6 ]; then
  filterMachines_Skills $skillsMachine
elif [ $flag_d -eq 1 ] && [ $flag_o -eq 1 ]; then
  filterMachines_OSandDifficulty $lvlDifficulty $operatingSystem
fi