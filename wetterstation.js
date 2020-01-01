
//Wetterstation Datenpunkte anlegen
 let DP="javascript.0.Wetterstation."
  createState(DP+"Innentemperatur"   ,"", {name: "Temperatur im Haus",          type: "number", role: "state", unit: "°C" });
  createState(DP+"Aussentemperatur"  ,"", {name: "Temperatur Außen",            type: "number", role: "state", unit: "°C" });
  createState(DP+"Taupunkt"          ,"", {name: "Taupunkt",                    type: "number", role: "state", unit: "°C" });
  createState(DP+"Chillfaktor"       ,"", {name: "Chillfaktor",                 type: "number", role: "state", unit: "°C" });
  createState(DP+"Innenfeuchtigkeit" ,"", {name: "Luftfeuchtigkeit Innen",      type: "number", role: "state", unit: "%" });
  createState(DP+"Aussenfeuchtigkeit","", {name: "Luftfeuchtigkeit Außen",      type: "number", role: "state", unit: "%" });
  createState(DP+"Wind"              ,"", {name: "Windgeschwindigkeit",         type: "number", role: "state", unit: "km/h" });
  createState(DP+"Wind_max"          ,"", {name: "Windgeschwindigkeit maximal", type: "number", role: "state", unit: "km/h" });
  createState(DP+"Windrichtung"      ,"", {name: "Windrichtung",                type: "number", role: "state", unit: "°" });
  createState(DP+"Druck_absolut"     ,"", {name: "Luftdruck absolut",           type: "number", role: "state", unit: "hPa" });
  createState(DP+"Druck_relativ"     ,"", {name: "Luftdruck relativ",           type: "number", role: "state", unit: "hPa" });
  createState(DP+"Regen_aktuell"     ,"", {name: "aktuelle Regenmenge",         type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Tag"         ,"", {name: "Regenmenge Heute",            type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Woche"       ,"", {name: "Regenmenge Woche",            type: "number", role: "state", unit: "mm" });
  createState(DP+"Regen_Monat"       ,"", {name: "Regenmenge Monat",            type: "number", role: "state", unit: "mm" });
  createState(DP+"Sonnenstrahlung"   ,"", {name: "Sonnenstrahlung",             type: "number", role: "state", unit: "W/m²" });
  createState(DP+"UV_Index"          ,"", {name: "UV Index",                    type: "number", role: "state" });
  createState(DP+"Zeitstempel"       ,"", {name: "von wann ist die Messung",    type: "string", role: "state" });
