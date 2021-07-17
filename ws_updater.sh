#!/bin/bash

UPDATE_VER=V2.7.0

###  Farbdefinition
      GR='\e[1;32m'
      GE='\e[1;33m'
      WE='\e[1;37m'
      BL='\e[1;36m'
      RE='\e[1;31m'

echo -e "\n\n\n$BL WS-Updater ${UPDATE_VER}"

 #Test ob bc und jq installiert sind
         if [ $(which bc) ]; then
           echo -e "\n $GR'bc'$WE installiert: $GR✓"
          else
           echo -e "\n $GR'bc'$WE installiert: $RE✗"
         fi
         if [ $(which jq) ]; then
           echo -e " $GR'jq'$WE installiert: $GR✓\n"
          else
           echo -e " $GR'jq'$WE installiert: $RE✗\n"
         fi


backup() {
 echo -e "\n Lege Sicherungskopie der wetterstation.conf an..."
 cp ./wetterstation.conf ./wetterstation.conf.backup
}

FEHLER() {
 if [ "$UPDATE_VER" == "$VERSION" ]; then echo -e "\n$WE Version ist aktuell, nothing to do...\n"; exit 0; fi
 echo -e "\n  Updater ist ${RE}nur\e[0m für Versionen ab V1.4.0 !\n"
 exit 1
}

main() {

         echo -en "\n${WE} Soll die ${RE}wetterstation.conf ${WE}nun auf eine neue Version gepatcht werden? [${GR}J/N${WE}]"
           read -n 1 -p ": " JN
           if [ "$JN" = "J" ] || [ "$JN" = "j" ]; then
             echo -e "\n\n\n"
            else
             echo -e "\n\n\n"
             echo -e " $RE Abbruch... ${WE}\n\n\n"; exit 1;
           fi

 VERSION=$(cat ./wetterstation.conf|grep "### Settings V"|cut -d" " -f3)
 case ${VERSION} in
           V1.4.0) PATCH140 ;;
           V1.5.0) PATCH150 ;;
           V1.6.0) PATCH160 ;;
           V2.0.0) PATCH210 ;;
           V2.1.0) PATCH220 ;;
           V2.2.0) PATCH230 ;;
           V2.3.0) PATCH240 ;;
           V2.4.0) PATCH250 ;;
           V2.5.0) PATCH260 ;;
           V2.6.0) PATCH270 ;;
           *)      FEHLER
 esac
 exit 0
}



########################################################################################
#Patch Version V1.4.0 auf V1.5.0
PATCH140() {
 backup
 echo -e "\n Patche wetterstation.conf auf V1.5.0 ..."
 sed -i '/^.#Port der Wetterstation/i \ #Protokoll (HTTP oder HTTPS) \/ default: HTTP\n  WEB=HTTP\n\n #User-Authentifizierung falls benutzt; sonst leer lassen\n  AUTH_USER=\n  AUTH_PASS=\n' ./wetterstation.conf
 sed -i 's/### Settings V1.4.0/### Settings V1.5.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V1.5.0 auf V1.6.0
PATCH150() {
 backup
 echo -e "\n Patche wetterstation.conf auf V1.6.0 ..."
 sed -i 's/### Settings V1.5.0/### Settings V1.6.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V1.6.0 auf V2.0.0
PATCH160() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.0.0 ..."
 sed -i '/^.#Protokoll (HTTP oder HTTPS)/i \ #Protokoll der Wetterstation [1/2] \/ 1=Wunderground ; 2=Ecowitt \/ default: 1\n  WS_PROTOKOLL=1\n\n #Anzahl der vorhandenen DP50 Sensoren \/ default: 0\n  ANZAHL_DP50=0\n\n #HTTP Anzahl der vorhandenen DP100 Sensoren \/ default: 0\n  ANZAHL_DP100=0\n' ./wetterstation.conf
 sed -i 's/### Settings V1.6.0/### Settings V2.0.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V2.0.0 auf V2.1.0
PATCH210() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.1.0 ..."
 sed -i 's/#Protokoll der Wetterstation \[1\/2\] \/ 1=Wunderground ; 2=Ecowitt \/ default: 1/#Protokoll der Wetterstation \[1\/2\/9\] \/ 1=Wunderground ; 2=Ecowitt ; 9=Sainlogic Profi \/ default: 1/' ./wetterstation.conf
 sed -i 's/### Settings V2.0.0/### Settings V2.1.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V2.1.0 auf V2.2.0
PATCH220() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.2.0 ..."
 sed -i 's/Chillfaktor/gefühlte Temperatur/' ./wetterstation.conf
 sed -i 's/### Settings V2.1.0/### Settings V2.2.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V2.2.0 auf V2.3.0
PATCH230() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.3.0 ..."
 sed -i '/#Anzahl der vorhandenen DP50/,/ANZAHL_DP100=/c\ #Anzahl der vorhandenen Zusatzsensoren \/ default: 0\n  ANZAHL_DP50=0\n  ANZAHL_DP60=0\n  ANZAHL_DP100=0' ./wetterstation.conf
 sed -i '/^.#letztes Regenereignis/i \ #InfluxDB-Konfiguration \/ ohne InfluxDB alles leer lassen\n  #IP und Port der API [xxx.xxx.xxx.xxx:xxxxx]\n   INFLUX_API=\n  #Name, User und Passwort der InfluxDB-Datenbank\n   INFLUX_DB=\n   INFLUX_USER=\n   INFLUX_PASSWORD=\n' ./wetterstation.conf
 sed -i 's/### Settings V2.2.0/### Settings V2.3.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP50/60/100 müssen neu eingetragen werden!"
 echo -e " Neuen Configblock für Influx beachten/konfigurieren!\n"
}


#Patch Version V2.3.0 auf V2.4.0
PATCH240() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.4.0 ..."
 sed -i '/^.*ANZAHL_DP100=.*/a \  ANZAHL_DP200=0' ./wetterstation.conf
 sed -i 's/### Settings V2.3.0/### Settings V2.4.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP200 müssen eingetragen werden!\n"
}


