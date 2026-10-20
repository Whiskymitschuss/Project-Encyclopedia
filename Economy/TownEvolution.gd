class_name TownEvolution
extends RefCounted

# Save IDs and economic coefficients stay stable. Only completed levels choose
# an architectural stage; an unfinished upgrade never changes the real model.
const NAMES={
 "townhall":["Waldbüro","Gemeindebüro","Gemeindehaus","Kleines Rathaus","Rathaus","Stadtrathaus","Großes Rathaus","Stadtverwaltung","Metropol-Rathaus","Timber-Stadtpalais"],
 "house":["Holzhütte","Holzhaus","Familienhaus","Stadthaus","Doppelhaus","Reihenhaus","Mehrfamilienhaus","Stadtresidenz","Wohnensemble","Waldstadt-Residenz"],
 "landhouse":["Landhütte","Landhaus","Gutshaus","Landvilla","Hofresidenz","Landgut","Herrenhaus","Gutsanlage","Landpalais","Großes Waldgut"],
 "apartments":["Kleines Wohnhaus","Mietshaus","Wohnblock","Stadthaus-Ensemble","Wohnquartier","Terrassenhaus","Wohnturm","Hochhaus","Wohnhochhaus","Skyline-Wohnturm"],
 "hotel":["Waldpension","Gasthof","Landhotel","Stadthotel","Komforthotel","Grand Hotel","Parkhotel","Luxushotel","Hotelresort","Grand Timber Resort"],
 "office":["Bürohaus","Kontor","Verwaltungshaus","Geschäftshaus","Bürozentrum","Firmenzentrale","Verwaltungsturm","Business Tower","Konzernzentrale","Timber Tower"],
 "fire":["Freiwillige Feuerwache","Ortsfeuerwache","Feuerwache","Stadtfeuerwache","Berufsfeuerwache","Große Feuerwache","Bezirksfeuerwache","Rettungszentrum","Hauptfeuerwache","Zentrale Hauptfeuerwache"],
 "clinic":["Rettungsstation","Sanitätsstation","Arztpraxis","Gesundheitsstation","Gesundheitszentrum","Tagesklinik","Stadtklinik","Krankenhaus","Zentralkrankenhaus","Universitätsklinikum"],
 "police":["Polizeiposten","Ortswache","Polizeiwache","Stadtwache","Polizeirevier","Bezirksrevier","Polizeizentrale","Polizeipräsidium","Hauptpräsidium","Zentrales Polizeipräsidium"],
 "taxi":["Taxistand","Taxibüro","Taxizentrale","Fahrdiensthof","Mobilitätsstützpunkt","Mobilitätszentrum","Großes Taxidepot","Stadtmobilitätszentrum","Verkehrszentrale","Metropol-Mobilitätszentrum"],
 "shop":["Kiosk","Dorfladen","Quartiersladen","Markthaus","Kaufhaus","Stadtmarkt","Handelshaus","Einkaufszentrum","Marktgalerie","Timber Handelsgalerie"],
 "villa":["Waldvilla","Gartenvilla","Komfortvilla","Poolvilla","Parkvilla","Luxusvilla","Designerresidenz","Panoramavilla","Palais","Waldpalais"],
 "school":["Dorfschule","Grundschule","Stadtschule","Berufsschule","Bildungszentrum","Berufskolleg","Technische Schule","Fachhochschule","Hochschule","Timber Campus"],
 "nightclub":["Musikbar","Waldbar","Tanzlokal","Nachtclub","Musikclub","Stadtclub","Konzerthaus","Eventzentrum","Festivalhaus","Timber Entertainment Palace"],
 "park":["Nachbarschaftsgarten","Kleiner Park","Quartierspark","Brunnenpark","Stadtgarten","Rosengarten","Skulpturenpark","Großer Stadtpark","Botanischer Garten","Timber Schlosspark"]}

static func title(kind: String,level: int) -> String:
 var names=NAMES.get(kind,[Catalog.HOMES.get(kind,{"name":kind}).name])
 return str(names[clampi(level-1,0,names.size()-1)])

static func floors(kind: String,level: int) -> int:
 match kind:
  "apartments": return 1+level
  "office": return 1+level
  "hotel": return 1+int(ceilf(level*0.6))
  "clinic","townhall": return 1+int(level/2.0)
  "school","shop","nightclub": return 1+int(level/3.0)
  "fire","police","taxi": return 1+int(level/2.0)
  "house","landhouse","villa": return 1+int((level-1)/3.0)
  _: return 1+int(level/4.0)

static func description(kind: String,level: int) -> String:
 var n=clampi(level,1,10)
 if kind=="townhall": return "%s · Architektur %s/10: Verwaltungsetagen, Uhrturm, Seitenflügel und ein wachsender Rathausvorplatz" % [title(kind,n),n]
 var feature={"apartments":"mehr Wohnungen, Balkone und eine wachsende Turmsilhouette","hotel":"Gästezimmer, Ankunftsbereich und gestaffelte Hotelflügel","fire":"zusätzliche Fahrzeugtore, Leitstelle und Schlauchturm","clinic":"Behandlungsflügel, Rettungszufahrt und Klinikbetten","school":"Klassenräume, Fachtrakte und Campusflächen","park":"Wege, Baumgruppen, Sitzplätze und Gartenarchitektur","taxi":"Fahrzeugplätze, Disposition und Servicehalle","police":"Revierbüros, Fahrzeughof und Einsatzzentrale","shop":"Verkaufsflächen, Schaufenster und Einkaufsgalerien","villa":"Terrassen, Garten und gestaffelte Wohnflügel","landhouse":"Veranda, Wirtschaftsflügel und Gutshaus","house":"Wohnraum, Veranda und zusätzliche Hausflügel","office":"Büroetagen, Glasfassade und Konzernzentrale","nightclub":"Bühnenräume, Lichtfassade und Veranstaltungsflächen"}.get(kind,"")
 return "%s · Architektur %s/10: %s" % [title(kind,n),n,feature]
