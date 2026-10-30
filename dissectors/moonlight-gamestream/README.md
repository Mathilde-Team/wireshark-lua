# Moonlight / NVIDIA GameStream — contrôle GRID et vidéo NVStream

Dissecteurs Wireshark en Lua du projet Moonlight (client libre de NVIDIA
GameStream) : protocole de contrôle GRID sur TCP 47995, en-tête des paquets
vidéo NVStream et analyse des unités NAL H.264 transportées en RTP (issue #384).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/moonlight-stream/moonlight-android (dossier `LuaScripts/`) ; l'issue cite https://github.com/mikulz6/PhantomClient (commit `d43c5fced7cad9ca819fa8839f1f0dc3952e2131`), qui en contient deux copies identiques octet pour octet (`origin_sdk/moonlight_core/moonlight-android/LuaScripts/` et `origin_sdk/moonlight_core/Client-Android/LuaScripts/`) |
| Commit importé | `b48494cb96bff23d8886c4775cc4f39a1075495d` du 12/09/2026 (dernier commit de `master`) ; dernier changement de `LuaScripts/` : `b14f2ce219cd4880857ac2d43248ed912b5e2d22` du 06/12/2016 |
| Licence amont | GPL-3.0-only (fichier `LICENSE.txt`, GPL version 3 ; aucune mention « or later » dans le dépôt ni en-tête de licence dans les fichiers Lua) |
| Natif Wireshark 4.6.4 | Partiel — Wireshark dissèque nativement RTP et H.264 (`h264`), mais ni le contrôle GRID ni l'en-tête vidéo NVStream de GameStream |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Auteur (en-tête amont) | Rôle |
|---|---|---|
| `src/gridctl.lua` | — | Protocole `gridctl` (« Nvidia GRID Control Protocol ») sur TCP 47995 : type de paquet, longueur, charge utile (entier 16/32 bits LE ou octets), réponses `0x0204` (type d'origine, code) |
| `src/NVStreamVideoPacket.lua` | Diego Waxemberg | Protocole `nv` (« Nvidia Video Stream Protocol ») : en-tête des paquets vidéo, enregistré sur `rtp.pt` 96 |
| `src/NALParser.lua` | Cameron Gutman | Protocole `h264raw` (« H264 Raw NAL Parser ») : en-têtes NAL H.264, enregistré sur `rtp.pt` 96 |

Fichiers repris tels quels, en-tête de provenance ajouté. Le reste du dépôt
(client Android) est hors périmètre.

## Utilisation

Copier les fichiers de `src/` dans le dossier des plugins Lua de Wireshark.
Filtres : `gridctl`, `nv`, `h264raw`. Pour la vidéo, le flux UDP doit d'abord
être décodé comme RTP (« Décoder comme… »), avec le type de charge 96.

## Limites constatées à l'import

- `NVStreamVideoPacket.lua` et `NALParser.lua` s'enregistrent tous deux sur
  `rtp.pt` 96 : le dernier chargé remplace l'autre ;
- scripts de 2013-2016, non mis à jour depuis : leur adéquation aux versions
  récentes de GameStream / Sunshine n'est pas vérifiée ;
- `gridctl.lua` : la demande de réassemblage (`desegment_len`) ne s'accompagne
  pas d'un retour, la lecture continue sur des données incomplètes ; variables
  globales (`subtree`, `i`, `ptype`, `paylen`…) ;
- protocoles et fonctions déclarés en globales (`p_gridctl`, `p_nv`,
  `p_h264raw`) ; nom de protocole très court (`nv`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
