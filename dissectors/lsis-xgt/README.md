# LS Electric XGT (FEnet)

Dissecteur Wireshark Lua du **protocole dédié XGT** (FEnet) des automates LS Electric (ex-LSIS) des séries XGT/XGB, sur TCP 2004 (issue #83).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ciaoly/PLC-XGT-protocol-for-Wireshark |
| Commit importé | `d76bc15014ee58508df06d4c0cf09cb885e40d60` du 13/08/2021 (dernier commit de la branche par défaut) |
| Licence amont | MIT (`LICENSE` amont, © 2021 chaol) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/xgb.lua` | Protocole `LSIS_XGT` (« XGT dedicated protocol »), TCP 2004 : en-tête LSIS (identifiant `LSIS-XGT`, infos automate et CPU, sens de la trame, numéro d'ordre, longueur, somme de contrôle), commande, type de données, blocs (adresse, nombre de données), état d'erreur |

Le script est repris tel quel (fins de ligne CRLF de l'amont conservées), avec l'en-tête de provenance ajouté.

## Utilisation

Copier le script dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `lsis_xgt`.

## Limites constatées à l'import

- port TCP 2004 codé en dur (le port UDP 2005 du protocole n'est pas enregistré)
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée sur du trafic réel.
