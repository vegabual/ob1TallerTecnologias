#!/bin/bash

# Comienzo Obligatorio 1 - Taller
archivo=basegestor.txt
cantPartidosSesion=0
equipos=()
partidos=()

# Colores para impresion en pantalla
rojo="\u001B[0;31m"
amarillo="\033[0;33m"
celeste="\033[0;36m"
verde="\033[0;32m"
reset="\033[0m"

comienzoScript(){
  imprimirColor "********************************"
  imprimirColor "* Bienvenidos al obligatorio 1 *"
  imprimirColor "*    Trabajo realizado por:    *"
  imprimirColor "*   Gonzalo Ferrari - 288461   *"
  imprimirColor "*  Veronica Busiello - 212712  *"
  imprimirColor "********************************"

  if [ ! -e $archivo ]; then
    cargaInicialDatos
  fi
  obtenerEquiposDeArchivo
  obtenerPartidosDeArchivo
  menu
}

#Carga los datos iniciales al archivo
cargaInicialDatos(){
  echo campeon,Argentina >> $archivo
  echo equipo,Uruguay >> $archivo
  echo equipo,Argentina >> $archivo
  echo equipo,Brasil >> $archivo
  echo partido,Uruguay 2 Brasil 0 2026-06-15 >> $archivo
  echo partido,Argentina 1 Brasil 3 2026-06-23 >> $archivo
}

menu(){
  local opcion=-1
  while [ "$opcion" -ne 0 ]; do
    imprimirColor "              MENU"
    imprimirColor "--------------------------------"
    echo ""
    echo "[1] Listar equipos"
    echo "[2] Mostrar campeon mundial"
    echo "[3] Registrar equipo"
    echo "[4] Registrar partido"
    echo "[5] Ver historial partidos"
    echo "[6] Buscar equipo"
    echo "[7] Cantidad de partidos jugados"
    echo "[8] Borrar equipos sin partidos"
    echo "[0] Salir"
    echo ""

    opcion=$(leerNumero "[>] Ingrese la opcion del menu: ")
    imprimirColor "--------------------------------"

    case $opcion in
      1)
        listarEquiposDisponibles
      ;;
      2)
        mostrarCampeonMundial
      ;;
      3)
        registrarEquipo
      ;;
      4)
        registrarPartido
      ;;
      5)
        listarPartidos
      ;;
      6)
        buscarEquipo
      ;;
      7)
        cantidadPartidos
      ;;
      8)
        borrarEquipos
      ;;
      0)
        imprimirExito "[+] Gracias por utilizar nuestro sistema"
      ;;
      *)
        imprimirError "[x] Opcion incorrecta, intenta de nuevo"
      ;;
    esac
    imprimirColor "--------------------------------"
  done
}

#funcionalidades

listarEquiposDisponibles(){
  imprimirExito "[+] Equipos disponibles \n"
  listarEquipos
}

mostrarCampeonMundial(){
  campeon=$(grep 'campeon,' $archivo | cut -d ',' -f2)

  if [ -z "$campeon" ]; then
    imprimirWarning "[!] Aún no hay un campeón registrado"
  else
    imprimirExito "[+] El campeon actual es $campeon"
  fi
}

