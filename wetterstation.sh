#!/bin/bash
: <<'Versionsinfo'


 V3.5.2 - 02.08.2025 (c) 2019-2025 SBorg

 wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-/Ecowitt-Format aus, konvertiert dieses und überträgt
 die Daten an den ioBroker (alternativ auch an AWEKAS, OpenSenseMap, Windy, wetter.com und WeatherObservationsWebsite)

 benötigt den 'Simple RESTful API'-Adapter im ioBroker, 'jq', 'bc' und 'dc' unter Linux


 V3.5.2 / 02.08.2025   ~ Fix fehlende Messwerte bei DP100 Sensor Nr.10-16 / Issue #81
 V3.5.1 / 04.07.2025   ~ Fix falsche Messwerte bei DP100 Sensor Nr.1 wenn mehr als 10 Sensoren vorhanden sind
 V3.5.0 / 10.05.2025   ~ Fix DP50/DP100 werden auch als FT0300-Sensoren erkannt
                       ~ Fix bei AWEKAS.at - Skript bleibt bei fehlender Internet-Verbindung hängen
                       + (Wasserdampf-)Drucksättigungsdefizit VPD / Issue #79
                       ~ Unterstützung für bis zu 16x DP100 / Issue #80
 V3.4.0 / 20.07.2024   ~ Fix "Kommunikationsfehler" bei Gateways mit Firmware ab V3.1.1 / Issue #71
                       ~ Fix am ws_updater, Restart des Service wird nach Update nicht ausgeführt
 V3.3.0 / 06.07.2024   + Fix Simple API-Fehlermeldung bei leerer Solarenergie
                       + Fix DP "Windy Datenübertragung" verbleibt auf "false" trotz erfolgreicher Datenübertragung
                         (Änderung an der API von windy)
                       + Raw-Werte bei DP100/WH51[L] hinzugefügt
 V3.2.0 / 12.08.2023   + Support für WeatherObservationsWebsite (WOW)
                       + Fix Zeitstempel für neuere Gateway-Firmwarereleases die ein URL-Encoding enthalten
 V3.1.1 / 04.06.2023   + Fix "MetSommer" (Skript bleibt bei den Mitternachtjobs hängen)
 V3.1.0 / 16.03.2023   + Windböe max für Stationen die den Wert nicht liefern
                       + Option "k" für selbstsignierte Zertifikate bei der Influx-Abfrage hinzugefügt
                       + Parameter "--influx_test" zum test der Influx-Konnektivität
                       + Fix "MetSommer" (Skript bleibt bei den Mitternachtjobs hängen)
 V3.0.0 / 08.02.2023   ~ Breaking Release / Support für (und nur noch!) InfluxDB V2.x / Issue #41
                       ~ Mindestintervall von 65 Sekunden beim Datenversand an AWEKAS.at
                       + Support Zusatzsensor Curconsa FT0300 / Pull Request #55 (LukasTr1980)
                       ~ Anzahl maximaler interner Sensoren von 30 auf 35 angehoben
                       + Debug-Option zum Test der InfluxDB-Konnektivität
 V2.22.0 / 23.01.2023  + Support für Bresser Thermo-Hygro-7Ch-Sensor #7009999 / Issue #53
 V2.21.0 / 15.01.2023  + Support für AWEKAS
                       ~ fix fehlende Regenwerte wenn nur der WS90 ohne weitere Außeneinheit benutzt wird / Issue #51
 V2.20.0 / 12.12.2022  ~ fix Wolkenbasis (keine Werte falls Taupunkt negativ) / Issue #46 (viper4iob)
                       ~ fix Wetterwarnung (Reif) / Issue #47 (viper4iob)
                       ~ fix OpenSenseMap für Stationen die 10-Minutendurchschnittswerte bereits liefern / Issue #48 (viper4iob)
 V2.19.0 / 12.08.2022  + Wetterwarnungen Schwüle, Tau/Nebel und Reif
                       ~ URL-Encoding für Umlaute
                       + Unterstützung für WS90 "Wittboy"
 V2.18.0 / 28.07.2022  + Höhe der Wolkenbasis
                       + Windrichtung der letzten 10 Minuten als Text
                       + Unterstützung für DP10/WN35 Blattfeuchte-Sensor
                       + Ausgabe der Skriptversion in Datenpunkt beim Start
 V2.17.0 / 22.07.2022  + durchschnittliche Windrichtung und -geschwindigkeit der letzten 10 Minuten alternativ anstelle
                         der aktuellen Werte an OpenSenseMap, windy und wetter.com senden
                       + Temperaturtrend Aussentemperatur der letzten Stunde
                       ~ Fix für Datenübertragung an nicht antwortenden OSeM-Server
 V2.16.0 / 12.07.2022  + Windrichtung der letzten 10 Minuten für alle Stationen (benötigt wird dafür nun noch 'dc')
                       + durchschnittliche Windgeschwindigkeit der letzten 10 Minuten für alle Stationen
                       ~ Bugfix gelegentlicher "jq parse"-Fehler
                       ~ Bugfix Regenmenge des meteorologischen Sommers aktualisiert sich nicht
 V2.15.0 / 19.06.2022  + neuer DP "Meldungen"; für Status- und Fehlermeldungen
                       + Datenübertragung an Wunderground.com auch bei eigenem DNS-Server (Protokoll #9)(@git-ZeR0)
                       + Windrichtung und -geschwindigkeit der letzten 10 Minuten (aktuell HP1000SE Pro)
                       + ws_updater: anlegen neuer Datenpunkte per Rest-API möglich
 V2.14.0 / 28.05.2022  ~ Fixed authentication for Simple-API setBulk requests (@crycode-de)
                       + Set ack flag on setBulk requests (requires PR ioBroker/ioBroker.simple-api#145) (@crycode-de)
                       + Added option to ignore SSL errors if HTTPS is used together with a self-signed certificate (@crycode-de)
                       + Added the state .Info.Sonnenschein_VorTag_Text (@crycode-de)
                       ~ Merge some SAPI "Single" calls into SAPI "Bulk" calls (@crycode-de)
 V2.13.0 / 05.04.2022  + Unterstützung für DP35/WN34 Sensor (@Omnedon)
 V2.12.1 / 29.03.2022  ~ Fehler bei "FIX_AUSSENTEMP" behoben (keine Datenübertragung an den ioB / Issue #31)
 V2.12.0 / 26.03.2022  + bei fehlerhafter Außentemperatur erfolgt keine Datenübertragung des Paketes an den ioB
 V2.11.1 / 14.02.2022  ~ Reduzierung valides Datenpaket auf 250 Zeichen
                       ~ "SainLogic Pro"-Protokoll in "DNS" umbenannt
 V2.11.0 / 03.12.2021  ~ Windgeschwindigkeit bei wetter.com in m/s
                       + Konfigurationsmöglichkeit des Kommunikationsfehlers (Issue #26)
                       ~ Bugfix Speicherort beim logging
                       ~ Ergänzung bei Prüfung auf valides Datenpaket (Außentemperatur hinzugefügt)
                       + Hinweis auf korrekte WS_ID bei Wunderground-Protokoll falls Kommunikationsfehler
 V2.10.1 / 22.11.2021  ~ Bugfix 'jq'-Fehlermeldungen von 0:00 Uhr bis 01:00 Uhr
                       ~ Bugfix Fehlermeldung "bereits existierender User" bei der OSeM-Registrierung obwohl keiner angelegt
                       + bei Option '--debug' werden, sofern aktiviert, nun auch die Daten an den/die Wetter-Dienst(e)
                         geschickt und deren Meldung(en) ausgegeben
                       ~ Fix auftretende Fehlermeldung falls SimpleAPI nicht erreichbar war
                       ~ Codeoptimierungen
 V2.10.0 / 21.10.2021  ~ Bugfix Option '--data' bei Ecowitt-Protokoll
                       ~ Passkey bei Nutzung des Ecowitt-Protokolls maskieren
                       + logging des Datenstrings der Wetterstation in eine Datei
                       + Unterstützung für DP40/WH32 (bzw. WH26) Sensor
                       + Unterstützung für DP300/WS68 Sensor
                       + Unterstützung für WH31 (bzw. WH25) Sensor
                       + netcat-/Success-Meldungen im Syslog entfernt
                       + Patch Sommer-/Winterzeit für wetter.com
 V2.9.0 / 25.08.2021   + Min-/Max-Aussentemperatur des heutigen Tages
                       ~ Änderung bei Datenübertragung per Simple-API wg. InfluxDB 2.x
                       + Meteorologischer Sommer Durchschnittstemperatur und Regenmenge
                       + neuer Shell-Parameter --metsommer (zur manuellen Berechnung der Werte des meteorologischen Sommers)
 V2.8.0 / 14.08.2021   ~ Änderung am Messverfahren der Solarenergie (festes Poll-Intervall --> Zeitstempel)
                       + Support für wetter.com
 V2.7.0 / 15.07.2021   + Bei bereits eingetragenem OSEM-User erfolgt Abbruch der OSEM-Registrierung
                       + Unterstützung für DP250/WH45 Sensor
                       ~ Fix Prüfung netcat-Version
                       ~ Berechnung Windchill nur bis 11°C
 V2.6.0 / 04.05.2021   ~ Fix Avg Aussentemperatur vor einem Jahr
                       ~ Windchill erst ab 5km/h Windgeschwindigkeit
                       + Prüfung bei Option "v" ob die netcat-Version korrekt ist
                       + Support für Windy
                       ~ Hitzeindex
 V2.5.0 / 08.02.2021   ~ Fix für Protokoll #9 wg. fehlender Regenrate
                       + Min/Max/Avg Aussentemperatur vor einem Jahr
                       + Unterstützung von max. 4 DP70 Sensoren
                       ~ Codeoptimierungen
 V2.4.0 / 03.02.2021   + Hitzeindex (>20°C)
                       + Unterstützung von max. 4 DP200 Sensoren
 V2.3.0 / 26.01.2021   ~ Fix Rundungsfehler Windchill/Taupunkt
                       + Min/max Aussentemperatur der letzten 24h
                       + Unterstützung für DP60 Sensor
                       ~ Fix für Protokoll #9 wg. fehlender Regenrate
 V2.2.0 / 21.01.2021   ~ Fix Batteriestatus
                       ~ Chillfaktor umbenannt auf Windchill/gefühlte Temperatur
                       + Berechnung Windchill + Taupunkt für Ecowitt-Protokoll
 V2.1.0 / 10.01.2021   + zusätzliches Protokoll "9" für userspezifische Abfrage
                       ~ Fix Reset kumulierte Regenmenge zum Jahresanfang
                       ~ Fix für DP100 Bodenfeuchte
 V2.0.0 / 15.12.2020   + Unterstützung des Gateways und Zusatzsensoren (@a200)
                       + Protokoll (wunderground oder ecowitt) wählbar
 V1.6.0 / 06.12.2020   + Patch (@a200) für neuere Firmwareversionen (V1.6.3) speziell bei Nutzung eines Gateways
                       ~ Reset des Error-Kommunikationszählers
                       + Prüfung bei Option "-v" ob 'bc' und 'jq' installiert sind
                       ~ Option "n" bei netcat hinzugefügt
 V1.5.0 / 30.11.2020   ~ Simple-API per HTTP[S] und Authentifizierung
                       + Update-Routine (beta)
 V1.4.0 / 30.10.2020   + Support für openSenseMap
 V1.3.1 / 08.10.2020   ~ Fix falls Leerzeichen im Verzeichnisnamen
 V1.3.0 / 19.06.2020   + letztes Regenereignis und Regenmenge
                       + Fehlermeldung bei falscher WS_ID / ID der Wetterstation
                       + Sonnenscheindauer + Solarenergie vom Vortag
                       ~ Änderung/Fix Sonnenscheindauer
 V1.2.0 / 20.04.2020   + Firmwareupgrade verfügbar?
                       + Firmwareversion
                       + Sonnenscheindauer Heute, Woche, Monat, Jahr
                       + UV-Belastung
                       + Solarenergie Heute, Woche, Monat, Jahr
                       + Vorjahreswerte von Regenmenge, Sonnenscheindauer und Solarenergie
 V1.1.0 / 03.04.2020   + aktueller Regenstatus
                       + Luftdrucktendenz, Wettertrend und aktuelles Wetter
 V1.0.0 / 12.03.2020   + Berechnung Jahresregenmenge
                       + Windrichtung zusätzlich als Text
                       ~ Änderung "Regen Aktuell" in "Regenrate"
                       ~ Splitt in conf- + sub-Datei
 V0.1.3 / 08.02.2020   + Unterstützung für Datenpunkt "Regenmenge Jahr", zB. für Froggit WH4000 SE
                       + Shell-Parameter -s (Klartextanzeige Passwort + Station-ID)
                       + Shell-Parameter --data (zeigt nur das gesendete Datenpaket der Wetterstation an)
 V0.1.2 / 31.01.2020   + Prüfung auf Datenintegrität
                       + neuer Datenpunkt bei Kommunikationsfehler
                       + Ausgabe Datenpaket der Wetterstation bei Debug
 V0.1.1 / 01.01.2020   + UTC-Korrektur
                       + Config-Versionscheck
                       + Shell-Parameter -v/-h/--debug
 V0.1.0 / 29.12.2019   erstes Release

Versionsinfo
### Ende Infoblock

 #Versionierung
  SH_VER="V3.5.2"
  CONF_V="V3.5.2"
  SUBVER="V3.5.2"


 #Installationsverzeichnis feststellen
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

 #Config-Version prüfen
  VER_CONFIG=$(cat "${DIR}/wetterstation.conf"|grep '### Setting'|cut -d" " -f3)
  if [ $CONF_V != $VER_CONFIG ]; then
     echo -e "wetterstation: \e[31mERROR #000 - Config-Version mismatch!\n"
     echo -e "benutzt: $VER_CONFIG\t benötigt wird: $CONF_V \e[0m"
     exit 1
  fi

 #Sub-Version prüfen
  SUB_CONFIG=$(cat "${DIR}/wetterstation.sub"|grep '### Subroutinen'|cut -d" " -f3)
  if [ $SUBVER != $SUB_CONFIG ]; then
     echo -e "wetterstation: \e[31mERROR #001 - Subroutinen-Version mismatch!\n"
     echo -e "benutzt: $SUB_CONFIG\t benötigt wird: $SUBVER \e[0m"
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
        --metsommer )           metsom_override=true
                                metsommer
                                exit
                                ;;
        --influx_test)          minmax24h DEBUG
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


 #Setup + Initial ausführen
  setup
  minmaxheute


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
   j=35
   for (( i=1; i<rawinlen; i++ ))
   do
     if [[ ${MESSWERTERAWIN[$i]} == tempinf=* ]] || [[ ${MESSWERTERAWIN[$i]} == indoortempf=* ]]
        then MESSWERTE[0]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); INDOOR_TEMP=${MESSWERTE[0]}; convertFtoC 0; fi
     if [[ ${MESSWERTERAWIN[$i]} == tempf=* ]]
        then MESSWERTE[1]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); TEMPF=${MESSWERTE[1]}; convertFtoC 1; do_trend_aussentemp; fi
     if [[ ${MESSWERTERAWIN[$i]} == dewptf=* ]]
        then MESSWERTE[2]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); DEWPTF=${MESSWERTE[2]}; convertFtoC 2; fi
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
     if [[ ${MESSWERTERAWIN[$i]} == rainratein=* ]] || [[ ${MESSWERTERAWIN[$i]} == rainin=* ]] || [[ ${MESSWERTERAWIN[$i]} == rrain_piezo=* ]]
        then MESSWERTE[11]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 11; fi
     if [[ ${MESSWERTERAWIN[$i]} == dailyrainin=* ]] || [[ ${MESSWERTERAWIN[$i]} == drain_piezo=* ]]
        then MESSWERTE[12]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 12; fi
     if [[ ${MESSWERTERAWIN[$i]} == weeklyrainin=* ]] || [[ ${MESSWERTERAWIN[$i]} == wrain_piezo=* ]]
        then MESSWERTE[13]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 13; fi
     if [[ ${MESSWERTERAWIN[$i]} == monthlyrainin=* ]] || [[ ${MESSWERTERAWIN[$i]} == mrain_piezo=* ]]
        then MESSWERTE[14]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertInchtoMM 14; fi
     if [[ ${MESSWERTERAWIN[$i]} == yearlyrainin=* ]] || [[ ${MESSWERTERAWIN[$i]} == yrain_piezo=* ]]
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
     if [[ ${MESSWERTERAWIN[$i]} == winddir_avg10m=* ]]
        then MESSWERTE[26]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); winddir 26; fi
     if [[ ${MESSWERTERAWIN[$i]} == windspdmph_avg10m=* ]]
        then MESSWERTE[27]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertMPHtoKMH 27; fi
     if [[ ${MESSWERTERAWIN[$i]} == vpd=* ]]
        then MESSWERTE[30]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi


     ### zusätzliche DPxxx-Sensoren ############################################################
      if [ "${ANZAHL_DP10}" -gt "0" ]; then DP10; fi
      if [ "${ANZAHL_DP35}" -gt "0" ]; then DP35; fi
      if [ "${ANZAHL_DP40}" -gt "0" ]; then DP40; fi
      if [ "${ANZAHL_DP50}" -gt "0" ] || [ "${ANZAHL_DP100}" -gt "0" ]; then DP50_100; fi
      if [ "${ANZAHL_DP60}" -gt "0" ]; then DP60; fi
      if [ "${ANZAHL_DP70}" -gt "0" ]; then DP70; fi
      if [ "${ANZAHL_DP200}" -gt "0" ]; then DP200; fi
      if [ "${ANZAHL_DP250}" -gt "0" ]; then DP250; fi
      if [ "${ANZAHL_DP300}" -gt "0" ]; then DP300; fi
     ### zusätzliche DPxxx-Sensoren ################################################### ENDE ###

     ### zusätzliche WHxxx-Sensoren ############################################################
      if [ "${ANZAHL_WH31}" -gt "0" ]; then WH31; fi
     ### zusätzliche WHxxx-Sensoren ################################################### ENDE ###

     ### zusätzliche WSxxx-Sensoren ############################################################
      if [ "${ANZAHL_WS90}" -gt "0" ]; then WS90; fi
     ### zusätzliche WHxxx-Sensoren ################################################### ENDE ###

     ### zusätzliche Bresser-Sensoren ##########################################################
      if [ "${ANZAHL_7009999}" -gt "0" ]; then BR_001; fi
     ### zusätzliche WHxxx-Sensoren ################################################### ENDE ###

     ### zusätzliche Sainlogic oder Curconsa Sensoren, Station FT0300 ###########################
     if [ "${ANZAHL_DP50}" -eq "0" ] || [ "${ANZAHL_DP100}" -eq "0" ]; then
      if [[ ${MESSWERTERAWIN[$i]} == temp1f=* ]]
        then MESSWERTE[28]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); convertFtoC 28; fi
      if [[ ${MESSWERTERAWIN[$i]} == humidity1=* ]]
        then MESSWERTE[29]=$(echo ${MESSWERTERAWIN[$i]}|cut -d"=" -f2); fi
     fi
     ### zusätzliche Sainlogic oder Curconsa Sensoren, Station FT0300 ################## ENDE ###

   done


   #Taupunkt und Windchill
    do_windchill

   #durchschnittliche Windgeschwindigkeit der letzten 10 Minuten
    if [[ ! "$DATA" =~ "windspdmph_avg10m=" ]]; then do_windspeed ${MESSWERTE[6]}; fi

   #Daten an ioB schicken
    if [ ${FIX_AUSSENTEMP} == "true" ]
     then
       if (( $(bc -l <<< "${MESSWERTE[1]} > -273") ))
        then
         iob_send
         if [ "${TEMPFIX_ERR}" -gt "0" ]; then let "TEMPFIX_ERR--"; fi
        else
         MELDUNG "unplausibler Messwert Aussentemperatur. Datenpaket verworfen..."
         let "TEMPFIX_ERR++"
         if [ "${TEMPFIX_ERR}" -gt "10" ]
          then
           MELDUNG "m%C3%B6glicherweise Batterie des Wettermastes schwach"
           SAPI "Single" "set/${DP_STATION_BATTERIE}?value=1&ack=true"
          fi
       fi
     else
       iob_send
    fi

   #Reset Kommfehler
    if [ ! -z "$KOMFEHLER" ] && [ "$KOMFEHLER" -gt "0" ]; then
       let "KOMFEHLER--"
       if [ "$KOMFEHLER" -eq "0" ] && [ $RESET_KOMFEHLER == "true" ]; then SAPI "Single" "set/${DP_KOMFEHLER}?value=false&ack=true"; fi
    fi


  else
   let "KOMFEHLER++"
   if [ "$KOMFEHLER" -eq "10" ]; then SAPI "Single" "set/${DP_KOMFEHLER}?value=true&ack=true"; fi
   if [ "$KOMFEHLER" -gt "10" ]; then KOMFEHLER=10; fi  #Anzahl beschränken
  fi



  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi



  #Mitternachtjobs
   if [ $(date +%H) -ge "23" ] && [ $(date +%M) -ge "58" ] && [ -z $MIDNIGHTRUN ]; then
        rain               #Jahresregenmenge
        firmware_check     #neue Firmware
        reset_zaehler      #Sonnenscheindauer, Solarenergie zurücksetzen (enthällt auch Speicherung Werte VorJahr)
        minmaxavg365d      #Min-/Max-/Avg-Aussentemperatur vor einem Jahr
        metsommer          #meteorologischer Sommer Durchschnittstemperatur und Regenmenge
        MELDUNG "Mitternachtjobs durchgef%C3%BChrt"
   fi
   if [ $(date +%H) -eq "0" ] && [ $(date +%M) -le "3" ]; then
       unset MIDNIGHTRUN
       if [ $(date +%Z) == "CEST" ]; then ZULU=22; else ZULU=23; fi
   fi



  #15-Minutenjobs: Wetterprognose; min/max Aussentemperatur der letzten 24h + heute
   DO_IT=$(date +%M)
   DO_IT=${DO_IT#0}
   if [ $(( $DO_IT % 15 )) -eq "0" ]; then
     if [ $(date +%s) -ge "$TIMER_SET" ]; then wetterprognose
      if [ ! -z ${INFLUX_BUCKET} ]; then minmax24h; minmaxheute; fi
     fi
     do_Wetterwarnung
     #stündlich Lebenszeichen
     if [ "$(date +%H)" -ne "${ALIVE}" ]; then ALIVE=$(date +%H); MELDUNG "Skript l%C3%A4uft..."; fi
   fi



  #6-Minutenjobs: WOW, Windy
   if [ $(( $DO_IT % 6 )) -eq "0" ] && [ ${block_6minjobs} -le "0" ]; then

     #Windy
      if [ ${use_windy} == "true" ]; then windy_update; fi
     #WOW
      if [ ${use_wow} == "true" ]; then wow_update; fi

     #run_onlyonce
      block_6minjobs=3;

    else
     let block_6minjobs--
   fi



  #5-Minutenjobs: wetter.com; Wolkenbasis
   if [[ $(( $DO_IT % 5 )) -eq "0" && -z ${run_5minjobs_onlyonce} ]]; then

     #wetter.com / Wolkenbasis
     if [ ! -z ${WETTERCOM_ID} ]; then wettercom_update; fi
     do_wolkenbasis

     #Windböe max. für Stationen die keinen Wert (#21) liefern
     if [ ! -z ${INFLUX_BUCKET} ] && [ -z ${MESSWERTE[21]} ]; then windboeemax; fi

     #run only once
      run_5minjobs_onlyonce=true

    else
     if [ ${run_5minjobs_onlyonce} ]; then unset run_5minjobs_onlyonce; fi
   fi



   #Hitzeindex
     if (( $(bc -l <<< "${MESSWERTE[1]} > 20") )); then
       HITZEINDEX=$(round $(hitzeindex ${MESSWERTE[1]} ${MESSWERTE[5]}) 2)
      else
       HITZEINDEX=
     fi


  #openSenseMap
   if [ ${openSenseMap} == "true" ]; then opensensemap; fi

  #Wunderground
   if [ ${WUNDERGROUND_UPDATE} == "true" ]; then wunderground_update; fi

  #AWEKAS
   if [ ${use_awekas} == "true" ]; then awekas_update; fi


  #Logging eingeschaltet?
   if [ $logging == "true" ]; then logging; fi


 done
###EoF

