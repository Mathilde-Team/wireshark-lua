# SafetyNET-P

Dissecteur Wireshark Lua pour **SafetyNET-P**, protocole Ethernet industriel
de sécurité de Pilz, sur UDP 40000 : en-tête (magic, version, type, longueur,
identifiant) puis charge utile affichée en bloc.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/GalloClaudio64/Safetynet-P |
| Commit importé | `10e3b01b50085ba64dd73a2e1bfdfcea3564d264` du 31/03/2023 (branche `main`, « Update README.md ») ; dernier changement de `safetynet-p.lua` au commit `67ca0b797864f94f3624a1d12858462da9b9c3ba` du même jour |
| Licence amont | GPL-3.0 (`LICENSE` amont, texte GPL v3 ; aucune mention « or later » dans le dépôt, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SafetyNET-P natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `safetynet-p.lua` | Dissecteur SafetyNET-P (UDP 40000) |
| `captures/trace with safety.pcapng` | Capture d'exemple amont (2 923 trames, dont 2 847 en UDP 40000) |

Fichiers importés tels quels (fins de ligne CRLF d'origine conservées).
Seule une en-tête SPDX + provenance de quatre lignes a été ajoutée en tête
de `safetynet-p.lua`.

## Utilisation

Copier `safetynet-p.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, puis
ouvrir la capture d'exemple.

## Remarques

- Décodage minimal : structure d'en-tête supposée par l'auteur amont, non
  confrontée à une spécification Pilz.
- Le test de longueur amont (`< 18`) laisse sans décodage les paquets de
  16 ou 17 octets, alors que l'en-tête en fait 16.
- Dépôt amont inactif depuis mars 2023.
