/* Wetterstation-Statistiken 

   holt die Messdaten aus einer InfluxDB und erstellt eine Monats- und Vorjahres-Statistik
   Wichtig: funktioniert nur mit der Default-Datenstruktur des WLAN-Wetterstation-Skriptes!

   (c)2020 by SBorg
   V0.1.0 - 06.10.2020  +DP für Statusmeldungen / Reset Jahresstatistik / AutoDelete "Data"
                        +ScriptVersion / Update vorhanden / UpdateCheck abschaltbar
                        +Jahresstatistik Min-/Max-/Durchschnittstemperatur/Trockenperiode
   V0.0.7 - 19.09.2020  +Min.-/Max.-/Durchschnittstemperatur vom Vortag
   V0.0.6 - 18.09.2020  +Regenmenge Monat
   V0.0.5 - 17.09.2020  +Gradtage Vorjahr
   V0.0.4 - 16.09.2020  +Eistage (Max. unter 0°C) / Sehr kalte Tage (Min. unter -10°C)
                        ~Frosttage (Korrektur: Tiefstwert unter 0°C)
   V0.0.3 - 15.09.2020  +Frosttage (Min. unter 0°C) / Kalte Tage (Max. unter 10°C)
   V0.0.2 - 12.09.2020  +warme Tage über 20°C / Sommertage über 25°C / heiße Tage über 30°C
   V0.0.1 - 11.09.2020   erste Beta + Temp-Min/Temp-Max/Temp-Durchschnitt/max. Windböe/max. Regenmenge pro Tag 

      ToDo: Autoreset Jahresstatistik
      known issues: keine

*/



// *** User-Einstellungen ***************************************************************************************
    let WET_DP='javascript.0.Wetterstation';    /* wo liegen die Datenpunkte mit den Daten der Wetterstation
                                                   [default: javascript.0.Wetterstation]                       */
    let INFLUXDB_INSTANZ='0';                   // unter welcher Instanz läuft die InfluxDB [default: 0]   
    let PRE_DP='0_userdata.0.Statistik.Wetter'; // wo sollen die Statistikwerte abgelegt werden   
    const ZEITPLAN = "3 1 * * *";               // wann soll die Statistik erstellt werden (Minuten Stunde * * *)                       
// *** ENDE User-Einstellungen **********************************************************************************




//ab hier gibt es nix mehr zu ändern :)
//first start?
let DP_Check='Control.ScriptVersion_UpdateCheck';
if (!existsState(PRE_DP+'.'+DP_Check)) { createDP(DP_Check); }

//Start des Scripts
    const ScriptVersion = "V0.1.0 RC3";
    let Tiefstwert, Hoechstwert, Temp_Durchschnitt, Max_Windboe, Max_Regenmenge, Regenmenge_Monat, warme_Tage, Sommertage;
    let heisse_Tage, Frost_Tage, kalte_Tage, Eistage, sehr_kalte_Tage;
    let monatstage = [31,28,31,30,31,30,31,31,30,31,30,31];
    let result = [], temps = [], wind = [], regen = [];
    console.log('Wetterstation-Statistiken gestartet...');
    setTimeout(Statusmeldung, 500);

//scheduler
    schedule(ZEITPLAN, main);



