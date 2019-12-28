#!/bin/bash

 ###Konfiguration lesen
 . ./wetterstation.conf

 declare -a MESSWERTE



#Endlosschleife
while true
 do
  #auf Daten der Wetterstation warten und nach GET filtern
   #DATA=`nc -lv ${WS_PORT}|grep GET`
   DATA="GET /weatherstation/updateweatherstation.php?ID=METEO1&PASSWORD=JUPP&indoortempf=75.2&tempf=40.8&dewptf=39.0&windchillf=40.8&indoorhumidity=42&humidity=94&windspeedmph=2.9&windgustmph=4.5&winddir=236&absbaromin=28.308&baromin=30.095&rainin=0.000&dailyrainin=0.012&weeklyrainin=0.201&monthlyrainin=1.673&solarradiation=0.00&UV=0&dateutc=2019-12-25%2005:11:31&softwaretype=EasyWeatherV1.4.4&action=updateraw&realtime=1&rtfreq=5 HTTP/1.0"

  #DATA zerlegen (Messwerte Block #3-#21)
   ii=2
   for ((i=0; i<9; i++))
    do
     let "ii++"
     MESSWERTE[$i]=$(echo ${DATA}|cut -d'&' -f${ii} | cut -d"=" -f2)
      if [ "$i" -ge "0" ] && [ "$i" -lt "4" ]; then convertFtoC; fi
      if [ "$i" -eq "6" ] || [ "$i" -eq "7" ]; then convertMPHtoKMH; fi
    done

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
   ZEITSTEMPEL=$(echo ${DATA}|cut -d'&' -f20 | cut -d"=" -f2)
   ZEITSTEMPEL=$(echo ${ZEITSTEMPEL}|awk -F'-|%20' '{printf "%02s.%02s.%s %s\n", $3, $2, $1, $4}')


  #Daten an ioB schicken
   #&${DP_DRUCK_ABS}=$DRUCK_ABS&${DP_DRUCK_REL}=$DRUCK_REL&${DP_REGEN_AKT}=$REGEN_AKT&${DP_REGEN_TAG}=$REGEN_TAG&${DP_REGEN_WOCHE}=$REGEN_WOCHE&${DP_REGEN_MONAT}=$REGEN_MONAT&${DP_SONNE}=$SONNE&${DP_UV_INDEX}=$UV_INDEX&${DP_DATUM}=$DATUM&${DP_ZEITSTEMPEL}=$ZEITSTEMPEL
   iob_send


  #Debug eingeschaltet?
   if [ $debug == "true" ]; then debuging; fi


 done

###EoF

