# IPbus

Dissecteur Wireshark Lua du protocole **IPbus** (version 2.0), lien de
contrôle UDP des cartes électroniques à FPGA, très utilisé en physique des
hautes énergies (CERN), sur UDP 50001 : en-tête de paquet, puis transactions
de contrôle (lecture, écriture, lecture-modification-écriture…) et mots de
données.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pcolladosoto/dissectors |
| Commit importé | `1ef3e4f174811752942d48ee8562a01df615c3d7` du 28/06/2025 (dernier commit de la branche par défaut) |
| Licence amont | GPL-3.0 (`LICENSE` amont, texte GPL v3 ; aucune mention « or later » dans le dépôt, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur IPbus natif |
| Spécification | https://ipbus.web.cern.ch/doc/user/html/_downloads/d251e03ea4badd71f62cffb24f110cfa/ipbus_protocol_v2_0.pdf |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `ipbus.lua` | Dissecteur IPbus (UDP 50001) |

Seul `ipbus.lua` est importé (le dépôt amont ne contient pas d'autre
dissecteur). Fichier importé tel quel ; seule une en-tête SPDX + provenance
de quatre lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `ipbus.lua` dans le dossier des plugins Lua personnels de Wireshark
(Aide → À propos de Wireshark → Dossiers), puis recharger les plugins Lua
(Ctrl+Maj+L).

## Remarques

- Seuls les paquets de contrôle en petit-boutiste (little endian) sont
  décodés ; les paquets gros-boutistes et les paquets d'état ou de
  renvoi sont signalés comme non pris en charge.
- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
