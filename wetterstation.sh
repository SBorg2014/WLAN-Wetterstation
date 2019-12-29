#!/bin/bash

# V0.1.0 - 29.12.2019 (c) 2019 SBorg
#
# wertet ein Datenpaket einer WLAN-Wetterstation im Wunderground-Format aus, konvertiert diese und überträgt
# die Daten an den ioBroker
#
# benötigt den 'Simple RESTful API'-Adapter im ioBroker und 'bc' unter Linux
#
# V0.1.0 / 29.12.2019 - erstes Release
#


 ###Konfiguration lesen
 . ./wetterstation.conf

 declare -a MESSWERTE

 #Check ob Pollintervall größer 10 Sekunden
  if [ ${WS_POLL} -lt "10" ]; then WS_POLL=10; fi


#Endlosschleife
while true
 do
  #auf Daten der Wetterstation warten und nach GET filtern
   DATA=`nc -lv ${WS_PORT}|grep GET`

  #DATA zerlegen (Messwerte Block #3-#21)
   ii=2
   for ((i=0; i<18; i++))
    do
     let "ii++"
     MESSWERTE[$i]=$(echo ${DATA}|cut -d'&' -f${ii} | cut -d"=" -f2)
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

