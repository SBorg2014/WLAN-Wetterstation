# :partly_sunny: WLAN-Wetterstation
<br/><br/>
[![Current Release](https://img.shields.io/github/v/release/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/SBorg2014/WLAN-Wetterstation/latest/total.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![GitHub download](https://img.shields.io/github/downloads/SBorg2014/WLAN-Wetterstation/total.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Contributors](https://img.shields.io/github/contributors/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/graphs/contributors)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![GitHub issues](https://img.shields.io/github/issues/SBorg2014/WLAN-Wetterstation)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Commits since last release](https://img.shields.io/github/commits-since/SBorg2014/WLAN-Wetterstation/latest.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![License](https://img.shields.io/github/license/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/LICENSE)

 schafft eine Verbindung von einer WLAN-Wetterstation zum ioBroker und kann optional die Wetterdaten in [openSenseMap](https://opensensemap.org), [Windy](https://www.windy.com) und [wetter.com](https://www.wetter.com) zur Verfügung stellen (__Projekt läuft nur unter Linux__)<br>
 
 Die Wetterstation muss dazu in der Lage sein ihre Daten im "Wunderground/Ecowitt"-Format zu senden.<br><br>
 Bisher getestete Stationen:
- BRESSER WLAN Farb-Wetter Center mit 5-in-1 Profi-Sensor V <sup>(*)</sup>
- ChiliTec Funk Wetterstation 12in1
- DNT Weatherscreen PRO
- ELV WS980WiFi
- Eurochron EFWS 2900 (baugleich zu Sainlogic 10in1 Wifi, Ambient Weather WS-2902, Chilitec CTW-902 Wifi)
- Froggit
  * HP1000SE Pro
  * WH3000 SE
  * WH4000 SE
- Renkforce WH2600
- Sainlogic 
  * 7in1 WiFi WS3500
  * Profi Wlan Wetterstation FT0300 <sup>(*)</sup>
- Ventus W830
   
 <sup>(*)</sup> über DNS-Server wie bspw. PiHole oder dnsmasq
<br><br>

Zusatzsensoren (mittels Station oder Gateway DP1500/GW1000):
- bis zu 8 Stück DP35/WN34 Wassertemperatur-Sensoren
- ein DP40/WH32 (bzw. WH26) Außentemperatur- und Luftfeuchtigkeitssensor
- bis zu 8 Stück DP50/WH31 Temperatur-/Luftfeuchtigkeit-Sensoren
- ein DP60/WH57 Blitzsensor
- bis zu 4 Stück DP70/WH55 Wasserleckage-Sensoren
- bis zu 8 Stück DP100/WH51 Bodenfeuchte-Sensoren
- bis zu 4 Stück DP200/WH43 PM2.5 Feinstaub-Sensoren
- ein DP250/WH45 5-In-1 CO2 / PM2.5 / PM10 / Temperatur / Luftfeuchte Innenraumsensor
- ein DP300/WS68 Solarunterstütztes Anemometer mit UV-Lichtsensor
- ein WH31 (bzw. WH25) Sensor
<br><br>*__Die mögliche Anzahl der Zusatzsensoren ist nicht durch das Skript begrenzt, sondern wird vom Display und/oder Gateway bestimmt.__*
<br><br>    
     
über eigenen DNS-Server:
- Stationen ohne Möglichkeit der Konfiguration mittels App *WS View* wie bspw. *Sainlogic Profi Wlan Wetterstation FT0300*
- Installation siehe [WiKi](https://github.com/SBorg2014/WLAN-Wetterstation/wiki/Installation---eigener-DNS-Server)
<br><br>
   
## Unterstützung für dieses/zukünftige Projekte ##
Wer möchte kann mir gerne einen Kaffee ausgeben und mich bei den Projekten unterstützen. Ich freue mich über jedweden Support.<br><br>
[![paypal](https://www.paypalobjects.com/de_DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RR76AEZHPJ7H4&source=url)
<br><br>
   
Beispiel einer Visualisierung per Grafana (zu finden [hier](https://github.com/SBorg2014/WLAN-Wetterstation/tree/master/Grafana%20Dashboard)):
![Grafana](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-0.png)
![Grafana](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-1.png)
<br><br>
Datenpunkte im ioBroker:<br>
![ioB-Datenpunkte](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/ioB-Datenpunkte.png)
<br><br>
Daten in openSenseMap:<br>
![Bild openSenseMap](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/OSEM_Messwerte.png)
<br><br>
Daten in Windy:<br>
![Bild Windy](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Windy.png)
<br><br>
Daten in Wetter.com:<br>
![Bild Wetter.com](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/wettercom.gif)
<br><br>

## Weiterführende Informationen ##
***[Thread im ioBroker-Forum](https://forum.iobroker.net/topic/28384/linux-shell-skript-wlan-wetterstation)***
<br><br>

## Installation ## 
***[siehe WiKi](https://github.com/SBorg2014/WLAN-Wetterstation/wiki)***
<br><br>

## Wetterstation-Statistik (Addon) ## 
![ioB-Datenpunkte](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Wetterstatistik_DPs.png)
<br>
***[siehe WiKi](https://github.com/SBorg2014/WLAN-Wetterstation/wiki/Wetterstation-Statistik)***
<br><br>

## Versionen ##
  
**V2.14.0 - 28.05.2022**
```
    ~ Fixed authentication for Simple-API setBulk requests (@crycode-de)
    + Set ack flag on setBulk requests (requires PR ioBroker/ioBroker.simple-api#145) (@crycode-de)
    + Added option to ignore SSL errors if HTTPS is used together with a self-signed certificate (@crycode-de)
    + Added the state .Info.Sonnenschein_VorTag_Text (@crycode-de)
    ~ Merge some SAPI "Single" calls into SAPI "Bulk" calls (@crycode-de)
 ```

**V2.13.0 - 05.04.2022**
```
    + Unterstützung für DP35/WN34 Sensor (@Omnedon)
```  


**V2.12.1 - 29.03.2022**
```
    ~ Fehler bei "FIX_AUSSENTEMP" behoben (keine Datenübertragung an den ioB / Issue #31)
```  


**V2.12.0 - 26.03.2022**
```
    + bei fehlerhafter Außentemperatur erfolgt keine Datenübertragung des Paketes an den ioB
```


**V2.11.1 - 14.02.2022**
```
    ~ Reduzierung valides Datenpaket auf 250 Zeichen
    ~ "SainLogic Pro"-Protokoll in "DNS" umbenannt
```


**V2.11.0 - 03.12.2021**
```
    ~ Windgeschwindigkeit bei wetter.com in m/s
    + Konfigurationsmöglichkeit des Kommunikationsfehlers (Issue #26)
    ~ Bugfix Speicherort beim logging
    ~ Ergänzung bei Prüfung auf valides Datenpaket (Außentemperatur hinzugefügt)
    + Hinweis auf korrekte WS_ID bei Wunderground-Protokoll falls Kommunikationsfehler
```


**V2.10.1 - 22.11.2021**
```
    ~ Bugfix 'jq'-Fehlermeldungen von 0:00 Uhr bis 01:00 Uhr
    ~ Bugfix Fehlermeldung "bereits existierender User" bei der OSeM-Registrierung obwohl keiner angelegt
    + bei Option '--debug' werden, sofern aktiviert, nun auch die Daten an den/die Wetter-Dienst(e) geschickt und deren Meldung(en) ausgegeben
    ~ Fix auftretende Fehlermeldung falls SimpleAPI nicht erreichbar war
    ~ Codeoptimierungen
```


**V2.10.0 - 21.10.2021**  
```
     ~ Bugfix Option '--data' bei Ecowitt-Protokoll
     ~ Passkey bei Nutzung des Ecowitt-Protokolls maskieren
     + logging des Datenstrings der Wetterstation in eine Datei
     + Unterstützung für DP40/WH32 (bzw. WH26) Sensor
     + Unterstützung für DP300/WS68 Sensor
     + Unterstützung für WH31 (bzw. WH25) Sensor
     + netcat-/Success-Meldungen im Syslog entfernt
     + Patch Sommer-/Winterzeit für wetter.com
```


**V2.9.0 - 25.08.2021**
```
     + Min-/Max-Aussentemperatur des heutigen Tages
     ~ Änderung bei Datenübertragung per Simple-API wg. InfluxDB 2.x
     + Meteorologischer Sommer Durchschnittstemperatur und Regenmenge
     + neuer Shell-Parameter --metsommer (zur manuellen Berechnung der Werte des meteorologischen Sommers)
```


**V2.8.0 - 14.08.2021**
```
     ~ Änderung am Messverfahren der Solarenergie (festes Poll-Intervall --> Zeitstempel)
     + Support für wetter.com
```


**V2.7.0 - 15.07.2021**
```
     + Bei bereits eingetragenem OSEM-User erfolgt Abbruch der OSEM-Registrierung
     + Unterstützung für DP250/WH45 Sensor
     ~ Fix Prüfung netcat-Version
     ~ Berechnung Windchill nur bis 11°C
```

     
**V2.6.0 - 04.05.2021**
```
     ~ Fix Avg Aussentemperatur vor einem Jahr
     ~ Windchill erst ab 5km/h Windgeschwindigkeit
     + Prüfung bei Option "v" ob die netcat-Version korrekt ist
     + Support für Windy
     ~ Hitzeindex
```


**V2.5.0 - 08.02.2021**
```
     ~ Fix für Protokoll #9 wg. fehlender Regenrate
     + Min/Max/Avg Aussentemperatur vor einem Jahr
     + Unterstützung von max. 4 DP70 Sensoren
     ~ Codeoptimierungen
```


**V2.4.0 - 03.02.2021**
```
    + Hitzeindex (>20°C)
    + Unterstützung von max. 4 DP200 Sensoren
```


**V2.3.0 - 26.01.2021**
```
    ~ Fix Rundungsfehler Windchill/Taupunkt
    + Min/max Aussentemperatur der letzten 24h
    + Unterstützung für DP60 Sensor
    ~ Fix für Protokoll #9 wg. fehlender Regenrate
```


**V2.2.0 - 21.01.2021**
```
    ~ Fix Batteriestatus
    ~ Chillfaktor umbenannt auf Windchill/gefühlte Temperatur
    + Berechnung Windchill + Taupunkt für Ecowitt-Protokoll
```


**V2.1.0 - 10.01.2021**
```
    + zusätzliches Protokoll "9" für userspezifische Abfrage
    ~ Fix Reset kumulierte Regenmenge zum Jahresanfang
    ~ Fix für DP100 Bodenfeuchte
```


**V2.0.0 - 15.12.2020**
```
    + Unterstützung des Gateways und Zusatzsensoren (@a200)
    + Protokoll (wunderground oder ecowitt) wählbar
```


**V1.6.0 - 06.12.2020**
```
    + Patch (@a200) für neuere Firmwareversionen (V1.6.3) speziell bei Nutzung eines Gateways
    ~ Reset des Error-Kommunikationszählers
    + Prüfung bei Option "-v" ob 'bc' und 'jq' installiert sind
    ~ Option "n" bei netcat hinzugefügt
```


**V1.5.0 - 30.11.2020**
```
    + Verschlüsselung mittels HTTPS möglich
    + Authentifizierung mittels User/Passwort
    + ws_updater.sh (zum updaten der wetterstation.conf)
```


**V1.4.0 - 15.11.2020**
```
    + Support für OpenSenseMap
```


**V1.3.1 - 10.10.2020**
```
    ~ fix für Leerzeichen im Verzeichnisnamen
    + Wetterstation-Statistik (JS-Addon)
```


**V1.3.0 - 22.06.2020**
```
    + letztes Regenereignis und Regenmenge
    + Fehlermeldung bei falscher WS_ID / ID der Wetterstation
    + Sonnenscheindauer + Solarenergie vom Vortag
    ~ Änderung/Fix Sonnenscheindauer
```


**V1.2.0 - 01.05.2020**
```
   + Firmwareupgrade verfügbar?
   + Firmwareversion
   + Sonnenscheindauer Heute, Woche, Monat, Jahr
   + UV-Belastung
   + Solarenergie Heute, Woche, Monat, Jahr
   + Vorjahreswerte von Regenmenge, Sonnenscheindauer und Solarenergie
```


**V1.1.0 - 14.04.2020**
```
   + aktueller Regenstatus
   + Luftdrucktendenz, Wettertrend und aktuelles Wetter
```


**V1.0.0 - 18.03.2020**
```
   + Berechnung der Jahresregenmenge
   + Windrichtung zusätzlich als Text
   ~ Änderung "Regen Aktuell" in "Regenrate"
   ~ Splitt in conf- + sub-Datei
```


**V0.1.3 - 08.02.2020**
```
    + Unterstützung für Datenpunkt "Regenmenge Jahr", zB. für Froggit WH4000SE
    + Shell-Parameter -s (Klartextanzeige Passwort + Station-ID)
    + Shell-Parameter --data (zeigt nur das gesendete Datenpaket der Wetterstation an)
```

**V0.1.2 - 31.01.2020**
```
    + Prüfung auf Datenintegrität
    + neuer Datenpunkt bei Kommunikationsfehler
    + Ausgabe Datenpaket der Wetterstation bei Debug
```

**V0.1.1 - 01.01.2020**
```
    + UTC-Korrektur
    + Config-Versionscheck
    + Shell-Parameter -v/-h/--debug
``` 
    
**V0.1.0 - erstes Release (29.12.2019)**
```
    + erstes Release
``` 

<br><br>
## :scroll: License ## 
 MIT License

Copyright (c)2019-2022 by SBorg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