registrarEquipo(){
  local input
  read -r -p "[>] Ingrese el nombre del equipo a registrar: " input
  input=${input,,}
  input=${input^}

  if [[ "${equipos[@]}" =~ $input ]]; then
    imprimirError "[x] Ese equipo ya se encuentra registrado"
  elif [[ $input =~ ^[0-9]+$ ]]; then
    imprimirError "[x] Debe escribir el nombre del equipo"
  else
    if [[ ${#equipos[@]} -ge 15 ]]; then
      imprimirWarning "[!] Los equipos ingresados no deben superar los 15 en total"
    fi

    echo equipo,$input >> $archivo
    obtenerEquiposDeArchivo
    imprimirExito "[+] Equipo registrado correctamente"
  fi
}

registrarPartido(){
  if [ ${#equipos[@]} -ge 2 ]; then 
    local equipo1
    local equipo2
    local goles1
    local goles2
    local fecha
    local partidosFecha=()
  
    equipo1=$(pedirEquipo)
    equipo1=$(($equipo1 - 1))
    equipo2=$(pedirEquipo)
    equipo2=$(($equipo2 - 1))
  
    while [ "$equipo1" -eq "$equipo2" ]; do
      imprimirError "[x] Se ingreso el mismo equipo de contrincante, vuelva a seleccionar un equipo"
      equipo2=$(pedirEquipo)
      equipo2=$(($equipo2 - 1))
    done
  
    goles1=$(leerNumero "[>] Ingrese los goles realizados por ${equipos[$equipo1]}: ")
    goles2=$(leerNumero "[>] Ingrese los goles realizados por ${equipos[$equipo2]}: ")
    fecha=$(leerFecha)

    for p in "${partidos[@]}"; do
      read e1 g1 e2 g2 f <<< "$p"
      if [[ "$f" == "$fecha" ]]; then
        partidosFecha+=($p)
      fi
    done

    if [[ "${partidosFecha[@]}" =~ $equipo1 || "${partidosFecha[@]}" =~ $equipo2 ]]; then
      imprimirError "[x] Uno de los equipos ya juega ese día"
    else
      echo "partido,${equipos[$equipo1]} $goles1 ${equipos[$equipo2]} $goles2 $fecha" >> $archivo
      ((cantPartidosSesion++))
      obtenerPartidosDeArchivo
      imprimirExito "[+] Se registro correctamente el partido"
    fi
  else
    imprimirError "[x] Deben haber al menos 2 equipos registrados. Actualmente hay ${#equipos[@]}"
  fi
}

cantidadPartidos(){
  if [[ $cantPartidosSesion -lt 1 ]]; then
    imprimirWarning "[!] No se han jugado partidos en esta sesión aún"
  elif [[ $cantPartidosSesion -eq 1 ]]; then
    imprimirExito "[+] Se jugó $cantPartidosSesion partido en esta sesion"
  else
    imprimirExito "[+] Se jugaron $cantPartidosSesion partidos en esta sesion"
  fi
}

buscarEquipo(){
  local input
  read -r -p "[>] Ingrese el nombre del equipo a buscar: " input
  input=${input,,}
  input=${input^}

  if [[ "${equipos[@]}" =~ $input ]]; then
    imprimirExito "[+] Ese equipo se encuentra registrado"
  else
    imprimirWarning "[!] El equipo ingresado no se encuentra registrado"
  fi
}

borrarEquipos(){
  equiposActivos=()
  for p in "${partidos[@]}"; do
    read equipo1 goles1 equipo2 goles2 fecha <<< "$p"
    if [[ "${equipos[@]}" =~ $equipo1 && ! "${equiposActivos[@]}" =~ $equipo1 ]]; then
      equiposActivos+=($equipo1)
    fi
    if [[ "${equipos[@]}" =~ $equipo2 && ! "${equiposActivos[@]}" =~ $equipo2 ]]; then
      equiposActivos+=($equipo2)
    fi
  done

  for e in "${equipos[@]}"; do
    if [[ ! "${equiposActivos[@]}" =~ $e ]]; then
      sed -i "/$e/d" $archivo
      obtenerEquiposDeArchivo
    fi
  done

  imprimirExito "[+] Equipos sin partidos eliminados con éxito"
}

#Metodos auxiliares
obtenerEquiposDeArchivo(){
  mapfile -t equipos < <(awk -F ',' '$1 == "equipo" { print $2 }' "$archivo")
}

obtenerPartidosDeArchivo(){
  mapfile -t partidos < <(awk -F ',' '$1 == "partido" { print $2 }' "$archivo")
}

#Metodos auxiliares para pedir datos
leerStringNoVacio(){
  local pedido="$1"
  local input

  read -r -p "$pedido" input

  while [ -z "$input" ]; do
    imprimirError "[x] Está vacio, intentá de nuevo"
    read -r -p "$pedido " input
  done

  echo "$input"
}

leerNumero(){
  local pedido="$1"
  local num

  num=$(leerStringNoVacio "$pedido")

  while [[ ! $num =~ ^[0-9]+$ ]]; do
    imprimirError "[x] No es un numero, intenta de nuevo"
    num=$(leerStringNoVacio "$pedido")
  done

  echo "$num"
}

leerEquipo(){
  local pedido="$1"
  local eq

  eq=$(leerNumero "$pedido")
  
  while [[ ! ( $eq -gt 0 && $eq -le ${#equipos[@]} ) ]]; do
    imprimirError "[x] No es un equipo valido, intenta de nuevo"
    eq=$(leerNumero "$pedido")
  done

  echo "$eq"
}

pedirEquipo(){
  local equipo
  
  listarEquipos
  
  equipo=$(leerEquipo "[>] Elegir equipo: ")
  
  echo "$equipo"
}

leerFecha() {
  local fecha
  read -r -p "[>] Ingrese la fecha del partido (YYYY-mm-dd): " fecha

  if [[ "$fecha" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$fecha" "+%Y-%m-%d" >/dev/null 2>&1; then
    echo $fecha
  else
    imprimirError "[x] La fecha debe contener un formato válido"
    leerFecha
  fi
}

#Metodos auxiliares para impresion en pantalla
listarEquipos(){
  indice=1

  if [ ${#equipos[@]} -eq 0 ]; then
    imprimirWarning "[!] Aún no existen equipos registrados"
  fi

  for e in "${equipos[@]}"; do
    echo "[$indice] - $e" >&2
    indice=$(($indice + 1))
  done
}

listarPartidos(){
  if [ ${#partidos[@]} -eq 0 ]; then
    imprimirWarning "[!] Aún no existen partidos registrados"
  fi

  for p in "${partidos[@]}"; do
    read equipo1 goles1 equipo2 goles2 fecha <<< "$p"
    echo "$fecha: $equipo1: $goles1 - $equipo2: $goles2" >&2
  done
}

#Metodos auxiliares para imprimir a color
imprimirError(){
  local texto="$1"
  echo -e "${rojo}$texto${reset}" >&2
}

imprimirWarning(){
  local texto="$1"
  echo -e "${amarillo}$texto${reset}" >&2
}

imprimirExito(){
  local texto="$1"
  echo -e "${verde}$texto${reset}" >&2
}

imprimirColor(){
  local texto="$1"
  echo -e "${celeste}$texto${reset}" >&2
}

#Comienzo del programa
comienzoScript