// ### Funktionen ###############################################################################################
function main() {
    let start, end;
    let zeitstempel = new Date();
    start = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-1,0,0,0);
    start = start.getTime();
    end = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-1,23,59,59);
    end = end.getTime();

    //Jobs Monatserster
 if (zeitstempel.getDate() == 1) { 
   speichern_Monat();  //vorherige Monatsstatistik speichern
   VorJahr();          //Vorjahresmonatsstatistik ausführen
   
   /*DPs unabhängig ihres Wertes initial schreiben; wir nehmen die aktuelle Aussentemp, da sie zum Start des Messzyklus
     Min, Max und Durchschnitt darstellt; Rest einfach nullen */
     let initialTemp=getState(WET_DP+'.Aussentemperatur').val;
    setState(PRE_DP+'.aktueller_Monat.Tiefstwert', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Hoechstwert', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt', initialTemp, true);
    setState(PRE_DP+'.aktueller_Monat.Max_Windboe', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Max_Regenmenge', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat', 0, true);
    setState(PRE_DP+'.aktueller_Monat.warme_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Sommertage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.heisse_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Frost_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.kalte_Tage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.Eistage', 0, true);
    setState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage', 0, true);

   if (getState(PRE_DP+'.Control.AutoDelete_Data').val >0) { AutoDelete_Data(); }
 }//End Jobs Monatserster

            //InfluxDB abfragen (Regen +1min Startverzögerung wg. ev. Ungenauigkeit der Systemzeit des Wetterstation-Displays)
            sendTo('influxdb.'+INFLUXDB_INSTANZ, 'query', 
            'select * FROM "' + WET_DP + '.Aussentemperatur" WHERE time >= ' + (start *1000000) + ' AND time <= ' + (end *1000000)
             + '; select * FROM "' + WET_DP + '.Wind_max" WHERE time >= '  + (start *1000000) + ' AND time <= ' + (end *1000000)
             + '; select * FROM "' + WET_DP + '.Regen_Tag" WHERE time >= ' + ((start+60000) *1000000) + ' AND time <= ' + (end *1000000)
         , function (result) {
             //Anlegen der Arrays + befüllen mit den relevanten Daten
            if (result.error) {
               console.error('Fehler: '+result.error);
               Statusmeldung('Fehler: '+result.error);
            } else {
                //console.log('Rows: ' + JSON.stringify(result.result[2]));
                for (let i = 0; i < result.result[0].length; i++) { temps[i] = result.result[0][i].value; }
                for (let i = 0; i < result.result[1].length; i++) { wind[i] = result.result[1][i].value; }
                for (let i = 0; i < result.result[2].length; i++) { regen[i] = result.result[2][i].value; }
            }           
                    
  //Temperaturen
    Tiefstwert = Math.min(...temps);
    Hoechstwert = Math.max(...temps);
    Math.sum = (...temps) => Array.prototype.reduce.call(temps,(a,b) => a+b);
    Temp_Durchschnitt = Number((Math.sum(...temps)/temps.length).toFixed(2));
    if (Hoechstwert > 20) { warme_Tage = 1; }
    if (Hoechstwert > 25) { Sommertage = 1; }
    if (Hoechstwert > 30) { heisse_Tage = 1; }
    if (Tiefstwert < 0) { Frost_Tage = 1; }
    if (Hoechstwert < 10) { kalte_Tage = 1; }
    if (Hoechstwert < 0) { Eistage = 1; }
    if (Tiefstwert < -10) { sehr_kalte_Tage = 1;}

  //Wind
    Max_Windboe = Math.max(...wind);      

  //Regen
    Max_Regenmenge = Math.max(...regen);
    

/* Debug-Consolenausgaben
    console.log('Daten ab ' + timeConverter(start));
    console.log('Daten bis ' + timeConverter(end));
    console.log('Erster Messwert: ' + new Date(result.result[0][0].ts).toISOString() + ' ***' + result.result[0][0].value);
    console.log('Letzter Messwert: ' + new Date(result.result[0][temps.length-1].ts).toISOString() + ' ***' + result.result[0][temps.length-1].value);
    console.log('Anzahl Datensätze: T_' + temps.length + '|W_' + wind.length + '|R_' + regen.length); */


   // Datenpunkte schreiben
   if (getState(PRE_DP+'.aktueller_Monat.Tiefstwert').val > Tiefstwert) {setState(PRE_DP+'.aktueller_Monat.Tiefstwert', Tiefstwert, true);}    
   if (getState(PRE_DP+'.aktueller_Monat.Hoechstwert').val < Hoechstwert) {setState(PRE_DP+'.aktueller_Monat.Hoechstwert', Hoechstwert, true);}    
   if (getState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt').val != Temp_Durchschnitt) {setState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt', Temp_Durchschnitt, true);}
   if (getState(PRE_DP+'.aktueller_Monat.Max_Windboe').val < Max_Windboe) {setState(PRE_DP+'.aktueller_Monat.Max_Windboe', Max_Windboe, true);}
   if (getState(PRE_DP+'.aktueller_Monat.Max_Regenmenge').val < Max_Regenmenge) {setState(PRE_DP+'.aktueller_Monat.Max_Regenmenge', Max_Regenmenge, true);}
   if (Max_Regenmenge > 0) {Regenmenge_Monat = getState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat').val + Max_Regenmenge; setState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat', Regenmenge_Monat, true);}
   if (warme_Tage) {warme_Tage = getState(PRE_DP+'.aktueller_Monat.warme_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.warme_Tage', warme_Tage, true);}
   if (Sommertage) {Sommertage = getState(PRE_DP+'.aktueller_Monat.Sommertage').val +1; setState(PRE_DP+'.aktueller_Monat.Sommertage', Sommertage, true);}
   if (heisse_Tage) {heisse_Tage = getState(PRE_DP+'.aktueller_Monat.heisse_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.heisse_Tage', heisse_Tage, true);}
   if (Frost_Tage) {Frost_Tage = getState(PRE_DP+'.aktueller_Monat.Frost_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.Frost_Tage', Frost_Tage, true);}
   if (kalte_Tage) {kalte_Tage = getState(PRE_DP+'.aktueller_Monat.kalte_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.kalte_Tage', kalte_Tage, true);}
   if (Eistage) {Eistage = getState(PRE_DP+'.aktueller_Monat.Eistage').val +1; setState(PRE_DP+'.aktueller_Monat.Eistage', Eistage, true);}
   if (sehr_kalte_Tage) {sehr_kalte_Tage = getState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage').val +1; setState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage', sehr_kalte_Tage, true);}
    //VorTag
    setState(PRE_DP+'.VorTag.Temperatur_Tiefstwert', Tiefstwert, true);
    setState(PRE_DP+'.VorTag.Temperatur_Hoechstwert', Hoechstwert, true);
    setState(PRE_DP+'.VorTag.Temperatur_Durchschnitt', Temp_Durchschnitt, true);
    //Jahresstatistik
    if (getState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert').val < Hoechstwert) {setState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert', Hoechstwert, true);}
    if (getState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert').val > Tiefstwert) {setState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert', Tiefstwert, true);}
       //Temperaturdurchschnitt
       let JahresTemp_Durchschnitt=Math.round(((getState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt').val + Temp_Durchschnitt)/2)*100)/100;
       setState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt', JahresTemp_Durchschnitt, true);
    if (getState(WET_DP+'.Info.Letzter_Regen').val.match(/Tag/g)) { //nur setzen bei [Tag]en, nicht bei Stunden
        let Trockenperiode_akt=parseInt(getState(WET_DP+'.Info.Letzter_Regen').val.replace(/[^0-9\.]/g, ''), 10);
        let Trockenperiode_alt=getState(PRE_DP+'.Jahreswerte.Trockenperiode').val;
        if (Trockenperiode_akt > Trockenperiode_alt) { setState(PRE_DP+'.Jahreswerte.Trockenperiode', Trockenperiode_akt, true); }
    }
  
 });
 if (getState(PRE_DP+'.Control.Reset_Jahresstatistik').val === true) { Reset_Jahresstatistik(); }
 console.log('Auswertung durchgeführt...');
 if (getState(PRE_DP+'.Control.ScriptVersion_UpdateCheck').val) { check_update(); } // neue Script-Version vorhanden?
 Statusmeldung('erfolgreich');
} //end function main

