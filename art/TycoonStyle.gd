class_name TycoonStyle
extends RefCounted

# Shared semantic palette. No material or presentation choice owns simulation.
const VERSION=2816
const TIMBER=Color("cb954f")
const TIMBER_DARK=Color("885b36")
const CREAM=Color("f4e6cb")
const TEAL=Color("278f98")
const BLUE=Color("398ed1")
const COPPER=Color("d97843")
const GOLD=Color("efbd51")
const STEEL=Color("a6b8b5")
const DARK=Color("354c54")
const CONCRETE=Color("c3bfb1")
const GRASS=Color("7eae6b")
const SAND=Color("dbc59f")
const ASPHALT=Color("405761")
const PAPER=Color("fff3df")

static func family(kind: String) -> Color:
 if kind in ["sawmill","station","paper","pellet"]: return TEAL
 if kind in ["central_depot","warehouse","express","garage"]: return BLUE if kind!="express" else GOLD
 if kind=="design": return Color("9d79af")
 if kind in ["quarry","stoneworks"]: return Color("c89c59")
 return COPPER

# Explicit old paint aliases; signal red/green, biome colours and emissions
# are deliberately not quantized by hue or saturation.
static func paint(color: Color) -> Color:
 if color.a<0.999: return color
 var hex=color.to_html(false)
 if hex in ["b67a42","bd874d","d59b53","c99459","dda155","da9953"]: return TIMBER
 if hex in ["415a6d","415b70","476775","34434a","34484b"]: return DARK
 if hex in ["a7bec2","9bb9bd","9eafb1","b5c1ae"]: return STEEL
 if hex in ["fff0cf","fff0d2","fff5df","eee0bf","e8d9b9"]: return CREAM
 if hex in ["368dd2","328dd2","338fd6"]: return BLUE
 if hex=="328db8": return TEAL
 if hex in ["eabf57","f5bd49","efad31"]: return GOLD
 return color
