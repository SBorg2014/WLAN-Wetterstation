# :partly_sunny: WLAN-Wetterstation
<br/><br/>
[![Current Release](https://img.shields.io/github/v/release/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/SBorg2014/WLAN-Wetterstation/latest/total.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![Contributors](https://img.shields.io/github/contributors/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation.svg/graphs/contributors)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Percentage of issues still open](http://isitmaintained.com/badge/open/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/issues)
[![Commits since last release](https://img.shields.io/github/commits-since/SBorg2014/WLAN-Wetterstation/latest.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/releases/latest)
[![License](https://img.shields.io/github/license/SBorg2014/WLAN-Wetterstation.svg)](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/LICENSE)

 schafft eine Verbindung von einer WLAN-Wetterstation zum ioBroker (__nur für Linux__)<br>
 
 Die Wetterstation muss dazu in der Lage sein ihre Daten im "Wunderground"-Format zu senden.<br><br>
 Bisher getestete Stationen:
- Eurochron EFWS2900 (baugleich zu Sainlogic 10in1 Wifi, Ambient Weather WS-2902, Chilitec CTW-902 Wifi)
- Froggit 
  * WH3000 SE
  * WH3500 SE
  * WH4000 SE<sup>(\*)</sup>
- Sainlogic 7in1 WiFi WS3500
- Ventus W830

<sup>(\*)</sup>noch in Arbeit, voraussichtlich in V0.1.3 unterstützt
<br><br>
## Installation ## 
***[siehe WiKi](https://github.com/SBorg2014/WLAN-Wetterstation/wiki)***

<br><br>
## Versionen ##

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

