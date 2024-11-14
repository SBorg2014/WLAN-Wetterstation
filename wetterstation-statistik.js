/* Wetterstation-Statistiken 

   holt die Messdaten aus einer InfluxDB V2 und erstellt eine Monats-, Vorjahresmonat- und
   Rekordwerte-Statistik
   Wichtig: funktioniert nur mit der Default-Datenstruktur des WLAN-Wetterstation-Skriptes!
            Auch keine Aliase unter Influx nutzen!

   (c)2020-2024 by SBorg
   v2.0.5 - 14.11.2024  ~Umstellung von axios auf httpGet (fixed "Fehler: AxiosError: Request failed with status code 429")
   v2.0.4 - 18.02.2024  ~Bugfix "Trockenperiode" wird uU. auf 365 Tage gesetzt (Fix Issue #69 @ch33f)
   v2.0.3 - 02.07.2023  ~Bugfix Fehlermeldung am Monatsersten
   v2.0.2 - 02.03.2023  ~Bugfix fehlender Vorjahresmonat (Fix Issue #58)
                        ~Bugfix fehlender Vorjahresmonat (Fix Issue für #58 / #62 @Boronsbruder)
   V2.0.1 - 22.02.2023  ~Bugfix Influx-Abfrage "Wind" (@Latzi)
                        ~Bugfix fester Datenpunkt auf "javascript.0..." bei Trockenperiode
   V2.0.0 - 15.02.2023  ~Umstellung auf Influx V2 
                        +Fix "{ack=true}" bei Wüstentage, Tropennächte und Regentage in VorJahres-Anzeige
                        ~Windboe nach Windboee umbenannt
   V1.3.2 - 03.02.2023  ~Verbesserung des JSON-handlings "VorJahr" (@Boronsbruder)
   V1.3.1 - 01.02.2023  ~Bugfix keine Daten für Vorjahresmonatswerte (Fix Issue #54) 
   V1.3.0 - 09.09.2022  +Regentage (Issue #40)
   V1.2.0 - 04.08.2022  +Wüstentage und Tropennächte
   V1.1.3 - 01.08.2022  +Rekordwerte auch bei Einstellung "LAST_RAIN=DATUM [+UNIX]" in der wetterstation.conf
   V1.1.2 - 19.06.2022  ~mögliche "Null"-Werte bei "Regenmenge Vortag" und "Windböe" gefixt (Fix Issue #35)
   V1.1.1 - 02.05.2022  ~Rework JSON-Management
   V1.1.0 - 02.04.2022  ~Bugfixing fehlender Vortag am 01. des Monats (Fix Issue #32)
                        ~Korrektur Reset der Monatswerte
   V1.0.1 - 18.12.2021  ~Bugfixing "error: TypeError: Cannot read property '0' of null"
                        ~Wechsel zu axios
   V1.0.0 - 02.10.2021  ~Bugfixing Werte VorJahresMonat
                        +Kompatibilität mit JSC 3.3.x hergestellt (Änderung JSON -> Array)
                        ~Rekordwerte werden nun korrekt am Tag des Ereignisses gespeichert
   V0.2.2 - 01.02.2021  ~Bugfixing Regenmenge Jahr + Monat
   V0.2.1 - 21.01.2021  ~Bugfixing Rekordwerte Spitzenhöchst-/-tiefstwert
   V0.2.0 - 15.01.2021  ~Bugfixing Benennung DPs / Korrektur Regenmenge
   V0.1.9 - 09.01.2021  +Regenmenge eines kpl. Monats im Jahr und Rekord
   V0.1.8 - 08.01.2021  +max. Windböe für Gestern und Jahres-/Rekordwerte
   V0.1.7 - 03.01.2021  ~Fix für fehlerhafte/fehlende Speicherung Jahreswerte + Trockenperiode
   V0.1.6 - 30.12.2020  +Summe "Sommertage", "heiße Tage", "Frosttage", "Eistage" und "sehr kalte Tage" für das gesamte Jahr
   V0.1.5 - 29.12.2020  +Summe "kalte Tage" und "warme Tage" für das gesamte Jahr
   V0.1.4 - 26.12.2020  +max. Regenmenge pro Tag für Jahres-/Rekordwerte
   V0.1.3 - 11.11.2020  +Rekordwerte
   V0.1.2 - 14.10.2020  ~Fix "NaN" bei Regenmenge Monat
   V0.1.1 - 12.10.2020  +AutoReset Jahresstatistik
   V0.1.0 - 08.10.2020  +DP für Statusmeldungen / Reset Jahresstatistik / AutoDelete "Data"
                        +ScriptVersion / Update vorhanden / UpdateCheck abschaltbar
                        +Jahresstatistik Min-/Max-/Durchschnittstemperatur/Trockenperiode
   V0.0.7 - 19.09.2020  +Min.-/Max.-/Durchschnittstemperatur vom Vortag
   V0.0.6 - 18.09.2020  +Regenmenge Monat
   V0.0.5 - 17.09.2020  +Gradtage Vorjahr
   V0.0.4 - 16.09.2020  +Eistage (Max. unter 0°C) / sehr kalte Tage (Min. unter -10°C)
                        ~Frosttage (Korrektur: Tiefstwert unter 0°C)
   V0.0.3 - 15.09.2020  +Frosttage (Min. unter 0°C) / kalte Tage (Max. unter 10°C)
   V0.0.2 - 12.09.2020  +warme Tage über 20°C / Sommertage über 25°C / heiße Tage über 30°C
   V0.0.1 - 11.09.2020   erste Beta + Temp-Min/Temp-Max/Temp-Durchschnitt/max. Windböe/max. Regenmenge pro Tag

      ToDo: ---
      known issues: keine

*/



// *** User-Einstellungen **********************************************************************************************************************************
    const WET_DP='0_userdata.0.Wetterstation';          // wo liegen die Datenpunkte mit den Daten der Wetterstation  [default: 0_userdata.0.Wetterstation]                          
    const INFLUXDB_INSTANZ='3';                         // unter welcher Instanz läuft die InfluxDB [default: 0]
    const INFLUXDB_BUCKET='Homeautomation';             // Name des zu benutzenden Buckets
    const PRE_DP='0_userdata.0.Statistik.Wetter';       // wo sollen die Statistikwerte abgelegt werden. Nur unter "0_userdata" oder "javascript" möglich!
    let REKORDWERTE_AUSGABEFORMAT="[WERT] im [MONAT] [JAHR]";   /* Wie soll die Ausgabe der Rekordwerte formatiert werden (Template-Vorlage)?
                                                                    [WERT]      = Messwert (zB. '22.42' bei Temperatur, '12' bei Tagen)
                                                                    [TAG]       = Tag (0-31)
                                                                    [MONAT]     = Monatsname (Januar, Februar,..., Dezember)
                                                                    [MONAT_ZAHL]= Monat als Zahl (01-12)
                                                                    [MONAT_KURZ]= Monatsname kurz (Jan, Feb,..., Dez)
                                                                    [JAHR]      = Jahreszahl vierstellig (2020)
                                                                 Die 'Units' wie bspw. "°C" oder "Tage" werden direkt aus dem Datenpunkt ergänzt. 
                                                                 [default: [WERT] im [MONAT] [JAHR] ] erzeugt als Beispiel im DP die 
                                                                 Ausgabe: "22.42 °C im Juni 2020"
                                                                */
    const ZEITPLAN = "3 1 * * *";                       // wann soll die Statistik erstellt werden (Minuten Stunde * * *) [default 1:03 Uhr] 
