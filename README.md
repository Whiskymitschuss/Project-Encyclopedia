# Timber Loot Tycoon — Wiederaufbau

Neuer, nachvollziehbar gesicherter Godot-4.6-Wiederaufbau nach Verlust des vorherigen Cloud-Arbeitsstands. Dies ist keine Wiederherstellung der früheren Dateien. Die Anforderungen und der Umfang stehen in `docs/DESIGN.md`.

## Sicherung

Jeder geprüfte Meilenstein erhält einen Git-Commit und wird nach `origin/main` übertragen. Ein lokaler Commit alleine ist keine externe Sicherung. `scripts/backup.py` erstellt zusätzlich ein Quellarchiv und ein vollständiges Git-Bundle außerhalb des Checkouts. Der externe Sicherungsstand wird durch erneutes Abrufen und Vergleich des Commit-Hashes geprüft.

Keine Zugangsdaten, privaten Signaturschlüssel, Spielstände oder Build-Caches gehören in Git.
