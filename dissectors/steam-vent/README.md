# Steam (steam-vent) — messages Steam sur WebSocket

Dissecteur Wireshark en Lua du protocole réseau du client Steam transporté en
WebSocket (connexions aux serveurs CM) : type de message, drapeau protobuf,
en-tête `CMsgProtoBufHeader`, corps protobuf, messages `CMsgMulti` (avec
décompression) et messages imbriqués des game coordinators (`CMsgGCClient`)
(issue #379).

## Import

| | |
|---|---|
| Dépôt amont | https://codeberg.org/steam-vent/steam-vent (dépôt principal, déclaré dans `Cargo.toml`) ; copie GitHub citée par l'issue : https://github.com/Tracklock/steam-vent (commit `eb9f66ffdbe6728fe6c973a29bf83bedaa68c991`, fichier identique octet pour octet) |
| Commit importé | `b0e40109dd7a1b5101e1546ed27f62663dbe5c4b` du 28/06/2026 (dernier commit de `main`) ; dernier changement de `tools/wireshard-steam.lua` : `a5894b228cd786d62bab62fa1f99f1e13ff4bf17` du 23/08/2024 (Robin Appelman) |
| Licence amont | MIT — déclarée par `license = "MIT"` dans `Cargo.toml` (auteur : Robin Appelman) ; l'amont ne fournit pas de fichier de licence |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif des messages du client Steam (Wireshark dissèque WebSocket et protobuf, pas ce protocole) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier. Faute
de fichier de licence dans l'amont, il s'agit du texte MIT de référence SPDX
(https://spdx.org/licenses/MIT.html) ; le titulaire du droit d'auteur est
l'auteur déclaré dans `Cargo.toml`, Robin Appelman.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshard-steam.lua` | Protocoles `_steam` (post-dissecteur sur les charges WebSocket binaires), `steam` (message Steam) et `steam_multi` (`CMsgMulti`) ; enregistrement dans la table `protobuf_field` pour `CMsgGCClient.payload` |

Fichier repris tel quel (nom amont conservé, « wireshard » compris), en-tête de
provenance ajouté. Le reste du dépôt (bibliothèque Rust) est hors périmètre.

## Utilisation

1. Copier `src/wireshard-steam.lua` dans le dossier des plugins Lua de Wireshark.
2. Le dissecteur s'appuie sur le dissecteur protobuf de Wireshark : ajouter dans
   Préférences › Protocols › Protobuf le chemin des fichiers `.proto` Steam
   (dans l'amont : `tools/protobufs/`, non importé ici, ou les protobufs de
   SteamDatabase).
3. Déchiffrer le TLS de la connexion WebSocket (fichier de clés
   `SSLKEYLOGFILE`), sinon aucune charge WebSocket n'est visible.
4. Filtres : `steam`, `steam.messageType`.

## Limites constatées à l'import

- table `msg_type_protos` limitée à quatre identifiants de messages (`CMsgMulti`,
  `CMsgGCClient`, `CMsgClientGamesPlayed`) ; les autres corps protobuf sont
  disséqués sans type de message ;
- globales (`steam_outer_proto`, `multi_proto`, `steam_proto`, champs,
  `msg_type_protos`) ;
- `f_header_body_gc_type` est déclaré mais absent de `steam_proto.fields` ;
- le post-dissecteur appelle `f_opcode().value` sans vérifier que le paquet
  contient du WebSocket (erreur Lua possible sur les autres paquets) ;
  `multi_proto` suppose la présence de `message_body` ;
- utilise `bit32`, disponible selon la version de Lua embarquée par Wireshark ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