function Reset_Jahresstatistik() {
        setState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert',   100,  true);
        setState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert',  -100, true);
        setState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt', 0,    true);
        setState(PRE_DP+'.Jahreswerte.Trockenperiode',          0,    true);

        setState(PRE_DP+'.Control.Reset_Jahresstatistik', false, true);
} //end function

function AutoDelete_Data() {
    let AutoDelete = getState(PRE_DP+'.Control.AutoDelete_Data').val; //Anzahl Monate
    let zeitstempel = new Date();
    let start = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth()-AutoDelete,1);
    let AutoDelete_Year = start.getFullYear();
    let AutoDelete_Month = start.getMonth();
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
    for ( let i=0; i<DP_Years.length; i++) {
        let DP_Ordner_test=$(PRE_DP+'.Data.'+DP_Years[i]+'.*');
        if ( DP_Ordner_test.length == 0 ) { deleteState(PRE_DP+'.Data.'+DP_Years[i]); }
    }
    
} //end function

function speichern_Monat() {
    let monat = ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'];
    let zeitstempel = new Date();
    let datum = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate()-2);
    let monatsdatenpunkt = '.Data.'+datum.getFullYear()+'.'+pad(datum.getMonth()+1); 
    //Datenpunkte lesen
    Tiefstwert=getState(PRE_DP+'.aktueller_Monat.Tiefstwert').val;
    Hoechstwert=getState(PRE_DP+'.aktueller_Monat.Hoechstwert').val;
    Temp_Durchschnitt=getState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt').val;
    Max_Windboe=getState(PRE_DP+'.aktueller_Monat.Max_Windboe').val;
    Max_Regenmenge=getState(PRE_DP+'.aktueller_Monat.Max_Regenmenge').val;
    Regenmenge_Monat=getState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat').val;
    warme_Tage=getState(PRE_DP+'.aktueller_Monat.warme_Tage').val;
    Sommertage=getState(PRE_DP+'.aktueller_Monat.Sommertage').val;
    heisse_Tage=getState(PRE_DP+'.aktueller_Monat.heisse_Tage').val;
    Frost_Tage=getState(PRE_DP+'.aktueller_Monat.Frost_Tage').val;
    kalte_Tage=getState(PRE_DP+'.aktueller_Monat.kalte_Tage').val;
    Eistage=getState(PRE_DP+'.aktueller_Monat.Eistage').val;
    sehr_kalte_Tage=getState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage').val;
    let json = JSON.stringify({Tiefstwert: Tiefstwert, Hoechstwert: Hoechstwert, Temp_Durchschnitt: Temp_Durchschnitt, Max_Windboe: Max_Windboe, 
        Max_Regenmenge: Max_Regenmenge, Regenmenge_Monat: Regenmenge_Monat, warme_Tage: warme_Tage,
        Sommertage: Sommertage, heisse_Tage: heisse_Tage, Frost_Tage: Frost_Tage, kalte_Tage: kalte_Tage, Eistage: Eistage, 
        sehr_kalte_Tage: sehr_kalte_Tage});
    createState(PRE_DP+monatsdatenpunkt,'',{ name: "Monatsstatistik für "+monat[datum.getMonth()]+' '+datum.getFullYear(), type: "string", role: "json" }, () => { setState(PRE_DP+monatsdatenpunkt, json, true); }); 
} //end function

