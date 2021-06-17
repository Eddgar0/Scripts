#!/bin/bash
#Script para renombrar archivos de series cursos que sean utiles para el formato de plex.
#By  Eddgar Rojas
#env  Bash Shell

course_name=${PWD##*/}
seasons=""

rename_season(){
# Funcion  para cambiar los directorios de  nombre a  temporada con formato s# donde # es numero entero
    local counter=1
    local season_number=""
    local season_name=""
    local dir=""
    echo "cambiando nombre directorios a numero de temporadas"
    for dir in [0-9]*
    do
        season_number=$( printf "%02d" counter )
        season_name="s${season_number}"
        echo "renombrando ${dir} --> ${season_name}"
        mv  "${dir}" "${season_name}"
        ((counter++))
    done
    echo "Directorios cambiados"
    echo "$(ls -d s*)"
}

 
rename_episode(){
# Funcion para renombrar espisodios previamente ordenados numericamente a formato usable para plex
    local counter=1
    local episode_number=""
    local episode_name=""
    local ep=""
    echo "cambiando nombres de archivos"
    for ep in [0-9]*
    do
        episode_number=$(printf "%02d" counter)
        episode_name="${ep#*[!A-Za-z0-9]}"
        echo "renombrado ${ep} --> ${1} - ${2}e${episode_number} - ${episode_name}"
        mv  "${ep}" "$1 - $2e${episode_number} - ${episode_name}"
        ((counter++))
    done
    
    echo "Archivos renombrados"
}



#main script

echo "Corrigiendo nombres"
echo "nombre del curso: ${course_name}"


rename_season

seasons=($(ls -d s*)

for season in "${seasons[@]}"
do
    cd "${season}"
    rename_episode $course_name $season
    cd ..
done

