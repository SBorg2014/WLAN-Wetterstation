#!/bin/bash

UPDATE_VER=V3.5.1

###  Farbdefinition
      GR='\e[1;32m'
      GE='\e[1;33m'
      WE='\e[1;37m'
      BL='\e[1;36m'
      RE='\e[1;31m'


echo -e "\n\n${BL}"
echo -e '
    _       _______       __  __          __      __
   | |     / / ___/      / / / /___  ____/ /___ _/ /____  _____
   | | /| / /\__ \______/ / / / __ \/ __  / __ `/ __/ _ \/ ___/
   | |/ |/ /___/ /_____/ /_/ / /_/ / /_/ / /_/ / /_/  __/ /
   |__/|__//____/      \____/ .___/\__,_/\__,_/\__/\___/_/'  ${GE}${UPDATE_VER}${BL}
echo -en '                           /_/'
echo -e "${WE}\n"


 #Nicht als root...
 if [ $(whoami) = "root" ]; then echo -e "$RE Ausführung als \"root\" nicht möglich...!\n"; exit 1; fi

 #Verzeichnis feststellen + conf lesen
  DIR=$(pwd)
  if [ -f "${DIR}/wetterstation.conf" ]; then . "${DIR}/wetterstation.conf"; fi


 #Test ob Datei auf GitHub, sonst Fallback
 if [ "$1" = "" ] && ( ! curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh|grep -xq '404: Not Found' ); then
    echo -e "$WE Benutze neuste Version ${BL}$(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh|grep -m 1 'UPDATE_VER='|cut -d"=" -f2)${WE} auf GitHub..."
    sleep 2
    source <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --menu
    exit 0
 fi



checker() {
         #Test ob bc, jq, unzip, patch und dc installiert sind / Service im User-Kontext läuft
         #installierte Influx-Version
         #Rest-Api im ioB läuft
         #Service im User-Kontext?
         if [ ! $(cat /etc/systemd/system/wetterstation.service|grep User=) ]; then
          echo -e "\n$GE Service läuft nicht im User-Kontext sondern unter User ${RE}root${GE}..."
          jn_abfrage "\n$WE Soll nun auf User (empfohlen) umgestellt werden?"
          if [ -z $antwort ]; then echo -e "\n"; return; fi
          echo -e "\n"
          sudo sed -i '/\[Service\]/a User='$(whoami)'\nGroup='$(whoami) /etc/systemd/system/wetterstation.service
          echo -e "\n Done... Restarte Service...\n"
          sudo systemctl daemon-reload
          sudo systemctl restart wetterstation
         fi
         if [ ! -z ${INFLUX_API} ]; then check_prog influx; fi
         check_prog bc
         check_prog jq
         check_prog dc
         check_prog unzip
         check_prog patch
         check_prog restapi
         echo -e "\n"
}


check_prog() {
         if [ $1 == "influx" ]; then
          if [ ! $(curl -skL -I "${INFLUX_WEB}://${INFLUX_API}/ping" | grep X-Influxdb-Version | cut -d" " -f2 | grep v2.[0-9].[0-9]) ]; then echo -e "${RE} Offizieller Support nur noch für Influx V2.x!\n\n${WE}"; sleep 5; fi
          return
         fi
         if [ $1 == "restapi" ]; then
          if [ "$(nc -vz $(echo "${RESTAPI_URL}" | grep -o '[\.0-9]*') &> /dev/null; echo $?)" -eq "0" ]; then RESTAPI=true
            echo -e "\n Zugriff auf $GR'Rest-API'$WE im ioBroker: [$GR✓$WE]"
           else
            RESTAPI=false
            echo -e "\n Zugriff auf $GR'Rest-API'$WE im ioBroker: [$RE✗$WE]"
            echo -e "  (Dies ist kein Problem, es können nur keine neuen Datenpunkte bei Bedarf automatisch angelegt werden."
            echo -e "  Dies muss im Fall neuer Datenpunkte per 'wetterstation.js' von Hand im ioBroker erfolgen.)"
           fi
          return
         fi
         if [ $(which $1) ]; then
           echo -e " $GR'$1'$WE installiert: [$GR✓$WE]"
          else
           echo -e " $GR'$1'$WE installiert: [$RE✗$WE]"
           echo -e "\n\n $RE Bitte zuerst '$1' installieren [sudo apt install $1]\n"
           exit 1
         fi
}

backup() {
 echo -e "\n Lege Sicherungskopie der wetterstation.conf an..."
 cp ./wetterstation.conf ./wetterstation.conf.backup
}

FEHLER() {
 if [ "$UPDATE_VER" == "$VERSION" ]; then echo -e "\n$WE Version ist aktuell, nothing to do...\n"; exit 0; fi
 echo -e "\n  Updater ist ${RE}nur${WE} für Versionen ab V1.4.0 !\n"
 exit 1
}

patcher() {
         echo -en "\n${WE} Soll die ${RE}wetterstation.conf ${WE}nun auf die neue Version ${GE}${UPDATE_VER}${WE} gepatcht werden? [${GR}J/N${WE}]"
           read -n 1 -p ": " JN
           if [ "$JN" = "J" ] || [ "$JN" = "j" ]; then
             echo -e "\n\n\n"
            else
             echo -e "\n\n\n"
             echo -e " $RE Abbruch... ${WE}\n\n\n"; exit 1;
           fi

  VERSION_SH=$(cat ./wetterstation.sh|grep "SH_VER"|cut -d"=" -f2|tr -d \")

  while [ "$VERSION_CONF" != "$VERSION_SH" ]
   do
    VERSION_CONF=$(cat ./wetterstation.conf|grep "### Settings V"|cut -d" " -f3)

    case ${VERSION_CONF} in
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
           V2.7.0) PATCH280 ;;
           V2.8.0) PATCH2100 ;;
           V2.9.0) echo -e "$GE Kein Patch nötig...\n" ;;
           V2.10.0) PATCH2110 ;;
           V2.11.0) PATCH2111 ;;
           V2.11.1) PATCH2120 ;;
           V2.12.0) PATCH2121 ;;
           V2.12.1) PATCH2130 ;;
           V2.13.0) PATCH2140 ;;
           V2.14.0) PATCH2150 ;;
           V2.15.0) PATCH2160 ;;
           V2.16.0) PATCH2170 ;;
           V2.17.0) PATCH2180 ;;
           V2.18.0) PATCH2190 ;;
           V2.19.0) PATCH2200 ;;
           V2.20.0) PATCH2210 ;;
           V2.21.0) PATCH2220 ;;
           V2.22.0) PATCH3000 ;;
           V3.0.0) PATCH3010 ;;
           V3.1.0) PATCH3011 ;;
           V3.1.1) PATCH3020 ;;
           V3.2.0) PATCH3030 ;;
           V3.3.0) PATCH3040 ;;
           V3.4.0) PATCH3050 ;;
           V3.5.0) PATCH3051 && service_restart && exit 0;;
           V3.5.1) echo -e "$GE Version ist bereits aktuell...\n" && exit 0;;
                *) FEHLER
    esac

   done
 exit 0
}

main() {
         #Wetterstation im Verzeichnis vorhanden
         if [ ! -f ./wetterstation.sh ]; then
          echo -e "\n$RE Keine Version von WLAN-Wetterstation im aktuellen Verzeichnis gefunden...\n"
          exit 1
         fi

         #aktuelle Version von GitHub holen
          GitHub=$(curl -sH "Accept: application/vnd.github.v3+json" https://api.github.com/repos/SBorg2014/WLAN-Wetterstation/releases/latest)
          akt_ver_long=$(echo ${GitHub} | jq -r '.name' | sed -e 's/-/vom/; s/\"//g')
          akt_version=$(echo ${GitHub} | jq -r '.tag_name')
          info_version=$(echo ${GitHub} | jq -r '.body' | tr -d '*\\')

          echo -e " Aktuelle Version (latest) auf GitHub: ${GR}$akt_ver_long$WE"
          VERSION=$(cat ./wetterstation.sh|grep "SH_VER"|cut -d"=" -f2|tr -d \")
          echo -e " Version im aktuellen Verzeichnis    : ${GR}$VERSION"

          if [ "$VERSION" == "$akt_version" ]; then echo -e "\n$GE Version ist bereits aktuell...\n"; exit 0; fi

          echo -e "\n$WE Informationen zum Release $akt_version:"
          echo -e " ─────────────────────────────────────────────────────────────"
          echo -e "\n$GE $info_version\n$WE"

          jn_abfrage "\n$WE Soll ein Update von WLAN-Wetterstation durchgeführt werden?"
          if [ -z $antwort ]; then echo -e "\n"; exit 0; fi

         #Update
          echo -e "\n\n$WE Führe Update aus...\n"
          DL_URL=$(echo ${GitHub} | jq -r '.assets | .[].browser_download_url')
          curl -LJ ${DL_URL} -o tmp.zip
          unzip -o tmp.zip -x wetterstation.conf
          sudo chmod +x wetterstation.sh ws_updater.sh

          rm tmp.zip
          source ./ws_updater.sh --patch
}

service_restart() {
          jn_abfrage "\n ${WE}Update ausgeführt. Soll der Service nun neu gestartet werden?"
          if [ ! -z $antwort ]; then echo -e "\n"; sudo systemctl restart wetterstation.service; fi
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


#Patch Version V2.7.0 auf V2.8.0
PATCH280() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.8.0 ..."
 sed -i '/^.*SONNENSCHEIN_TXTFORMAT=.*/a \ \n\n  #Daten an Wetter.com senden (leer lassen falls nicht gewünscht)?\n   WETTERCOM_ID=\n   WETTERCOM_PW=' ./wetterstation.conf
 sed -i 's/### Settings V2.7.0/### Settings V2.8.0/' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Falls die Übertragung der Wetterdaten an wetter.com erfolgen soll, nun aktivieren durch eintragen von User-ID und Passwort!\n"
}


#Patch Version V2.8.0 auf V2.10.0
PATCH2100() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.10.0 ..."
 patch_2100 && patch ./wetterstation.conf < patch.dat
 rm patch.dat
 echo -e " Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP300/WS68, DP40/WH32 oder WH25/WH31 müssen eingetragen werden!\n"
}


#Patch Version V2.10.0 auf V2.11.0
PATCH2110() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.11.0 ..."
 sed -i 's/### Settings V2.10.0/### Settings V2.11.0/' ./wetterstation.conf
 sed -i '/^.*debug=.*/a \ \n #Verhalten bei Kommunikationsfehler [true/false] / default: false / Soll der Datenpunkt automatisch resettet werden?\n  RESET_KOMFEHLER=false' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Parameter für Kommunikationsfehler ggf. ändern. Per Default verbleibt er im Zustand 'true' bei einem Fehler.\n"
}


#Patch Version V2.11.0 auf V2.11.1
PATCH2111() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.11.1 ..."
 sed -i 's/### Settings V2.11.0/### Settings V2.11.1/' ./wetterstation.conf
 sed -i 's/Sainlogic Profi/DNS/' ./wetterstation.conf
 echo -e " Fertig...\n"
}


#Patch Version V2.11.1 auf V2.12.0
PATCH2120() {
 backup
 echo -e "\n Patche wetterstation.conf auf V2.12.0 ..."
 sed -i 's/### Settings V2.11.1/### Settings V2.12.0/' ./wetterstation.conf
 sed -i '/^.*WETTERCOM_PW=.*/a \ \n #Fix aktivieren bei fehlerhafter Außentemperatur [true/false] / default: false\n #Bei unplausiblem Messwert wird kein Datenpaket an den ioB geschickt\n  FIX_AUSSENTEMP=false' ./wetterstation.conf
 echo -e " Fertig...\n"
 echo -e " ${GE}Parameter für FIX_AUSSENTEMP ggf. ändern. Per Default werden auch unplausible Messwerte an den ioB geschickt.\n"
}


#Patch Version V2.12.0 auf V2.12.1
PATCH2121() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.12.1 ..."
 sed -i 's/### Settings V2.12.0/### Settings V2.12.1/' ./wetterstation.conf
 echo -e "${WE} Fertig...\n"
}


#Patch Version V2.12.1 auf V2.13.0
PATCH2130() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.13.0 ..."
 sed -i 's/### Settings V2.12.1/### Settings V2.13.0/' ./wetterstation.conf
 sed -i '/^.*ANZAHL_WH31=.*/a \  ANZAHL_DP35=0' ./wetterstation.conf
 echo -e "${WE} Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP35 müssen eingetragen werden!\n"
}


#Patch Version V2.13.0 auf V2.14.0
PATCH2140() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.14.0 ..."
 sed -i 's/### Settings V2.13.0/### Settings V2.14.0/' ./wetterstation.conf
 sed -i '/^.*WEB=HTTP.*/a \\n #Ignoriere Zertifikatsfehler bei der Simple-Restful-API [true/false] / default: false / nötig bei eigenen Zertifikaten\n  WEB_IGN_SSL_ERROR=false' ./wetterstation.conf
 echo -e "${WE} Fertig...\n"
}


#Patch Version V2.14.0 auf V2.15.0
PATCH2150() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.15.0 ..."
 sed -i 's/### Settings V2.14.0/### Settings V2.15.0/' ./wetterstation.conf
 sed -i '/^.*WETTERCOM_PW=.*/a \\n\n #Daten an Wunderground.com senden? [true/false] / default: false\n   #Nur nötig und sinnvoll bei WS_PROTOKOLL=9 (DNS) wenn trotzdem auch Daten weiterhin an Wunderground.com gesendet werden sollen.\n   WUNDERGROUND_UPDATE=false' ./wetterstation.conf
 sed -i 's/#InfluxDB-Konfiguration/#InfluxDB-Konfiguration für Influx V1.x.x/' ./wetterstation.conf
 echo -e "${WE} Fertig...\n"
 echo -e " ${GE}Die Datenübertragung an Wunderground.com kann nun aktiviert werden!\n"
}


#Patch Version V2.15.0 auf V2.16.0
PATCH2160() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.16.0 ..."
 sed -i 's/### Settings V2.15.0/### Settings V2.16.0/' ./wetterstation.conf
 sed -i '/^.*IPP=.*/a \\n #Protokoll, ioBroker-IP und Port der Rest-API [http(s)://xxx.xxx.xxx.xxx:xxxxx] / leer lassen falls nicht benutzt\n  RESTAPI_URL=\n  RESTAPI_USER=\n  RESTAPI_PW=' ./wetterstation.conf
 echo -e "${WE} Fertig...\n"
 echo -e " ${GE}Die Rest-API kann nun durch Eingabe der URL und den Zugangsdaten aktiviert werden!\n"
}


#Patch Version V2.16.0 auf V2.17.0
PATCH2170() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.17.0 ..."
 sed -i 's/### Settings V2.16.0/### Settings V2.17.0/' ./wetterstation.conf
 sed -i '/^.*WUNDERGROUND_UPDATE=.*/a \\n #Windrichtung und -geschwindigkeit der letzten 10 Minuten anstelle aktueller Werte an\n #windy/OpenSenseMap/wetter.com übertragen? [true/false] / default: false\n  USE_AVG_WIND=false' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then make_objects ".Aussentemperatur_Trend" "Trend der Aussentemperatur der letzten Stunde" "number" "°C"; fi
 echo -e "${WE} Fertig...\n"
 echo -e " ${GE}Die alternative Datenübertragung von Windrichtung und -geschwindigkeit der letzten\n 10 Minuten an windy/OpenSenseMap/wetter.com kann nun aktiviert werden!"
 echo -e " Einstellung dafür in der wetterstation.conf: ${BL}USE_AVG_WIND=true\n${WE}"
}


#Patch Version V2.17.0 auf V2.18.0
PATCH2180() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.18.0 ..."
 sed -i 's/### Settings V2.17.0/### Settings V2.18.0/' ./wetterstation.conf
 sed -i '/^.*ANZAHL_DP35=.*/i \  ANZAHL_DP10=0' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then
  make_objects ".Info.Wolkenbasis" "Höhe der Wolkenbasis" "number" "m"
  make_objects ".Info.Shellscriptversion" "Versionsnummer des Scriptes" "string"
  make_objects ".Windrichtung_Text_10min" "Windrichtung Durchschnitt 10 Minuten als Text" "string"
 fi
 echo -e "${WE} Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren DP10/WN35 können nun eingetragen werden!\n${WE}"
}


#Patch Version V2.18.0 auf V2.19.0
PATCH2190() {
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.19.0 ..."
 sed -i 's/### Settings V2.18.0/### Settings V2.19.0/' ./wetterstation.conf
 sed -i '/^.*ANZAHL_WH31=.*/a \  ANZAHL_WS90=0' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then make_objects ".Info.Wetterwarnung" "mögliche Wetterereignisse" "string"
#     #Abfrage starten zum Anlegen der DPs des WS90
#     jn_abfrage "${WE} Sollen nun Datenpunkte für den WS90 angelegt werden...(nur sinnvoll wenn man auch einen hat ;-))?"
#     if [ ! -z $antwort ]; then
#      make_objects ".WS90" "WS90 Wittboy" "folder"
#      make_objects ".WS90.1.aktuelle_Regenrate" "WS90 Kanal 1 aktuelle Regenrate" "number" "mm/h"
#     fi
 fi
 echo -e "\n${WE} Fertig...\n"
 echo -e " ${GE}Eventueller Zusatzsensor WS90 kann nun eingetragen werden!${WE}"
# if [ ${RESTAPI} != "true" ] || [ -z $antwort ]; then echo -e " ${GE}Dazu noch 'wetterstation.js' im ioB ersetzen, konfigurieren und einmalig ausführen.\n${WE}"; fi
 echo -e " ${GE}Dazu noch 'wetterstation.js' im ioB ersetzen, konfigurieren und einmalig ausführen.\n${WE}"
}


#Patch Version V2.19.0 auf V2.20.0
PATCH2200(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.20.0 ..."
 sed -i 's/### Settings V2.19.0/### Settings V2.20.0/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
}


#Patch Version V2.20.0 auf V2.21.0
PATCH2210(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.21.0 ..."
 sed -i 's/### Settings V2.20.0/### Settings V2.21.0/' ./wetterstation.conf
 sed -i '/^.*Ende Usereinstellungen.*/i \\n #############################################################################################\n ###    AWEKAS - Einstellungen (nur nötig falls AWEKAS benutzt werden soll)                ###\n #############################################################################################' ./wetterstation.conf
 sed -i '/^.*Ende Usereinstellungen.*/i \\n  #AWEKAS aktivieren [true/false] / default: false\n   use_awekas=false\n\
  #AWEKAS Login Username und Passwort\n   AWEKAS_USER=\n   AWEKAS_PW=\n\
 #############################################################################################\
 ###    AWEKAS - Ende der Einstellungen    ###################################################\
 #############################################################################################\n' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then
  make_objects ".Info.Awekas_at" "Datenübertragung an AWEKAS.at erfolgreich" "boolean"
 fi
 echo -e "\n${WE} Fertig...\n"
 echo -e " ${GE}Die Datenübertragung kann nun (optional) in der wetterstaion.conf nach Eintragung der Zugangsdaten aktiviert werden.${WE}"
}


#Patch Version V2.21.0 auf V2.22.0
PATCH2220(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V2.22.0 ..."
 sed -i 's/### Settings V2.21.0/### Settings V2.22.0/' ./wetterstation.conf
 sed -i 's/Anzahl der vorhandenen Zusatzsensoren/Anzahl der vorhandenen Zusatzsensoren Froggit, Ecowitt und Bresser/' ./wetterstation.conf
 sed -i '/^.*ANZAHL_DP300=.*/a \  ANZAHL_7009999=0' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
 echo -e " ${GE}Eventuelle Zusatzsensoren Bresser #7009999 können nun eingetragen werden!${WE}"
 echo -e " ${GE}Dazu noch 'wetterstation.js' im ioB ersetzen, konfigurieren und einmalig ausführen.\n${WE}"
}


#Patch Version V2.22.0 auf V3.0.0
PATCH3000(){
 echo -e "${RE}"'
      ___        __    __                       __
     /   | _____/ /_  / /___  ______  ____ _   / /
    / /| |/ ___/ __ \/ __/ / / / __ \/ __ `/  / /
   / ___ / /__/ / / / /_/ /_/ / / / / /_/ /  /_/
  /_/  |_\___/_/ /_/\__/\__,_/_/ /_/\__, /  (_)
                                   /____/'"${WE}"

  echo -e "\n${GE} ┌──────────────────────────────────────────────────────┐"
  echo -e " │ V3.0.0 ist ein Breaking-Release!                     │"
  echo -e " │ Es wird zwingend bei der Nutzung der Influx-Features │"
  echo -e " │ InfluxDB mindestens in der Version 2.x oder höher    │"
  echo -e " │ benötigt !                                           │"
  echo -e " └──────────────────────────────────────────────────────┘${WE}\n"

   jn_abfrage "${WE}\n Möchten Sie ${BL}WLAN-Wetterstation${WE} auf Version V3.0.0 updaten?"
   if [ -z $antwort ]; then echo -e "\n ${RE}Abbruch...${WE}\n\n"; exit 1; fi
   unset antwort

 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.0.0 ..."
 sed -i 's/### Settings V2.22.0/### Settings V3.0.0/' ./wetterstation.conf
 sed -i 's/#Name, User und Passwort der InfluxDB-Datenbank/#Bucket, Token und Organisation der InfluxDB/' ./wetterstation.conf
 sed -i 's/INFLUX_DB=/INFLUX_BUCKET=/' ./wetterstation.conf
 sed -i 's/INFLUX_USER=.*/INFLUX_TOKEN=/' ./wetterstation.conf
 sed -i 's/INFLUX_PASSWORD=.*/INFLUX_ORG=/' ./wetterstation.conf
 sed -i '/^.*#InfluxDB-Konfiguration \/ ohne InfluxDB alles leer lassen.*/a \  #Protokoll (HTTP oder HTTPS) / default: HTTP\n   INFLUX_WEB=HTTP' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
 echo -e " ${GE}InfluxDB in Version 2.x kann nun in der Konfiguration aktiviert werden.\n${WE}"
}


