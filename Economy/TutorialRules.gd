class_name TutorialRules
extends RefCounted

static func initial() -> Dictionary:
 return {"version":1,"active":false,"paused":false,"start_trees":0,"job":-1,"finished":false}

static func can_resume(state: Dictionary) -> bool:
 var data=state.get("onboarding",{})
 return int(state.tutorial)<5 or int(data.get("job",-1))>=0 and not data.get("finished",false)

static func phase(state: Dictionary) -> String:
 var data=state.get("onboarding",{})
 if not data.get("active",false): return ""
 match int(state.tutorial):
  1: return "chop"
  2: return "deposit"
  3: return "boards" if float(state.resources.boards)<1 else "sell"
  4: return "build"
 if int(data.get("job",-1))>=0:
  for job in state.jobs:
   if int(job.get("id",-2))==int(data.job): return "construction"
 return "done" if data.get("finished",false) else "build"

static func info(state: Dictionary) -> Dictionary:
 var p=phase(state)
 var count=clampi(int(state.trees)-int(state.get("onboarding",{}).get("start_trees",0)),0,5)
 var entries={
 "chop":[1,"Hi, ich bin Benno!","Tippe unten auf Fällen. Fünf Bäume reichen für deinen ersten kleinen Auftrag.","WALD ANSEHEN",count,5],
 "deposit":[2,"Dein Holz kommt ins Lager","Tippe unten auf Abliefern. Dein Helfer und das Sägewerk kümmern sich dann um die ersten Bretter.","ZUM HOLZLAGER",0,1],
 "boards":[3,"Aus Holz wird mehr","Das Sägewerk verarbeitet dein Holz automatisch. Schau zu, wie die ersten Bretter entstehen.","SÄGEWERK ANSEHEN",minf(1,float(state.resources.boards)),1],
 "sell":[3,"Deine ersten Münzen","Öffne den Verkauf und verkaufe einen Teil deiner Bretter. Jede verkaufte Ware wird wirklich bezahlt.","ZUM VERKAUF",0,1],
 "build":[4,"Hier wächst deine Firma","Platziere deine erste Arbeiterhütte. Du kannst sie verschieben und drehen. Bezahlt wird erst beim Bestätigen.","HÜTTE PLATZIEREN",0,1],
 "construction":[5,"Dein erster Bau entsteht","Dein Auftrag ist bezahlt. Schau deinem Bauteam zu — in Kürze gehört das neue Gebäude zu deiner Firma.","BAUSTELLE ANSEHEN",0,1],
 "done":[5,"Das ist dein Anfang!","Du hast Holz verarbeitet, Münzen verdient und deine Firma erweitert. Jetzt wartet dein eigenes Rathaus auf dich.","MEINE NÄCHSTEN ZIELE",1,1]}
 if not entries.has(p): return {}
 var entry=entries[p]
 return {"phase":p,"step":entry[0],"title":entry[1],"text":entry[2],"action":entry[3],"value":entry[4],"target":entry[5]}
