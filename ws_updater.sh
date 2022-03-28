#!/bin/bash

UPDATE_VER=V2.12.0

###  Farbdefinition
      GR='\e[1;32m'
      GE='\e[1;33m'
      WE='\e[1;37m'
      BL='\e[1;36m'
      RE='\e[1;31m'

            echo -e "\n\n\n${GE} ┌────────────────────────┐"
            echo -e " │                        │"
            echo -e " │  ${BL} WS-Updater ${UPDATE_VER}${GE}\t  │"
            echo -e " │                        │"
            echo -e " └────────────────────────┘${WE}\n"

#Nicht als root...
 if [ $(whoami) = "root" ]; then echo -e "$RE Ausführung als \"root\" nicht möglich...!\n"; exit 1; fi


#Test ob Datei auf GitHub, sonst Fallback
 if [ "$1" = "" ] && ( ! curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh|grep -q '404: Not Found' ); then
    echo -e "$WE Benutze neuste Version ${BL}$(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh|grep -m 1 'UPDATE_VER='|cut -d"=" -f2
)${WE} auf GitHub..."
    sleep 2
    bash <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --menu
    exit 0
 fi



checker() {
         #Test ob bc, jq, unzip und patch installiert sind / Service im User-Kontext läuft
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
         check_prog bc
         check_prog jq
         check_prog unzip
         check_prog patch
         echo -e "\n"
}

check_prog() {
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
         echo -en "\n${WE} Soll die ${RE}wetterstation.conf ${WE}nun auf eine neue Version gepatcht werden? [${GR}J/N${WE}]"
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
           V2.11.1) PATCH2120 && exit 0;;
           V2.12.0) echo -e "$GE Version ist bereits aktuell...\n" ;;
           *)      FEHLER
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
          /bin/bash ./ws_updater.sh --patch

          jn_abfrage "\n ${WE}Update ausgeführt. Soll der Service nun neu gestartet werden?"
          if [ ! -z $antwort ]; then echo -e "\n"; sudo systemctl restart wetterstation.service; fi

exit
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
     unzip tmp.zip

     echo -e "\n Lösche Dateidownload..."
     rm tmp.zip

     echo -e "\n Dateien ausführbar setzen..."
     chmod +x ws_updater.sh wetterstation.sh

     jn_abfrage "\n${WE} Soll WLAN-Wetterstation nun als Service eingerichtet werden?"
     if [ ! -z $antwort ]; then service; fi

    #Konfiguration öffnen
     jn_abfrage "\n${WE} Konfiguration nun öffnen?"
     if [ ! -z $antwort ]; then $(cat ~/.selected_editor | grep SELECTED_EDITOR | cut -d"=" -f2 | tr -d \") wetterstation.conf; fi

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
    echo -e "Wenn der Testlauf ausgeführt wurde und erfolgreich verlief, sollten nun aktuelle Daten der Wetterstation im ioBroker in den Datenpunkten stehen ;-)\n"
}

service() {
      #existiert der Service schon?
      if [ -f /etc/systemd/system/wetterstation.service ]; then
         echo -e "\n\n ${RE}Wetterstation-Service existiert bereits!${WE}\n"
         return 0
      fi

      #Verzeichnis feststellen
      DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
        echo -en "\t Ihre Auswahl: [${GR}1-4${WE}]"

        read -n 1 -p ": " MENU_AUSWAHL
        echo -e "\n"
        case $MENU_AUSWAHL in
           1)   bash <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --install
                exit 0 ;;
           2)   bash <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --service
                exit 0 ;;
           3)   bash <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh) --patch
                exit 0 ;;
           4)   bash <(curl -s https://raw.githubusercontent.com/SBorg2014/WLAN-Wetterstation/master/ws_updater.sh)
                exit 0 ;;
           e|E) exit 0 ;;
           *) menu
        esac
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
        --patch )               patcher
                                exit 0
                                ;;
        -h | --help )           usage
                                exit 0
                                ;;
        * )                     echo -e "\n${RE}\"$1\"${WE} wird nicht unterstüzt...\n\n"
                                usage
                                exit 1
    esac
    shift
  done


 checker
 main

