# WAMP sur WebSocket (gmerlino / mdslab)

Post-dissecteur Wireshark en Lua du protocole WAMP (Web Application Messaging
Protocol : RPC et publication/abonnement) transporté en WebSocket, avec les
sérialisations JSON et MessagePack, accompagné de son propre dissecteur
WebSocket en Lua (`WS`) : poignée de main HTTP, trames, démasquage de la
charge (issue #401).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/gmerlino/wamp-wireshark (les en-têtes citent aussi https://github.com/mdslab/wamp-wireshark) |
| Commit importé | `0f66906c08903e988bcfdbd182616b277ec65f48` du 20/08/2018 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE` et en-têtes de `ws-dissector.lua` et `ws_wampdissector.lua`, « Copyright (c) 2016-2017 Emanuele Munafo', Sebastiano Alberto D'Ali', Valentina Pagliuca, Giovanni Merlino ») ; exceptions : `json.lua` en CC-BY-3.0 (JSON.lua, © 2010-2016 Jeffrey Friedl) et `msgpack.lua` en MIT (lua-MessagePack 0.3.5, © 2012-2016 François Perrad), mentions dans les fichiers |
| Natif Wireshark 4.6.4 | Partiel — WebSocket natif (`websocket`), aucun dissecteur WAMP natif |

Textes complets des licences amont : `LICENSE.txt` (copie conforme du `LICENSE`
amont, MIT) et `LICENSE-CC-BY-3.0.txt` (texte de référence SPDX de la licence
Creative Commons Attribution 3.0 Unported, à laquelle renvoie `json.lua`). `msgpack.lua`
indique en fin de fichier être « licensed under the terms of the MIT/X11
license » (même texte MIT que `LICENSE.txt`, avec son propre titulaire).

## Fichiers

| Fichier | Licence | Rôle |
|---|---|---|
| `src/ws-dissector.lua` | MIT | Protocole `ws` (« WebSocket (WS) dissector ») sur TCP 80 : poignée de main, en-tête de trame, clé de masquage, charge démasquée (`websocket.mdec_pay`) |
| `src/ws_wampdissector.lua` | MIT | Post-dissecteur `wamp` : type de message (HELLO, WELCOME, PUBLISH, SUBSCRIBE, CALL, RESULT, REGISTER, INVOCATION, YIELD…), realm, session, requête, sujet, procédure, arguments ; JSON et MessagePack |
| `src/json.lua` | CC-BY-3.0 | Bibliothèque JSON en Lua pur de Jeffrey Friedl (version 20160916.19), chargée par `require("json")` |
| `src/msgpack.lua` | MIT | Bibliothèque lua-MessagePack de François Perrad (0.3.5), chargée par `require("msgpack")` |

Fichiers repris tels quels, en-tête de provenance ajouté (pour `json.lua`, la
notice de copyright, les liens et `AUTHOR_NOTE` exigés par l'auteur sont
conservés). Non importés : les clients Python d'exemple (`clients/`) et les
captures (`traces/`, 584 Ko).

## Utilisation

1. Copier les quatre fichiers de `src/` dans le dossier des plugins Lua de
   Wireshark, sans les renommer (`json.lua` et `msgpack.lua` doivent être
   trouvables par `require`).
2. Dans « Analyse › Protocoles activés », désactiver `WEBSOCKET` (natif) et
   activer `WS` et `WAMP`.
3. Si le serveur WAMP n'est pas sur le port 80, « Décoder comme… › WS » sur le
   port TCP concerné (8080 dans les captures de l'amont). Filtre : `wamp`.

## Limites constatées à l'import

- testé par l'amont sous Wireshark 2.2.1 et Lua 5.2 ;
- remplace le dissecteur WebSocket natif, à désactiver ; les champs du `WS`
  Lua utilisent le préfixe `websocket.` du dissecteur natif (`websocket.rsv1`,
  `websocket.key`…) ; pas de nom identique à un champ natif de 4.6.4
  (comparaison avec `packet-websocket.c`), mais le mélange gêne le filtrage ;
- `require("json")` / `require("msgpack")` dépendent du `package.path` de
  Wireshark : selon la version et l'installation, le dossier des plugins n'y
  figure pas forcément ;
- `json.lua` et `msgpack.lua`, placés dans le dossier des plugins, sont aussi
  chargés comme greffons (sans effet, ils ne déclarent pas de protocole) ;
- sérialisation CBOR non prise en charge (une capture CBOR figure pourtant
  dans l'amont) ; utilise `bit32` ; globales (`json`, `msgpack`,
  `getdifference_offset`…) ;
- captures d'exemple non importées : syntaxe vérifiée avec `luac5.4 -p`, pas
  de dissection testée.
