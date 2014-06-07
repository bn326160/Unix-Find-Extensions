#!/bin/bash

#VARS


#FUNCTIONS
#Helpfunctie
function help() {
  echo "Helpfunctie"
  echo
  echo "Dit script gaat op zoek naar bestanden met een bepaalde extensie, in één of meerdere directories. De output geeft weer welke bestanden gevonden werden, gevolgd door de directory waar het respectievelijke bestand zich bevindt."
  echo
  echo "De het argument -e <ext> is vereist, anders is er geen opdracht."
  echo "Andere argumenten zijn de te doorzoeken directories."
  echo
  echo "Verder bevat dit script de volgende optionele argumenten:"
  echo "-h of --help geeft dit help-document weer."
  echo "-l <letter> zoekt enkel bestanden, die beginnen met de letter <letter>."
  echo "-l <letter1>-<letter2> doet hetzelfde, maar zoekt alles van <letter1> t.e.m <letter2>."
  echo "-b <block-device> laat toe een partitie te doorzoeken, door ze (automatisch) te mounten in de directory /mnt en dan nadien deze directory te gaan doorzoeken."
  echo "-nn (no numbers) belet dat in een bestandsnaam een cijfer 0 tot 9 voorkomt."
  echo "-nr (no recursion) voorkomt dat je programma ook in onderliggende directories gaat zoeken."
  echo "-f of –fout <bestand> schrijft mogelijke fouten die optreden (bvb een niet-leesbare directory) weg naar het bestand <bestand>."
  echo "-s <woord> zoekt binnen de gevonden bestanden het woord <woord>, en geeft enkel die bestanden weer die ook dit woord bevatten."
}

#SCRIPT
#Nagaan of er argumenten gebruikt worden, zo niet, foutmelding weergeven, met suggestie help te raadplagen.
if [ $# -lt 1 ]
then
  echo "Fout, gelieve de extensie op te geven met argument -e en minstens 1 map waarin gezocht moet worden naar die extensie."
  echo "Voor meer info gelieve Help te raadplegen met argumenten -h of --help."
  exit 0
fi

#Alle argumenten opsommen
#for FOLDER in "$@"
#do
#  echo $FOLDER
#done

#Extensies variabelen toewijzen
#while getopts e:h:help::l:b:nn:nr:f:fout:s: option
while getopts e:h option
do
  case "${option}"
  in
    e) EXT=${OPTARG};;
    h) help;;
#    l) CHAR=${OPTARG};;
#    b) PART=${OPTARG};;
#    nn) NONUM=${OPTARG};;
#    nr) NOREC=${OPTARG};;
#    f) FOUT=${OPTARG};;
#    fout) FOUT=${OPTARG};;
#    s) SEARCH=${OPTARG};;
    ?) FOLDER=${OPTARG};;
  esac
done

#Uitvoer
ls *.$EXT -lh | cut -d: -f2 | cut -d' ' -f2

echo $FOLDER
