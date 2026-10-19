class_name Catalog
extends RefCounted

const RESOURCES = {"nuts":"Muttern", "screws":"Schrauben", "wood":"Holz", "boards":"Bretter", "dry":"Trockenholz", "furniture":"Möbel", "sawdust":"Sägespäne", "walls":"Wandmodule", "roofs":"Dachmodule", "parts":"Bauelemente", "pellets":"Pellets", "paper":"Papier", "design":"Designmöbel"}
const PRICES = {"nuts":8.0,"screws":6.0,"wood":2.0,"boards":6.0,"dry":15.0,"furniture":65.0,"sawdust":0.5,"walls":160.0,"roofs":220.0,"parts":110.0,"pellets":14.0,"paper":26.0,"design":480.0}
const BUILDINGS = {
 "station":{"name":"Sammelstation","cost":150,"max":50,"color":"dbb579","desc":"Liefert das Holz der Helfer an die Betriebe."},
 "sawmill":{"name":"Sägewerk","cost":250,"max":100,"color":"278fa9","desc":"2 Holz → 1 Brett + 1 Sägespäne"},
 "kiln":{"name":"Trockenkammer","cost":500,"max":50,"color":"d9844f","desc":"2 Bretter → 1 Trockenholz"},
 "furniture":{"name":"Möbelfabrik","cost":900,"max":100,"color":"428dc2","desc":"2 Trockenholz + 1 Brett → 1 Möbel"},
 "warehouse":{"name":"Lagerhaus","cost":350,"max":50,"color":"e8b646","desc":"Vergrößert die Kapazität aller Materialpuffer."},
 "cabin":{"name":"Arbeiterhütte","cost":200,"max":25,"color":"f07e53","desc":"Wohnraum für jeweils fünf zusätzliche Helfer."},
 "market":{"name":"Verkaufsstelle","cost":450,"max":50,"color":"f1a33e","desc":"Mehr automatische Möbel-Exporte pro Lieferung."},
 "research":{"name":"Forschungszentrum","cost":1800,"max":25,"color":"4b9fcb","desc":"Ermöglicht Forschung für Produktion, Loot und Bauwirtschaft."},
 "garage":{"name":"Vehicle Garage","cost":1400,"max":25,"color":"4fae8a","desc":"Jede Stufe schafft Platz für zwei zusätzliche LKWs."},
 "prefab":{"name":"Fertighauswerk","cost":3500,"max":25,"color":"76a6a4","desc":"4 Trockenholz + 2 Bretter → Wand- und Dachmodul"},
 "joinery":{"name":"Bauelemente-Tischlerei","cost":4200,"max":25,"color":"c896bd","desc":"3 Bretter + 1 Trockenholz → 2 Bauelemente"},
 "pellet":{"name":"Pelletwerk","cost":2700,"max":25,"color":"a5aa6e","desc":"5 Sägespäne → 3 Pellets"},
 "paper":{"name":"Papierfabrik","cost":6000,"max":25,"color":"76b7bc","desc":"3 Holz + 3 Sägespäne → 2 Papier"},
 "design":{"name":"Design-Manufaktur","cost":12000,"max":25,"color":"ac92d2","desc":"2 Möbel + 2 Papier + 1 Bauelement → Designmöbel"}}
const RECIPES = {
 "sawmill":{"in":{"wood":2.0},"out":{"boards":1.0,"sawdust":1.0},"speed":0.9,"overflow_sell":["sawdust"]},
 "kiln":{"in":{"boards":2.0},"out":{"dry":1.0},"speed":0.42},
 "furniture":{"in":{"dry":2.0,"boards":1.0},"out":{"furniture":1.0},"speed":0.2},
 "prefab":{"in":{"dry":4.0,"boards":2.0},"out":{"walls":1.0,"roofs":1.0},"speed":0.06},
 "joinery":{"in":{"boards":3.0,"dry":1.0},"out":{"parts":2.0},"speed":0.1},
 "pellet":{"in":{"sawdust":5.0},"out":{"pellets":3.0},"speed":0.3},
 "paper":{"in":{"wood":3.0,"sawdust":3.0},"out":{"paper":2.0},"speed":0.2},
 "design":{"in":{"furniture":2.0,"paper":2.0,"parts":1.0},"out":{"design":1.0},"speed":0.04}}
