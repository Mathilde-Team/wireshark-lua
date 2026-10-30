# Contrôle d'antenne (station sol satellite)

Dissecteurs Wireshark Lua pour les protocoles propriétaires de contrôle
d'antenne utilisés en station sol satellite : le contrôleur de rotor
Jeju LP-ACS (protocole ROT2PROG) et l'Antenna Control Unit Viasat 4110.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/joosing/msg-dissector |
| Commit importé | `ec03e9c077a3be2dbcd4c4a21f655ddf7e268a35` du 04/02/2022 (branche `master`) |
| Licence amont | LGPL-2.1 (fichier `LICENSE` amont) — compatible GPL-3.0-or-later |
| Natif Wireshark 4.6.4 | Non — protocoles propriétaires, aucun dissector natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/lp-acs-rot2prog.lua` | Dissecteur « rot2 » du contrôleur de rotor Jeju LP-ACS (ROT2PROG) : commandes et états d'azimut/élévation, s'attache au port TCP 23 |
| `src/acu-viasat-4110.lua` | Dissecteur « ACU » de l'Antenna Control Unit Viasat 4110 : s'attache aux ports TCP 6100 et 6400, préférences Wireshark (activation, sous-dissecteurs, niveau de debug) |

Le dépôt amont contient aussi `README.md`, `install/copy.bat` et
`.gitignore` : non importés ici (le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier les fichiers `src/*.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.local/lib/wireshark/plugins` sous Linux ; l'amont fournit
`install/copy.bat` pour Windows). Le dissecteur ACU expose ses réglages
dans les préférences Wireshark (Edit → Preferences → Protocols → ACU).

## Limites constatées à l'import

- protocoles propriétaires spécifiques au parc matériel de l'auteur :
  la couverture se limite aux commandes implémentées ;
- le dissecteur rot2 s'attache au port TCP 23 (telnet) : il peut entrer en
  conflit avec le dissector telnet si le contrôleur n'utilise pas ce port.
