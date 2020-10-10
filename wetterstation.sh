#!/bin/bash

# V1.3.1 - 08.10.2020 (c) 2019-2020 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-Format aus, konvertiert dieses und überträgt
# die Daten an den ioBroker
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker und 'bc' unter Linux
#
# V1.3.1 / 08.10.2020 - ~ Fix falls Leerzeichen im Verzeichnisnamen
# V1.3.0 / 19.06.2020 - + letztes Regenereignis und Regenmenge
#                       + Fehlermeldung bei falscher WS_ID / ID der Wetterstation
#                       + Sonnenscheindauer + Solarenergie vom Vortag
#                       ~ Änderung/Fix Sonnenscheindauer
# V1.2.0 / 20.04.2020 - + Firmwareupgrade verfügbar?
#                       + Firmwareversion
#                       + Sonnenscheindauer Heute, Woche, Monat, Jahr
#                       + UV-Belastung
#                       + Solarenergie Heute, Woche, Monat, Jahr
#                       + Vorjahreswerte von Regenmenge, Sonnenscheindauer und Solarenergie
# V1.1.0 / 03.04.2020 - + aktueller Regenstatus
#                       + Luftdrucktendenz, Wettertrend und aktuelles Wetter
# V1.0.0 / 12.03.2020 - + Berechnung Jahresregenmenge
#                       + Windrichtung zusätzlich als Text
#                       ~ Änderung "Regen Aktuell" in "Regenrate"
#                       ~ Splitt in conf- + sub-Datei
# V0.1.3 / 08.02.2020 - + Unterstützung für Datenpunkt "Regenmenge Jahr", zB. für Froggit WH4000 SE
#                       + Shell-Parameter -s (Klartextanzeige Passwort + Station-ID)
#                       + Shell-Parameter --data (zeigt nur das gesendete Datenpaket der Wetterstation an)
# V0.1.2 / 31.01.2020 - + Prüfung auf Datenintegrität
#                       + neuer Datenpunkt bei Kommunikationsfehler
#                       + Ausgabe Datenpaket der Wetterstation bei Debug
# V0.1.1 / 01.01.2020 - + UTC-Korrektur
#                       + Config-Versionscheck
#                       + Shell-Parameter -v/-h/--debug
# V0.1.0 / 29.12.2019 - erstes Release


 SH_VER="V1.3.1"
 CONF_V="V1.3.1"
 SUBVER="V1.3.1"


 #Installationsverzeichnis feststellen
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

 #Config-Version prüfen
  VER_CONFIG=$(cat "${DIR}/wetterstation.conf"|grep '### Setting'|cut -d" " -f3)
  if [ $CONF_V != $VER_CONFIG ]; then
	echo -e "wetterstation: \e[31mERROR #000 - Config-Version mismatch!\n"
	echo -e "benutzt: $VER_CONFIG\t benötigt wird: $CONF_V$WE"
	exit 1
  fi

 #Sub-Version prüfen
  SUB_CONFIG=$(cat "${DIR}/wetterstation.sub"|grep '### Subroutinen'|cut -d" " -f3)
  if [ $SUBVER != $SUB_CONFIG ]; then
	echo -e "wetterstation: \e[31mERROR #001 - Subroutinen-Version mismatch!\n"
	echo -e "benutzt: $SUB_CONFIG\t benötigt wird: $SUBVER$WE"
	exit 1
  fi


 #Konfiguration lesen + Subroutinen laden
  . "${DIR}/wetterstation.conf"
  . "${DIR}/wetterstation.sub"
 #Setup ausführen
  setup


 #gibt es Parameter?
  while [ "$1" != "" ]; do
    case $1 in
        --debug	)               debug=true   #override
                                ;;
        -s | --show )           show_pwid=true
                                ;;
        -d | --data )           ws_data
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
  done




#Endlosschleife
while true
 do

  #Kommunikation herstellen und Daten empfangen
   get_DATA

  #KOM-Fehler?
  if [ "$?" -eq "0" ]; then

   #DATA zerlegen (Messwerte Block #3-#22)
   ii=2
   for ((i=0; i<20; i++))
    do
     let "ii++"
     MESSWERTERAW[$i]=$(echo ${DATA}|cut -d'&' -f${ii} | cut -d"=" -f2)
     MESSWERTE[$i]=${MESSWERTERAW[$i]}
      if [ "$i" -ge "0" ] && [ "$i" -lt "4" ]; then convertFtoC; fi
      if [ "$i" -eq "6" ] || [ "$i" -eq "7" ]; then convertMPHtoKMH; fi
      if [ "$i" -eq "8" ]; then winddir; fi
      if [ "$i" -eq "9" ] || [ "$i" -eq "10" ]; then convertLuftdruck; fi
      if [ "$i" -ge "11" ] && [ "$i" -lt "16" ]; then convertInchtoMM; fi
      if [ "$i" -eq "16" ]; then sonnenpuls; fi
      if [ "$i" -eq "17" ]; then uv_belastung; fi
      if [ "$i" -eq "18" ]; then convertTime; fi
    done

   #Daten an ioB schicken
    iob_send


  else
   let "KOMFEHLER++"
   if [ "$KOMFEHLER" -eq "5" ]; then curl "http://${IPP}/set/${DP_KOMFEHLER}?value=true&ack=true" >/dev/null 2>&1;fi
  fi


  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi

  #Mitternachtjobs
   if [ `date +%H` -ge "23" ] && [ `date +%M` -ge "58" ] && [ -z $MIDNIGHTRUN ]; then
	rain               #Jahresregenmenge
	firmware_check     #neue Firmware
	reset_zaehler      #Sonnenscheindauer, Solarenergie zurücksetzen (enthällt auch Speicherung Werte VorJahr)
   fi
   if [ `date +%H` -eq "0" ] && [ `date +%M` -le "3" ]; then unset MIDNIGHTRUN; fi


  #Wetterprognose
   DO_IT=`date +%M`
   DO_IT=${DO_IT#0}
   if [ $(( $DO_IT % 15 )) -eq "0" ] && [ `date +%s` -ge "$TIMER_SET" ]; then wetterprognose; fi
 done

###EoF

