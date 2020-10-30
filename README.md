# :partly_sunny: WLAN-Wetterstation
<br/><br/>
[![Current Release](https://img.shields.io/github/v/release/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/SBorg2014/WLAN-Wetterstation/latest/total.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Contributors](https://img.shields.io/github/contributors/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/graphs/contributors)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Commits since last release](https://img.shields.io/github/commits-since/SBorg2014/WLAN-Wetterstation/latest.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![License](https://img.shields.io/github/license/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/LICENSE)

 schafft eine Verbindung von einer WLAN-Wetterstation zum ioBroker und kann die Wetterdaten in openSenseMap zur Verfügung stellen (__Projekt läuft nur unter Linux__)<br>
 
 Die Wetterstation muss dazu in der Lage sein ihre Daten im "Wunderground"-Format zu senden.<br><br>
 Bisher getestete Stationen:
- Eurochron EFWS2900 (baugleich zu Sainlogic 10in1 Wifi, Ambient Weather WS-2902, Chilitec CTW-902 Wifi)
- Froggit
  * HP1000SE Pro
  * WH3000 SE
  * WH4000 SE
- Sainlogic 7in1 WiFi WS3500
- Ventus W830

<br><br>
Beispiel einer Visualisierung per Grafana (zu finden [hier](https://github.com/SBorg2014/WLAN-Wetterstation/tree/master/Grafana%20Dashboard)):
![Grafana](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-0.png)
![Grafana](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-1.png)
<br><br>
Datenpunkte im ioBroker:
![ioB-Datenpunkte](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/ioB-Datenpunkte.png)
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

Copyright (c) 2019-2020 SBorg2014

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

