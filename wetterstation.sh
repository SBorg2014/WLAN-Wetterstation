#!/bin/bash

# V0.1.1 - 01.01.2020 (c) 2019-2020 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-Format aus, konvertiert diese und überträgt
# die Daten an den ioBroker
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker und 'bc' unter Linux
#
# V0.1.1 / 01.01.2020 - + UTC-Korrektur
#			+ Config-Versionscheck
#			+ Shell-Parameter -v/-h/--debug
# V0.1.0 / 29.12.2019 - erstes Release
#
#
 SH_VER="V0.1.1"
 CONF_V="V0.1.1"


 #Installationsverzeichnis feststellen
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

 #Config-Version prüfen
  VER_CONFIG=$(cat ${DIR}/wetterstation.conf|grep '### Setting'|cut -d" " -f3)
  if [ $CONF_V != $VER_CONFIG ]; then
	echo -e "wetterstation: \e[31mERROR #000 - Config-Version mismatch!\n"
	echo -e "benutzt: $VER_CONFIG\t benötigt wird: $CONF_V$WE"
	exit 1
  fi

 #Konfiguration lesen
  . ${DIR}/wetterstation.conf

 #gibt es Parameter?
  while [ "$1" != "" ]; do
    case $1 in
	--debug	)		debug=true   #override
				;;
	-v | --version )	version
				exit
				;;
        -h | --help )		usage
				exit
                                ;;
        * )			usage
                                exit 1
    esac
    shift
  done


 declare -a MESSWERTE
 declare -a MESSWERTERAW

 #Check ob Pollintervall größer 10 Sekunden
  if [ ${WS_POLL} -lt "10" ]; then WS_POLL=10; fi


#Endlosschleife
while true
 do
  #auf Daten der Wetterstation warten und nach GET filtern
   DATA=$(nc -lv -p ${WS_PORT}|sed '3 p')
   
  #DATA zerlegen (Messwerte Block #3-#21)
   ii=2
   for ((i=0; i<18; i++))
    do
     let "ii++"
     MESSWERTERAW[$i]=$(echo ${DATA}|cut -d'&' -f${ii} | cut -d"=" -f2)
     MESSWERTE[$i]=${MESSWERTERAW[$i]}
      if [ "$i" -ge "0" ] && [ "$i" -lt "4" ]; then convertFtoC; fi
      if [ "$i" -eq "6" ] || [ "$i" -eq "7" ]; then convertMPHtoKMH; fi
      if [ "$i" -eq "9" ] || [ "$i" -eq "10" ]; then convertLuftdruck; fi
      if [ "$i" -ge "11" ] && [ "$i" -lt "15" ]; then convertInchtoMM; fi
      if [ "$i" -eq "17" ]; then convertTime; fi
    done


  #Daten an ioB schicken
   iob_send

  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi

  #...und schlafen gehen
   let "schlafe=WS_POLL-5"
   sleep $schlafe

 done

###EoF

