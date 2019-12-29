# WLAN-Wetterstation
 schafft eine Verbindung von einer WLAN-Wetterstation zum ioBroker (__nur für Linux__)<br>
 
 Die Wetterstation muss dazu in der Lage sein ihre Daten im "Wunderground"-Format zu senden.<br><br>
 Bisher getestete Stationen:
- Eurochron EFWS2900 (baugleich zu Sainlogic 10in1 Wifi, Froggit WH3000 SE, Ambient Weather WS-2902, Chilitec CTW-902 Wifi, Ventus W830)
- yyy
 
ins Wiki
 ```
 Install: bc (apt install -y bc)<br>
 DP Broker --> JS-Skript<br>
 conf + sh in ein Verzeichnis<br>
 chmod +x wetterstation.sh<br>
 Simple-Restful Adapter installieren<br>
 crontab -e (root) erweitern @reboot /home/iobroker/wetterstation.sh &<br>
 Zeitstempel im UTC-Format <br>
```

## Versionen ##
    
**V0.1.0 - erstes Release (29.12.2019)**
```
    + erstes Release
``` 

<br><br><br>
## License ## 
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

