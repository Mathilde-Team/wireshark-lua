# Vert.x EventBus — échanges entre nœuds Vert.x en cluster

Dissecteur Wireshark en Lua du protocole EventBus de Vert.x en mode cluster
(TCP) : longueur, version du protocole filaire, codec, adresses d'envoi et de
réponse, en-têtes, corps selon le codec (types simples, buffer, JSON passé au
dissecteur `json` natif, exceptions de réponse), ping/pong (issue #416).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/noseka1/vertx-eventbus-wireshark-dissector |
| Commit importé | `d9a8ca40c79d5259a2c8e5b2729b8b871832c2f6` du 17/05/2020 (dernier commit de `master`) |
| Licence amont | En-tête du fichier : « This code is in the Public Domain, or the BSD (3 clause) license if Public Domain does not apply in your country » (« Copyright (c) 2019, Ales Nosek ») ; pas de fichier de licence dans le dépôt. Importé sous `BSD-3-Clause`, l'option valable partout |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Vert.x natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence : fichier `LICENSE.txt` de ce dossier (texte de
référence SPDX `BSD-3-Clause`, avec la mention de copyright de l'en-tête amont),
l'amont ne fournissant pas de fichier de licence.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/vertx_eventbus_dissector.lua` | Protocole `vertx_eventbus`, proposé dans « Décoder comme » pour `tcp.port` |

Fichier repris tel quel, en-tête de provenance ajouté. Non importés : capture
d'exemple `vertx_eventbus_sample_capture.pcapng`, captures d'écran, `README.md`.

## Utilisation

Copier `src/vertx_eventbus_dissector.lua` dans le dossier des plugins Lua de
Wireshark, puis « Décoder comme… » → `VERTX_EVENTBUS` sur le port TCP du cluster
Vert.x (aucun port n'est enregistré d'office). Filtre : `vertx_eventbus`.

## Limites constatées à l'import

- pas de réassemblage TCP : un message réparti sur plusieurs segments n'est
  pas reconstitué ;
- `debug_level = 1` : le script écrit des messages (`print`) à chaque
  chargement ;
- fonctions et variables globales (`dprint`, `read_*`, `body_read_*`,
  `decode_headers`, `item`, `status`, `json_dissector`…) ;
- pas de capture d'exemple dans ce dépôt (celle de l'amont n'est pas
  importée) : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée.
