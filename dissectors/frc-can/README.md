# FRC CAN

Dissecteur Wireshark Lua des messages **CAN de la FIRST Robotics
Competition** (FRC) : identifiant CAN au format SocketCAN, champs FRC de
l'identifiant (type d'appareil, fabricant, classe et index d'API), puis
décodage des trames CTRE (contrôleurs de moteurs Talon, statuts 2 et 4 ;
PDP, statuts 1 à 3, énergie et commande).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/truher/frc-can-dissector |
| Commit importé | `8394af09f43d36e81249bca02b0135b3c32d4e98` du 06/01/2023 (branche `main`, dernier commit) |
| Licence amont | MIT (`LICENSE` amont, © 2023 truher) |
| Natif Wireshark 4.6.4 | Non — Wireshark décode le CAN/SocketCAN, pas la couche FRC/CTRE |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `can.lua` | Point d'entrée : protocole `FRC_CAN`, enregistré dans `wtap_encap` (valeur 109) |
| `can/socketcan.lua` | En-tête CAN au format SocketCAN (drapeaux, identifiant, longueur, données) |
| `frc/frc.lua` | Champs FRC de l'identifiant CAN (tables des types d'appareils et fabricants) |
| `ctre/motor.lua`, `ctre/motor_status2.lua`, `ctre/motor_status4.lua` | Contrôleurs de moteurs CTRE |
| `ctre/pdp.lua`, `ctre/pdp_*.lua` | Power Distribution Panel CTRE |

Fichiers importés tels quels, arborescence amont conservée. Seule une
en-tête SPDX + provenance de quatre lignes a été ajoutée en tête de chaque
fichier `.lua`.

## Utilisation

Copier `can.lua` et les dossiers `can/`, `frc/` et `ctre/` dans le dossier
`plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis
recharger les plugins Lua. Les captures visées sont celles de l'enregistreur
Teensy de l'auteur (https://github.com/truher/frc-test/tree/main/can-logger),
en-têtes pcap sans l'en-tête « Linux cooked capture » de SocketCAN.

## Remarques

- `can.lua` charge `require("ctre.pdp")`, mais `ctre/motor.lua` et
  `ctre/pdp.lua` chargent leurs sous-modules sans préfixe
  (`require("motor_status2")`, `require("pdp_status1")`…) : ils ne sont
  trouvés que si le dossier `ctre/` figure lui-même dans `package.path`.
  Wireshark ajoute les sous-dossiers du dossier des plugins à
  `package.path`, ce qui devrait suffire ; non vérifié.
- Wireshark charge aussi comme greffons les modules des sous-dossiers ;
  `frc/frc.lua` déclare des tables globales (`device_types`,
  `manufacturers`…).
- Les champs `can.*` (`can.id`, `can.eff_flag`…) portent les mêmes noms que
  ceux du dissecteur CAN natif de Wireshark ; conflit possible au chargement
  ou dans les filtres, non vérifié.
- Pas de capture d'exemple amont ; dépôt inactif depuis janvier 2023.
