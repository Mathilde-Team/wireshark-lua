# FINAL FANTASY XIV (Minoost)

Dissecteur Wireshark Lua du protocole réseau de FINAL FANTASY XIV sur TCP :
en-tête de trame (signature, horodatage, longueur, type de connexion,
compression), décompression deflate et découpage des messages (entités source
et cible, type, opcode, données) (issue #344).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Minoost/ffxiv-wireshark (archivé, non maintenu selon son README) |
| Commit importé | `bf63d943b9940984fadd79fc6bb92aa5ae2f9557` du 17/12/2017 (dernier commit de `master`) |
| Licence amont | GPL-3.0-only (fichier `LICENSE` amont, texte de la GPLv3 ; README : « Licensed under the GPL3 », sans mention « or later ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur FFXIV natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

Autre dissecteur FFXIV suivi : zhyupe/FFXIV-Packet-Dissector (#259). L'auteur
renvoie aussi vers FFXIVMonReborn et ayyaruq/ffxiv-dissector.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ffxiv_dissector.lua` | Protocole `ffxiv` : heuristique TCP (signature de 16 octets en tête de trame) et port TCP 42424 ; trame de 40 octets d'en-tête, réassemblage par `desegment_len`, messages décompressés si besoin ; type de message (ClientWorld, ServerWorld, Game, Ping, Pong, ClientHandshake, ServerHandshake), opcode pour les messages de jeu (seul `0x142` ActorEvent est nommé), données brutes |

Le fichier est repris tel quel, en-tête de provenance ajouté. Le README et
`.editorconfig` amont ne sont pas importés.

## Utilisation

Copier `src/ffxiv_dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `ffxiv`.

## Limites constatées à l'import

- outil abandonné par son auteur (2017) : opcodes et format datant de cette
  époque, les versions actuelles du jeu ne sont probablement plus décodées ;
- `dissect_frame` ne renvoie aucune valeur après une trame complète : la
  comparaison `result > 0` de `ffxiv_proto.dissector` porte alors sur `nil` et
  lève une erreur Lua (la première trame est affichée, les suivantes du même
  segment ne le sont pas) ;
- l'heuristique compare deux objets `Tvb` avec `~=` : la signature risque de
  ne jamais être reconnue, seul le port 42424 restant actif ;
- `TvbRange:uncompress()` est l'ancienne API de décompression (remplacée par
  `uncompress_zlib` dans les versions récentes de Wireshark) ;
- fonctions globales (`dissect_frame`, `dissect_payload`,
  `check_frame_length`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
