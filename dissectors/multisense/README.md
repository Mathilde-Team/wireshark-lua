# MultiSense

Dissecteur Wireshark Lua du **MultiSense Wire Protocol**, le protocole UDP
des caméras stéréo MultiSense de Carnegie Robotics (issue #66).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/carnegierobotics/LibMultiSense (fichier `wireshark/multisense.lua`) |
| Commit importé | `723cd371f4ae808f7d56ad8dfdb46771e236f2e9` du 15/10/2026 (dernier commit de la branche par défaut) |
| Licence amont | BSD-3-Clause : texte BSD 3 clauses dans `LICENSE.TXT` amont et dans l'en-tête du fichier (© 2024 Carnegie Robotics, LLC). L'API GitHub indique `NOASSERTION` parce que le nom de Carnegie Robotics remplace « the copyright holder » dans la 3e clause |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur MultiSense natif (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE.TXT` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/multisense.lua` | Protocole `MultiSense` (UDP 9001) : en-tête wire (magic, version, groupe, drapeaux, séquence, longueur du message, offset), réassemblage des messages fragmentés, type du message, charge utile brute |

Seul le dissecteur est importé ; la bibliothèque C++ LibMultiSense ne l'est pas.

## Utilisation

Copier `src/multisense.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `multisense`.

## Limites constatées à l'import

- port UDP 9001 codé en dur ;
- les charges utiles ne sont pas décodées champ par champ (octets bruts après
  l'type du message) ;
- tables de réassemblage gardées en mémoire pendant toute la capture (remises
  à zéro seulement par `init`, au chargement d'un fichier) ; variable
  `length` globale ;
- pas de capture d'exemple amont : chargement vérifié avec `tshark` 4.6.4,
  pas de dissection testée sur du trafic réel.
