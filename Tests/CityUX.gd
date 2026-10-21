extends SceneTree
var checks=0
var failures=[]
var game
func _initialize() -> void: call_deferred("run")
func check(ok: bool,detail: String) -> void:
 checks+=1
 if not ok: failures.append(detail); printerr("FAILED: ",detail)
func fresh() -> void:
 game.state=game.initial_state()
 game.state.tutorial=5
 game.state.construction_intro=true
 game.state.companion_enabled=false
 game.state.city_services.enabled=false
 game.state.workers=0
 game.state.coins=1000000
 game.state.company_xp=800
 game.tick_clock=0
func run() -> void:
 await process_frame
 game=root.get_node("Game")
 game.set_process(false)
 fresh()
 var city_models=load("res://Buildings/CityEvolution.gd")
 var container=Node3D.new()
 root.add_child(container)
 for kind in Catalog.HOMES:
  var signatures={}
  var names={}
  for level in range(1,11):
   var model=city_models.create(kind,level)
   container.add_child(model)
   check(model.get_meta("evolution_level")==level,"Completed architectural stage exists: %s %s" % [kind,level])
   check(TownEvolution.title(kind,level)==model.get_meta("stage_name"),"The model and interface use the same stage name")
   var signature=[]
   var inside=true
   for mesh in model.find_children("*","MeshInstance3D",true,false):
    for corner in 8:
     var point=model.to_local(mesh.global_transform*mesh.get_aabb().get_endpoint(corner))
     inside=inside and absf(point.x)<=9.51 and absf(point.z)<=11.51
    if mesh.mesh is ArrayMesh:
     for surface in mesh.mesh.get_surface_count(): signature.append(hash(mesh.mesh.surface_get_arrays(surface)))
   check(inside,"Every stage stays within its saved building parcel: %s %s" % [kind,level])
   var fingerprint=hash(signature)
   check(not signatures.has(fingerprint),"Each upgrade changes actual mesh geometry: %s %s" % [kind,level])
   check(not names.has(model.get_meta("stage_name")),"Each upgrade has an individual city stage name")
   signatures[fingerprint]=true
   names[model.get_meta("stage_name")]=true
   model.free()
 check(TownEvolution.floors("apartments",10)>=10 and "hochhaus" in TownEvolution.title("apartments",9).to_lower(),"Apartment progression reaches a real high-rise")
 check(TownEvolution.title("clinic",1)=="Rettungsstation" and TownEvolution.title("clinic",8)=="Krankenhaus","Medical architecture advances from rescue station to hospital")
 check("Hauptfeuerwache" in TownEvolution.title("fire",10) and "Resort" in TownEvolution.title("hotel",10),"Fire and hotel buildings reach their named major complexes")
 var bill=UXRules.upgrade_bill(game.state,false,1)
 check(bill.coins==game.cost_for("sawmill",2),"Contextual industrial upgrade uses the exact real economy price")
 game.state.prestige=3
 bill=UXRules.upgrade_bill(game.state,false,1)
 check(bill.coins==game.cost_for("sawmill",2),"Prestige affects the advertised and actual upgrade cost identically")
 fresh()
 var first=game.create_group(Vector3(-60,0,-58),Vector3(-8,0,-29),"Holzrevier")
 check(first>0 and UXRules.group_members(game.state,game.state.ux.groups[0]).size()==2,"An actual rectangular district selects only buildings inside its bounds")
 check(game.rename_group(first,"  Mein Sägeviertel  ") and game.state.ux.groups[0].name=="Mein Sägeviertel","District names are editable, trimmed and persisted")
 bill=UXRules.group_bill(game.state,game.state.ux.groups[0])
 var coins=float(game.state.coins)
 game.state.coins=float(bill.coins)-1
 var low=float(game.state.coins)
 check(not game.upgrade_group(first) and game.state.coins==low and game.state.jobs.is_empty(),"An unaffordable group purchase cannot partially charge or create jobs")
 game.state.coins=coins
 game.state.builders=1
 check(not game.upgrade_group(first,float(bill.coins)+1) and game.state.jobs.is_empty(),"A changed quote cannot silently charge a different district price")
 check(game.upgrade_group(first) and game.state.jobs.size()==2,"Confirmed group plan starts one real upgrade per eligible building")
 check(absf(coins-float(game.state.coins)-float(bill.coins))<0.000001,"The whole group is charged exactly its displayed total")
 check(not game.upgrade_group(first),"An already queued group cannot be charged twice")
 check(game.state.jobs[0].has("phases") and game.state.buildings[1].level==1,"Grouped upgrades still wait for real staged material deliveries")
 check(int(game.state.jobs[0].workers)==1 and int(game.state.jobs[1].workers)==0,"A group cannot invent extra crew while the first project is active")
 var pressure=game.state.duplicate(true)
 for pressure_job in pressure.jobs: pressure_job.materials.wood=5000.0
 check(ConstructionRules.reserved_materials(pressure,"wood")==game.capacity()*0.5,"Oversized district plans leave half of warehouse capacity available to feed production")
 for key in ["wood","boards","nuts","screws"]: game.state.resources[key]=100.0
 for i in 700:
  game.step(1)
  if game.state.jobs.is_empty(): break
 check(game.state.jobs.is_empty() and int(game.state.buildings[0].level)==2 and int(game.state.buildings[1].level)==2,"One real crew automatically moves on and completes all grouped staged upgrades")
 var before=game.state.duplicate(true)
 check(game.create_group(Vector3(140,0,110),Vector3(152,0,120))<0 and game.state==before,"Empty district selection neither creates fake members nor spends currency")
 fresh()
 game.state.buildings.append({"kind":"kiln","level":1,"paused":false,"position":[20,-12]})
 game.state.resources.dry=12
 var sources=UXRules.material_sources(game.state,"dry")
 var shared=false
 for source in sources:
  if source.kind=="kiln": shared=source.get("shared",false) and float(source.amount)==0
 check(shared,"A legacy producer does not pretend its shared warehouse goods are a second local stock")
 fresh()
 var path=TownRules.path(Vector2i(80,176),Vector2i(104,176))
 coins=game.state.coins
 check(game.build_road("asphalt",path),"Undo scenario first constructs and pays for a valid real road")
 check(game.state.coins<coins and game.state.ux.road_undo.size()==1,"Only paid newly built roads enter the bounded undo history")
 check(game.undo_road() and game.state.town.roads.is_empty() and game.state.coins==coins,"Undo removes the unused road and returns exactly its original cost")
 check(not game.undo_road() and game.state.coins==coins,"Repeated road undo cannot generate money")
 check(game.build_road("asphalt",path),"Road can be rebuilt after undo")
 game.state.delivery.shipments=[{"path":[[80,0,176],[84,0,176],[104,0,176]]}]
 check(not game.undo_road() and not game.state.town.roads.is_empty(),"Active saved cargo protects an otherwise undoable road")
 game.state.delivery.shipments.clear()
 check(game.undo_road(),"The road becomes undoable only when the active cargo has left")
 game.state.ux.vibration=true
 game.state.ux.large_text=true
 game.state.ux.high_contrast=true
 game.state.ux.motion=false
 game.create_group(Vector3(-60,0,-58),Vector3(-8,0,-29),"Gespeichert")
 UXRules.push_event(game.state,"test","Wirklich fertig",Vector3(-20,0,-43))
 var saved=JSON.parse_string(JSON.stringify(game.state,"",true,true))
 game.restore(saved)
 check(game.state.ux.vibration and game.state.ux.large_text and game.state.ux.high_contrast and not game.state.ux.motion,"All accessibility, sound-independent haptics and motion preferences survive actual JSON restoration")
 check(game.state.ux.groups[0].name=="Gespeichert" and game.state.ux.events.size()==1,"Districts and actual event history survive restoration")
 for i in 40: UXRules.push_event(game.state,"event:%s" % i,"Fertig",Vector3.ZERO)
 check(game.state.ux.events.size()==24,"Event history has a fixed maximum rather than growing forever")
 game.state.muted=true
 game.state.quality=0
 game.state.earned=game.prestige_requirement()
 game.state.unlocked=3
 check(game.prestige() and game.state.ux.vibration and game.state.ux.large_text and game.state.muted and game.state.quality==0,"Prestige preserves player accessibility, sound and battery preferences")
 check(game.state.ux.groups.is_empty() and game.state.ux.events.is_empty(),"Prestige cannot keep old district membership or stale city events in the new company")
 var legacy=game.state.duplicate(true)
 legacy.erase("ux")
 game.restore(legacy)
 check(game.state.ux.groups.is_empty() and not game.state.ux.vibration,"Legacy profiles receive safe optional UX defaults without invented groups")
 fresh()
 game.state.homes=[{"kind":"apartments","level":4,"plot":0,"position":[-44,84],"rent_bank":0.0}]
 bill=UXRules.upgrade_bill(game.state,true,0)
 coins=game.state.coins
 check(game.upgrade_home(0),"A real city upgrade can be ordered")
 check(absf(coins-float(game.state.coins)-float(bill.coins))<0.000001,"The named architectural upgrade is charged the displayed actual city price")
 check(int(game.state.homes[0].level)==4,"A paid blueprint does not prematurely change architecture")
 var pending=game.state.jobs[0]
 for key in pending.materials: pending.delivered[key]=float(pending.materials[key])
 for i in 90:
  game.step(1)
  if game.state.jobs.is_empty(): break
 check(game.state.homes[0].level==5 and game.state.ux.events.size()==1,"Actual upgrade completion records a persistent named city event before any UI exists")
 var scene=load("res://Scenes/Main.tscn").instantiate()
 root.add_child(scene)
 for i in 4: await process_frame
 var ui=scene.hud.ux
 ui.select_building(1)
 check(ui.sheet.visible and not scene.hud.overlay.visible,"A building opens a contextual bottom card while the world stays interactive")
 ui.open_material("boards")
 check(scene.hud.current=="material_help" and scene.hud.contents.get_child_count()>0,"Actual material sources are available in the working help interface")
 ui.select_building(0,true)
 ui.show_evolution("apartments",10)
 check(scene.hud.current=="evolution" and scene.hud.contents.get_child_count()>0,"All ten architecture stages are reachable in the actual rendered preview menu")
 for menu in ["overview","events","districts","district_unlock","biome_unlock"]:
  scene.hud.open_menu(menu)
  check(scene.hud.contents.get_child_count()>0,"Complete new UX menu is wired: "+menu)
 ui.open_palette()
 check(ui.palette.visible and not scene.hud.overlay.visible,"Primary building palette keeps the world visible")
 ui.palette_category="Stadt"
 ui.open_palette()
 var tiles=0
 for child in ui.carousel.get_children():
  if child is HBoxContainer: tiles=child.get_child_count()
 check(tiles==Catalog.HOMES.size(),"City palette contains every actual selectable city building")
 ui.hide_panels(true)
 fresh()
 game.state.builders=1
 var group=game.create_group(Vector3(-60,0,-58),Vector3(-8,0,-29),"Sichtbarer Teamwechsel")
 game.upgrade_group(group)
 var waiting=game.state.jobs[1]
 var first_job=game.state.jobs[0]
 for resource in first_job.materials: first_job.delivered[resource]=float(first_job.materials[resource])
 for i in 50:
  game.step(1)
  if game.state.buildings[0].level==2: break
 var crew_visible=false
 for site in scene.world_buildings.get_children():
  if site.get("job_id")==int(waiting.id):
   for worker in site.get_children():
    if worker.get("role")=="construction": crew_visible=true
 check(waiting.workers==1 and crew_visible,"Automatic crew handoff creates the actual visible worker at the next construction site")
 game.assign_builders(int(waiting.id),0)
 game.step(1)
 check(waiting.workers==0 and not waiting.auto_crew,"An explicit manual crew assignment takes precedence over the group scheduler")
 scene.queue_free()
 container.queue_free()
 await process_frame
 print("CITY UX: ",checks," checks, ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
