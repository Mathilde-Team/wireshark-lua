# LEEP (LBNL)

Dissecteur Wireshark Lua du **LBNL Embedded Ethernet Protocol** (LEEP), le protocole requête/réponse sur UDP 50006 qu'utilise le module EPICS feed-core du Lawrence Berkeley National Laboratory. Il sert à lire et écrire les registres 32 bits des cartes FPGA (issue #87).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/BerkeleyLab/feed-core |
| Commit importé | `0472d88f3a42ad8adde5b32d7e348efe43d84199` du 11/02/2025 (dernier commit de la branche par défaut) |
| Licence amont | BSD-3-Clause (`LICENSE` amont, © The Regents of the University of California) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/leep.lua` | Protocole `leep` (UDP 50006) : en-tête, puis suite de commandes lecture/écriture (adresse 24 bits, données 32 bits) |

Seul le dissecteur est importé ; le module EPICS feed-core ne l'est pas. La spécification du protocole est dans `proto.md` de l'amont.

## Utilisation

Copier le script dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `leep`.

## Limites constatées à l'import

- port UDP 50006 codé en dur
- `print("Loading LEEP...")` au chargement (console Lua)
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée sur du trafic réel.
