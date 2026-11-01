# InfyPower CAN (alimentations de bornes de recharge)

Dissecteur Wireshark Lua du **protocole CAN InfyPower V1.13**, utilisé par
les modules d'alimentation DC InfyPower des bornes de recharge de véhicules
électriques, tiré du projet EVerest. Dissecteur heuristique sur `can`
(identifiant étendu : source, destination, commande, type d'équipement
`0x0A`), avec appariement requête/réponse (ordre FIFO par module et
commande) et repérage des commandes internes `0x17`.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/EVerest/EVerest (dossier `modules/HardwareDrivers/PowerSupplies/InfyPower/wireshark/`) |
| Commit importé | `2265c29a8dc0a841672012ccc0c31b00217174d8` du 31/10/2026 (branche `main`, dernier commit ; dernière modification du dissecteur : `2de4b8a` du 02/06/2026) |
| Licence amont | Apache-2.0 (`LICENSE` amont et en-tête `SPDX-License-Identifier: Apache-2.0` du fichier Lua ; pas de fichier `NOTICE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur InfyPower natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `infypower_can.lua` | Dissecteur `infypower` (heuristique sur `can`), filtres `infypower.src`, `infypower.dest`, `infypower.command`, `infypower.internal`, `infypower.pair` |
| `infypower_colorfilters` | Règle de coloration amont (trafic interne, commande `0x17`) |
| `outils/vcan.sh` | Script amont : création d'une interface CAN virtuelle `vcan0` (root) |
| `outils/sim_module0_responses.sh` | Script amont : simulation des réponses du module 0 avec `cansend` (can-utils) |

Fichiers importés tels quels ; seule une en-tête SPDX + provenance de
quatre lignes a été ajoutée en tête du fichier Lua (l'en-tête SPDX amont
est conservée juste en dessous).

## Utilisation

Copier `infypower_can.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, capturer
sur l'interface CAN (SocketCAN) et filtrer avec `infypower`. Règle de
couleur facultative : Affichage → Règles de coloration → Importer →
`infypower_colorfilters`.

Essai sans matériel (Linux, can-utils) : `sudo outils/vcan.sh`, capture sur
`vcan0`, puis `outils/sim_module0_responses.sh vcan0 once`.

## Remarques

- Pas de capture d'exemple amont ; non vérifié dans Wireshark.
- L'amont indique de recharger les plugins Lua une fois la capture ouverte
  pour que les requêtes affichent aussi le lien vers leur réponse.
- Le dissecteur heuristique peut revendiquer d'autres trames CAN étendues
  dont le champ équipement vaut `0x0A` (non vérifié).
