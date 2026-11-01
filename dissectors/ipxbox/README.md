# IPXbox : Doom, ROTT et IPX tunnelé (jeux DOS)

Dissecteurs Wireshark Lua du projet IPXbox (serveur IPX autonome pour DOSBox),
pour le trafic des jeux DOS en réseau : protocoles de jeu en réseau de Doom et
de Rise of the Triad (ROTT), tunnel IPX ipxpkt.com, et rattachement du port UDP
d'IPXbox au dissecteur IPX natif de Wireshark (issue #258).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/fragglet/ipxbox (dossier `wireshark/`) |
| Commit importé | `221f9f6ea1749942805d7bfeab1ab0b9bfae0683` du 14/09/2026 (dernier commit de `master`) ; dernier changement de `wireshark/` : `38dc3413c10cfe6f07e11683b539208330912c50` du 11/03/2025 |
| Licence amont | GPL-2.0 (`COPYING.md` amont, texte de la version 2, sans mention « or later ») → `GPL-2.0-only`, décision de Mathilde du 01/11/2026 |
| Natif Wireshark 4.6.4 | Non pour Doom, ROTT et ipxpkt ; IPX est natif (`ipxbox.lua` se contente d'y rattacher le port UDP 10000) |

Texte complet de la licence amont : `LICENSE.md` dans ce dossier, copie
conforme de `COPYING.md`. Les fichiers `.lua` sont repris sans modification ;
seule une en-tête SPDX et de provenance a été ajoutée.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ipxbox.lua` | Rattache le port UDP 10000 (IPXbox) au dissecteur `ipx` natif. Équivaut à « Decode As… » |
| `src/doom.lua` | Protocole `doom` : paquets du jeu en réseau de Doom (drapeaux, somme de contrôle, commandes) |
| `src/rott.lua` | Protocole `rott` : jeu en réseau de Rise of the Triad (phase de configuration, commandes) |
| `src/ipxpkt.lua` | Protocole `ipxpkt` : tunnel ipxpkt.com (fragments, trames Ethernet encapsulées) |
| `examples/*.cap` | Captures d'exemple de l'amont (Doom, ROTT, ipxpkt) |

## Utilisation

Copier les fichiers de `src/` dans le dossier des plugins Lua personnels de
Wireshark (`~/.local/lib/wireshark/plugins/` sous Linux), puis ouvrir l'une des
captures de `examples/`.

## Licence

`GPL-2.0-only`, licence amont conservée fichier par fichier. Le reste du dépôt
est en GPL-3.0-or-later : ces fichiers sont distribués à côté, sans être
combinés avec le reste du code.