const HOMES = {
 "police":{"name":"Polizeiwache","cost":9000,"materials":{"walls":9.0,"roofs":5.0,"parts":6.0},"rent":0.0,"people":0,"color":"659fbd"},
 "taxi":{"name":"Taxizentrale","cost":6500,"materials":{"walls":6.0,"roofs":3.0,"parts":4.0},"rent":0.0,"people":0,"color":"e7ba62"},
 "house":{"name":"Holzhaus","cost":1200,"materials":{"walls":3.0,"roofs":2.0,"furniture":2.0},"rent":2.0,"people":4,"color":"d99066"},
 "shop":{"name":"Quartiersladen","cost":2600,"materials":{"walls":5.0,"roofs":3.0,"parts":3.0},"rent":4.0,"people":2,"color":"e4b66b"},
 "apartments":{"name":"Wohnhaus","cost":5500,"materials":{"walls":9.0,"roofs":4.0,"parts":6.0,"furniture":6.0},"rent":8.0,"people":14,"color":"87a5be"},
 "villa":{"name":"Waldvilla","cost":13000,"materials":{"walls":12.0,"roofs":6.0,"design":2.0},"rent":17.0,"people":6,"color":"e5d4a4"},
 "hotel":{"name":"Stadthotel","cost":24000,"materials":{"walls":18.0,"roofs":8.0,"design":6.0,"paper":12.0},"rent":32.0,"people":25,"color":"b691b7"},
 "office":{"name":"Bürohaus","cost":40000,"materials":{"walls":24.0,"roofs":10.0,"parts":15.0,"design":10.0},"rent":60.0,"people":32,"color":"77aeb2"},
 "park":{"name":"Quartierspark","cost":2000,"materials":{"boards":20.0,"parts":2.0},"rent":0.0,"people":0,"color":"8bb86e"},
 "school":{"name":"Berufsschule","cost":7000,"materials":{"walls":8.0,"roofs":4.0,"furniture":8.0},"rent":0.0,"people":0,"color":"d5b86e"},
 "clinic":{"name":"Gesundheitszentrum","cost":9000,"materials":{"walls":10.0,"roofs":5.0,"parts":6.0},"rent":0.0,"people":0,"color":"93c6b5"},
 "landhouse":{"name":"Landhaus","cost":4800,"materials":{"walls":6.0,"roofs":4.0,"furniture":4.0},"rent":6.0,"people":6,"color":"b5cc87"},
 "nightclub":{"name":"Nachtclub","cost":16000,"materials":{"walls":12.0,"roofs":5.0,"parts":8.0,"design":3.0},"rent":22.0,"people":8,"color":"9c80c9"},
 "fire":{"name":"Feuerwehr","cost":11000,"materials":{"walls":10.0,"roofs":6.0,"parts":8.0},"rent":0.0,"people":0,"color":"c96e5a"}}
