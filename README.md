# :partly_sunny: WLAN-Wetterstation
<br/><br/>
[![Current Release](https://img.shields.io/github/v/release/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/SBorg2014/WLAN-Wetterstation/latest/total.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Contributors](https://img.shields.io/github/contributors/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/graphs/contributors)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Commits since last release](https://img.shields.io/github/commits-since/SBorg2014/WLAN-Wetterstation/latest.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![License](https://img.shields.io/github/license/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/LICENSE)

 schafft eine Verbindung von einer WLAN-Wetterstation zum ioBroker und kann optional die Wetterdaten in [openSenseMap](https://opensensemap.org) und [Windy](https://www.windy.com) zur Verfügung stellen (__Projekt läuft nur unter Linux__)<br>
 
 Die Wetterstation muss dazu in der Lage sein ihre Daten im "Wunderground/Ecowitt"-Format zu senden.<br><br>
 Bisher getestete Stationen:
- DNT Weatherscreen PRO
- ELV WS980WiFi
- Eurochron EFWS 2900 (baugleich zu Sainlogic 10in1 Wifi, Ambient Weather WS-2902, Chilitec CTW-902 Wifi)
- Froggit
  * HP1000SE Pro
  * WH3000 SE
  * WH4000 SE
- Renkforce WH2600
- Sainlogic 7in1 WiFi WS3500
- Ventus W830
<br><br>

Zusatzsensoren (mittels Station oder Gateway DP1500/GW1000):
- bis zu 8 Stück DP50/WH31 Temperatur-/Luftfeuchtigkeit-Sensoren
- ein DP60/WH57 Blitzsensor
- bis zu 4 Stück DP70/WH55 Wasserleckage-Sensoren
- bis zu 8 Stück DP100/WH51 Bodenfeuchte-Sensoren
- bis zu 4 Stück DP200/WH43 PM2.5 Feinstaub-Sensoren
- ein DP250/WH45 5-In-1 CO2 / PM2.5 / PM10 / Temperatur / Luftfeuchte Innenraumsensor
<br><br>


Experimentell (über eigenen DNS-Server):
- Stationen ohne Möglichkeit der Konfiguration mittels App *WS View* wie bspw. *Sainlogic Profi Wlan Wetterstation FT0300*
- Installation siehe [WiKi](https://github.com/SBorg2014/WLAN-Wetterstation/wiki/Installation---eigener-DNS-Server)
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

## Weiterführende Informationen ##
***[Thread im ioBroker-Forum](https://forum.iobroker.net/topic/28384/linux-shell-skript-wlan-wetterstation)***
<br><br>

## Unterstützung für dieses/zukünftige Projekte ##
Wer möchte kann mir gerne einen Kaffee ausgeben und mich bei den Projekten unterstützen. Ich freue mich über jedweden Support.<br><br>
[![paypal](https://www.paypalobjects.com/de_DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RR76AEZHPJ7H4&source=url)
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

Copyright (c)2019-2021 by SBorg

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

