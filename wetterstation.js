//Wetterstation Datenpunkte anlegen V2.9.0
 let DP="javascript.0.Wetterstation.";
 let DP50  = 0;  // Anzahl der DP50 Sensoren  (max. 8 Stück)
 let DP60  = 0;  // Anzahl der DP60 Sensoren  (max. 1 Stück)
 let DP70  = 0;  // Anzahl der DP70 Sensoren  (max. 4 Stück)
 let DP100 = 0;  // Anzahl der DP100 Sensoren (max. 8 Stück)
 let DP200 = 0;  // Anzahl der DP200 Sensoren (max. 4 Stück)
 let DP250 = 0;  // Anzahl der DP250 Sensoren (max. 1 Stück)
 //Ende der User-Einstellungen -------------------

  createState(DP+"Innentemperatur"             , 0,    {name: "Temperatur im Haus",                     type: "number", role: "state", unit: "°C" });
  createState(DP+"Aussentemperatur"            , 0,    {name: "Temperatur Außen",                       type: "number", role: "state", unit: "°C" });
  createState(DP+"Taupunkt"                    , 0,    {name: "Taupunkt",                               type: "number", role: "state", unit: "°C" });
  createState(DP+"Gefuehlte_Temperatur"        , 0,    {name: "Windchill",                              type: "number", role: "state", unit: "°C" });
  createState(DP+"Innenfeuchtigkeit"           , 0,    {name: "Luftfeuchtigkeit Innen",                 type: "number", role: "state", unit: "%" });
  createState(DP+"Aussenfeuchtigkeit"          , 0,    {name: "Luftfeuchtigkeit Außen",                 type: "number", role: "state", unit: "%" });
  createState(DP+"Wind"                        , 0,    {name: "Windgeschwindigkeit",                    type: "number", role: "state", unit: "km/h" });
  createState(DP+"Wind_max"                    , 0,    {name: "Windgeschwindigkeit maximal",            type: "number", role: "state", unit: "km/h" });
  createState(DP+"Windrichtung"                , 0,    {name: "Windrichtung in Grad",                   type: "number", role: "state", unit: "°" });
  createState(DP+"Windrichtung_Text"           ," ",   {name: "Windrichtung als Text",                  type: "string", role: "state" });
  createState(DP+"Druck_absolut"               , 0,    {name: "Luftdruck absolut",                      type: "number", role: "state", unit: "hPa" });
  createState(DP+"Druck_relativ"               , 0,    {name: "Luftdruck relativ",                      type: "number", role: "state", unit: "hPa" });
  createState(DP+"Druck_Tendenz"               ,"",    {name: "Luftdrucktendenz",                       type: "mixed",  role: "state" });
  createState(DP+"Wetter_Trend"                ," ",   {name: "Wettertrend",                            type: "string", role: "state" });
  createState(DP+"Wetter_aktuell"              ," ",   {name: "aktuelles Wetter",                       type: "string", role: "state" });
  createState(DP+"Regenrate"                   , 0,    {name: "Regenrate",                              type: "number", role: "state", unit: "mm/h" });
  createState(DP+"Regenstatus"                 ,"--",  {name: "aktueller Regenstatus",                  type: "string", role: "state" });
  createState(DP+"Regen_Tag"                   , 0,    {name: "Regenmenge Heute",                       type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Woche"                 , 0,    {name: "Regenmenge Woche",                       type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Monat"                 , 0,    {name: "Regenmenge Monat",                       type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Jahr"                  , 0,    {name: "Regenmenge Jahr aus Station",            type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Jahr_kumuliert"        , 0,    {name: "Regenmenge Jahr berechnet",              type: "number", role: "state", unit: "mm" });
  createState(DP+"Sonnenstrahlung"             , 0,    {name: "Sonnenstrahlung",                        type: "number", role: "state", unit: "W/m²" });
  createState(DP+"UV_Index"                    , 0,    {name: "UV Index",                               type: "number", role: "state" });
  createState(DP+"UV_Belastung"                ," ",   {name: "UV-Belastung",                           type: "string", role: "state" });
  createState(DP+"Zeitstempel"                 ," ",   {name: "von wann ist die Messung",               type: "string", role: "state" });
  createState(DP+"_Kommunikationsfehler"       , false,{name: "liegt ein Problem vor",                  type: "boolean",role: "state" });
  createState(DP+"tempData.Wetterdaten"        ," ",   {name: "temporär gespeicherte Wetterdaten",      type: "string" ,role: "state" });
  createState(DP+"tempData.Sonnenschein"       ," ",   {name: "temporäre Daten Tag, Woche, Monat, Jahr",type: "string", role: "state" });
  createState(DP+"tempData.Solarenergie"       ,"0",   {name: "temporäre Daten Tag, Woche, Monat, Jahr",type: "string", role: "state" });
  createState(DP+"Info.FW_Upgrade"             , false,{name: "neue Firmware für die Station",          type: "boolean",role: "state" });
  createState(DP+"Info.FW_Version"             ," ",   {name: "Firmwareversion der Station",            type: "string", role: "state" });
  createState(DP+"Info.Hitzeindex"             , 0,    {name: "Hitzeindex (erst ab 20°C)",              type: "mixed",  role: "state", unit: "°C" });
  createState(DP+"Info.openSenseMap"           , false,{name: "Datenübertragung openSenseMap erfolgreich",type: "boolean",role: "state" });
  createState(DP+"Info.Windy"                  , false,{name: "Datenübertragung Windy erfolgreich",     type: "boolean",role: "state" });
  createState(DP+"Info.Wetter_com"             , false,{name: "Datenübertragung Wetter.com erfolgreich",type: "boolean",role: "state" });
  createState(DP+"Info.Sonnenschein_VorTag"    , 0,    {name: "Sonnenscheindauer Gestern",              type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Sonnenschein_Tag"       , 0,    {name: "Sonnenscheindauer Heute",                type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Sonnenschein_Woche"     , 0,    {name: "Sonnenscheindauer diese Woche",          type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Sonnenschein_Monat"     , 0,    {name: "Sonnenscheindauer diesen Monat",         type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Sonnenschein_Jahr"      , 0,    {name: "Sonnenscheindauer dieses Jahr",          type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Sonnenschein_Tag_Text"  ," ",   {name: "Sonnenscheindauer Heute als Text",       type: "string", role: "state" });
  createState(DP+"Info.Sonnenschein_Woche_Text"," ",   {name: "Sonnenscheindauer diese Woche als Text", type: "string", role: "state" });
  createState(DP+"Info.Sonnenschein_Monat_Text"," ",   {name: "Sonnenscheindauer diesen Monat als Text",type: "string", role: "state" });
  createState(DP+"Info.Sonnenschein_Jahr_Text" ," ",   {name: "Sonnenscheindauer dieses Jahr als Text", type: "string", role: "state" });
  createState(DP+"Info.Sonnenschein_VorJahr"   , 0,    {name: "Sonnenscheindauer letztes Jahr",         type: "number", role: "state", unit: "Sek." });
  createState(DP+"Info.Regenmenge_VorJahr"     , 0,    {name: "Regenmenge letztes Jahr",                type: "number", role: "state", unit: "mm" });
  createState(DP+"Info.Regenmenge_Met_Sommer"  , 0,    {name: "Regenmenge des meteorologischen Sommers",type: "number", role: "value", unit: "l/m²" });
  createState(DP+"Info.Solarenergie_VorTag"    , 0,    {name: "Solarenergie Gestern",                   type: "number", role: "state", unit: "Wh/m²" });
  createState(DP+"Info.Solarenergie_Tag"       , 0,    {name: "Solarenergie Heute",                     type: "number", role: "state", unit: "Wh/m²" });
  createState(DP+"Info.Solarenergie_Woche"     , 0,    {name: "Solarenergie diese Woche",               type: "number", role: "state", unit: "kWh/m²" });
  createState(DP+"Info.Solarenergie_Monat"     , 0,    {name: "Solarenergie diesen Monat",              type: "number", role: "state", unit: "kWh/m²" });
  createState(DP+"Info.Solarenergie_Jahr"      , 0,    {name: "Solarenergie dieses Jahr",               type: "number", role: "state", unit: "kWh/m²" });
  createState(DP+"Info.Solarenergie_VorJahr"   , 0,    {name: "Solarenergie letztes Jahr",              type: "number", role: "state", unit: "kWh/m²" });
  createState(DP+"Info.Letzter_Regen"          ," ",   {name: "letztes Regenereignis",                  type: "string", role: "state" });
  createState(DP+"Info.Letzte_Regenmenge"      , 0,    {name: "letzte Regenmenge",                      type: "number", role: "value", unit: "mm" });
  createState(DP+"Info.Station_Batteriestatus" , 0,    {name: "Batteriestatus [0=OK, 1=Alarm]",         type: "number", role: "value" });
  createState(DP+"Info.Wetterstation_Gateway"  , 0,    {name: "Gateway Informationen",                  type: "string", role: "state" });
  createState(DP+"Info.Temp_Aussen_24h_max"    , 0,    {name: "höchste Aussentemperatur der letzten 24 Stunden",type: "number", role: "state", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_Heute_max"  , 0,    {name: "bisher höchste Aussentemperatur des heutigen Tages",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_Heute_min"  , 0,    {name: "bisher niedrigste Aussentemperatur des heutigen Tages",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_24h_min"    , 0,    {name: "tiefste Aussentemperatur der letzten 24 Stunden",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_365t_min"   , 0,    {name: "tiefste Aussentemperatur vor einem Jahr",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_365t_max"   , 0,    {name: "höchste Aussentemperatur vor einem Jahr",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Aussen_365t_avg"   , 0,    {name: "durchschnittliche Aussentemperatur vor einem Jahr",type: "number", role: "value", unit: "°C" });
  createState(DP+"Info.Temp_Met_Sommer_avg"    , 0,    {name: "Durchschnittstemperatur des meteorologischen Sommers",type: "number", role: "value", unit: "°C" });
  createState(DP+"Windboeen_max"               , 0,    {name: "Windböengeschwindigkeit maximal",        type: "number", role: "value", unit: "km/h" });
  createState(DP+"Regen_Event"                 , 0,    {name: "Regenmenge Event",                       type: "number", role: "value", unit: "mm" });
  createState(DP+"Regen_Stunde"                , 0,    {name: "Regenmenge Stunde",                      type: "number", role: "value", unit: "mm" });
  createState(DP+"Regen_Total"                 , 0,    {name: "Regenmenge Insgesammt",                  type: "number", role: "value", unit: "mm" });



if (DP50>0 && DP50<=8)  {
  if (!existsState(DP + "DP50")) {createState(DP + "DP50", '', { name: "Mehrkanal Thermo-Hygrometersensoren" });}
  for(var i=1; i<=DP50; i++) {
    if (!existsState(DP + "DP50." + i + ".Temperatur")) {
        createState(DP + "DP50." + i + ".Temperatur", "", {
            "name": "DP50 Kanal " + i + " Temperatur",
            "type": "number",
            "role": "state",
            "unit": "°C"
        });
    }
    if (!existsState(DP + "DP50." + i + ".Feuchtigkeit")) {
        createState(DP + "DP50." + i + ".Feuchtigkeit", "", {
            "name": "DP50 Kanal " + i + " Feuchtigkeit",
            "type": "number",
            "role": "state",
            "unit": "%"
        });
    }
    if (!existsState(DP + "DP50." + i + ".Batterie")) {
        createState(DP + "DP50." + i + ".Batterie", "", {
            "name": "DP50 Kanal " + i + " Batterie",
            "type": "number",
            "role": "state",
        });
    }
  }
}

if (DP60>0 && DP60<=1)  {
  if (!existsState(DP + "DP60")) {createState(DP + "DP60", '', { name: "Blitzdetektor" });}
  for(let i=1; i<=DP60; i++) {
    if (!existsState(DP + "DP60." + i + ".Entfernung")) {
        createState(DP + "DP60." + i + ".Entfernung", "", {
            "name": "DP60 Kanal " + i + " Entfernung",
            "type": "number",
            "role": "state",
            "unit": "km"
        });
    }
    if (!existsState(DP + "DP60." + i + ".Zeitpunkt")) {
        createState(DP + "DP60." + i + ".Zeitpunkt", "", {
            "name": "DP60 Kanal " + i + " Zeitpunkt (Unix-Timestamp)",
            "type": "number",
            "role": "state"
        });
    }
    if (!existsState(DP + "DP60." + i + ".Anzahl")) {
        createState(DP + "DP60." + i + ".Anzahl", "", {
            "name": "DP60 Kanal " + i + " Anzahl innerhalb von 24 Stunden",
            "type": "number",
            "role": "state"
        });
    }
    if (!existsState(DP + "DP60." + i + ".Batterie")) {
        createState(DP + "DP60." + i + ".Batterie", "", {
            "name": "DP60 Kanal " + i + " Batterie (5 = max)",
            "type": "number",
            "role": "state",
        });
    }
  }
}

if (DP70>0 && DP70<=4) {
  if (!existsState(DP + "DP70")) {createState(DP + "DP70", '', { name: "Mehrkanal-Wasserlecksensoren" });}
  for(var i=1; i<=DP70; i++) {
    if (!existsState(DP + "DP70." + i + ".Status")) {
        createState(DP + "DP70." + i + ".Status", "", {
            "name": "DP70 Kanal " + i + " Status (normal/Alarm)",
            "type": "string",
            "role": "state"
        });
    }
    if (!existsState(DP + "DP70." + i + ".Batterie")) {
        createState(DP + "DP70." + i + ".Batterie", "", {
            "name": "DP70 Kanal " + i + " Batterie",
            "type": "number",
            "role": "state",
        });
    }
  }
}

if (DP100>0 && DP100<=8) {
  if (!existsState(DP + "DP100")) {createState(DP + "DP100", '', { name: "Mehrkanal Bodenfeuchtesensoren" });}
  for(var i=1; i<=DP100; i++) {
    if (!existsState(DP + "DP100." + i + ".Bodenfeuchtigkeit")) {
        createState(DP + "DP100." + i + ".Bodenfeuchtigkeit", "", {
            "name": "DP100 Kanal " + i + " Bodenfeuchtigkeit",
            "type": "number",
            "role": "state",
            "unit": "%"
        });
    }
    if (!existsState(DP + "DP100." + i + ".Batterie")) {
        createState(DP + "DP100." + i + ".Batterie", "", {
            "name": "DP100 Kanal " + i + " Batterie",
            "type": "number",
            "role": "state",
        });
    }
  }
}

if (DP200>0 && DP200<=4) {
  if (!existsState(DP + "DP200")) {createState(DP + "DP200", '', { name: "Feinstaub Emissionssensoren" });}
  for(var i=1; i<=DP200; i++) {
    if (!existsState(DP + "DP200." + i + ".PM25")) {
        createState(DP + "DP200." + i + ".PM25", "", {
            "name": "DP200 Kanal " + i + " 2.5µm Partikel",
            "type": "number",
            "role": "state",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP200." + i + ".PM25_24h")) {
        createState(DP + "DP200." + i + ".PM25_24h", "", {
            "name": "DP200 Kanal " + i + " Durchschnitt per 24h",
            "type": "number",
            "role": "state",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP200." + i + ".Batterie")) {
        createState(DP + "DP200." + i + ".Batterie", "", {
            "name": "DP200 Kanal " + i + " Batterie (5 = max)",
            "type": "number",
            "role": "state",
        });
    }
  }
}

if (DP250>0 && DP250<=1)  {
  if (!existsState(DP + "DP250")) {createState(DP + "DP250", '', { name: "5-In-1 CO2 / PM2.5 / PM10 / Temperatur / Luftfeuchte Innenraumsensor" });}
  for(let i=1; i<=DP250; i++) {
    if (!existsState(DP + "DP250." + i + ".Temperatur")) {
        createState(DP + "DP250." + i + ".Temperatur", "", {
            "name": "DP250 Kanal " + i + " Temperatur",
            "type": "number",
            "role": "value",
            "unit": "°C"
        });
    }
    if (!existsState(DP + "DP250." + i + ".Luftfeuchtigkeit")) {
        createState(DP + "DP250." + i + ".Luftfeuchtigkeit", "", {
            "name": "DP250 Kanal " + i + " Luftfeuchtigkeit",
            "type": "number",
            "role": "value",
            "unit": "%"
        });
    }
    if (!existsState(DP + "DP250." + i + ".PM25")) {
        createState(DP + "DP250." + i + ".PM25", "", {
            "name": "DP250 Kanal " + i + " 2.5µm Partikel",
            "type": "number",
            "role": "value",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP250." + i + ".PM25_24h")) {
        createState(DP + "DP250." + i + ".PM25_24h", "", {
            "name": "DP250 Kanal " + i + " Durchschnitt per 24h",
            "type": "number",
            "role": "value",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP250." + i + ".PM10")) {
        createState(DP + "DP250." + i + ".PM10", "", {
            "name": "DP250 Kanal " + i + " 10µm Partikel",
            "type": "number",
            "role": "value",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP250." + i + ".PM10_24h")) {
        createState(DP + "DP250." + i + ".PM10_24h", "", {
            "name": "DP250 Kanal " + i + " Durchschnitt per 24h",
            "type": "number",
            "role": "value",
            "unit": "µg/m³"
        });
    }
    if (!existsState(DP + "DP250." + i + ".CO2")) {
        createState(DP + "DP250." + i + ".CO2", "", {
            "name": "DP250 Kanal " + i + " CO2-Konzentration",
            "type": "number",
            "role": "value",
            "unit": "ppm"
        });
    }
    if (!existsState(DP + "DP250." + i + ".CO2_24h")) {
        createState(DP + "DP250." + i + ".CO2_24h", "", {
            "name": "DP250 Kanal " + i + " Durchschnitt per 24h",
            "type": "number",
            "role": "value",
            "unit": "ppm"
        });
    }
    if (!existsState(DP + "DP250." + i + ".Batterie")) {
        createState(DP + "DP250." + i + ".Batterie", "", {
            "name": "DP250 Kanal " + i + " Batterie (6 = max)",
            "type": "number",
            "role": "value",
        });
    }
  }
}

