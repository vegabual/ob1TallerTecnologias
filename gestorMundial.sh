#!/bin/bash

#Comienzo Obligatorio1 taller 

archivo=basegestor.txt
cantPartidosSesion=0
equipos=()

#colores para impresion en pantalla
rojo="\u001B[0;31m"
amarillo="\033[0;31m"
celeste="\033[0;36m"
verde="\033[0;32m"
reset="\033[0m"

comienzoScript(){
  imprimirColor "********************************"
  imprimirColor "* Bienvenido all obligatorio 1 *"
  imprimirColor "*    Trabajo realizado por:    *"
  imprimirColor "*   Gonzalo Ferrari - 288461   *"
  imprimirColor "*  Veronica Busiello - 212712  *"
  imprimirColor "********************************"

  if [ ! -e $archivo ]; then
    cargaInicialDatos
  fi
  obtenerEquipos
  menu
}

#Carga los datos iniciales al archivo
cargaInicialDatos(){
  echo campeon-Argentina >> $archivo
  echo equipo-Uruguay >> $archivo
  echo equipo-Argentina >> $archivo
  echo equipo-Brasil >> $archivo
  echo partido-Uruguay 2 Brasil 0 >> $archivo
}

menu(){
  local opcion=-1
  while [ "$opcion" -ne 0 ]; do
    echo "1 - Listar equipos"
    echo "2 - Mostrar campeon mundial"
    echo "3 - Registrar equipo"
    echo "4 - Registrar partido"
    echo "5 - Ver historial partidos"
    echo "6 - Buscar equipo"
    echo "7 - Cantidad de partidos jugados"
    echo "0 - Salir"

    opcion=$(leerNumero "Ingrese la opcion del menu")

    case $opcion in
      1)
        echo "listarEquipos"
      ;;
      2)
        mostrarCampeonMundial
      ;;
      3)
        echo "registrarEquipo"
      ;;
      4)
        registrarPartido
      ;;
      5)
        echo "verHistorial"
      ;;
      6)
        echo "buscarPartido"
      ;;
      7)
        cantidadPartidos
      ;;
      0)
        imprimirColor "Gracias por jugar"
      ;;
      *)
        imprimirError "Opcion incorrecta"
      ;;
    esac
  done
}

#funcionalidades
mostrarCampeonMundial(){
  campeon=$(grep 'campeon-' $archivo | cut -d '-' -f2)
  imprimirExito "El campeon actual es $campeon"
}

registrarPartido(){
  local equipo1
  local equipo2
  local goles1
  local goles2
  
  equipo1=$(pedirEquipo)
  equipo1=$(($equipo1 - 1))
  equipo2=$(pedirEquipo)
  equipo2=$(($equipo2 - 1))
  
  while [ $equipo1 -eq $equipo2 ]; do
    imprimirError "Se ingreso el mismo equipo de contrincante, vuelva a seleccionar un equipo"
    equipo2=$(pedirEquipo)
    equipo2=$(($equipo2 - 1))
  done
  
  goles1=$(leerNumero "Ingrese los goles realizaodos por ${equipos[$equipo1]}")
  goles2=$(leerNumero "Ingrese los goles realizaodos por ${equipos[$equipo2]}")
  
  echo "partido-${equipos[$equipo1]} $goles1 ${equipos[$equipo2]} $goles2" >> $archivo
  cantPartidosSesion=$(($cantPartidosSesion+1))
  imprimirExito "Se registro correctamente el partido"
}

cantidadPartidos(){
  imprimirExito "Se jugaron $cantPartidosSesion partidos en esta sesion"
}

#Metodos auxiliares
obtenerEquipos(){
  mapfile -t equipos < <(awk -F '-' '$1 == "equipo" { print $2 }' "$archivo")
}

#Metodos auxiliares para pedir datos
leerStringNoVacio(){
  local pedido="$1"
  local input

  read -r -p "$pedido: " input
  while [ -z "$input" ]; do
    imprimirError "Está vacio, intentá de nuevo"
    read -r -p "$pedido " input
  done

  echo "$input"
}

leerNumero(){
  local pedido="$1"
  local num

  num=$(leerStringNoVacio "$pedido")

  while [[ ! $num =~ ^[0-9]+$ ]]; do
    imprimirError "No es un numero, intenta de nuevo"
    num=$(leerStringNoVacio "$pedido")
  done

  echo "$num"
}

leerEquipo(){
  local pedido="$1"
  local eq

  eq=$(leerNumero "$pedido")
  
  while [[ ! ( $eq -gt 0 && $eq -le ${#equipos[@]} ) ]]; do
    imprimirError "No es un equipo valido, intenta de nuevo"
    eq=$(leerNumero "$pedido")
  done

  echo "$eq"
}

pedirEquipo(){
  local equipo
  
  listarEquipos
  
  equipo=$(leerEquipo "Elegir equipo")
  
  echo "$equipo"
}

#Metodos auxiliares para impresion en pantalla
listarEquipos(){
  indice=1
  for e in "${equipos[@]}"; do
    echo "$indice - $e" >&2
	indice=$(($indice + 1))
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