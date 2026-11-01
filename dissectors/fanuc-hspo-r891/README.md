# Fanuc HSPO (R891)

Dissecteur Wireshark Lua du protocole **Fanuc High-Speed Position Output**
(option logicielle R891 des contrôleurs de robots Fanuc). Ce flux UDP publie
à haute fréquence la position des axes et du point outil (issue #76).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/gavanderhoorn/packet-fanuc-hspo-r891 |
| Commit importé | `952fd8f4c1a905e506c159f11ff189dd8cfd0651` du 06/09/2020 (dernier commit de `master`, v0.1.5) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « either version 2 of the License, or (at your option) any later version », © 2020 G.A. vd. Hoorn) ; `LICENSE` amont = texte de la GPLv2 |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur R891 natif (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-fanuc-hspo-r891.lua` | Protocole `FRR891`. Port UDP réglable (préférence « UDP Ports », 80 par défaut). Préférences : affichage des champs réservés, nombre d'axes affichés, contrôle facultatif de l'adresse MAC source |

Le script est repris tel quel, avec l'en-tête de provenance ajouté. La capture
d'écran de l'amont n'est pas importée.

## Utilisation

Copier `src/packet-fanuc-hspo-r891.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `frr891`.

## Limites constatées à l'import

- d'après l'amont : les paquets XML (non binaires) et les paquets de variables
  (type 16) ne sont pas pris en charge ;
- le port par défaut (UDP 80) doit souvent être adapté dans les préférences ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur du trafic réel.
