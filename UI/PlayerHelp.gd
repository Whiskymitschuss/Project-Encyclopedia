extends RefCounted

# Help only navigates; opening it never advances jobs or changes inventory.
static func populate(hud: Control,tab: String) -> void:
 if tab=="privacy":
  privacy(hud)
  return
 hud.modal_title.text="HILFE & WARENFLUSS"
 var start=hud.card("Dein nächster Schritt","Die Kapitelanzeige oben führt zum nächsten Ziel. Benno erklärt dir die ersten Schritte; du kannst seine Anleitung später wieder aufnehmen.")
 hud.button(start,"ERSTE SCHRITTE MIT BENNO",func(): hud.open_menu("guide"))
 hud.button(start,"KAPITEL & RATHAUS",func(): hud.open_menu("journey"))
 var flow=hud.card("Vom Wald bis zur Baustelle","Biber fällen und pflanzen. Werke verarbeiten ihre Eingänge. Mit aktivem Zentrallager holen Lager-LKW fertige Waren ab und bringen fehlende Rohstoffe zu den Werken. Baustellen fordern Material an; das Bauteam kommt separat im Sprinter.")
 hud.button(flow,"LOGISTIKÜBERSICHT",func(): hud.open_menu("logistics"))
 var factory=hud.card("Ein Werk steht still?","Prüfe in dieser Reihenfolge: Ist das Werk fertig und nicht pausiert? Fehlt Material im Wareneingang? Ist sein Ausgang oder das Ziellager voll? Ist bereits eine Fahrt unterwegs? Ein hoher Gesamtbestand bedeutet nicht, dass die Ware schon im richtigen Werk liegt.")
 hud.button(factory,"WERKE & NACHSCHUB PRÜFEN",func(): hud.logistics_tab="factories";hud.open_menu("logistics"))
 hud.button(factory,"LAGERPLÄTZE ANSEHEN",func(): hud.open_menu("stock"))
 var waiting=hud.card("Warten auf freien LKW","Sieh unter Fahrten nach laufenden Transporten. Straßenanschluss, freie Ladeplätze und freie Lagerfächer müssen vorhanden sein. Mehr Fahrzeuge und Lagerausbau helfen bei dauerhaften Engpässen. „Nachschub prüfen“ im Betrieb fordert fehlende Eingänge an; es erzeugt keine Gratisware.")
 hud.button(waiting,"FAHRTEN ANSEHEN",func(): hud.logistics_tab="trips";hud.open_menu("logistics"))
 var building=hud.card("Eine Baustelle kommt nicht weiter?","Öffne ihre Materialliste. Fehlende Waren müssen erst produziert oder beschafft und dann geliefert werden. Prüfe zusätzlich Kleinteile, Straßenanschluss und das Bauteam. Fehlendes Material hält die nächste Bauphase an.")
 hud.button(building,"BAUSTELLEN PRÜFEN",func(): hud.logistics_tab="sites";hud.open_menu("logistics"))
 var forest=hud.card("Keine Bäume zum Fällen?","Das Teammenü zeigt erntebereite Bäume, Jungbäume und offene Pflanzstellen je Wald. Pflanzer sind während ihrer Mission keine Holzfäller. Neue Bäume wachsen erst nach dem Pflanzen; ein voller Abholvorrat kann das Fällen anhalten.")
 hud.button(forest,"TEAM & AUFFORSTUNG",func(): hud.open_menu("team"))
 var trouble=hud.card("Ruckeln oder lange Hänger","Wähle zunächst Standard oder Sparmodus. Unter Leistung stehen Bildzeiten und zuletzt erfasste lange Hänger. Für einen Fehlerbericht: Version, Ansicht und die Aktion vor dem Hänger ergänzen. Die Messung allein erklärt noch nicht jede Ursache.")
 hud.button(trouble,"LEISTUNG & HÄNGER",func(): hud.open_menu("performance"))
 hud.button(trouble,"TESTBERICHT ERSTELLEN",func(): hud.open_menu("alpha"))
 hud.button(hud.contents,"SPEICHERN & DATENSCHUTZ",func(): hud.open_menu("privacy"))

static func privacy(hud: Control) -> void:
 hud.modal_title.text="SPEICHERN & DATENSCHUTZ"
 hud.card("Dein Fortschritt bleibt auf diesem Gerät","Spielstand, Einstellungen und eine Sicherung des vorherigen gültigen Spielstands liegen im privaten App-Speicher. Es gibt derzeit kein Konto und keinen Cloud-Spielstand. Bis zu acht Stunden Abwesenheit werden beim Zurückkommen berechnet.")
 var save=hud.card("Speichern prüfen","Automatische Speicherungen laufen regelmäßig und beim Hintergrundwechsel. Warte auf die Erfolgsmeldung, wenn du manuell speicherst. Bei einem Fehler App-Daten behalten und einen Testbericht erstellen.")
 hud.dynamic_text(save,func(): return Store.status_text())
 hud.button(save,"JETZT SPEICHERN",func():
  if Game.queue_save(true):hud.show_notice("Speichern läuft im Hintergrund."))
 hud.card("Vor einem Gerätewechsel","Eine Deinstallation oder „App-Daten löschen“ kann deinen Fortschritt entfernen. Die lokale Backup-Datei schützt nicht vor Geräteverlust. Testupdates über die vorhandene App installieren. Ein automatischer geräteübergreifender Transfer ist derzeit nicht verfügbar.")
 hud.card("Keine automatische Übertragung","Diese Fassung hat keine Werbung, In-App-Käufe oder automatische Analytik. Leistungswerte bleiben lokal. Das Spiel fordert keinen Zugriff auf Kontakte, Standort, Kamera, Mikrofon oder gemeinsame Dateien an.")
 hud.card("Ein Bericht ist freiwillig","Der Testbericht enthält unter anderem Version, Gerätemodell, Betriebssystem, Spiel- und Leistungsangaben sowie deinen eigenen Text. „Sichern“ legt ihn nur im privaten App-Speicher ab. „Text kopieren“ kopiert ihn in die Zwischenablage. Erst wenn du ihn selbst in einer anderen App teilst, erhält jemand den Inhalt. Prüfe deinen Text vor dem Teilen.")
 hud.button(hud.contents,"ZUM TESTBERICHT",func(): hud.open_menu("alpha"))
 hud.button(hud.contents,"ZUR SPIELHILFE",func(): hud.open_menu("guide_help"))
