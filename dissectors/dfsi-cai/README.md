# DFSI CAI (radio P25)

Dissecteur Wireshark Lua pour DFSI CAI (Digital Fixed Station Interface, Common Air Interface) : interface des stations fixes radio P25, basé sur le dissecteur SMPTE ST 2110-20.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/vitorespindola/dfsi-cai-dissector |
| Commit importé | `0d0e8982d6d528eb6b87dd0b1a2322e43f6d2d39` du 26/08/2018 (branche `master`) |
| Licence amont | GPLv2 ou toute version ultérieure (énoncée dans l'en-tête du fichier) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur DFSI natif dans Wireshark |

Texte de la licence : fichier `LICENSE.txt` de ce dossier. L'amont ne fournit pas de fichier de licence : c'est le texte canonique de la GPLv2, celle que l'en-tête du fichier déclare.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/DFSI-CAI.lua` | Dissecteur (11 Ko) : données CAI dans la charge RTP (déclaré via « Decode As » → RTP) |

Non importés : `README.md` (documentation, reprise ici).

## Utilisation

Copier `src/DFSI-CAI.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Décoder les paquets CAI via « Decode As » → RTP ; la dissection DFSI CAI apparaît dans la charge RTP.

## Limites constatées à l'import

- TODO amont non couverts : paquets FSC, voix non-CAI (uLaw), Link Control, Encryption Sync, Low Speed Data, voter control, en-têtes voix 1/2, données constructeur ;
- non maintenu depuis 2018.
