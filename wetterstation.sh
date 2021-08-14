#!/bin/bash

# V2.8.0 - 14.08.2021 (c) 2019-2021 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-/Ecowitt-Format aus, konvertiert dieses und überträgt
# die Daten an den ioBroker (alternativ auch an OpenSenseMap und/oder Windy)
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker, 'jq' und 'bc' unter Linux
#
# V2.8.0 / 14.08.2021 - ~ Änderung am Messverfahren der Solarenergie (festes Poll-Intervall --> Zeitstempel)
# V2.7.0 / 15.07.2021 - + Bei bereits eingetragenem OSEM-User erfolgt Abbruch der OSEM-Registrierung
#                       + Unterstützung für DP250/WH45 Sensor
#                       ~ Fix Prüfung netcat-Version
#                       ~ Berechnung Windchill nur bis 11°C
# V2.6.0 / 04.05.2021 - ~ Fix Avg Aussentemperatur vor einem Jahr
#                       ~ Windchill erst ab 5km/h Windgeschwindigkeit
#                       + Prüfung bei Option "v" ob die netcat-Version korrekt ist
#                       + Support für Windy
#                       ~ Hitzeindex
# V2.5.0 / 08.02.2021 - ~ Fix für Protokoll #9 wg. fehlender Regenrate
#                       + Min/Max/Avg Aussentemperatur vor einem Jahr
#                       + Unterstützung von max. 4 DP70 Sensoren
#                       ~ Codeoptimierungen
# V2.4.0 / 03.02.2021 - + Hitzeindex (>20°C)
#                       + Unterstützung von max. 4 DP200 Sensoren
# V2.3.0 / 26.01.2021 - ~ Fix Rundungsfehler Windchill/Taupunkt
#                       + Min/max Aussentemperatur der letzten 24h
#                       + Unterstützung für DP60 Sensor
#                       ~ Fix für Protokoll #9 wg. fehlender Regenrate
# V2.2.0 / 21.01.2021 - ~ Fix Batteriestatus
#                       ~ Chillfaktor umbenannt auf Windchill/gefühlte Temperatur
#                       + Berechnung Windchill + Taupunkt für Ecowitt-Protokoll
# V2.1.0 / 10.01.2021 - + zusätzliches Protokoll "9" für userspezifische Abfrage
#                       ~ Fix Reset kumulierte Regenmenge zum Jahresanfang
#                       ~ Fix für DP100 Bodenfeuchte
# V2.0.0 / 15.12.2020 - + Unterstützung des Gateways und Zusatzsensoren (@a200)
#                       + Protokoll (wunderground oder ecowitt) wählbar
# V1.6.0 / 06.12.2020 - + Patch (@a200) für neuere Firmwareversionen (V1.6.3) speziell bei Nutzung eines Gateways
#                       ~ Reset des Error-Kommunikationszählers
#                       + Prüfung bei Option "-v" ob 'bc' und 'jq' installiert sind
#                       ~ Option "n" bei netcat hinzugefügt
# V1.5.0 / 30.11.2020 - ~ Simple-API per HTTP[S] und Authentifizierung
#                       + Update-Routine (beta)
# V1.4.0 / 30.10.2020 - + Support für openSenseMap
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


 SH_VER="V2.8.0"
 CONF_V="V2.7.0"
 SUBVER="V2.8.0"


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


 #gibt es Parameter?
  while [ "$1" != "" ]; do
    case $1 in
        --debug )               version
                                debug=true   #override
                                ;;
        --osem_reg )            osem_register
                                exit
                                ;;
        --windy_reg )           windy_register
                                exit
                                ;;
        -s | --show )           show_pwid=true
                                ;;
        -d | --data )           setup
                                ws_data
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


 #Setup ausführen
  setup