#Patch Version V3.0.0 auf V3.1.0
PATCH3010(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.1.0 ..."
 sed -i 's/### Settings V3.0.0/### Settings V3.1.0/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
}


#Patch Version V3.1.0 auf V3.1.1
PATCH3011(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.1.1 ..."
 sed -i 's/### Settings V3.1.0/### Settings V3.1.1/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
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

patch_2100() {
cat <<EofP >patch.dat
--- wetterstation.org	2021-10-26 20:01:56.772982845 +0200
+++ wetterstation.conf	2021-10-26 20:04:21.625615091 +0200
@@ -1,7 +1,10 @@
-### Settings V2.8.0 -----------------------------------------------------------
+### Settings V2.10.0 -----------------------------------------------------------
  #Debuging einschalten [true/false] / default: false / Ausgabe der Messwerte
   debug=false

+ #Logging einschalten [true/false] / default: false / schreibt die Datenstrings der Station in eine Datei
+  logging=false
+
  #ioBroker-IP und Port der Simple-Restful-API [xxx.xxx.xxx.xxx:xxxxx]
   IPP=192.168.1.3:8087

@@ -9,12 +12,15 @@
   WS_PROTOKOLL=1

  #Anzahl der vorhandenen Zusatzsensoren / default: 0
+  ANZAHL_WH31=0
+  ANZAHL_DP40=0
   ANZAHL_DP50=0
   ANZAHL_DP60=0
   ANZAHL_DP70=0
   ANZAHL_DP100=0
   ANZAHL_DP200=0
   ANZAHL_DP250=0
+  ANZAHL_DP300=0

  #Protokoll (HTTP oder HTTPS) / default: HTTP
   WEB=HTTP
EofP
}


#Patch Version V3.1.1 auf V3.2.0
PATCH3020(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.2.0 ..."
 sed -i 's/### Settings V3.1.1/### Settings V3.2.0/' ./wetterstation.conf
 sed -i '/^.*Ende Usereinstellungen.*/i \\n\n #############################################################################################\n ###    WOW - Einstellungen (nur nötig falls WOW benutzt werden soll)                      ###\n #############################################################################################' ./wetterstation.conf
 sed -i '/^.*Ende Usereinstellungen.*/i \\n  #WOW aktivieren [true/false] / default: false\n   use_wow=false\n\
  #WOW Site ID und Authentication Key\n   WOW_SITEID=\n   WOW_AUTHKEY=\n\
 #############################################################################################\
 ###    WOW - Ende der Einstellungen    ######################################################\
 #############################################################################################\n' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then
  make_objects ".Info.WOW" "Datenübertragung WOW erfolgreich" "boolean"
 fi
 echo -e "\n${WE} Fertig...\n"
 echo -e " ${GE}Die Datenübertragung kann nun (optional) in der wetterstaion.conf nach Eintragung der Zugangsdaten und Aktivierung erfolgen.${WE}"
}


#Patch Version V3.2.0 auf V3.3.0
PATCH3030(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.3.0 ..."
 sed -i 's/### Settings V3.2.0/### Settings V3.3.0/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
}


#Patch Version V3.3.0 auf V3.4.0
PATCH3040(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.4.0 ..."
 sed -i 's/### Settings V3.3.0/### Settings V3.4.0/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
}


#Patch Version V3.4.0 auf V3.5.0
PATCH3050(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.5.0 ..."
 sed -i 's/### Settings V3.4.0/### Settings V3.5.0/' ./wetterstation.conf
 if [ ${RESTAPI} == "true" ]; then
  make_objects ".Sättigungsdefizit" "(Wasserdampf-)Drucksättigungsdefizit VPD" "number" "kPa"
 fi
 echo -e "\n${WE} Fertig...\n"
}


#Patch Version V3.5.0 auf V3.5.1
PATCH3051(){
 backup
 echo -e "${WE}\n Patche wetterstation.conf auf V3.5.1 ..."
 sed -i 's/### Settings V3.5.0/### Settings V3.5.1/' ./wetterstation.conf
 echo -e "\n${WE} Fertig...\n"
}


jn_abfrage() {
         echo -en "\n$1 ${WE}[${GR}J/N${WE}]"
           read -n 1 -p ": " JN
           if [ "$JN" = "J" ] || [ "$JN" = "j" ]; then
             antwort=true
            else
             unset antwort
           fi

}

install() {
   #WLAN-Wetterstation Installationsroutine
    jn_abfrage "${WE}\n Möchten Sie ${BL}WLAN-Wetterstation${WE} im aktuellen Verzeichnis installieren?"
    if [ -z $antwort ]; then echo -e "\n ${RE}Abbruch...${WE}\n\n"; exit 1; fi
    unset antwort

    #aktuelle Version feststellen, downloaden und entpacken
     echo -e "\n\n\n Hole Daten von GitHub..."
     GitHub=$(curl -sH "Accept: application/vnd.github.v3+json" https://api.github.com/repos/SBorg2014/WLAN-Wetterstation/releases/latest)
     akt_version=$(echo ${GitHub} | jq -r '.name' | sed -e 's/-/vom/; s/\"//g')
     echo -e " Aktuelle Version: ${GR}${akt_version}${WE}"
     DL_URL=$(echo ${GitHub} | jq -r '.assets | .[].browser_download_url')
     echo -e " Lade Datei von GitHub herunter...\n"
     curl -LJ ${DL_URL} -o tmp.zip
     echo -e "\n Entpacke Dateien...\n"
     unzip -n tmp.zip

     echo -e "\n Lösche Dateidownload..."
     rm tmp.zip

     echo -e "\n Dateien ausführbar setzen..."
     chmod +x ws_updater.sh wetterstation.sh

     jn_abfrage "\n${WE} Soll WLAN-Wetterstation nun als Service eingerichtet werden?"
     if [ ! -z $antwort ]; then service; fi

    #Konfiguration öffnen
     jn_abfrage "\n${WE} Konfiguration nun öffnen?"
     if [ ! -z $antwort ]; then
       if [ ! -f ~/.selected_editor ]; then update-alternatives --config editor; fi
       $(cat ~/.selected_editor | grep SELECTED_EDITOR | cut -d"=" -f2 | tr -d \") wetterstation.conf
     fi

    #DPs im ioB anlegen...
     jn_abfrage "\n${BL} Nun mittels des Javascriptes ${GE}'wetterstation.js'${BL} die Datenpunkte im ioBroker anlegen! Fertig [\e[101m Nein=Abbruch \e[0m${BL}]?"
     if [ -z $antwort ]; then echo -e "\n"; exit 1; fi
     unset antwort

    #Testlauf starten
     jn_abfrage "\n${WE} Einmaligen Testdurchlauf im Debug-Modus starten...(empfiehlt sich)?"
     if [ ! -z $antwort ]; then ./wetterstation.sh --debug; fi

    #enable Service
     jn_abfrage "\n${WE} WLAN-Wetterstation Service nun starten?"
     if [ ! -z $antwort ]; then sudo systemctl start wetterstation.service; fi

    echo -e "\n\n Fertig..."
    echo -e " Wenn der Testlauf ausgeführt wurde und erfolgreich verlief, sollten nun aktuelle Daten\n der Wetterstation im ioBroker in den Datenpunkten stehen ;-)\n"
}

service() {
      #existiert der Service schon?
      if [ -f /etc/systemd/system/wetterstation.service ]; then
         echo -e "\n\n ${RE}Wetterstation-Service existiert bereits!${WE}\n"
         return 0
      fi

        sudo tee -a /etc/systemd/system/wetterstation.service > /dev/null <<-EoD
	[Unit]
	Description=Service für ioBroker Wetterstation

	[Service]
	User=$(whoami)
	Group=$(whoami)
	ExecStart=${DIR}/wetterstation.sh

	[Install]
	WantedBy=multi-user.target
	EoD

      echo -e "\n Aktiviere den Service nun..."
      sudo systemctl daemon-reload
      sudo systemctl enable wetterstation.service
      echo -e "\n ${GE}Der Service kann nun mittels ${GR}systemctl start wetterstation${GE} gestartet werden..."

}

usage() {
        echo -e "\nusage: ws_updater [[--install] | [--patch] | [--service] | [-h|--help]]\n"
        echo -e " --install\tinstalliert WLAN-Wetterstation im aktuellen Verzeichnis"
        echo -e " --patch\tpatcht die 'wetterstation.conf' auf eine neue Version"
        echo -e " --service\trichtet WLAN-Wetterstation als Service ein"
        echo -e " -h | --help\tdieses Hilfemenue\n"
}

menu() {
        clear
        echo -e "$WE\n\n\n"
        echo -e "\t Auswahlmenü für WLAN-Wetterstation:"
        echo -e "\t_____________________________________\n\n"
        echo -e "\t [${BL}1${WE}] im aktuellen Verzeichnis installieren\n"
        echo -e "\t [${BL}2${WE}] als Service einrichten\n"
        echo -e "\t [${BL}3${WE}] Konfigurationsdatei patchen\n"
        echo -e "\t [${BL}4${WE}] Update ausführen\n\n"
        echo -e "\t [${BL}E${WE}] Exit\n\n\n"
        echo -en "\t Ihre Auswahl: [${GR}1-4,E${WE}]"

        read -n 1 -p ": " MENU_AUSWAHL
        echo -e "\n"
        case $MENU_AUSWAHL in
           1)   source <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --install
                exit 0 ;;
           2)   source <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --service
                exit 0 ;;
           3)   source <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --patch
                exit 0 ;;
           4)   source <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --gitup
                exit 0 ;;
           e|E) exit 0 ;;
           *) menu
        esac
}

