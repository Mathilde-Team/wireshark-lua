# ROS-Industrial SimpleMessage

Dissecteur Wireshark Lua du protocole **SimpleMessage** de ROS-Industrial
(version Groovy, utilisée aussi par Hydro et Indigo), qui sert entre les
pilotes ROS et les contrôleurs de robots industriels (Motoman/MotoROS, ABB,
Fanuc…) sur TCP (issue #70).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ros-industrial/packet-simplemessage |
| Commit importé | `b3a655b227a76e29912b8148020908202fc9d4cb` du 23/02/2022 (dernier commit de `master`, v0.1.11) |
| Licence amont | GPL-2.0-or-later, d'après l'en-tête de `packet-simplemessage.lua` (« either version 2 of the License, or (at your option) any later version », © 2013-2016 G.A. vd. Hoorn, TU Delft Robotics Institute). L'amont n'a pas de fichier `LICENSE` et l'API GitHub indique `null` |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SimpleMessage natif (`tshark -G protocols`) |

`LICENSE.txt` : texte de la GNU GPL version 2. L'amont ne le fournit pas, mais
l'en-tête du fichier y renvoie. La copie vient de
`/usr/share/common-licenses/GPL-2` (Debian).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-simplemessage.lua` | Protocole `SIMPLEMESSAGE` (TCP 11000, 11002, 50240, 50241, 50242, réglables dans les préférences) : préfixe, en-tête (type de message, type de communication, code de réponse) et 14 types de corps (Ping, Joint Position, Joint Trajectory Point, Status, Joint Feedback, messages Motoman…). Détection de l'ordre des octets, réassemblage TCP |
| `captures/motoman_single_group_simple_move.pcapng` | Capture d'exemple de l'amont (`samples/`), 188 trames MotoROS |

Le script est repris tel quel, avec l'en-tête de provenance ajouté.

## Utilisation

Copier `src/packet-simplemessage.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `simplemessage`.

## Vérification à l'import

Avec `tshark` 4.6.4, sur la capture d'exemple :

```
tshark -X lua_script:src/packet-simplemessage.lua -r captures/motoman_single_group_simple_move.pcapng
```

Résultat : 164 messages décodés (Motoman Motion Reply, Joint Trajectory Point,
Status, Joint Feedback, Motoman Motion Ctrl), aucune trame malformée ni erreur
Lua ; les 24 autres trames sont des ACK TCP.

## Limites constatées à l'import

- seule la version Groovy du protocole est prise en charge (d'après l'amont) ;
- l'amont n'a été testé que jusqu'à Wireshark 2.0.2. Le chargement et la
  capture d'exemple fonctionnent avec 4.6.4, les autres types de messages
  n'ont pas été testés.
