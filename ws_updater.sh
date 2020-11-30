#!/bin/bash

UPDATE_VER=V1.5.0

backup() {
 echo -e "\n Lege Sicherungskopie der wetterstation.conf an..."
 cp ./wetterstation.conf ./wetterstation.conf.backup
}

FEHLER() {
 clear
 if [ "$UPDATE_VER" == "$VERSION" ]; then echo -e "\n Version ist aktuell, nothing do do...\n"; exit 0; fi
 echo -e "\n  Updater ist \e[31mnur\e[0m für Versionen ab V1.4.0 !\n"
 exit 1
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




 VERSION=$(cat ./wetterstation.conf|grep "### Settings V"|cut -d" " -f3)


 case ${VERSION} in
           V1.4.0) PATCH140 ;;
           *)      FEHLER
 esac
 exit 0


