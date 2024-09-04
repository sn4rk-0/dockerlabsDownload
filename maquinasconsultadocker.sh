#!/usr/bin/bash
greenColour="\e[0;32m\033[1m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turqueColour="\e[0;36m\033[1m"
grayColour="\e[1;30m\033[1m"
endColour="\033[0m\e[0m"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}"
}

# ctrl_c
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${yellowColour}[!] Uso:${endColour}${greenColour} ./$0 [- parametro] [options]${endColour}"
  echo -e "\t${redColour}-f${endColour}${grayColour} Descargar fichero de maquinas ${endColour}"
  echo -e "\t${redColour}-u${endColour}${grayColour} Actualizar fichero${endColour}"
  echo -e "\t${redColour}-b${endColour}${grayColour} Buscar maquina por nombre${endColour}${purpleColour}[nombre]${endColour}"
  echo -e "\t${redColour}-n${endColour}${grayColour} Buscar maquinas por niveles${endColour}${purpleColour} [muy facil, fácil, medio, dificil]${endColour}"

  echo -e "\t${redColour}-d${endColour}${grayColour} Descargar maquina${endColour}${purpleColour} [URL]${endColour}"
}

function downloadfichero(){
  if [ ! -f "machinesdockerlabs" ]; then
    echo -e "\n${yellowColour}[!]${endColour} ${grayColour}Descargando fichero de maquinas de Dockerlabs.es${endColour}"
    sleep 2
    
    curl -s https://dockerlabs.es | grep -E 'presentacion|window.open' > machinesdockerlabs
    
    echo -e "\n${greenColour}[!] Fichero generado exitosamente.${endColour}"
  else          
    echo -e "\n${greenColour}[+] El fichero ya existe.${endColour}"
  fi
}

function updatefile(){
  if [ -f machinesdockerlabs ]; then
    file_md5="$(md5sum machinesdockerlabs | awk '{print $1}')"

     curl -s https://dockerlabs.es | grep -E 'presentacion|window.open' > machinesdockerlabs_temp

    file_md5_temp="$(md5sum machinesdockerlabs_temp | awk '{print $1}')"
 
    if [ $file_md5 = $file_md5_temp ]; then
      echo -e "\n${greenColour}[+] No se encontraron actualizaciones${endColour}"
    else
      echo -e "\n${redColour}[!]${endColour} ${grayColour}Actualizando fichero de maquina${endColour}"
      sleep 2
      mv machinesdockerlabs_temp machinesdockerlabs
      echo -e "\n${greenColour}[+] Fichero actualizado correctamente.${endColour}"
    fi
    rm machinesdockerlabs_temp 2>/dev/null
  else
    echo -e "\n${redColour}[X] No existe machinesdockerlabs...${endColour}"
  fi
}

function buscar_machine_name(){
  if [ -f machinesdockerlabs ];then
    nameall="$(echo $1 | sed 's/ /\\s/g')"
    name_machine="$(grep -E 'presentacion|window.open' machinesdockerlabs | grep -i -oP "ion\('\K[^']*$nameall[^']*'" | tr -d "'")"

    nivel_machine="$(grep -E 'presentacion|window.open' machinesdockerlabs | grep -i -oP "ion\(.*?$nameall.*?', '.*?', '#"|sed "s/, '#//g" | awk 'NF{print $NF}' FS="," | tr -d "'")"

    link_machine="$(grep -E 'presentacion|window.open' machinesdockerlabs | grep -i -P "ion\('\K[^']*$nameall[^']*'" -A 1 |grep -oP "https://mega.*?'" | tr -d "'")"
    paste -d'\n' <(echo "$name_machine") <(echo "$nivel_machine") <(echo "$link_machine") <(echo -e "\n") 
  else
    echo -e "\n${redColour}[x] No se pudo encontrar el fichero machinesdockerlabs${endColour}"
    echo -e "\n${yellowColour}[+] Para solucionar usa el parametro -f o -h para para la ayuda{endColour}"
  fi
}

function buscar_machine_level(){
  if [ -f machinesdockerlabs ]; then
    nameall="$1"
    words="facil Facil fácil Fácil"
    words2="muy Muy"
    if [ "$(echo "$words" | grep -q "$nameall"; echo $?)" -eq 0 ]; then
      nameall='f.cil'
    elif [ "$(echo "$words2" | grep -q "$nameall"; echo $?)" -eq 0 ];then
      nameall="muy\sfácil"
    fi
    machine_level="$(grep -E 'presentacion|window.open' machinesdockerlabs | grep -i -oP "ion\('.*?', '*$nameall[^']*'" | sed 's/ion(//g' | tr -d "'" | sed 's/,/ ->/g')"
    links="$(grep -E 'presentacion|window.open' machinesdockerlabs | grep -i -P "ion\('.*?', '*$nameall[^']*'" -A 1 | grep -oP "https://mega.*?'," | tr -d "',")"

    paste -d'\n' <(echo "$machine_level") <(echo "$links") <(echo -e "\n")
  else
    echo -e "\n${redColour}[x] No se pudo encontrar el fichero machinesdockerlabs${endColour}"
    echo -e "\n${yellowColour}[+] Para solucionar usa el parametro -f o -h para para la ayuda{endColour}"
  fi
}

function downloadMachine(){
  url="$1"
  if [ ! command -v megadl &> /dev/null ]; then
    echo "megacmd no está instalado."
    echo -e "[-] Instalando megatools...."
#    sudo apt-get update
    sudo apt-get install megatools
    clear
    echo -e "[+] Instalado correctamente megatools."
  fi
  echo -e "\n${yellowColour}[*] Descargando maquina de dockerlabs.es${endColour}"
  
  /usr/bin/megadl $url
  echo -e "\n${greenColour}[*] Descarga completada.${endColour}"
}

#indicadores
declare -i parameter_counter=0

while getopts "fub:n:d:h" arg;do
  case $arg in
    f) let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    b) machine_name="$OPTARG"; let parameter_counter+=3;;
    n) level=$OPTARG; let parameter_counter+=4;;
    d) url="$OPTARG"; let parameter_counter+=5;;
    h) helpPanel;;
  esac
done

if [ $# -eq 0 ]; then
  helpPanel
elif [ $parameter_counter -eq 1 ]; then
  downloadfichero
elif [ $parameter_counter -eq 2 ]; then
  updatefile
elif [ $parameter_counter -eq 3 ]; then
  buscar_machine_name "$machine_name"
elif [ $parameter_counter -eq 4 ]; then
  buscar_machine_level "$level"
elif [ $parameter_counter -eq 5 ]; then
  downloadMachine "$url"  
fi







