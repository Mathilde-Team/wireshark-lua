# UDPFS / UDPRDMA

Dissecteur Wireshark Lua des protocoles UDPRDMA (transport fiable sur UDP) et
UDPFS (accès fichiers et blocs de la PlayStation 2 sur le réseau), implémentés
côté serveur par [udpfsd](https://github.com/pcm720/udpfsd) (issue #269).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pcm720/udpfsd |
| Commit importé | `ee94414f9f45ed33b8dd4ca4e03847440df946e9` du 24/10/2026 (dernier commit de `main`) ; dernier changement de `docs/wireshark/` : `ee653f36ed84b50af75d0e168225a94ef3f8e3a2` du 19/03/2026 |
| Licence amont | BSD-3-Clause (`LICENSE` amont, Copyright 2026 Ivan V (pcm720)) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur UDPFS ou UDPRDMA natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence BSD-3-Clause est conservée (en-tête SPDX
`BSD-3-Clause`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/udpfs_udprdma.lua` | Protocoles `udprdma` (UDP 62966 = `0xF5F6` : en-tête de base, `DISCOVERY`, `INFORM`, `DATA` avec accusés et drapeaux `ACK`/`FIN`) et `udpfs` (messages applicatifs dans les `DATA` : `OPEN`, `CLOSE`, `READ`, `WRITE`, `LSEEK`, `DREAD`, `GETSTAT`, `MKDIR`, `REMOVE`, `RMDIR`, `BREAD`, `BWRITE`, `RESULT_REPLY`…), y compris les blocs de lecture en continuation |

Seul `docs/wireshark/udpfs_udprdma.lua` est importé ; le serveur Go et le
`docs/wireshark/README.md` amont (installation, filtres) sont hors périmètre.
Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/udpfs_udprdma.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic UDP 62966 est décodé
automatiquement. Filtres utiles (README amont) : `udprdma`,
`udprdma.packet_type == 2` (DATA), `udpfs`, `udpfs.msg_type == 0x10`
(`OPEN_REQ`), `udpfs.path`.

## Limites constatées à l'import

- la détection des blocs de lecture en continuation dépend de l'ordre de
  dissection (état par flux rempli au fil des paquets) : après un rechargement
  des plugins Lua, recharger la capture (Ctrl+R) pour éviter des paquets `DATA`
  mal étiquetés (limite documentée par l'amont) ;
- cet état (`transfer_state`) n'est jamais remis à zéro (pas de fonction
  `init`) : il persiste d'une capture à l'autre jusqu'au rechargement des
  plugins ;
- le port 62966 est codé en dur (pas de préférence) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