const BIOMES = [
 {"name":"Starter-Wald","cost":0,"nuts":"Muttern", "screws":"Schrauben", "wood":"Holz","ground":"70d675","tree":"289f62"},
 {"name":"Eichenwald","cost":1500,"wood":"Eichenholz","ground":"c8ce68","tree":"6eae41"},
 {"name":"Bergwald","cost":6000,"wood":"Hartholz","ground":"7fcfa0","tree":"249877"},
 {"name":"Winterwald","cost":22000,"wood":"Frostholz","ground":"d3e7df","tree":"7eb8b0"},
 {"name":"Vulkanwald","cost":75000,"wood":"Glutholz","ground":"a58a80","tree":"ad685b"},
 {"name":"Kristallwald","cost":240000,"wood":"Kristall-Holz","ground":"b7b0d9","tree":"9b81ca"},
 {"name":"Mystischer Wald","cost":800000,"wood":"Mahagoni","ground":"94b2b7","tree":"607ca5"},
 {"name":"Titan-Wald","cost":2600000,"wood":"Titanholz","ground":"98a3b2","tree":"647b93"},
 {"name":"Goldhain","cost":9000000,"wood":"Legendäres Holz","ground":"d2bc7a","tree":"d0a54f"},
 {"name":"Prestige-Hain","cost":30000000,"wood":"Mythisches Holz","ground":"a9bfd5","tree":"a888ce"}]
const TOOLS = ["Rostige Axt","Holzaxt","Stahlaxt","Silberaxt","Goldaxt","Diamantaxt","Titan-Axt","Laser-Axt","Plasma-Axt","Ultimative Holzfräse","Mini-Forstmaschine","Holzharvester","Industrie-Harvester","Legendärer Bagger","Titan-Bagger"]
const RARITIES = ["Common","Uncommon","Rare","Epic","Legendary","Mythic"]
const VEHICLES = ["Handwagen","Schubkarre","Pickup","LKW","Schwertransporter","Forstmaschine","Holzharvester","Industrie-Harvester","Mega-Harvester","Titan-Bagger"]
const RESEARCH = {"production":"Serienfertigung","forestry":"Nachhaltige Forstwirtschaft","logistics":"Transportlogistik","loot":"Glücksforschung","construction":"Modulares Bauen"}
const PROJECTS = [
 {"name":"Wald-Ferienanlage","cost":8000.0,"materials":{"walls":8.0,"roofs":4.0,"furniture":8.0},"income":5.0,"position":Vector3(-176,0,-72)},
 {"name":"Panorama-Hotel","cost":18000.0,"materials":{"walls":15.0,"roofs":8.0,"design":4.0},"income":12.0,"position":Vector3(176,0,-72)},
 {"name":"Güterbahnhof","cost":40000.0,"materials":{"parts":30.0,"boards":100.0,"walls":20.0},"income":25.0,"position":Vector3(176,0,10)},
 {"name":"Handelshafen","cost":95000.0,"materials":{"walls":30.0,"roofs":15.0,"parts":40.0},"income":55.0,"position":Vector3(-176,0,90)},
 {"name":"Timber-Holzhochhaus","cost":220000.0,"materials":{"walls":60.0,"roofs":20.0,"design":30.0,"paper":100.0},"income":120.0,"position":Vector3(176,0,150)}]

static func number(value: float) -> String:
 if absf(value) >= 1e9: return "%.2f Mrd" % (value / 1e9)
 if absf(value) >= 1e6: return "%.2f Mio" % (value / 1e6)
 if absf(value) >= 1e3: return "%.1f Tsd" % (value / 1e3)
 return str(int(value))

static func industry_position(index: int) -> Vector3:
 return Vector3([-45,-21,21,45][index % 4],0, -43 + int(index / 4.0) * 32)

static func home_position(index: int) -> Vector3:
 if index>=12:
  var local = (index-12)%12
  var side = 1 if index<24 else -1
  return Vector3(side*[216,248,280][local%3],0,-112+int(local/3.0)*32)
 return Vector3([-45,-21,21,45][index % 4],0, 86 + int(index / 4.0) * 30)

static func biome_position(index: int) -> Vector3:
 return [Vector3(-140,0,-115),Vector3(-45,0,-115),Vector3(45,0,-115),Vector3(140,0,-115),Vector3(-140,0,-30),Vector3(140,0,-30),Vector3(-140,0,50),Vector3(140,0,50),Vector3(-140,0,130),Vector3(140,0,130)][index]


static func project_road_z(project: Dictionary) -> float:
 return snappedf(float(project.position.z)+16.0,4.0)
