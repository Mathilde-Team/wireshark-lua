# JCZ Laser (contrôleurs de gravure laser)

Dissecteur Wireshark Lua du protocole **USB des contrôleurs de gravure laser
JCZ/BJJCZ** (galvo, pilotés par EZCAD2), sur USB bulk : commandes
immédiates de l'hôte (12 octets : opcode et cinq paramètres), tampons de
liste de 3 072 octets et réponses de 8 octets du contrôleur, avec les noms
des opcodes connus.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MichalDzialak/LaserMeRaw (dérivé de Balor, https://gitlab.com/bryce15/balor/) |
| Commit importé | `f52c7d94ce74aeb1478a01685a6a1458c1da9b45` du 02/10/2024 (branche `main`, dernier commit, « simple wireshark dissector for the JCZ protocol ») |
| Licence amont | GPL-3.0-or-later (`LICENSE` amont : « either version 3 of the License, or (at your option) any later version », © 2021 Bryce Schroeder, © 2024 Michal Dzialak) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur JCZ natif |

Le fichier `LICENSE` de ce dossier est la copie conforme de la notice amont
(elle renvoie au texte de la GPL v3, identique au `LICENSE` racine du dépôt).

## Fichiers

| Fichier | Rôle |
|---|---|
| `jczlaser.lua` | Dissecteur JCZ (amont : `wireshark/jczlaser.lua`), enregistré dans `usb.bulk` pour la classe 0xff (spécifique fournisseur) |

Fichier importé tel quel. Seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `jczlaser.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, puis
capturer le trafic USB du contrôleur (usbmon sous Linux, USBPcap sous
Windows).

## Remarques

- Le type de message est déduit uniquement de la longueur et du sens
  (`host` en source ou en destination) ; tout autre périphérique USB de
  classe 0xff en bulk sera aussi décodé comme JCZ.
- Variables et fonctions globales (`jcz_proto`, `opcode`, `param1`…,
  `dissect_immediate`, `immediate_opcodes`) : collision possible avec
  d'autres plugins.
- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