function VorJahr() {    
    let zeitstempel = new Date();
    let datum = new Date(zeitstempel.getFullYear(),zeitstempel.getMonth(),zeitstempel.getDate());
    let monatsdatenpunkt = '.Data.'+ (datum.getFullYear()-1) +'.'+pad(datum.getMonth()+1);
    if (existsState(PRE_DP+monatsdatenpunkt)) { //der einfache Weg: wir haben schon Daten vom Vorjahr...
        let VorJahr = getState(PRE_DP+monatsdatenpunkt).val;
        VorJahr = JSON.parse(VorJahr);
        setState(PRE_DP+'.Vorjahres_Monat.Tiefstwert', VorJahr.Tiefstwert, true);
        setState(PRE_DP+'.Vorjahres_Monat.Hoechstwert', VorJahr.Hoechstwert, true);
        setState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt', VorJahr.Temp_Durchschnitt, true); 
        setState(PRE_DP+'.Vorjahres_Monat.Max_Windboe', VorJahr.Max_Windboe, true); 
        setState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge', VorJahr.Max_Regenmenge, true);
        setState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat', VorJahr.Regenmenge_Monat, true);
        setState(PRE_DP+'.Vorjahres_Monat.warme_Tage', VorJahr.warme_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Sommertage', VorJahr.Sommertage, true);
        setState(PRE_DP+'.Vorjahres_Monat.heisse_Tage', VorJahr.heisse_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Frost_Tage', VorJahr.Frost_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.kalte_Tage', VorJahr.kalte_Tage, true);
        setState(PRE_DP+'.Vorjahres_Monat.Eistage', VorJahr.Eistage, true);
        setState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage', VorJahr.sehr_kalte_Tage, true);

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

        //Abfrage der Influx-Datenbank
        let start, end;
        start = new Date(zeitstempel.getFullYear()-1,zeitstempel.getMonth(),1,0,0,0);
        start = start.getTime();
        end = new Date(zeitstempel.getFullYear()-1,zeitstempel.getMonth(),monatstage[zeitstempel.getMonth()],23,59,59);
        end = end.getTime();
            sendTo('influxdb.'+INFLUXDB_INSTANZ, 'query', 
             'select * FROM "' + WET_DP + '.Aussentemperatur" WHERE time >= ' + (start *1000000) + ' AND time <= ' + (end *1000000)
             + '; select * FROM "' + WET_DP + '.Wind_max" WHERE time >= '  + (start *1000000) + ' AND time <= ' + (end *1000000)
             + '; select * FROM "' + WET_DP + '.Regen_Tag" WHERE time >= ' + (start *1000000) + ' AND time <= ' + (end *1000000)
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
                    for (let i = 0; i < result.result[0].length; i++) { temps[i] = result.result[0][i].value; }
                    for (let i = 0; i < result.result[1].length; i++) { wind[i] = result.result[1][i].value; }
                    for (let i = 0; i < result.result[2].length; i++) { regen[i] = result.result[2][i].value; }
                   }
                }           
      
                //Temperaturen
                let VTiefstwert = Math.min(...temps);
                let VHoechstwert = Math.max(...temps);
                Math.sum = (...temps) => Array.prototype.reduce.call(temps,(a,b) => a+b);
                let VTemp_Durchschnitt = Number((Math.sum(...temps)/temps.length).toFixed(2));

                //let's do Gradtage...
                let MonatsTag, MonatsTag_old, Temp, Hit = [false,false,false,false,false,false,false];
                //Reset der Gradtage je nachdem ob Daten vorhanden oder nicht
                if (typeof result.result[0][0] !== "undefined") { Vwarme_Tage=0, VSommertage=0, Vheisse_Tage=0, VFrost_Tage=0, Vkalte_Tage=0, VEistage=0, Vsehr_kalte_Tage=0; }
                
                for (let i = 0; i < result.result[0].length; i++) {
                    MonatsTag = new Date(result.result[0][i].ts).getDate();
                    if (MonatsTag != MonatsTag_old) { Hit=[false,false,false,false,false,false,false]; }
                    Temp = result.result[0][i].value;
                     if (Temp > 20 && Hit[0] == false) { Vwarme_Tage++; Hit[0] = true; }
                     if (Temp > 25 && Hit[1] == false) { VSommertage++; Hit[1] = true; }
                     if (Temp > 30 && Hit[2] == false) { Vheisse_Tage++; Hit[2] = true; }
                     if (Temp < 0 && Hit[3] == false) { VFrost_Tage++; Hit[3] = true; }
                     if (Temp < 10 && Hit[4] == false) { Vkalte_Tage++; Hit[4] = true; }
                     if (Temp < 0 && Hit[5] == false) { VEistage++; Hit[5] = true; }
                     if (Temp < -10 && Hit[6] == false) { Vsehr_kalte_Tage++; Hit[6] = true; }
                    MonatsTag_old=MonatsTag; 
                } 

                //Wind
                let VMax_Windboe = Math.max(...wind);

                //Regen
                let VMax_Regenmenge = Math.max(...regen);
                let VRegenmenge_Monat=0, Rain = [];
                for (let i = 0; i < result.result[2].length; i++) {
                    MonatsTag = new Date(result.result[2][i].ts).getDate();
                    Rain[i] = result.result[2][i].value;
                    if (MonatsTag != MonatsTag_old) {
                        VRegenmenge_Monat+= Math.max(...Rain);
                        Rain.length=0; }
                    MonatsTag_old=MonatsTag; 
                }
                if (typeof result.result[0][0] === "undefined") { VRegenmenge_Monat=99999; } //keine Daten vom Vorjahresmonat

                //DPs schreiben
                setState(PRE_DP+'.Vorjahres_Monat.Tiefstwert', VTiefstwert, true);
                setState(PRE_DP+'.Vorjahres_Monat.Hoechstwert', VHoechstwert, true);
                setState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt', VTemp_Durchschnitt, true);
                setState(PRE_DP+'.Vorjahres_Monat.Max_Windboe', VMax_Windboe, true);
                setState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge', VMax_Regenmenge, true);
                setState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat', VRegenmenge_Monat, true);
                setState(PRE_DP+'.Vorjahres_Monat.warme_Tage', Vwarme_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Sommertage', VSommertage, true);
                setState(PRE_DP+'.Vorjahres_Monat.heisse_Tage', Vheisse_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Frost_Tage', VFrost_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.kalte_Tage', Vkalte_Tage, true);
                setState(PRE_DP+'.Vorjahres_Monat.Eistage', VEistage, true);
                setState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage', Vsehr_kalte_Tage, true);

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

//Datenpunkte anlegen
async function createDP(DP_Check) {
    console.log(PRE_DP + '.' + DP_Check + ' existiert nicht... Lege Datenstruktur an...');
    createState(PRE_DP, '', { name: 'Wetterstatistik' });
    createState(PRE_DP+'.aktueller_Monat',                        '',   { name: 'Statistik für den aktuellen Monat' });
    createState(PRE_DP+'.Vorjahres_Monat',                        '',   { name: 'Statistik für den Monat des Vorjahres' });
    createState(PRE_DP+'.Data',                                   '',   { name: 'bisherige Statistiken' });
    createState(PRE_DP+'.VorTag',                                 '',   { name: 'Werte von Gestern' });
    createState(PRE_DP+'.Control',                                '',   { name: 'Einstellungen, Meldungen'});
    createState(PRE_DP+'.Jahreswerte',                            '',   { name: 'Jahresstatistik'});
    
    createState(PRE_DP+'.aktueller_Monat.Tiefstwert',             100,  { name: "niedrigste Temperatur",                       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Hoechstwert',            -100, { name: "höchste Temperatur",                          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Temperatur_Durchschnitt',0,    { name: "Durchschnittstemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.aktueller_Monat.Max_Windboe',            0,    { name: "stärkste Windböe",                            type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.aktueller_Monat.Max_Regenmenge',         0,    { name: "maximale Regenmenge pro Tag",                 type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.aktueller_Monat.Regenmenge_Monat',       0,    { name: "Regenmenge im Monat",                         type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.aktueller_Monat.warme_Tage',             0,    { name: "Tage mit einer Temperatur über 20°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Sommertage',             0,    { name: "Tage mit einer Temperatur über 25°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.heisse_Tage',            0,    { name: "Tage mit einer Temperatur über 30°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Frost_Tage',             0,    { name: "Tage mit einer Mindesttemperatur unter 0°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.kalte_Tage',             0,    { name: "Tage mit einer Höchsttemperatur unter 10°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.Eistage',                0,    { name: "Tage mit einer Höchsttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.aktueller_Monat.sehr_kalte_Tage',        0,    { name: "Tage mit einer Mindesttemperatur unter -10°", type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.Vorjahres_Monat.Tiefstwert',             99999, { name: "niedrigste Temperatur",                       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Hoechstwert',            99999, { name: "höchste Temperatur",                          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Temperatur_Durchschnitt',99999, { name: "Durchschnittstemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Vorjahres_Monat.Max_Windboe',            99999, { name: "stärkste Windböe",                            type: "number", role: "state", unit: "km/h" });
    createState(PRE_DP+'.Vorjahres_Monat.Max_Regenmenge',         99999, { name: "maximale Regenmenge pro Tag",                 type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Vorjahres_Monat.Regenmenge_Monat',       99999, { name: "Regenmenge im Monat",                         type: "number", role: "state", unit: "l/m²" });
    createState(PRE_DP+'.Vorjahres_Monat.warme_Tage',             99999, { name: "Tage mit einer Temperatur über 20°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Sommertage',             99999, { name: "Tage mit einer Temperatur über 25°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.heisse_Tage',            99999, { name: "Tage mit einer Temperatur über 30°",          type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Frost_Tage',             99999, { name: "Tage mit einer Mindesttemperatur unter 0°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.kalte_Tage',             99999, { name: "Tage mit einer Höchsttemperatur unter 10°",   type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.Eistage',                99999, { name: "Tage mit einer Höchsttemperatur unter 0°",    type: "number", role: "state", unit: "Tage" });
    createState(PRE_DP+'.Vorjahres_Monat.sehr_kalte_Tage',        99999, { name: "Tage mit einer Mindesttemperatur unter -10°", type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.VorTag.Temperatur_Tiefstwert',           99999, { name: "niedrigste Tagestemperatur",                  type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.VorTag.Temperatur_Hoechstwert',          99999, { name: "höchste Tagestemperatur",                     type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.VorTag.Temperatur_Durchschnitt',         99999, { name: "Durchschnittstemperatur",                     type: "number", role: "state", unit: "°C" });
    
    createState(PRE_DP+'.Jahreswerte.Temperatur_Hoechstwert',     -100,  { name: "höchste Tagestemperatur des Jahres",          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Temperatur_Tiefstwert',      100,   { name: "niedrigste Tagestemperatur des Jahres",       type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Temperatur_Durchschnitt',    0,     { name: "Durchschnittstemperatur des Jahres",          type: "number", role: "state", unit: "°C" });
    createState(PRE_DP+'.Jahreswerte.Trockenperiode',             0,     { name: "längste Periode ohne Regen",                  type: "number", role: "state", unit: "Tage" });

    createState(PRE_DP+'.Control.Statusmeldung',                  '',    { name: "Statusmeldungen",                             type: "string", role: "state"});
    createState(PRE_DP+'.Control.Reset_Jahresstatistik',          false, { name: "Jahresstatistik zurücksetzen",                type: "boolean",role: "state"});
    createState(PRE_DP+'.Control.AutoDelete_Data',                0,     { name: "Data bereinigen? [0 = nie, 1...n = nach x Monaten]",  type: "number", role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion',                  '',    { name: "aktuelle Versionsnummer des Statistik-Skriptes",type: "string",role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion_Update',           '',    { name: "neue Version des Statistik-Skriptes vorhanden",type: "string",role: "state"});
    createState(PRE_DP+'.Control.ScriptVersion_UpdateCheck',      '',    { name: "Skript-Updatecheck ein-/ausschalten",         type: "boolean",role: "state"});
    await Sleep(5000);
}

function check_update() {
    const util = require('util')
    const request = util.promisify(require('request'))
   
    request('https://github.com/SBorg2014/WLAN-Wetterstation/commits/master/wetterstation-statistik.js')
    .then((response) => {

     //console.error(`status code: ${response && response.statusCode}`)
     //console.log(response.body) /<a aria-label="V.*[\r\n]+.*<\/a>/

     let regex = /<a aria-label="V.*[\r\n]+.*/
     , version = response.body.match(regex);

     if (version[0].match(ScriptVersion)) { 
         setState(PRE_DP+'.Control.ScriptVersion_Update','---',true); 
     } else {
         setState(PRE_DP+'.Control.ScriptVersion_Update','https://github.com/SBorg2014/WLAN-Wetterstation/blob/master/wetterstation-statistik.js',true);
         console.log('neue Script-Version verfügbar...');
     }

    })
        .catch((error) => {
        console.error(`error: ${error}`)
    })
} // end function
