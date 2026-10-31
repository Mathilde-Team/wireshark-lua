# XBDM (Xbox Debug Manager)

Dissecteur Wireshark Lua des conversations Xbox Debug Manager (XBDM) entre un
ordinateur et un kit de développement Microsoft Xbox original : requêtes et
réponses du débogueur, flux de notifications (issue #319).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/abaire/wireshark_xbdm_dissector |
| Commit importé | `882ce83498548f2bb2814f882e00b2ce470d66af` du 19/11/2025 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2025 Erik Abair ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur XBDM natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/xbdm_analyzer.lua` | Protocoles `XBDM` (TCP 731 et 1731, tunnel de développement) et `XBDM-Notification` : expéditeur (XBDM ou XBOX), requêtes et réponses suivies par flux TCP, enregistrement dynamique des ports de notification annoncés par `notifyat port=…` |

Le fichier est repris tel quel, en-tête de provenance ajouté. Le README et le
`.gitignore` amont ne sont pas importés.

## Utilisation

Copier `src/xbdm_analyzer.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtres : `xbdm`, `xbdm-notification`.

## Limites constatées à l'import

- version 0.1 selon `set_plugin_info` ;
- IPv4 seulement : le dissecteur lit `ip.src`/`ip.dst` et s'arrête si ces
  champs sont absents (trafic IPv6 ignoré) ;
- les segments partiels sont ignorés (pas de réassemblage TCP) ;
- les ports de notification enregistrés ne sont jamais retirés de la table
  `tcp.port` (TODO amont) ;
- `print(...)` à chaque paquet hors ports connus : sortie console abondante ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
