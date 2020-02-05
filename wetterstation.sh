#!/bin/bash

# V0.1.3 - 05.02.2020 (c) 2019-2020 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-Format aus, konvertiert diese und überträgt
# die Daten an den ioBroker
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker und 'bc' unter Linux
#
# V0.1.3 / 05.02.2020 - + Unterstützung für Datenpunkt "Regenmenge Jahr", zB. für Froggit WH4000SE
#                       + Shell-Parameter -s (Klartextanzeige Passwort + Station-ID)
#			+ Shell-Parameter --data (zeigt nur das gesendete Datenpaket der Wetterstation an)
# V0.1.2 / 31.01.2020 - + Prüfung auf Datenintegrität
#                       + neuer Datenpunkt bei Kommunikationsfehler
#                       + Ausgabe Datenpaket der Wetterstation bei Debug
# V0.1.1 / 01.01.2020 - + UTC-Korrektur
#			+ Config-Versionscheck
#			+ Shell-Parameter -v/-h/--debug
# V0.1.0 / 29.12.2019 - erstes Release


 SH_VER="V0.1.3"
 CONF_V="V0.1.3"


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
	-s | --show )		show_pwid=true
				;;
	-d | --data )		ws_data
				exit
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

 #Check ob Pollintervall größer 30 Sekunden
  if [ ${WS_POLL} -lt "30" ]; then WS_POLL=30; fi

 #Fehlermeldungen resetten
  curl http://${IPP}/set/${DP_KOMFEHLER}?value=false >/dev/null 2>&1


#Endlosschleife
while true
 do

  #Kommunikation herstellen und Daten empfangen
   get_DATA

  #KOM-Fehler?
  if [ "$?" -eq "0" ]; then

   #DATA zerlegen (Messwerte Block #3-#22)
   ii=2
   for ((i=0; i<19; i++))
    do
     let "ii++"
     MESSWERTERAW[$i]=$(echo ${DATA}|cut -d'&' -f${ii} | cut -d"=" -f2)
     MESSWERTE[$i]=${MESSWERTERAW[$i]}
      if [ "$i" -ge "0" ] && [ "$i" -lt "4" ]; then convertFtoC; fi
      if [ "$i" -eq "6" ] || [ "$i" -eq "7" ]; then convertMPHtoKMH; fi
      if [ "$i" -eq "9" ] || [ "$i" -eq "10" ]; then convertLuftdruck; fi
      if [ "$i" -ge "11" ] && [ "$i" -lt "16" ]; then convertInchtoMM; fi
      if [ "$i" -eq "18" ]; then convertTime; fi
    done

   #Daten an ioB schicken
    iob_send


  else
   let "KOMFEHLER++"
   if [ "$KOMFEHLER" -eq "5" ]; then curl http://${IPP}/set/${DP_KOMFEHLER}?value=true&prettyPrint&ack=true >/dev/null 2>&1;fi
  fi


  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi

  #...und schlafen gehen
   let "schlafe=WS_POLL-5"
   sleep $schlafe

 done

###EoF

