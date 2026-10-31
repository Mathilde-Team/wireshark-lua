# Socket.IO (ksmyth) — post-dissecteur des messages Socket.IO

Post-dissecteur Wireshark en Lua des messages Socket.IO transportés en
WebSocket texte : type de message (envoi / réponse), numéro de message,
charge utile (100 premiers caractères) et, pour les réponses, trame de la
requête d'origine et délai de réponse (issue #391).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ksmyth/wireshark-socket.io |
| Commit importé | `9220111a9a1a50b75c010fc0464a81d6d6076c74` du 11/05/2015 (dernier commit de `master`) |
| Licence amont | GPL-2.0-only (fichier `LICENSE`, GPL version 2 ; aucune mention « or later » dans le README ni d'en-tête de licence dans le fichier Lua) |
| Natif Wireshark 4.6.4 | Non — Wireshark dissèque WebSocket, mais pas la couche Socket.IO / Engine.IO |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/socketio_proto.lua` | Protocole `socketio` (post-dissecteur) ; champs `SocketIO.type`, `SocketIO.msgno`, `SocketIO.requestframe`, `SocketIO.reply_duration`, `SocketIO.payload`, `SocketIO.replay_payload` |

Fichier repris tel quel (fins de ligne CRLF de l'amont conservées), en-tête de
provenance ajouté.

## Utilisation

Copier `src/socketio_proto.lua` dans le dossier des plugins Lua de Wireshark,
puis sélectionner un paquet WebSocket portant un message Socket.IO. Colonnes
personnalisées suggérées par l'amont : `SocketIO.msgno`,
`SocketIO.reply_duration`.

## Limites constatées à l'import

- s'appuie sur le champ `websocket.payload.text` ; sa présence dans
  Wireshark 4.6.4 n'est pas vérifiée (si le champ n'existe pas,
  `Field.new` échoue au chargement) ;
- ne traite que les paquets Engine.IO de type « message » (`4`) suivis d'un
  type Socket.IO `2` ou `3` ; numérotation des messages propre à la version de
  Socket.IO de 2015 ;
- une réponse dont la requête n'est pas dans la capture provoque une erreur
  Lua (`messages[msgno]` nil, signalé en `TODO` par l'amont) ;
- variables globales (`tcp_stream`, `websocket_payload`, `socketio_proto`,
  champs) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
