#!/bin/bash

# V1.6.0 - 06.12.2020 (c) 2019-2020 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-Format aus, konvertiert dieses und überträgt
# die Daten an den ioBroker
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker, 'jq' und 'bc' unter Linux
#
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


 SH_VER="V1.6.0"
 CONF_V="V1.6.0"
 SUBVER="V1.6.0"


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
        --debug )               debug=true   #override
                                ;;
        --osem_reg )            osem_register
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

  # Reihenfolgenanpassung ###
   MESSWERTERAWIN=(${DATA//&/ })
   rawinlen=${#MESSWERTERAWIN[@]}
   for ((i=0; i<rawinlen; i++))
   do
     if [[ ${MESSWERTERAWIN[$i]} == indoortempf* ]]; then myindoortempf=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == tempf* ]]; then mytempf=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == dewptf* ]]; then mydewptf=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == windchillf* ]]; then mywindchillf=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == indoorhumidity* ]]; then myindoorhumidity=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == humidity* ]]; then myhumidity=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == windspeedmph* ]]; then mywindspeedmph=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == windgustmph* ]]; then mywindgustmph=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == winddir* ]]; then mywinddir=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == rainin* ]]; then myrainin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == dailyrainin* ]]; then mydailyrainin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == weeklyrainin* ]]; then myweeklyrainin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == monthlyrainin* ]]; then mymonthlyrainin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == yearlyrainin* ]]; then myyearlyrainin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == solarradiation* ]]; then mysolarradiation=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == UV* ]]; then myUV=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == baromin* ]]; then mybaromin=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == lowbatt* ]]; then mylowbatt=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == dateutc* ]]; then mydateutc=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == softwaretype* ]]; then mysoftwaretype=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == action* ]]; then myaction=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == realtime* ]]; then myrealtime=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == rtfreq* ]]; then myrtfreq=$i; fi
     if [[ ${MESSWERTERAWIN[$i]} == absbaromin* ]]; then myabsbaromin=$i; fi
   done

   MYDATA="${MESSWERTERAWIN[0]} ${MESSWERTERAWIN[1]}&${MESSWERTERAWIN[2]}&${MESSWERTERAWIN[$myindoortempf]}\
   &${MESSWERTERAWIN[$mytempf]}&${MESSWERTERAWIN[$mydewptf]}&${MESSWERTERAWIN[$mywindchillf]}\
   &${MESSWERTERAWIN[$myindoorhumidity]}&${MESSWERTERAWIN[$myhumidity]}&${MESSWERTERAWIN[$mywindspeedmph]}\
   &${MESSWERTERAWIN[$mywindgustmph]}&${MESSWERTERAWIN[$mywinddir]}&"
   if [ -z $myabsbaromin ]; then
     MYDATA="${MYDATA}absbaromin=0";
   else
     MYDATA="${MYDATA}${MESSWERTERAWIN[$myabsbaromin]}";
   fi
   MYDATA="${MYDATA}&${MESSWERTERAWIN[$mybaromin]}&${MESSWERTERAWIN[$myrainin]}&${MESSWERTERAWIN[$mydailyrainin]}\
   &${MESSWERTERAWIN[$myweeklyrainin]}&${MESSWERTERAWIN[$mymonthlyrainin]}&${MESSWERTERAWIN[$myyearlyrainin]}\
   &${MESSWERTERAWIN[$mysolarradiation]}&${MESSWERTERAWIN[$myUV]}&${MESSWERTERAWIN[$mydateutc]}\
   &${MESSWERTERAWIN[$mysoftwaretype]}&${MESSWERTERAWIN[$myaction]}&${MESSWERTERAWIN[$myrealtime]}\
   &${MESSWERTERAWIN[$myrtfreq]}"

   DATA=$MYDATA

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

   #Reset Kommfehler
    if [ ! -z "$KOMFEHLER" ] && [ "$KOMFEHLER" -gt "0" ]; then let "KOMFEHLER--"; fi

  else
   let "KOMFEHLER++"
   if [ "$KOMFEHLER" -eq "5" ]; then SAPI "Single" "set/${DP_KOMFEHLER}?value=true&ack=true"; fi
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

  #openSenseMap
   if [ ${openSenseMap} == "true" ]; then opensensemap; fi
 done

###EoF

