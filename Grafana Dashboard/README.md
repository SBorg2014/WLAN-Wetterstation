Ersteller: crunchip@forum.iobroker.net  
Modifikationen: sborg@forum.iobroker.net

Das Grafana-Dashboard als JSON-Export.   

V3.0 des Dashboards ist speziell auf InfluxDB V2.x angepasst. Die Abfrage erfolgt mittels Flux.
Benötigt :
 * Boom Theme Plugin (für das Hintergrundbild)
 * Spectraphilic Windrose Plugin
 * Blendstat Panel (by farski) Plugin
 * Table Plugin

Installation des Windrose-Plugins:
```
sudo su -
cd /var/lib/grafana/plugins
git clone https://github.com/spectraphilic/grafana-windrose.git
```
Das Plugin in Grafana laden, dazu die `grafana.ini` bearbeiten:
```
nano /etc/grafana/grafana.ini
```
und unter **[plugins]** das laden erlauben:
```
[plugins]
allow_loading_unsigned_plugins = spectraphilic-windrose-panel
```
Nun noch den Grafana Service neu starten.

Für die Wetter- und Regenvorhersage werden weitere Datenpunkte aus den Adaptern "Das Wetter" und "Weatherunderground" 
benötigt, sowie weitere Datenpunkte aus dem ioBroker (bspw. "Ozon" oder "Strahlenbelastung" etc.).

Die Konfiguration des Dashboardes erfolgt in dessen Settings über die Variablen:
![Konfiguration Dashboard](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-Settings_V3.png)

Hier besteht die Möglichkeit mit zwei unterschiedlichen Buckets zu arbeiten. Nutzt man nur eines für alles (was ich nicht 
unbedingt empfehlen würde) trägt man bei beiden den gleichen Bucketnamen ein.

Bilder zur V3.0:<br>
![Übersicht Teil 1](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana_V3a.png)
![Übersicht Teil 2](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana_V3b.png)
---


V2.0 ist für Grafana V8.x angepasst und enthällt zahlreiche Fixes für die einzelnen Panels. 

Benötigt :
 * Boom Theme Plugin (für das Hintergrundbild)
 * WindRose Plugin
 * Blendstat Panel (by farski) Plugin
 * Table Plugin
  
  
Vor dem Import in der Datei ***\_\_DBname\_\_*** durch den eigenen Influx-Datenbanknamen ersetzen (40 Treffer bzw. bei V2.0 dann 45 Treffer), sonst gibt das
später eine Klickorgie 😉

Für die Wetter- und Regenvorhersage werden weitere Datenpunkte aus den Adaptern "Das Wetter" und "Weatherunderground" 
benötigt.

KEIN Support zu Fragen bzgl. Influx, Grafana oder dem Import etc. des DashBoardes!
 
Mit freundlicher Genehmigung zur Veröffentlichung von crunchip@forum.iobroker.net
<br>
<br>
<br> 
<br>
Creator: crunchip@forum.iobroker.net   
Modifications: sborg@forum.iobroker.net
 
The Grafana dashboard as a JSON export.  
V2.0 is adapted for Grafana V8.x and contains numerous fixes for the individual panels.

Requires:
  * Boom Theme plugin (for the background image)
  * WindRose plugin
  * Blendstat Panel (by farski) Plugin
  * Table Plugin

Before importing, replace ***\_\_DBname\_\_*** in the file with your own Influx database name (40 hits or 45 hits with V2.0), otherwise you get 
later a click orgy 😉
  
For the weather and rain forecast, further data points from the adapters "Das Wetter" and "Weatherunderground"
needed.

NO support for questions regarding Influx, Grafana or the import etc. of the DashBoard!

Courtesy of crunchip@forum.iobroker.net for posting   
   
   
---   
 
Bilder V2.0 / Pictures from V2.0:<br>
![Pic1](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-Dashboard_V8.png)
![Pic2](https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/Bilder/Grafana-Dashboard_V8a.png)
