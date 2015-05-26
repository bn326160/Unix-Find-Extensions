#!/bin/bash

#FUNCTIONS
#Foutmelding
charfout(){
  echo "Uw ingevoerde eerste letter met argument -l is ongeldig."
  echo "Gebruik: $0 -e <extensie> -l <a>/<a-c>"
}

extfout() {
  echo 1>&2;
  echo "Fout, onvoldoende argumenten" 1>&2;
  echo "Gebruik: $0 [-e <extensie>] [<folder>]" 1>&2;
  echo "Gelieve de extensie op te geven met argument -e en minstens 1 map waarin gezocht moet worden naar die extensie." 1>&2;
  echo "Voor meer info gelieve Help te raadplegen met argumenten -h of --help." 1>&2;
  echo 1>&2;
  exit
 }

#Help
help() {
  echo
  echo "--- Help ---"
  echo
  echo "Dit script gaat op zoek naar bestanden met een bepaalde extensie, in één of meerdere directories. De output geeft weer welke bestanden gevonden werden, gevolgd door de directory waar het respectievelijke bestand zich bevindt."
  echo
  echo "De het argument -e <ext> is vereist, anders kan er geen extensie gevonden worden."
  echo "Andere argumenten zijn de te doorzoeken directories."
  echo
  echo "Verder bevat dit script de volgende optionele argumenten:"
  echo "-h of --help geeft dit help-document weer."
  echo "-l <letter> zoekt enkel bestanden, die beginnen met de letter <letter>."
  echo "-l <letter1>-<letter2> doet hetzelfde, maar zoekt alles van <letter1> t.e.m <letter2>."
  echo "-b <block-device> laat toe een partitie te doorzoeken, door ze (automatisch) te mounten in de directory /mnt en dan nadien deze directory te gaan doorzoeken."
  echo "--nn (no numbers) belet dat in een bestandsnaam een cijfer 0 tot 9 voorkomt."
  echo "--nr (no recursion) voorkomt dat je programma ook in onderliggende directories gaat zoeken."
  echo "-f of –-fout <bestand> schrijft mogelijke fouten die optreden (bvb een niet-leesbare directory) weg naar het bestand <bestand>."
  echo "-s <woord> zoekt binnen de gevonden bestanden het woord <woord>, en geeft enkel die bestanden weer die ook dit woord bevatten."
  echo
  exit
}


#Opties in getopt instellen + argumenten in volgorde plaatsen (mappen achter case-opties)
OPTS=$(getopt -o e:hl:b:f:s: -l "help,nn,nr,fout" -n "ExamenScript" -- "$@");
eval set -- "$OPTS";

#Case doorlopen om opties aan respectievelijke variabelen toe te wijzen
while true; do
  case "$1" in
    -e)
      shift;
      if [ -n "$1" ]; then
        BESTANDSEXTENSIE=$1;
        shift;
      fi
      ;;
    -h|--help)
      shift;
      help;
      ;;
    -l)
      shift;
      if [ -n "$1" ]; then
        BEGINLETTER=$1;
        shift;
      fi
      ;;
    -b)
      shift;
      if [ -n "$1" ]; then
        BLOCKDEVICE=$1;
        shift;
      fi
      ;;
    --nn)
      shift;
      NONUMBERS=true;
      ;;
    --nr)
      shift;
      NORECURSION=true;
      ;;
    -f|--fout)
      shift;
      if [ -n "$1" ]; then
        FOUTLOG=true;
        shift;
      fi
      ;;
    -s)
      shift;
      if [ -n "$1" ]; then
        ZOEKEN=$1;
        shift;
      fi
      ;;
    --)
      shift;
      break;
      ;;
  esac
done

#De overige argumenten, ergo de te-doorzoeken-folders, in een array plaatsen
TEDOORZOEKENFOLDERS=("$@")

#De array van folders als eerste argumenten van de find functie opgeven
FINDARGUMENTEN=$(printf "%s " "${TEDOORZOEKENFOLDERS[@]}")

#Nagaan of er een block device gemount dient te worden
if [[ $BLOCKDEVICE ]]; then
  echo "Gelieve admin rechten te geven om het block-device te kunnen mounten."
  sudo mount /dev/$BLOCKDEVICE /mnt
  FINDARGUMENTEN=$FINDARGUMENTEN" /mnt" #Pad van gemounte drive aan array toevoegen
fi

#Indien de no-recursion vlag gebruikt is, enkel level 1 mappen toestaan
if [[ $NORECURSION ]]; then
  FINDARGUMENTEN=$FINDARGUMENTEN" -maxdepth 1"
fi

#Beargumenteren dat er naar bestanden moet gezocht worden (type -f)
FINDARGUMENTEN=$FINDARGUMENTEN" -type f"

#De extensie implementeren door een naamfilter aan find toe te voegen
#Indien geen extensie opgegeven, foutmelding
if [[ $BESTANDSEXTENSIE ]]; then
  FINDARGUMENTEN=$FINDARGUMENTEN" -name \*.${BESTANDSEXTENSIE}"
else
  extfout
fi

#Nagaan hoeveel karakters er aan het -l argument toegewezen zijn
case ${#BEGINLETTER} in
  0) #Niet toewijzen
    ;;
  1) FINDARGUMENTEN=$FINDARGUMENTEN" -name '${BEGINLETTER}*'" #Beginnen met een letter
    ;;
  3) FINDARGUMENTEN=$FINDARGUMENTEN" -name '[${BEGINLETTER}]*'" #Beginnenn met een letter-range
    ;;
  *) charfout
    ;;
  esac

#Indien de no-numbers vlag gebruikt is, nummers verbieden in de bestandsnaam
if [[ $NONUMBERS ]]; then
  FINDARGUMENTEN=$FINDARGUMENTEN" \! -name '*[0-9]*'"
fi


echo $FINDARGUMENTEN

find $FINDARGUMENTEN

find ~ /ex -type f -name \*.sh



#FILES=( $(find ${ARG} | rev | cut -d/ -f 1 | rev) )
#FOLDER=( $(find ${ARG} | rev | cut -d/ -f 1 --complement | rev) )
#Arrays in 2 kolommen weergeven
#for ((i = 0; i <= ${#FILES[@]}; i++));
#do
#    printf '%s %s\n' "${FILES[i]}" "${FOLDER[i]}"
#done | column -t | sort -k1 #Kolommen duidelijker maken + Sorteren op bestandsnaam
