# Zenoh (kydos) — dissecteur Lua récent du protocole Zenoh

Dissecteur Wireshark en Lua du protocole Zenoh (pub/sub, requêtes, stockage
distribué) d'après la spécification de travail https://spec.zenoh.io :
messages de transport (INIT, OPEN, CLOSE, KEEP_ALIVE, FRAME, FRAGMENT, JOIN),
messages réseau (PUSH, DECLARE, REQUEST, RESPONSE, RESPONSE_FINAL, INTEREST),
sous-messages de données (PUT, DEL, QUERY, REPLY, ERR), déclarations, scouting
(SCOUT, HELLO), expressions de clés résolues, extensions ; corrélation
requête/réponse, détection de trous de séquence, statistiques. Les charges
utiles ne sont pas affichées par défaut (issue #398).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/kydos/zenoh-wireshark |
| Commit importé | `ad7d3813cd81345e7cb6ced7c1a1fa6e0ca7d21d` du 16/06/2026 (dernier commit de `main`) |
| Licence amont | GPL-3.0-only (fichier `LICENSE`, GPL version 3 ; aucune mention « or later » ni en-tête de licence dans `zenoh.lua`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Zenoh natif dans Wireshark (l'amont cite le greffon Rust séparé https://github.com/ZettaScaleLabs/zenoh-dissector) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/zenoh.lua` | Protocole `zenoh` (« Zenoh Protocol (Lua) ») sur TCP 7447, UDP 7446 (scouting), 7447 et 7448 ; heuristiques TCP et UDP ; préférences `show_payload` et `expert_unknown` ; tap de statistiques |
| `doc/index.md` | Guide d'utilisation amont (ports, messages, filtres, préférences, corrélation, statistiques) |
| `doc/display-filter-reference.md` | Référence amont des filtres d'affichage |

Fichiers repris tels quels, en-tête de provenance ajouté au fichier Lua. Non
importés : les captures d'exemple (`assets/`, 9,8 Mo, dont une de 10 Mo), le
script `tests/regression.sh` qui en dépend, et les fichiers de consignes pour
agents (`AGENTS.md`, `CLAUDE.md`).

## Utilisation

Copier `src/zenoh.lua` dans le dossier des plugins Lua personnels de Wireshark
(`~/.local/lib/wireshark/plugins/`, `%APPDATA%\Wireshark\plugins\` sous
Windows), puis redémarrer ou « Analyse › Recharger les plugins Lua ».
Filtres : `zenoh`, `zenoh.net.msg_id`, `zenoh.keyexpr`,
`zenoh.session.src_zid`… (voir `doc/display-filter-reference.md`).

## Limites constatées à l'import

- même nom de protocole `zenoh` (et même préfixe de champs `zenoh.`) que
  `dissectors/zenoh` (eclipse-zenoh, Zenoh < 0.10.0) : les deux greffons ne
  peuvent pas être chargés ensemble ; ce dissecteur-ci vise les versions
  récentes du protocole ;
- l'amont affirme coexister avec le greffon Rust de ZettaScaleLabs grâce à son
  nom d'affichage distinct ; non vérifié ici ;
- charges utiles masquées par défaut (préférence `show_payload`) ;
- captures d'exemple amont non importées : syntaxe vérifiée avec
  `luac5.4 -p`, pas de dissection testée ici.