#Endlosschleife
while true
 do

  #Kommunikation herstellen und Daten empfangen
  get_DATA

  #KOM-Fehler?
  if [ "$?" -eq "0" ]; then
   unset MESSWERTE; unset MESSWERTERAWIN
   MESSWERTERAWIN=(${DATA//&/ })
   rawinlen=${#MESSWERTERAWIN[@]}
   j=30
   for (( i=1; i<rawinlen; i++ ))
   do
     if [[ ${MESSWERTERAWIN[$i]} == tempinf=* ]] || [[ ${MESSWERTERAWIN[$i]} == indoortempf=* ]]
        then MESSWERTE[0]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertFtoC 0; fi
     if [[ ${MESSWERTERAWIN[$i]} == tempf=* ]]
        then MESSWERTE[1]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertFtoC 1; fi
     if [[ ${MESSWERTERAWIN[$i]} == dewptf=* ]]
        then MESSWERTE[2]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertFtoC 2; fi
     if [[ ${MESSWERTERAWIN[$i]} == windchillf=* ]]
        then MESSWERTE[3]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertFtoC 3; fi
     if [[ ${MESSWERTERAWIN[$i]} == humidityin=* ]] || [[ ${MESSWERTERAWIN[$i]} == indoorhumidity=* ]]
        then MESSWERTE[4]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi
     if [[ ${MESSWERTERAWIN[$i]} == humidity=* ]]
        then MESSWERTE[5]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi
     if [[ ${MESSWERTERAWIN[$i]} == windspeedmph=* ]]
        then MESSWERTE[6]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertMPHtoKMH 6; fi
     if [[ ${MESSWERTERAWIN[$i]} == windgustmph=* ]]
        then MESSWERTE[7]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertMPHtoKMH 7; fi
     if [[ ${MESSWERTERAWIN[$i]} == winddir=* ]]
        then MESSWERTE[8]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); winddir 8; fi
     if [[ ${MESSWERTERAWIN[$i]} == baromabsin=* ]] || [[ ${MESSWERTERAWIN[$i]} == absbaromin=* ]]
        then MESSWERTE[9]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertLuftdruck 9; fi
     if [[ ${MESSWERTERAWIN[$i]} == baromrelin=* ]] || [[ ${MESSWERTERAWIN[$i]} == baromin=* ]]
        then MESSWERTE[10]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertLuftdruck 10; fi
     if [[ ${MESSWERTERAWIN[$i]} == rainratein=* ]] || [[ ${MESSWERTERAWIN[$i]} == rainin=* ]]
        then MESSWERTE[11]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 11; fi
     if [[ ${MESSWERTERAWIN[$i]} == dailyrainin=* ]]
        then MESSWERTE[12]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 12; fi
     if [[ ${MESSWERTERAWIN[$i]} == weeklyrainin=* ]]
        then MESSWERTE[13]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 13; fi
     if [[ ${MESSWERTERAWIN[$i]} == monthlyrainin=* ]]
        then MESSWERTE[14]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 14; fi
     if [[ ${MESSWERTERAWIN[$i]} == yearlyrainin=* ]]
        then MESSWERTE[15]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 15; fi
     if [[ ${MESSWERTERAWIN[$i]} == solarradiation=* ]]
        then MESSWERTE[16]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); sonnenpuls 16; fi
     if [[ ${MESSWERTERAWIN[$i]} == uv=* ]] || [[ ${MESSWERTERAWIN[$i]} == UV=* ]]
        then MESSWERTE[17]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); uv_belastung 17; fi
     if [[ ${MESSWERTERAWIN[$i]} == dateutc=* ]]
        then MESSWERTE[18]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertTime 18; fi
     if [[ ${MESSWERTERAWIN[$i]} == stationtype=* ]] || [[ ${MESSWERTERAWIN[$i]} == softwaretype=* ]]
        then MESSWERTE[19]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi
     if [[ ${MESSWERTERAWIN[$i]} == wh65batt=* ]]
        then MESSWERTE[20]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi
     if [[ ${MESSWERTERAWIN[$i]} == maxdailygust=* ]]
        then MESSWERTE[21]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertMPHtoKMH 21; fi
     if [[ ${MESSWERTERAWIN[$i]} == eventrainin=* ]]
        then MESSWERTE[22]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 22; fi
     if [[ ${MESSWERTERAWIN[$i]} == hourlyrainin=* ]]
        then MESSWERTE[23]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 23; fi
     if [[ ${MESSWERTERAWIN[$i]} == totalrainin=* ]]
        then MESSWERTE[24]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 24; fi
     if [[ ${MESSWERTERAWIN[$i]} == model=* ]]
        then MESSWERTE[25]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi


     ### zusätzliche DPxxx-Sensoren ############################################################
      if [ "${ANZAHL_DP50}" -gt "0" ] || [ "${ANZAHL_DP100}" -gt "0" ]; then DP50_100; fi
      if [ "${ANZAHL_DP60}" -gt "0" ]; then DP60; fi
      if [ "${ANZAHL_DP70}" -gt "0" ]; then DP70; fi
      if [ "${ANZAHL_DP200}" -gt "0" ]; then DP200; fi
      if [ "${ANZAHL_DP250}" -gt "0" ]; then DP250; fi
     ### zusätzliche DPxxx-Sensoren ################################################### ENDE ###

   done


   #Taupunkt und Windchill berechnen
   if [ -z ${MESSWERTE[3]} ] && [ ! -z ${MESSWERTE[1]} ] && [ ! -z ${MESSWERTE[6]} ]; then
     if (( $(bc -l <<< "${MESSWERTE[6]} > 5") )) && (( $(bc -l <<< "${MESSWERTE[1]} < 11") )); then
        WINDCHILL=$(echo "scale=4;(13.12 + 0.6215 * ${MESSWERTE[1]} - 11.37 * e(l(${MESSWERTE[6]})*0.16) + 0.3965 * ${MESSWERTE[1]} * e(l(${MESSWERTE[6]})*0.16))/1" | bc -l)
        MESSWERTE[3]=$(round $WINDCHILL 2)
      else
        MESSWERTE[3]=$(echo ${MESSWERTE[1]})
     fi
   fi

   if [ -z ${MESSWERTE[2]} ] && [ ! -z ${MESSWERTE[1]} ] && [ ! -z ${MESSWERTE[5]} ]; then
     TAUPUNKT=$(echo "scale=4;(e(l(${MESSWERTE[5]}/100)*(1/8.02)) * (109.8 + ${MESSWERTE[1]}) - 109.8)/1" | bc -l)
     MESSWERTE[2]=$(round $TAUPUNKT 2)
   fi
   ##################################


   #Daten an ioB schicken
    iob_send



   #Reset Kommfehler
    if [ ! -z "$KOMFEHLER" ] && [ "$KOMFEHLER" -gt "0" ]; then let "KOMFEHLER--"; fi


  else
   let "KOMFEHLER++"
   if [ "$KOMFEHLER" -eq "10" ]; then SAPI "Single" "set/${DP_KOMFEHLER}?value=true&ack=true"; fi
  fi


  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi

  #Mitternachtjobs
   if [ `date +%H` -ge "23" ] && [ `date +%M` -ge "58" ] && [ -z $MIDNIGHTRUN ]; then
        rain               #Jahresregenmenge
        firmware_check     #neue Firmware
        reset_zaehler      #Sonnenscheindauer, Solarenergie zurücksetzen (enthällt auch Speicherung Werte VorJahr)
        minmaxavg365d      #Min-/Max-/Avg-Aussentemperatur vor einem Jahr
   fi
   if [ `date +%H` -eq "0" ] && [ `date +%M` -le "3" ]; then unset MIDNIGHTRUN; fi


  #15-Minutenjobs: Wetterprognose; min/max Aussentemperatur der letzten 24h
   DO_IT=$(date +%M)
   DO_IT=${DO_IT#0}
   if [ $(( $DO_IT % 15 )) -eq "0" ]; then
     if [ `date +%s` -ge "$TIMER_SET" ]; then wetterprognose
      if [ ! -z ${INFLUX_DB} ]; then minmax24h; fi
     fi
   fi

  #5-Minutenjobs: Windy
   if [ $(( $DO_IT % 5 )) -eq "0" ] && [ -z ${run_5minjobs_onlyonce} ]; then

     #Windy
     if [ ${use_windy} == "true" ]; then windy_update; fi

     #run only once
     run_5minjobs_onlyonce=true

    else
     unset run_5minjobs_onlyonce
   fi



   #Hitzeindex
     if (( $(bc -l <<< "${MESSWERTE[1]} > 20") )); then
       HITZEINDEX=$(round $(hitzeindex ${MESSWERTE[1]} ${MESSWERTE[5]}) 2)
      else
       HITZEINDEX=
     fi


  #openSenseMap
   if [ ${openSenseMap} == "true" ]; then opensensemap; fi

 done
###EoF