// *** ENDE User-Einstellungen *****************************************************************************************************************************



//ab hier gibt es nix mehr zu ändern :)
//first start?
const DP_Check ='aktueller_Monat.Regentage';
if (!existsState(PRE_DP+'.'+DP_Check)) { createDP(DP_Check); }

//Start des Scripts
    const ScriptVersion = "V2.0.5";
    const dayOfYear = date => Math.floor((date - new Date(date.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
    let Tiefstwert, Hoechstwert, Temp_Durchschnitt, Max_Windboee, Max_Regenmenge, Regenmenge_Monat, warme_Tage, Sommertage;
    let heisse_Tage, Frost_Tage, kalte_Tage, Eistage, sehr_kalte_Tage, Wuestentage, Tropennaechte, Trockenperiode_akt;
    let kalte_Tage_Jahr, warme_Tage_Jahr, Sommertage_Jahr, heisse_Tage_Jahr, Frosttage_Jahr, Eistage_Jahr, sehrkalte_Tage_Jahr, Wuestentage_Jahr, Tropennaechte_Jahr;
    let Regentage, Regentage_Jahr;
    let monatstage = [31,28,31,30,31,30,31,31,30,31,30,31];
    let monatsname = ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'];
    let monatsname_kurz = ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'];
    console.log("Wetterstation-Statistiken " + ScriptVersion + " gestartet...");
    setTimeout(Statusmeldung, 500);

//scheduler
    schedule(ZEITPLAN, main);


// ### Funktionen ###############################################################################################
function main() {
    let temps = [], wind = [], regen = [], start, end, zeitstempel = new Date();
    let start_ts = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-1,0,0,0);
    start = start_ts.getTime();
    let end_ts = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-1,23,59,59);
    end = end_ts.getTime();

    //Jobs Monatserster
 if (zeitstempel.getDate() == 1) { 
     if (zeitstempel.getMonth() == 0) { //heute ist der 01.01. 

        //Rekordwerte (Temperatur-Durchschnitt) setzen
            //max Jahrestemperaturdurchschnitt
            let JahresTemperatur_Durchschnitt = getState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt').val;
            if (getState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Max').val < JahresTemperatur_Durchschnitt) {
                setState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Max', JahresTemperatur_Durchschnitt, true);
                setState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Max', JahresTemperatur_Durchschnitt+' °C für '+ (zeitstempel.getFullYear()-1), true);
                //, () => { Template_Rekordwerte('Temp_Durchschnitt_Max','Rekordwerte.Temperatur_Jahresdurchschnitt_Max'); });
            }  
            //min Jahrestemperaturdurchschnitt
            if (getState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Min').val > JahresTemperatur_Durchschnitt) {
                setState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Min', JahresTemperatur_Durchschnitt, true);
                setState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Min', JahresTemperatur_Durchschnitt+' °C für '+ (zeitstempel.getFullYear()-1), true);
                //, () => { Template_Rekordwerte('Temp_Durchschnitt_Min','Rekordwerte.Temperatur_Jahresdurchschnitt_Min'); });
            }

        //Rekordwerte (Temperatur-Durchschnitt) einmalig resetten [InstallationsJahr +1]
        let Inst_Jahr = (new Date(getState(PRE_DP).ts)).getFullYear();
        if (zeitstempel.getFullYear() == Inst_Jahr+1) {
            setState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Max', -99.99, true);
            setState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Min',  99.99, true);
            setState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Max' ,'' ,true);
            setState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Min' ,'' ,true);
        }

        let mode=getState(PRE_DP+'.Control.AutoReset_Jahresstatistik').val;
        switch (mode) { //0=Aus, 1=Ein, 2=Ein+Backup
            case 0:
               break;

            case 1:
               Reset_Jahresstatistik();
               break;

            case 2:
               Backup_Jahresstatistik();
               Reset_Jahresstatistik();
               break;

            default:
               break;
        } // end switch

     } // end if 01.01.

   speichern_Monat();  //vorherige Monatsstatistik speichern
   VorJahr();          //Vorjahresmonatsstatistik ausführen

    sleep(10000);
    
   if (getState(PRE_DP+'.Control.AutoDelete_Data').val >0) { AutoDelete_Data(); }

 }//End Jobs Monatserster

  //InfluxDB abfragen (Regen +1min Startverzögerung wg. ev. Ungenauigkeit der Systemzeit des Wetterstation-Displays)
    sendTo('influxdb.'+INFLUXDB_INSTANZ, 'query', 
            'from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+(start/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Aussentemperatur") |> filter(fn: (r) => r._field == "value"); from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+(start/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Wind_max") |> filter(fn: (r) => r._field == "value"); from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+((start+72000)/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Regen_Tag") |> filter(fn: (r) => r._field == "value")'
  
         , function (result) {
             //Anlegen der Arrays + befüllen mit den relevanten Daten
            if (result.error) {
               console.error('Fehler beim Lesen der InfluxDB: '+result.error);
               Statusmeldung('Fehler beim Lesen der InfluxDB: '+result.error);
            } else {
                //console.log('Rows: ' + JSON.stringify(result.result[0], null, 2));
                for (let i = 0; i < result.result[0].length; i++) { temps[i] = result.result[0][i]._value; }
                for (let i = 0; i < result.result[1].length; i++) { wind[i] = result.result[1][i]._value; }
                for (let i = 0; i < result.result[2].length; i++) { regen[i] = result.result[2][i]._value; }
            }
                                   

    //Temperaturen
    Tiefstwert = Math.min(...temps);
    Hoechstwert = Math.max(...temps);
    //Math.sum = (...temps) => Array.prototype.reduce.call(temps,(a,b) => a+b);
    const reducer = (accumulator, curr) => accumulator + curr;
    //Temp_Durchschnitt = Number((Math.sum(...temps)/temps.length).toFixed(2));
    let Temp_Durchschnitt = Number((temps.reduce(reducer)/temps.length).toFixed(2));
    let MonatsTemp_Durchschnitt = Math.round(((((getState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt').val)*(zeitstempel.getDate()-1))+Temp_Durchschnitt)/zeitstempel.getDate())*100)/100;
    if (Hoechstwert >= 35) { Wuestentage = 1; } else { Wuestentage = 0; }
    if (Hoechstwert > 20) { warme_Tage = 1; } else { warme_Tage = 0; }
    if (Hoechstwert > 25) { Sommertage = 1; } else { Sommertage = 0; } 
    if (Hoechstwert > 30) { heisse_Tage = 1; } else { heisse_Tage = 0; } 
    if (Tiefstwert < 0) { Frost_Tage = 1; } else { Frost_Tage = 0; } 
    if (Tiefstwert >= 20) { Tropennaechte = 1; } else { Tropennaechte = 0; }
    if (Hoechstwert < 10) { kalte_Tage = 1; } else { kalte_Tage = 0; }
    if (Hoechstwert < 0) { Eistage = 1; } else { Eistage = 0; }
    if (Tiefstwert < -10) { sehr_kalte_Tage = 1; } else { sehr_kalte_Tage = 0; }

  //Wind
    if (wind.length == 0) { Max_Windboee = 0; } else { Max_Windboee = Math.max(...wind); }     

  //Regen (Regentag = Mindestmenge größer oder gleich 0.1mm)
    if (regen.length == 0) { Max_Regenmenge = 0; } 
      else { 
        Max_Regenmenge = Math.max(...regen);
        if (Max_Regenmenge >= 0.1) { Regentage = 1; } else { Regentage = 0; }
    }


/* Debug-Consolenausgaben
    console.log('Daten ab ' + timeConverter(start));
    console.log('Daten bis ' + timeConverter(end));
    console.log('Erster Messwert: ' + new Date(result.result[0][0].ts).toISOString() + ' ***' + result.result[0][0].value);
    console.log('Letzter Messwert: ' + new Date(result.result[0][temps.length-1].ts).toISOString() + ' ***' + result.result[0][temps.length-1].value);
    console.log('Anzahl Datensätze: T_' + temps.length + '|W_' + wind.length + '|R_' + regen.length); */


    //VorTag
    setState(PRE_DP+'.VorTag.Temperatur_Tiefstwert', Tiefstwert, true);
    setState(PRE_DP+'.VorTag.Temperatur_Hoechstwert', Hoechstwert, true);
    setState(PRE_DP+'.VorTag.Temperatur_Durchschnitt', Temp_Durchschnitt, true);
    setState(PRE_DP+'.VorTag.Regenmenge', Max_Regenmenge, true);
    setState(PRE_DP+'.VorTag.Windboee_max', Max_Windboee, true);

 //nun beenden falls Monatserster    
  if (zeitstempel.getDate() == 1) { 
    console.log('Ausführung zum Monatsersten beendet...');
    Statusmeldung('erfolgreich');
    return; 
  }

// Tag des Jahres berechnen
   let Jahr = zeitstempel.getFullYear();
   let heutestart = Number(new Date(zeitstempel.setHours(0,0,0,0)));
   let neujahr = Number(new Date(Jahr,0,1));
   let difftage = (heutestart - neujahr) / (24*60*60*1000) + 1;
   let tag_des_jahres = Math.ceil(difftage);
   

   // Datenpunkte schreiben
   if (getState(PRE_DP+'.aktueller_Monat.Tiefstwert').val > Tiefstwert) {setState(PRE_DP+'.aktueller_Monat.Tiefstwert', Tiefstwert, true);}    
   if (getState(PRE_DP+'.aktueller_Monat.Hoechstwert').val < Hoechstwert) {setState(PRE_DP+'.aktueller_Monat.Hoechstwert', Hoechstwert, true);}    
   if (getState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt').val != MonatsTemp_Durchschnitt) {setState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt', MonatsTemp_Durchschnitt, true);}
   if (getState(PRE_DP+'.aktueller_Monat.Max_Windboee').val < Max_Windboee) {setState(PRE_DP+'.aktueller_Monat.Max_Windboee', Max_Windboee, true);}
   if (getState(PRE_DP+'.aktueller_Monat.Max_Regenmenge').val < Max_Regenmenge) {setState(PRE_DP+'.aktueller_Monat.Max_Regenmenge', Max_Regenmenge, true);}
   if (Max_Regenmenge > 0) {Regenmenge_Monat = getState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat').val + Max_Regenmenge; setState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat', Number((Regenmenge_Monat).toFixed(2)), true);}
   if (warme_Tage) {warme_Tage = getState(PRE_DP+'.aktueller_Monat.warme_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.warme_Tage', warme_Tage, true);
                    warme_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_warmeTage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_warmeTage', warme_Tage_Jahr, true);}
   if (Sommertage) {Sommertage = getState(PRE_DP+'.aktueller_Monat.Sommertage').val +1; setState(PRE_DP+'.aktueller_Monat.Sommertage', Sommertage, true);
                    Sommertage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Sommertage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_Sommertage', Sommertage_Jahr, true);}
   if (heisse_Tage) {heisse_Tage = getState(PRE_DP+'.aktueller_Monat.heisse_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.heisse_Tage', heisse_Tage, true);
                    heisse_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_heisseTage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_heisseTage', heisse_Tage_Jahr, true);}
   if (Frost_Tage) {Frost_Tage = getState(PRE_DP+'.aktueller_Monat.Frost_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.Frost_Tage', Frost_Tage, true);
                    Frosttage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Frosttage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_Frosttage', Frosttage_Jahr, true);}
   if (kalte_Tage) {kalte_Tage = getState(PRE_DP+'.aktueller_Monat.kalte_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.kalte_Tage', kalte_Tage, true);
                    kalte_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_kalteTage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_kalteTage', kalte_Tage_Jahr, true);}
   if (Eistage) {Eistage = getState(PRE_DP+'.aktueller_Monat.Eistage').val +1; setState(PRE_DP+'.aktueller_Monat.Eistage', Eistage, true);
                 Eistage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Eistage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_Eistage', Eistage_Jahr, true);}
   if (sehr_kalte_Tage) {sehr_kalte_Tage = getState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage', sehr_kalte_Tage, true);
                         sehrkalte_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_sehrkalteTage').val +1; setState(PRE_DP+'.Jahreswerte.Gradtage_sehrkalteTage', sehrkalte_Tage_Jahr, true);}
   if (Wuestentage) {Wuestentage = getState(PRE_DP + '.aktueller_Monat.Wuestentage').val + 1; setState(PRE_DP + '.aktueller_Monat.Wuestentage', Wuestentage, true);
                     Wuestentage_Jahr = getState(PRE_DP + '.Jahreswerte.Gradtage_Wuestentage').val + 1; setState(PRE_DP + '.Jahreswerte.Gradtage_Wuestentage', Wuestentage_Jahr, true);}
   if (Tropennaechte) {Tropennaechte = getState(PRE_DP + '.aktueller_Monat.Tropennaechte').val + 1; setState(PRE_DP + '.aktueller_Monat.Tropennaechte', Tropennaechte, true);
                        Tropennaechte_Jahr = getState(PRE_DP + '.Jahreswerte.Gradtage_Tropennaechte').val + 1; setState(PRE_DP + '.Jahreswerte.Gradtage_Tropennaechte', Tropennaechte_Jahr, true);}
   if (Regentage) {Regentage = getState(PRE_DP + '.aktueller_Monat.Regentage').val + 1; setState(PRE_DP + '.aktueller_Monat.Regentage', Regentage, true);
                   Regentage_Jahr = getState(PRE_DP + '.Jahreswerte.Regentage').val + 1; setState(PRE_DP + '.Jahreswerte.Regentage', Regentage_Jahr, true);
             }


    //Jahresstatistik
       //Temperatur
       if (getState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert').val < Hoechstwert) {setState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert', Hoechstwert, true);}
       if (getState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert').val > Tiefstwert) {setState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert', Tiefstwert, true);}
       //Temperaturdurchschnitt
       let JahresTemp_Durchschnitt=Math.round(((getState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt').val * (tag_des_jahres-1) + Temp_Durchschnitt)/tag_des_jahres)*100)/100;
       setState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt', JahresTemp_Durchschnitt, true);
       //Regenmenge
       if (getState(PRE_DP+'.Jahreswerte.Regenmengetag').val < Max_Regenmenge) {setState(PRE_DP+'.Jahreswerte.Regenmengetag', Max_Regenmenge, true);}
       //Windböe
       if (getState(PRE_DP+'.Jahreswerte.Windboee_max').val <= Max_Windboee) {setState(PRE_DP+'.Jahreswerte.Windboee_max', Max_Windboee, true);} 
       // Trockenperiode
        // Aktuelles Datum erhalten
         let currentDate = new Date();
         let letzterRegenStr = getState(WET_DP + '.Info.Letzter_Regen').val;
         let letzterRegenDatum = null;

        // Überprüfen, ob das Format dem Muster "TT.MM.JJJJ SS:MM" entspricht
         if (letzterRegenStr.match(/\d{2}\.\d{2}.\d{4} \d{2}:\d{2}/)) {
          letzterRegenDatum = new Date(letzterRegenStr.replace(/(\d{2})\.(\d{2})\.(\d{4}) (\d{2}):(\d{2})/, '$3-$2-$1T$4:$5'));
          BerechnungTrockenperiode();
         }

        // Überprüfen, ob der Wert genau aus 10 Ziffern besteht (Unix-Zeitstempelformat)
         else if (letzterRegenStr.match(/^\d{10}$/)) {
          letzterRegenDatum = new Date(parseInt(letzterRegenStr) * 1000);
          BerechnungTrockenperiode();
         }

        // Überprüfen, ob der Wert das Wort "Tag" enthält
         else if (letzterRegenStr.match(/Tag/g)) {
          Trockenperiode_akt = parseInt(letzterRegenStr.replace(/[^0-9\.]/g, ''), 10);
          BerechnungTrockenperiode();
         }

   function BerechnungTrockenperiode() {
    if (letzterRegenDatum !== null) {
      let Trockenperiode_akt = dayOfYear(currentDate) - dayOfYear(letzterRegenDatum);
            if (Trockenperiode_akt < 0) {
                let daysInLastYear = dayOfYear(new Date(currentDate.getFullYear() - 1, 11, 31));
                Trockenperiode_akt += daysInLastYear;
            }
            let Trockenperiode_alt = getState(PRE_DP + '.Jahreswerte.Trockenperiode').val;
            if (Trockenperiode_akt >= Trockenperiode_alt) {
                setState(PRE_DP + '.Jahreswerte.Trockenperiode', Trockenperiode_akt, true);
            }
    }
   }
    //Rekordwerte 
    Rekordwerte();

  }); //end sendTo
 if (getState(PRE_DP+'.Control.Reset_Jahresstatistik').val === true) { Reset_Jahresstatistik(); }
 console.log('Auswertung durchgeführt...');
 if (getState(PRE_DP+'.Control.ScriptVersion_UpdateCheck').val) { check_update(); } // neue Script-Version vorhanden?
 Statusmeldung('erfolgreich');
} //end function main

function Reset_Jahresstatistik() {
        setState(PRE_DP + '.Jahreswerte.Temperatur_Tiefstwert',   100,  true);
        setState(PRE_DP + '.Jahreswerte.Temperatur_Hoechstwert',  -100, true);
        setState(PRE_DP + '.Jahreswerte.Temperatur_Durchschnitt', 0,    true);
        setState(PRE_DP + '.Jahreswerte.Trockenperiode',          0,    true);
        setState(PRE_DP + '.Jahreswerte.Regenmengetag',           0,    true);
        setState(PRE_DP + '.Jahreswerte.Regenmengemonat',         0,    true);
        setState(PRE_DP + '.Jahreswerte.Windboee_max',            0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_kalteTage',      0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_warmeTage',      0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_Sommertage',     0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_heisseTage',     0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_Frosttage',      0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_Eistage',        0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_sehrkalteTage',  0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_Wuestentage',    0,    true);
        setState(PRE_DP + '.Jahreswerte.Gradtage_Tropennaechte',  0,    true);
        setState(PRE_DP + '.Jahreswerte.Regentage',               0,    true);

        setState(PRE_DP+'.Control.Reset_Jahresstatistik', false, true);
} //end function

function AutoDelete_Data() {
    let AutoDelete = getState(PRE_DP+'.Control.AutoDelete_Data').val; //Anzahl Monate
    let zeitstempel = new Date();
    let startAD = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth()-AutoDelete,1);
    let AutoDelete_Year = startAD.getFullYear();
    let AutoDelete_Month = startAD.getMonth();
    let DP_Years = []; //Jahresordnernamen

    $(PRE_DP+'.Data.*').each(function(DPID) {
        let OID=[],i=0;
        OID=DPID.replace(PRE_DP+'.Data.', '').split('.');
        if (typeof OID[1] === "undefined") { DP_Years[i]=OID[0]; i++; } //Jahresordnername sichern
        if ((Number(OID[0])<AutoDelete_Year) || (Number(OID[0])==AutoDelete_Year && Number(OID[1])<=AutoDelete_Month)) {
            deleteState(PRE_DP+'.Data.'+OID[0]+'.'+OID[1]);
        }
    }); //end selector

    //check ob Jahresordner leer ist + ggf. löschen
    for ( let i=0; i<DP_Years.length; i++ ) {
        let DP_Ordner_test=$(PRE_DP+'.Data.'+DP_Years[i]+'.*');
        if ( DP_Ordner_test.length == 0 ) { deleteState(PRE_DP+'.Data.'+DP_Years[i]); }
    }
    
} //end function

function speichern_Monat() {
    let zeitstempel = new Date();
    let datum = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-2);
    let monatsdatenpunkt = '.Data.'+datum.getFullYear()+'.'+pad(datum.getMonth()+1); 
    let initialTemp=getState(WET_DP+'.Aussentemperatur').val;
    let jsonSummary = [];

    //Datenpunkte lesen
    Tiefstwert=getState(PRE_DP+'.aktueller_Monat.Tiefstwert').val;
    Hoechstwert=getState(PRE_DP+'.aktueller_Monat.Hoechstwert').val;
    Temp_Durchschnitt=getState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt').val;
    Max_Windboee=getState(PRE_DP+'.aktueller_Monat.Max_Windboee').val;
    Max_Regenmenge=getState(PRE_DP+'.aktueller_Monat.Max_Regenmenge').val;
    Regenmenge_Monat=getState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat').val;
    warme_Tage=getState(PRE_DP+'.aktueller_Monat.warme_Tage').val;
    Sommertage=getState(PRE_DP+'.aktueller_Monat.Sommertage').val;
    heisse_Tage=getState(PRE_DP+'.aktueller_Monat.heisse_Tage').val;
    Frost_Tage=getState(PRE_DP+'.aktueller_Monat.Frost_Tage').val;
    kalte_Tage=getState(PRE_DP+'.aktueller_Monat.kalte_Tage').val;
    Eistage=getState(PRE_DP+'.aktueller_Monat.Eistage').val;
    sehr_kalte_Tage=getState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage').val;
    Wuestentage = getState(PRE_DP + '.aktueller_Monat.Wuestentage').val;
    Tropennaechte = getState(PRE_DP + '.aktueller_Monat.Tropennaechte').val;
    Regentage = getState(PRE_DP + '.aktueller_Monat.Regentage').val;
    //ggf. höchste Monatsregenmenge im Jahr schreiben
    if (getState(PRE_DP+'.Jahreswerte.Regenmengemonat').val <= Regenmenge_Monat) {setState(PRE_DP+'.Jahreswerte.Regenmengemonat', Regenmenge_Monat, true);} 
    jsonSummary.push(
        {"Tiefstwert": Tiefstwert, "Hoechstwert": Hoechstwert, "Temp_Durchschnitt": Temp_Durchschnitt, "Max_Windboee": Max_Windboee, 
        "Max_Regenmenge": Max_Regenmenge, "Regenmenge_Monat": Regenmenge_Monat, "warme_Tage": warme_Tage,
        "Sommertage": Sommertage, "heisse_Tage": heisse_Tage, "Frost_Tage": Frost_Tage, "kalte_Tage": kalte_Tage, "Eistage": Eistage, 
        "sehr_kalte_Tage": sehr_kalte_Tage, "Wuestentage": Wuestentage, "Tropennaechte": Tropennaechte, "Regentage": Regentage})
    createState(PRE_DP+monatsdatenpunkt,'',{ name: "Monatsstatistik für "+monatsname[datum.getMonth()]+' '+datum.getFullYear(), type: "string", role: "json" }, () => { setState(PRE_DP+monatsdatenpunkt, JSON.stringify(jsonSummary), true); }); 

    /* Monatswerte resetten. DPs unabhängig ihres Wertes initial schreiben; wir nehmen die aktuelle Außentemperatur, da sie 
    zum Start des Messzyklus Min, Max und Durchschnitt darstellt; Rest einfach nullen */
    setState(PRE_DP+'.aktueller_Monat.Tiefstwert', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Hoechstwert', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Max_Windboee', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Max_Regenmenge', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat', 0, true);
    setState(PRE_DP+'.aktueller_Monat.warme_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Sommertage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.heisse_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Frost_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.kalte_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Eistage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Wuestentage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Tropennaechte', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Regentage', 0, true);
} //end function

function VorJahr() {   
    let zeitstempel = new Date();
    let datum = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate());
    let monatsdatenpunkt = '.Data.'+ (datum.getFullYear()-1) +'.'+pad(datum.getMonth()+1);
    if (existsState(PRE_DP+monatsdatenpunkt)) { //der einfache Weg: wir haben schon Daten vom Vorjahr...

        let VorJahr = getState(PRE_DP+monatsdatenpunkt).val;
        VorJahr = JSON.parse(VorJahr);

        
        // Daten vom Vorjahr durchiterieren und Datenpunkte befüllen
            //console.log (VorJahr);
            VorJahr.forEach(obj => {
                Object.keys(obj).forEach(key => {
                    //console.log ('.Vorjahres_' + key + '--> ' + obj[key]);

                    // fix für Datenpunktname
                    let setkey = key;                                       
                    if (key == 'Temp_Durchschnitt') setkey = "Temperatur_Durchschnitt";

                    setState(PRE_DP+'.Vorjahres_Monat.' +setkey, obj[key], true);

                });
            });

/*        setState(PRE_DP+'.Vorjahres_Monat.Tiefstwert', VorJahr.Tiefstwert, true);
        setState(PRE_DP+'.Vorjahres_Monat.Hoechstwert', VorJahr.Hoechstwert, true);
        setState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt', VorJahr.Temp_Durchschnitt, true); 
        setState(PRE_DP+'.Vorjahres_Monat.Max_Windboee', VorJahr.Max_Windboee, true); 
        setState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge', VorJahr.Max_Regenmenge, true);
        setState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat', VorJahr.Regenmenge_Monat, true);
        setState(PRE_DP+'.Vorjahres_Monat.warme_Tage', VorJahr.warme_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Sommertage', VorJahr.Sommertage, true);
        setState(PRE_DP+'.Vorjahres_Monat.heisse_Tage', VorJahr.heisse_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Frost_Tage', VorJahr.Frost_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.kalte_Tage', VorJahr.kalte_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Eistage', VorJahr.Eistage, true);
        setState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage', VorJahr.sehr_kalte_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Wuestentage', VorJahr.Wuestentage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Tropennaechte', VorJahr.Tropennaechte, true);
        setState(PRE_DP+'.Vorjahres_Monat.Regentage', VorJahr.Regentage, true);
*/
    } else {
        //leider noch keine Daten vom Vorjahr; wir haben was zu tun...
        
                    //Werte setzen
                    let VRegenmenge_Monat=99999;
                    let Vwarme_Tage=99999;
                    let VSommertage=99999;
                    let Vheisse_Tage=99999;
                    let VFrost_Tage=99999;
                    let Vkalte_Tage=99999;
                    let VEistage=99999;
                    let Vsehr_kalte_Tage=99999;
                    let VWuestentage = 99999;
                    let VTropennaechte = 99999;
                    let VRegentage = 99999;

        //Abfrage der Influx-Datenbank
        let start, end, temps = [], wind = [], regen = [];
        start = new Date(zeitstempel.getFullYear()-1,zeitstempel.getMonth(),1,0,0,0);
        start = start.getTime();
        end = new Date(zeitstempel.getFullYear()-1,zeitstempel.getMonth(),monatstage[zeitstempel.getMonth()],23,59,59);
        end = end.getTime(); 
            
             sendTo('influxdb.'+INFLUXDB_INSTANZ, 'query', 
            'from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+(start/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Aussentemperatur") |> filter(fn: (r) => r._field == "value"); from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+(start/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Wind_max") |> filter(fn: (r) => r._field == "value"); from(bucket: "'+INFLUXDB_BUCKET+'") |> range(start: '+(start/1000)+', stop: '+(end/1000)+') |> filter(fn: (r) => r._measurement == "' + WET_DP + '.Regen_Tag") |> filter(fn: (r) => r._field == "value")'
  
                , function (result) {
                //Anlegen der Arrays + befüllen mit den relevanten Daten
                if (result.error) {
                  console.error('Fehler: '+result.error);
                } else {
                 //falls keinerlei Daten vom Vorjahr vorhanden sind...
                   if (typeof result.result[0][0] === "undefined") {
                    //Arrays löschen und mit default-Wert initiieren   
                    temps.length=0;
                    temps[0]=99999; 
                    wind.length=0;
                    wind[0]=99999;
                    regen.length=0;
                    regen[0]=99999;

                   } else {               
                    for (let i = 0; i < result.result[0].length; i++) { temps[i] = result.result[0][i]._value; }
                    for (let i = 0; i < result.result[1].length; i++) { wind[i] = result.result[1][i]._value; }
                    for (let i = 0; i < result.result[2].length; i++) { regen[i] = result.result[2][i]._value; }
                   }
                }           
      
                //Temperaturen
                let VTiefstwert = Math.min(...temps);
                let VHoechstwert = Math.max(...temps);
                const reducer = (accumulator, curr) => accumulator + curr;
                let VTemp_Durchschnitt = Number((temps.reduce(reducer)/temps.length).toFixed(2));

                //let's do Gradtage...
                let MonatsTag, MonatsTag_old, Temp, Hit = [false,false,false,false,false,false,false,false,false];
                //Reset der Gradtage je nachdem ob Daten vorhanden oder nicht
                if (typeof result.result[0][0] !== "undefined") { Vwarme_Tage=0, VSommertage=0, Vheisse_Tage=0, VFrost_Tage=0, Vkalte_Tage=0, VEistage=0, Vsehr_kalte_Tage=0, VWuestentage=0, VTropennaechte=0, VRegentage=0; }
                
                for (let i = 0; i < result.result[0].length; i++) {
                    MonatsTag = new Date(result.result[0][i].ts).getDate();
                    if (MonatsTag != MonatsTag_old) { Hit=[false,false,false,false,false,false,false,false,true]; }
                    Temp = result.result[0][i].value;
                     if (Temp > 20 && Hit[0] == false) { Vwarme_Tage++; Hit[0] = true; }
                     if (Temp > 25 && Hit[1] == false) { VSommertage++; Hit[1] = true; }
                     if (Temp > 30 && Hit[2] == false) { Vheisse_Tage++; Hit[2] = true; }
                     if (Temp < 0 && Hit[3] == false) { VFrost_Tage++; Hit[3] = true; }
                     if (Temp < 10 && Hit[4] == false) { Vkalte_Tage++; Hit[4] = true; }
                     if (Temp < 0 && Hit[5] == false) { VEistage++; Hit[5] = true; }
                     if (Temp < -10 && Hit[6] == false) { Vsehr_kalte_Tage++; Hit[6] = true; }
                     if (Temp >= 35 && Hit[7] == false) { VWuestentage++; Hit[7] = true; }
                     if (Temp < 20 && Hit[8] == true) { Hit[8] = false; }
                    MonatsTag_old=MonatsTag; 
                    if (Hit[8]) { VTropennaechte++; }
                } 

                //Wind
                let VMax_Windboee = Math.max(...wind);

                //Regen
                let VMax_Regenmenge = Math.max(...regen);
                let VRegenmenge_Monat=0, Rain = [];
                for (let i = 0; i < result.result[2].length; i++) {
                    MonatsTag = new Date(result.result[2][i].ts).getDate();
                    Rain[i] = result.result[2][i].value;
                    if (MonatsTag != MonatsTag_old) {
                        VRegenmenge_Monat+= Math.max(...Rain);
                        if (Math.max(...Rain) >= 0.1) { VRegentage++; }
                        Rain.length=0; }
                    MonatsTag_old=MonatsTag; 
                }
                if (typeof result.result[0][0] === "undefined") { VRegenmenge_Monat=99999; } //keine Daten vom Vorjahresmonat

                //DPs schreiben
                setState(PRE_DP+'.Vorjahres_Monat.Tiefstwert', VTiefstwert, true);
                setState(PRE_DP+'.Vorjahres_Monat.Hoechstwert', VHoechstwert, true);
                setState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt', VTemp_Durchschnitt, true);
                setState(PRE_DP+'.Vorjahres_Monat.Max_Windboee', VMax_Windboee, true);
                setState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge', VMax_Regenmenge, true);
                setState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat', VRegenmenge_Monat, true);
                setState(PRE_DP+'.Vorjahres_Monat.warme_Tage', Vwarme_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Sommertage', VSommertage, true);
                setState(PRE_DP+'.Vorjahres_Monat.heisse_Tage', Vheisse_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Frost_Tage', VFrost_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.kalte_Tage', Vkalte_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Eistage', VEistage, true);
                setState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage', Vsehr_kalte_Tage, true);
                setState(PRE_DP + '.Vorjahres_Monat.Wuestentage', VWuestentage, true);
                setState(PRE_DP + '.Vorjahres_Monat.Tropennaechte', VTropennaechte, true);
                setState(PRE_DP + '.Vorjahres_Monat.Regentage', VRegentage, true);

            }); //end sendTo
        
    } //end else  

} //end function


function timeConverter(UNIX_timestamp){
  let a = new Date(UNIX_timestamp);
  let months = ['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'];
  let year = a.getFullYear();
  let month = months[a.getMonth()];
  let date = a.getDate();
  let hour = a.getHours();
  let min = a.getMinutes();
  let sec = a.getSeconds();
  let time = pad(date) + '. ' + month + ' ' + year + ' ' + pad(hour) + ':' + pad(min) + ':' + pad(sec) ;
  return time;
}

function pad(n) {
    return n<10 ? '0'+n : n;
}

// Pause einlegen
function Sleep(milliseconds) {
 return new Promise(resolve => setTimeout(resolve, milliseconds));
}

// Statusmeldungen in DP schreiben
function Statusmeldung(Text) {
    if (typeof(Text) === "undefined") { //nur beim Start des Skriptes
        Text = 'Skript gestartet';
        setState(PRE_DP+'.Control.ScriptVersion', ScriptVersion, true);    
    }
    setState(PRE_DP+'.Control.Statusmeldung', Text, true);
}

// Test auf neue Skriptversion
function check_update() {
    const link="https://github.com/SBorg2014/WLAN-Wetterstation/commits/master/wetterstation-statistik.js";

    try {
        httpGet(link, { responseType: 'text' }, (error, response) => { 
            if (!error && response.statusCode == 200) {
               let regex = /">V.*<\/a>/
               , version = response.data.match(regex);
               if (version[0].match(ScriptVersion)) { 
                 setState(PRE_DP+'.Control.ScriptVersion_Update','---',true); 
               } else {
                 setState(PRE_DP+'.Control.ScriptVersion_Update','https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/wetterstation-statistik.js',true);
                 console.log('neue Script-Version verfügbar...');
               }
            } else { 
                log(error, 'error'); 
            } 
        });
    } catch (fehler) {
        log("Fehler (try): " + fehler, "error");
    }
} // end function

// Jahresstatistik-Backup
function Backup_Jahresstatistik() {
    let Temperatur_Hoechstwert = getState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert').val;
    let Temperatur_Tiefstwert = getState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert').val;
    let Temperatur_Durchschnitt = getState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt').val;
    let Regenmengetag = getState(PRE_DP+'.Jahreswerte.Regenmengetag').val;
    let Regenmengemonat = getState(PRE_DP+'.Jahreswerte.Regenmengemonat').val;
    let Windboee_max = getState(PRE_DP+'.Jahreswerte.Windboee_max').val;
    let Trockenperiode = getState(PRE_DP+'.Jahreswerte.Trockenperiode').val;
    let kalte_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_kalteTage').val;
    let warme_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_warmeTage').val;
    let Sommertage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Sommertage').val;
    let heisse_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_heisseTage').val;
    let Frosttage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Frosttage').val;
    let Eistage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_Eistage').val;
    let sehrkalte_Tage_Jahr = getState(PRE_DP+'.Jahreswerte.Gradtage_sehrkalteTage').val;
    let Wuestentage_Jahr = getState(PRE_DP + '.Jahreswerte.Gradtage_Wuestentage').val;
    let Tropennaechte_Jahr = getState(PRE_DP + '.Jahreswerte.Gradtage_Tropennaechte').val;
    let Regentage_Jahr = getState(PRE_DP + '.Jahreswerte.Regentage').val;
    let jsonSummary = [];

    jsonSummary.push({
        "Temperatur Tiefstwert": Temperatur_Tiefstwert, "Temperatur Höchstwert": Temperatur_Hoechstwert, "Temperatur Durchschnitt": Temperatur_Durchschnitt,
        "Regenmengetag": Regenmengetag, "höchste Regenmengemonat": Regenmengemonat, "Windböe": Windboee_max,
        "Trockenperiode": Trockenperiode,
        "kalte Tage": kalte_Tage_Jahr, "warme Tage": warme_Tage_Jahr, "Sommertage": Sommertage_Jahr, "heiße Tage": heisse_Tage_Jahr, "Frosttage": Frosttage_Jahr, "Eistage": Eistage_Jahr,
        "sehr kalte Tage": sehrkalte_Tage_Jahr, "Wuestentage": Wuestentage_Jahr, "Tropennaechte": Tropennaechte_Jahr, "Regentage": Regentage_Jahr});
    createState(PRE_DP+'.Jahreswerte.VorJahre.'+(new Date().getFullYear()-1), '', { name: "Jahresstatistik", type: "string", role: "json" }, () => { setState(PRE_DP+'.Jahreswerte.VorJahre.'+(new Date().getFullYear()-1), JSON.stringify(jsonSummary), true) });
} // end function


function Rekordwerte() {
    //max Temp
    if (getState(PRE_DP+'.Rekordwerte.value.Temp_Max').val <= Hoechstwert) {
        setState(PRE_DP+'.Rekordwerte.value.Temp_Max', Hoechstwert, true, () => { Template_Rekordwerte('Temp_Max','Rekordwerte.Temperatur_Spitzenhoechstwert'); });
    }

    //min Temp
    if (getState(PRE_DP+'.Rekordwerte.value.Temp_Min').val >= Tiefstwert) {
        setState(PRE_DP+'.Rekordwerte.value.Temp_Min', Tiefstwert, true, () => { Template_Rekordwerte('Temp_Min','Rekordwerte.Temperatur_Spitzentiefstwert'); });
    }  

    //Regenmenge
    if (getState(PRE_DP+'.Rekordwerte.value.Regenmengetag').val <= Max_Regenmenge) {
        setState(PRE_DP+'.Rekordwerte.value.Regenmengetag', Max_Regenmenge, true, () => { Template_Rekordwerte('Regenmengetag','Rekordwerte.Regenmengetag'); });
    }
    Regenmenge_Monat = getState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat').val;
    if (getState(PRE_DP+'.Rekordwerte.value.Regenmengemonat').val <= Regenmenge_Monat) {
        setState(PRE_DP+'.Rekordwerte.value.Regenmengemonat', Regenmenge_Monat, true, () => { Template_Rekordwerte('Regenmengemonat','Rekordwerte.Regenmengemonat'); });
    }

    //Windböe
    if (getState(PRE_DP+'.Rekordwerte.value.Windboee').val <= Max_Windboee) {
        setState(PRE_DP+'.Rekordwerte.value.Windboee', Max_Windboee, true, () => { Template_Rekordwerte('Windboee','Rekordwerte.Windboee'); });
    }

    //Trockenperiode
    if (getState(PRE_DP+'.Rekordwerte.value.Trockenperiode').val <= Trockenperiode_akt) {
        setState(PRE_DP+'.Rekordwerte.value.Trockenperiode', Trockenperiode_akt, true, () => { Template_Rekordwerte('Trockenperiode','Rekordwerte.Trockenperiode'); });
    }  

} // end function


async function Template_Rekordwerte(DatenPunkt, DatenPunktName) {
    await Sleep(5000);
    let wert = getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).val;
    let unit = getObject(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).common.unit;
    let REKORDWERTEAUSGABE="";
    
    //[WERT]
    if (REKORDWERTE_AUSGABEFORMAT.search("[WERT]") != -1) {
        REKORDWERTEAUSGABE = REKORDWERTE_AUSGABEFORMAT.replace("[WERT]", wert+' '+unit);
    } else { REKORDWERTEAUSGABE = REKORDWERTE_AUSGABEFORMAT; }

    //[TAG]
    REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("[TAG]", new Date((getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).lc)-86400).getDate()); 

    //[MONAT]
    REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("[MONAT]", monatsname[new Date((getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).lc)-86400).getMonth()]);

    //[MONAT_ZAHL]
    REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("[MONAT_ZAHL]", pad(new Date((getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).lc)-86400).getMonth()+1));

    //[MONAT_KURZ]
    REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("[MONAT_KURZ]", monatsname_kurz[new Date((getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).lc)-86400).getMonth()]);

    //[JAHR]
    REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("[JAHR]", new Date((getState(PRE_DP+'.Rekordwerte.value.'+DatenPunkt).lc)-86400).getFullYear());

    //Spezialpatch für 1 Tag
    if ((REKORDWERTEAUSGABE.search("Tage") != -1) && (wert == 1)) {
        REKORDWERTEAUSGABE = REKORDWERTEAUSGABE.replace("Tage", "Tag");
    }

    setState(PRE_DP+'.'+DatenPunktName, REKORDWERTEAUSGABE, true);                                                 
} // end function


//Datenpunkte anlegen
async function createDP(DP_Check) {
    console.log(PRE_DP + '.' + DP_Check + ' existiert nicht... Lege Datenstruktur an...');
    createState(PRE_DP,                                           '',   { name: 'Wetterstatistik',                              type: "folder" });
    createState(PRE_DP+'.aktueller_Monat',                        '',   { name: 'Statistik für den aktuellen Monat',            type: "folder" });
    createState(PRE_DP+'.Vorjahres_Monat',                        '',   { name: 'Statistik für den Monat des Vorjahres',        type: "folder" });
    createState(PRE_DP+'.Data',                                   '',   { name: 'bisherige Statistiken',                        type: "folder" });
    createState(PRE_DP+'.VorTag',                                 '',   { name: 'Werte von Gestern',                            type: "folder" });
    createState(PRE_DP+'.Control',                                '',   { name: 'Einstellungen, Meldungen',                     type: "folder" });
    createState(PRE_DP+'.Jahreswerte',                            '',   { name: 'Jahresstatistik',                              type: "folder" });
    createState(PRE_DP+'.Rekordwerte',                            '',   { name: 'Rekordwerte seit Aufzeichnungsbeginn',         type: "folder" });
    
    createState(PRE_DP+'.aktueller_Monat.Tiefstwert',             100,  { name: "niedrigste Temperatur",                        type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Hoechstwert',            -100, { name: "höchste Temperatur",                           type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt',0,    { name: "Durchschnittstemperatur",                      type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Max_Windboee',           0,    { name: "stärkste Windböe",                             type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.aktueller_Monat.Max_Regenmenge',         0,    { name: "maximale Regenmenge pro Tag",                  type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat',       0,    { name: "Regenmenge im Monat",                          type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.aktueller_Monat.warme_Tage',             0,    { name: "Tage mit einer Temperatur über 20°",           type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Sommertage',             0,    { name: "Tage mit einer Temperatur über 25°",           type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.heisse_Tage',            0,    { name: "Tage mit einer Temperatur über 30°",           type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Frost_Tage',             0,    { name: "Tage mit einer Mindesttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.kalte_Tage',             0,    { name: "Tage mit einer Höchsttemperatur unter 10°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Eistage',                0,    { name: "Tage mit einer Höchsttemperatur unter 0°",     type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage',        0,    { name: "Tage mit einer Mindesttemperatur unter -10°",  type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.aktueller_Monat.Wuestentage',          0,    { name: "Tage mit einer Hochsttemperatur größer/gleich 35°", type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.aktueller_Monat.Tropennaechte',        0,    { name: "Tage mit einer Mindesttemperatur über/gleich 20°", type: "number", role: "state", unit: "Tage" });
    await createStateAsync(PRE_DP + '.aktueller_Monat.Regentage', 0,    { name: "Regentage im Monat",                              type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.Vorjahres_Monat.Tiefstwert',             99999, { name: "niedrigste Temperatur",                       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Hoechstwert',            99999, { name: "höchste Temperatur",                          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt',99999, { name: "Durchschnittstemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Max_Windboee',           99999, { name: "stärkste Windböe",                            type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge',         99999, { name: "maximale Regenmenge pro Tag",                 type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat',       99999, { name: "Regenmenge im Monat",                         type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Vorjahres_Monat.warme_Tage',             99999, { name: "Tage mit einer Temperatur über 20°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Sommertage',             99999, { name: "Tage mit einer Temperatur über 25°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.heisse_Tage',            99999, { name: "Tage mit einer Temperatur über 30°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Frost_Tage',             99999, { name: "Tage mit einer Mindesttemperatur unter 0°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.kalte_Tage',             99999, { name: "Tage mit einer Höchsttemperatur unter 10°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Eistage',                99999, { name: "Tage mit einer Höchsttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage',        99999, { name: "Tage mit einer Mindesttemperatur unter -10°", type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.Vorjahres_Monat.Wuestentage',          99999, { name: "Tage mit einer Hochsttemperatur größer/gleich 35°", type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.Vorjahres_Monat.Tropennaechte',        99999, { name: "Tage mit einer Mindesttemperatur über/gleich 20°", type: "number", role: "state", unit: "Tage" });
    await createStateAsync(PRE_DP + '.Vorjahres_Monat.Regentage', 99999, { name: "Regentage im Monat",                          type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.VorTag.Temperatur_Tiefstwert',           99999, { name: "niedrigste Tagestemperatur",                  type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.VorTag.Temperatur_Hoechstwert',          99999, { name: "höchste Tagestemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.VorTag.Temperatur_Durchschnitt',         99999, { name: "Durchschnittstemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.VorTag.Regenmenge',                      0,     { name: "Regenmenge vom Vortag",                       type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.VorTag.Windboee_max',                    0,     { name: "stärkste Windböe vom Vortag",                 type: "number", role: "state", unit: "km/h" });

    createState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert',     -100,  { name: "höchste Tagestemperatur des Jahres",          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert',      100,   { name: "niedrigste Tagestemperatur des Jahres",       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt',    0,     { name: "Durchschnittstemperatur des Jahres",          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Trockenperiode',             0,     { name: "längste Periode ohne Regen",                  type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Regenmengetag',              0,     { name: "höchste Regenmenge an einem Tag",             type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Jahreswerte.Regenmengemonat',            0,     { name: "höchste Regenmenge innerhalb eines Monats",   type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Jahreswerte.Windboee_max',               0,     { name: "stärkste Windböe des Jahres",                 type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_kalteTage',         0,     { name: "Tage mit einer Höchsttemperatur unter 10°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_warmeTage',         0,     { name: "Tage mit einer Höchsttemperatur über 20°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_Sommertage',        0,     { name: "Tage mit einer Höchsttemperatur über 25°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_heisseTage',        0,     { name: "Tage mit einer Höchsttemperatur über 30°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_Frosttage',         0,     { name: "Tage mit einer Tiefsttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_Eistage',           0,     { name: "Tage mit einer Höchsttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Jahreswerte.Gradtage_sehrkalteTage',     0,     { name: "Tage mit einer Tiefsttemperatur unter -10°",  type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.Jahreswerte.Gradtage_Wuestentage',     0,     { name: "Tage mit einer Hochsttemperatur größer/gleich 35°", type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP + '.Jahreswerte.Gradtage_Tropennaechte',   0,     { name: "Tage mit einer Mindesttemperatur über/gleich 20°", type: "number", role: "state", unit: "Tage" });
    await createStateAsync(PRE_DP + '.Jahreswerte.Regentage',     0,     { name: "Regentage im Jahr",                           type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.Rekordwerte.value.Temp_Max',             -100,  { name: "Max. Tagestemperatur",                        type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Rekordwerte.value.Temp_Min',             100,   { name: "Min. Tagestemperatur",                        type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Rekordwerte.value.Trockenperiode',       0,     { name: "längste Trockenperiode",                      type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Min',99.99, { name: "niedrigster Jahrestemperaturdurchschnitt",    type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Rekordwerte.value.Temp_Durchschnitt_Max',-99.99,{ name: "höchster Jahrestemperaturdurchschnitt",       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Rekordwerte.value.Regenmengetag',        0,     { name: "höchste je gemessene Regenmenge an einem Tag",type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Rekordwerte.value.Regenmengemonat',      0,     { name: "höchste je gemessene Regenmenge eines Monats",type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Rekordwerte.value.Windboee',             0,     { name: "stärkste je gemessene Windböe"               ,type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.Rekordwerte.Temperatur_Spitzenhoechstwert', '', { name: "höchste je gemessene Tagestemperatur",        type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Temperatur_Spitzentiefstwert',  '', { name: "niedrigste je gemessene Tagestemperatur",     type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Max', '', { name: "höchster Jahrestemperaturdurchschnitt",   type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Temperatur_Jahresdurchschnitt_Min', '', { name: "niedrigster Jahrestemperaturdurchschnitt",type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Regenmengetag',             '',     { name: "höchste je gemessene Regenmenge an einem Tag",type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Regenmengemonat',           '',     { name: "höchste je gemessene Regenmenge eines Monats",type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Windboee',                  '',     { name: "stärkste je gemessene Windböe"               ,type: "string", role: "state" });
    createState(PRE_DP+'.Rekordwerte.Trockenperiode',            '',     { name: "längste je andauernde Trockenperiode",        type: "string", role: "state" });

    createState(PRE_DP+'.Control.Statusmeldung',                  '',    { name: "Statusmeldungen",                             type: "string", role: "state"});
    createState(PRE_DP+'.Control.Reset_Jahresstatistik',          false, { name: "Jahresstatistik zurücksetzen",                type: "boolean",role: "state"});
    createState(PRE_DP+'.Control.AutoReset_Jahresstatistik',      0,     { name: "Jahresstatistik zurücksetzen [0=Aus, 1=Ein, 2=Ein+Backup]",type: "number",role: "state"});
    createState(PRE_DP+'.Control.AutoDelete_Data',                0,     { name: "Data bereinigen? [0 = nie, 1...n = nach x Monaten]",  type: "number", role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion',                  '',    { name: "aktuelle Versionsnummer des Statistik-Skriptes",type: "string",role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion_Update',           '',    { name: "neue Version des Statistik-Skriptes vorhanden",type: "string",role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion_UpdateCheck',      '',    { name: "Skript-Updatecheck ein-/ausschalten",         type: "boolean",role: "state"});
    await Sleep(5000);
}

