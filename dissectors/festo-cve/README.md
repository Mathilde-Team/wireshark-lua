# Festo CVE

Dissecteur Wireshark Lua du protocole **Festo Control Via Ethernet** (CVE) des contrôleurs de moteurs Festo CMMO-ST. Sa structure de messages ressemble à CANopen (objets du dictionnaire, automate d'états CiA 402), mais il circule sur TCP 49700 (issue #89).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/gavanderhoorn/packet-festo-cve |
| Commit importé | `1e3ad229b2d18e05e2a08a19fc548c1ac5200c27` du 01/03/2015 (dernier commit de la branche par défaut) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « or (at your option) any later version », © G.A. vd. Hoorn) ; `LICENSE` amont = texte de la GPLv2 |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-festo-cve.lua` | Protocole `FESTO-CVE` (« Festo Control Via Ethernet »), TCP 49700 : commandes de lecture et d'écriture d'objets, mots de contrôle et d'état |

Les scripts sont repris tels quels, avec l'en-tête de provenance ajouté.

## Utilisation

Copier le script dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `festo-cve`.

## Limites constatées à l'import

- d'après l'amont, les objets et bits ne suivent pas toujours CiA 402 ; ils sont décodés d'après le manuel CMMO-ST 8022056
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée sur du trafic réel.
