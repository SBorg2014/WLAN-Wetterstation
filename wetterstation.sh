#!/bin/bash

 ###Konfiguration lesen
 . ./wetterstation.conf 

 
while true
 do
  #auf Daten der Wetterstation warten und nach GET filtern
  #DATA=`nc -lv 80|grep GET`
  DATA='GET /weatherstation/updateweatherstation.php?ID=METEO1&PASSWORD=JUPP&indoortempf=75.2&tempf=40.8&dewptf=39.0&windchillf=40.8&indoorhumidity=42&humidity=94&windspeedmph=2.9&windgustmph=4.5&winddir=236&absbaromin=28.308&baromin=30.095&rainin=0.000&dailyrainin=0.012&weeklyrainin=0.201&monthlyrainin=1.673&solarradiation=0.00&UV=0&dateutc=2019-12-25%2005:11:31&softwaretype=EasyWeatherV1.4.4&action=updateraw&realtime=1&rtfreq=5 HTTP/1.0'

  #DATA zerlegen
  #Innentemperatur:
   TEMP_INNEN=$(echo ${DATA}|cut -d'&' -f3 | cut -d"=" -f2)
   TEMP_INNEN=`echo "scale=2;(${TEMP_INNEN}-32)*5/9"|bc -l`
  #Aussentemperatur:
   TEMP_AUSSEN=$(echo ${DATA}|cut -d'&' -f4 | cut -d"=" -f2)
   TEMP_AUSSEN=`echo "scale=2;(${TEMP_AUSSEN}-32)*5/9"|bc -l`
  #Taupunkt:
   TAUPUNKT=$(echo ${DATA}|cut -d'&' -f5 | cut -d"=" -f2)
   TAUPUNKT=`echo "scale=2;(${TAUPUNKT}-32)*5/9"|bc -l`
  #Chill-Faktor:
   CHILL=$(echo ${DATA}|cut -d'&' -f6 | cut -d"=" -f2)
   CHILL=`echo "scale=2;(${CHILL}-32)*5/9"|bc -l`
  #Innenluftfeuchte:
   FEUCHTE_INNEN=$(echo ${DATA}|cut -d'&' -f7 | cut -d"=" -f2)
  #Aussenluftfeuchte:
   FEUCHTE_AUSSEN=$(echo ${DATA}|cut -d'&' -f8 | cut -d"=" -f2)
  #Windgeschwindigkeit:
   WIND=$(echo ${DATA}|cut -d'&' -f9 | cut -d"=" -f2)
   WIND=`echo "scale=2;${WIND}*16094/10000"|bc -l`
  #Windgeschwindigkeit max:
   WIND_MAX=$(echo ${DATA}|cut -d'&' -f10 | cut -d"=" -f2)
   WIND_MAX=`echo "scale=2;${WIND_MAX}*16094/10000"|bc -l`
  #Windrichtung:
   WIND_DIR=$(echo ${DATA}|cut -d'&' -f11 | cut -d"=" -f2)
  #Luftdruck absolut:
   DRUCK_ABS=$(echo ${DATA}|cut -d'&' -f12 | cut -d"=" -f2)
   DRUCK_ABS=`echo "scale=2;${DRUCK_ABS}*33864/1000"|bc -l`
  #Luftdruck relativ:
   DRUCK_REL=$(echo ${DATA}|cut -d'&' -f13 | cut -d"=" -f2)
   DRUCK_REL=`echo "scale=2;${DRUCK_REL}*33864/1000"|bc -l`
  #Regen aktuell:
   REGEN_AKT=$(echo ${DATA}|cut -d'&' -f14 | cut -d"=" -f2)
   REGEN_AKT=`echo "scale=1;${REGEN_AKT}*254/10"|bc -l`
  #Regen Tag:
   REGEN_TAG=$(echo ${DATA}|cut -d'&' -f15 | cut -d"=" -f2)
   REGEN_TAG=`echo "scale=1;${REGEN_TAG}*254/10"|bc -l`
  #Regen Woche:
   REGEN_WOCHE=$(echo ${DATA}|cut -d'&' -f16 | cut -d"=" -f2)
   REGEN_WOCHE=`echo "scale=1;${REGEN_WOCHE}*254/10"|bc -l`
  #Regen Monat:
   REGEN_MONAT=$(echo ${DATA}|cut -d'&' -f17 | cut -d"=" -f2)
   REGEN_MONAT=`echo "scale=1;${REGEN_MONAT}*254/10"|bc -l`
  #Sonnenstrahlung:
   SONNE=$(echo ${DATA}|cut -d'&' -f18 | cut -d"=" -f2)
  #UV-Index:
   UV_INDEX=$(echo ${DATA}|cut -d'&' -f19 | cut -d"=" -f2)
  #Zeitstempel:
   ZEITSTEMPEL=$(echo ${DATA}|cut -d'&' -f20 | cut -d"=" -f2 | sed -e 's/%20/_/')
   ZEITSTEMPEL=$(echo ${ZEITSTEMPEL}|awk -F'-|_' '{printf "%02s.%02s.%s %s\n", $3, $2, $1, $4}')
  #Datum und Zeit abfragen
   #DAT_ZEIT=`timedatectl |grep Local`
   #DATUM=$(echo ${DAT_ZEIT}|cut -d' ' -f4)
   #UHRZEIT=$(echo ${DAT_ZEIT}|cut -d' ' -f5)
 
  #Daten an ioB schicken
   curl --data "${DP_TEMP_INNEN}=$TEMP_INNEN&${DP_TEMP_AUSSEN}=$TEMP_AUSSEN&${DP_TAUPUNKT}=$TAUPUNKT&${DP_CHILL}=$CHILL&${DP_FEUCHTE_INNEN}=$FEUCHTE_INNEN&${DP_FEUCHTE_AUSSEN}=$FEUCHTE_AUSSEN&${DP_WIND}=$WIND&${DP_WIND_MAX}=$WIND_MAX&${DP_WIND_DIR}=$WIND_DIR&${DP_DRUCK_ABS}=$DRUCK_ABS&${DP_DRUCK_REL}=$DRUCK_REL&${DP_REGEN_AKT}=$REGEN_AKT&${DP_REGEN_TAG}=$REGEN_TAG&${DP_REGEN_WOCHE}=$REGEN_WOCHE&${DP_REGEN_MONAT}=$REGEN_MONAT&${DP_SONNE}=$SONNE&${DP_UV_INDEX}=$UV_INDEX&${DP_DATUM}=$DATUM&${DP_ZEIT}=$UHRZEIT&prettyPrint" http://${IPP}/setBulk
 
  if [ $debug == "true" ]; then
   # Datenfelder ausgeben
   echo -e "Temperatur Innen\t: $TEMP_INNEN °C"
   echo -e "Temperatur Aussen\t: $TEMP_AUSSEN °C"
   echo -e "Taupunkt\t\t: $TAUPUNKT °C"
   echo -e "Chill-Faktor\t\t: $CHILL °C"
   echo -e "Luftfeuchte Innen\t: $FEUCHTE_INNEN %"
   echo -e "Luftfeuchte Aussen\t: $FEUCHTE_AUSSEN %"
   echo -e "Windgeschwindkeit\t: $WIND km/h"
   echo -e "max. Windgeschwindkeit\t: $WIND_MAX km/h"
   echo -e "Windrichtung\t\t: $WIND_DIR °"
   echo -e "Luftdruck absolut\t: $DRUCK_ABS hPa"
   echo -e "Luftdruck relativ\t: $DRUCK_REL hPa"
   echo -e "Regen aktuell\t\t: $REGEN_AKT mm"
   echo -e "Regen Tag\t\t: $REGEN_TAG mm"
   echo -e "Regen Woche\t\t: $REGEN_WOCHE mm"
   echo -e "Regen Monat\t\t: $REGEN_MONAT mm"
   echo -e "Sonnenstrahlung\t\t: $SONNE W/m²"
   echo -e "UV-Index\t\t: $UV_INDEX"
   echo -e "Zeitstempel\t\t: $ZEITSTEMPEL"
  fi
 
 done
 