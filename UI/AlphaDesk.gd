extends RefCounted
var hud
var report: TextEdit
var draft=""
var original=""

func populate() -> void:
 hud.modal_title.text="ALPHA · FEEDBACK"
 hud.text(hud.contents,"Installiert: %s" % ProjectSettings.get_setting("application/config/version"),14,hud.MUTED)
 # Keep the useful actions and editor above the longer test tips on small phones.
 var actions=hud.row(hud.contents)
 hud.button(actions,"Text kopieren",copy_report)
 hud.button(actions,"Sichern",save_report)
 var device={"os":OS.get_name(),"os_version":OS.get_version(),"model":OS.get_model_name(),"viewport":str(hud.get_viewport_rect().size)}
 var health=Store.load_status+(" · letzte Speicherung fehlgeschlagen" if not Game.last_save_ok else "")
 if draft.is_empty() and FileAccess.file_exists("user://Alpha-Testbericht.txt"): draft=FileAccess.get_file_as_string("user://Alpha-Testbericht.txt")
 report=TextEdit.new()
 report.text=AlphaReport.build(Game.state,device,health) if draft.is_empty() else draft
 if draft.is_empty() and not Game.performance_results.is_empty():
  var result=Game.performance_results
  report.text+="\nKamerarunde: %.1f FPS · P95 %.1f ms · %s · %.1f Sekunden\nWärme am Gerät: [bitte ergänzen]\n" % [result.fps,result.p95_ms,result.profile,result.seconds]
  if result.has("work"):
   report.text+="Version: %s · Zeichenaufrufe: %s\n%s\n" % [result.get("version",""),int(result.draw_calls),RuntimeStats.profile_summary(result.work)]
 if draft.is_empty(): report.text+="\nStart & Leistung:\n"+RuntimeStats.summary()+"\nWärme am Gerät: [bitte ergänzen]\n"
 original=report.text
 report.custom_minimum_size=Vector2(0,clampf(hud.size.y*0.15,96,180))
 report.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
 report.add_theme_font_size_override("font_size",roundi(14*(1.15 if Game.state.ux.large_text else 1.0)))
 hud.contents.add_child(report)
 hud.text(hud.contents,"Ergänze deinen Fehler oder deine Idee im Textfeld. Kopiere den Bericht dann in deine Nachricht an die Person, von der du die Alpha erhalten hast. Es wird nichts automatisch gesendet.",14,hud.MUTED)
 var box=hud.card("Schön, dass du mittestest!","Zehn bis zwanzig Minuten reichen für den ersten Eindruck. Sag uns auch, was Spaß macht oder noch unklar ist.")
 hud.text(box,"1  Intro und erste Schritte ausprobieren\n2  Gebäude setzen, drehen und verschieben\n3  Speichern, App schließen und wieder öffnen\n4  Später: Straßen, Export und Feuerwehr ansehen",14,hud.INK)
 hud.button(box,"ANLEITUNG & ERSTE SCHRITTE",func(): hud.open_menu("guide"))
 if TutorialRules.can_resume(Game.state) and not Game.state.onboarding.active:
  hud.button(box,"BENNO WIEDER EINBLENDEN",func(): Game.begin_tutorial(); hud.close_menu())
 hud.text(box,"Hafen und Flughafen sind geplant. Schiffs- und Flugexport sind in Alpha 1 noch nicht aktiv. Dein Fortschritt wird auf diesem Gerät gespeichert. Der Testbericht enthält keine Spielstanddatei und keine automatisch angehängten Kontaktdaten.",14,hud.INK)

func copy_report() -> void:
 if not is_instance_valid(report): return
 if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
  report.grab_focus()
  report.select_all()
  hud.show_notice("Bitte den markierten Text über die Textauswahl kopieren")
  return
 DisplayServer.clipboard_set(report.text)
 hud.show_notice("Testbericht kopiert · füge ihn in deine Nachricht ein")

func save_report() -> void:
 if not is_instance_valid(report): return
 var file=FileAccess.open("user://Alpha-Testbericht.txt",FileAccess.WRITE)
 if file==null: hud.show_notice("Bericht konnte nicht gespeichert werden"); return
 file.store_string(report.text)
 file.close()
 draft=report.text
 hud.show_notice("Testbericht im privaten App-Speicher gespeichert · hier wieder kopierbar")

func capture_draft() -> void:
 if is_instance_valid(report) and report.text!=original: draft=report.text
