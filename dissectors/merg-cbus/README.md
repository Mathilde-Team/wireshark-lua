# MERG CBUS / VLCB

Dissecteur Wireshark Lua du protocole **CBUS/VLCB** de la MERG (Model
Electronic Railway Group, réseaux ferroviaires miniatures), dans sa forme
texte « GridConnect » transportée sur TCP (port 5550 par défaut,
modifiable dans les préférences) : trames `:S<id>N<opcode><données>;`,
identifiant CAN décomposé (priorités majeure et mineure, CAN ID) et opcode
nommé (130 opcodes CBUS).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/traintastic/traintastic |
| Commit importé | `4bf0c60672f40667723137b7963c1b8ac2c4c4dc` du 01/11/2026 (branche `master`) ; `utils/wireshark/cbus.lua` ajouté au commit `4c4ca76e35469fb69e39968105bafd2947a3e0ec` du 04/04/2026, inchangé depuis |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « either version 2 of the License, or (at your option) any later version », © 2026 Reinder Feenstra ; `LICENSE` amont : GPL v2) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur CBUS natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont, GPL v2).

## Fichiers

| Fichier | Fichier amont | Rôle |
|---|---|---|
| `cbus.lua` | `utils/wireshark/cbus.lua` | Dissecteur CBUS/VLCB (TCP 5550, préférence « Port number ») |

Fichier importé tel quel ; seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier. Le dossier amont contient aussi
`traintastic.lua` (protocole Traintastic) et `z21.lua` (Roco Z21), hors du
périmètre de l'issue #123 : non importés.

## Utilisation

Copier `cbus.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua ; changer
le port si besoin dans Préférences → Protocoles → CBUS.

## Remarques

- Seul le format texte GridConnect sur TCP est décodé, pas les trames CAN
  binaires.
- Plusieurs trames par segment TCP sont décodées en boucle ; le découpage
  d'une trame entre deux segments n'est pas géré (pas de réassemblage).
- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
