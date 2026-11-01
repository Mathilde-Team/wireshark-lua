# LocoNet

Dissecteur Wireshark Lua des messages **LocoNet** (bus de commande de
Digitrax pour réseaux ferroviaires miniatures), écrit d'après la
spécification « LocoNet Personal Use Edition 1.0 » : opcode, longueur des
messages variables, somme de contrôle et décodage de 24 opcodes (vitesse et
direction des locomotives, aiguillages, capteurs, gestion des slots,
transferts entre pairs, paquets DCC immédiats…).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/reinder/loconet-wireshark |
| Commit importé | `90a8ab6b709af143d0b6c037cb28aebcd0306912` du 28/04/2023 (branche `main`, dernier commit) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « either version 2 of the License, or (at your option) any later version », © 2023 Reinder Feenstra ; `LICENSE` amont : GPL v2) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur LocoNet natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont, GPL v2).

## Fichiers

| Fichier | Rôle |
|---|---|
| `loconet.lua` | Dissecteur `loconet` (un message LocoNet par tampon) |

Fichier importé tel quel ; seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `loconet.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.

Le dissecteur ne s'enregistre sur aucun port ni table : il est fait pour
être appelé par un autre dissecteur (`Dissector.get("loconet")`) ou
associé à un type de lien utilisateur (Préférences → Protocoles →
DLT_USER, protocole de charge utile `loconet`) pour des captures de
messages LocoNet bruts.

## Remarques

- Chaque tampon doit contenir exactement un message : la somme de contrôle
  est lue sur le dernier octet.
- Les opcodes non reconnus ne sont décodés que pour l'opcode, la longueur
  et la somme de contrôle.
- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
