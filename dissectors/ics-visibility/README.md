# ICS Visibility (ics_wireshark_tools)

Collection de plugins Wireshark Lua de **visibilité sur les protocoles
industriels** (ICS/SCADA). Ce ne sont pas des dissecteurs : ils s'appuient
sur les dissecteurs natifs de Wireshark et ajoutent, par protocole, une
fenêtre de synthèse (menu Outils → ICS Visibility), des compteurs et un
export CSV.

Protocoles couverts : Modbus/TCP, EtherNet/IP / CIP, BACnet/IP, PROFINET
DCP, OPC UA, S7comm, DNP3 et IEC 60870-5-104.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/cruz53/ics_wireshark_tools |
| Commit importé | `d0649b4041b3c91a30334b64aa5a7375de73c0fc` du 08/07/2026 (branche `main`, dernier commit) |
| Licence amont | GPL-3.0 (`LICENSE` amont, texte GPL v3 ; README : « GNU General Public License v3.0 », sans mention « or later », d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Les protocoles sont décodés nativement (`mbtcp`, `enip`, `bacnet`, `pn_dcp`, `opcua`, `s7comm`, `dnp3`, `iec60870_104`) ; la collection est complémentaire (synthèses, compteurs, CSV) |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `ics_visibility.lua` | Point d'entrée : ajoute les dossiers du projet à `package.path`, puis charge `init` |
| `init.lua` | Charge `lib.csv` et les huit modules `protocols.*`, enregistre les menus |
| `lib/bootstrap.lua`, `lib/counters.lua`, `lib/csv.lua`, `lib/fields.lua`, `lib/windows.lua` | Bibliothèques communes (chemins, compteurs, export CSV, accès aux champs, fenêtres) |
| `protocols/*.lua` | Un module par protocole : écouteur (`Listener`) sur le filtre du protocole, fenêtre de synthèse |

Fichiers Lua importés tels quels, arborescence amont conservée. Seule une
en-tête SPDX + provenance de quatre lignes a été ajoutée en tête de chaque
fichier. Les simulateurs de trafic Python amont (`simulators/*.py`, réservés
aux réseaux de laboratoire) ne sont pas importés.

## Utilisation

Copier tout le dossier (`ics_visibility.lua`, `init.lua`, `lib/`,
`protocols/`) dans un sous-dossier du dossier des plugins personnels de
Wireshark, par exemple `~/.local/lib/wireshark/plugins/ics_visibility/`,
puis redémarrer Wireshark. Les fenêtres se trouvent dans
Outils → ICS Visibility → <protocole> → Summary.

## Remarques

- Wireshark charge aussi comme greffons tous les `.lua` des sous-dossiers
  (`init.lua`, `lib/*`, `protocols/*`). Chaque module protège son
  enregistrement par un indicateur `registered`, mais le comportement exact
  de ce double chargement n'a pas été vérifié dans Wireshark.
- Le module Modbus associe en plus le port TCP 1502 au dissecteur natif
  `mbtcp` (port utilisé par le simulateur amont).
- Les exports CSV sont écrits dans le dossier temporaire du système
  (`ics_visibility_<protocole>_*.csv`).