make_objects(){
 #1: ID
 #2: name
 #3: type
 #4: unit

 echo -e "\n ${WE}Lege neues Object im ioBroker an: $BL${PRE_DP}$1$WE"
 local TOKEN=$(echo -n ${RESTAPI_USER}:${RESTAPI_PW} | base64)

 #build Data-String
  local DATA=$(cat <<-EOD
	{
	"_id": "${PRE_DP}$1",
	"type": "state",
	"common": {
	"name": "$2",
	"type": "$3",
	"role": "state"
	},
	"native": {
	"name": "$2",
	"type": "$3",
	"role": "state"
	}
	}
	EOD
  )

  #Check 4 Units
   if [ "$4" != "" ]; then DATA=$(echo $DATA | sed "s|\"role\": \"state\"|\"role\": \"state\", \"unit\": \"$4\"|g"); fi

 local RESULT=$(curl -skX 'POST' \
  ${RESTAPI_URL}'/v1/object/'${PRE_DP}${1} \
  -H 'accept: application/json' \
  -H 'authorization: Basic '${TOKEN} \
  -H 'Content-Type: application/json' \
  --data "$DATA"
 )

  #Fehler beim anlegen?
  if [[ $RESULT == *"error"* ]]; then local FEHLER_ioB=$(echo ${RESULT} | jq -r '.error')
   echo -e "${RE} Fehlermeldung beim Anlegen des Datenpunktes: ${FEHLER_ioB}${WE}\n"
  fi
  if [ "$RESULT" == "" ]; then echo -e "${RE} Keine Antwort der Rest-API erhalten! Stimmt das Protokoll (http/https), IP-Adresse und der Port?${WE}\n"; fi

}


  #gibt es Parameter?
  while [ "$1" != "" ]; do
    case $1 in
        --install )             checker
                                install
                                exit 0
                                ;;
        --menu )                menu
                                exit 0
                                ;;
        --service )             service
                                exit 0
                                ;;
        --gitup )               checker
                                main
                                exit 0
                                ;;
        --patch )               checker
                                patcher
                                exit 0
                                ;;
        -h | --help )           usage
                                exit 0
                                ;;
        * )                     echo -e "\n${RE}\"$1\"${WE} wird nicht unterstützt...\n\n"
                                usage
                                exit 1
    esac
    shift
  done



  checker
  main