#Patch Version V2.4.0 auf V2.5.0
PATCH250() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.5.0 ..."
 sed -i '/^.*ANZAHL_DP100=.*/i \  ANZAHL_DP70=0' ./wetterstation.conf
 sed -i 's/### Settings V2.4.0/### Settings V2.5.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP70 müssen eingetragen werden!\n"
}


#Patch Version V2.5.0 auf V2.6.0
PATCH260() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.6.0 ..."
 patch_260 && patch ./wetterstation.conf < patch
 rm patch
 echo -e " ${GE}Windy kann nun mittels \033[30m\033[47m./wetterstation.sh --windy_reg\033[0m ${GE}eingerichtet werden !\n"
}


#Patch Version V2.6.0 auf V2.7.0
PATCH270() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.7.0 ..."
 sed -i '/^.*ANZAHL_DP200=.*/a \  ANZAHL_DP250=0' ./wetterstation.conf
 sed -i 's/### Settings V2.6.0/### Settings V2.7.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Eventueller Zusatzsensor DP250/WH45 muss eingetragen werden!\n"
}


patch_260() {
cat <<EoD >patch
--- wetterstation.conf_250	2021-05-13 13:45:06.297750501 +0200
+++ wetterstation.conf	2021-05-12 18:39:24.358821394 +0200
@@ -1,4 +1,4 @@
-### Settings V2.5.0 -----------------------------------------------------------
+### Settings V2.6.0 -----------------------------------------------------------
  #Debuging einschalten [true/false] / default: false / Ausgabe der Messwerte
   debug=false
 
@@ -112,5 +112,42 @@
  #############################################################################################
 
 
+
+ #############################################################################################
+ ###    Windy - Einstellungen (nur nötig falls Windy benutzt werden soll)                  ###
+ #############################################################################################
+
+  #Windy aktivieren [true/false] / default: false
+   use_windy=false
+
+  #Windy API-Key
+   windy_APIKey=
+
+  #Station [number: 0 - 2147483647] / default: 0
+   windy_Station=
+
+  #Name der Station [Text]
+   windy_Name=
+
+  #Latitude/Breitengrad der Station
+   windy_Latitude=
+
+  #Longitude/Längengrad der Station
+   windy_Longitude=
+
+  #Elevation/Höhe ÜNN
+   windy_Elevation=
+
+  #Montagehöhe Temperatursensor über Boden
+   windy_Tempheight=
+
+  #Montagehöhe Windsensor über Boden
+   windy_Windheight=
+
+ #############################################################################################
+ ###    Windy - Ende der Einstellungen    ####################################################
+ #############################################################################################
+
+
 ###  Ende Usereinstellungen  
 ###EoF
EoD
}


 main

