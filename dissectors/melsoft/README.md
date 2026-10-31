# MELSOFT (Mitsubishi Electric)

Dissecteur Wireshark Lua du protocole **MELSOFT**, le protocole natif des logiciels Mitsubishi Electric (GX Works 2/3, MX Component, MX OPC Server) pour dialoguer avec les automates MELSEC. Il cible les opérations de lecture et d'écriture de données (vérifié par l'auteur sur R32ENCPU + RJ71EN71) (issue #82).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/louislau86/Mitsubishi-protocol-wireshark-plugin |
| Commit importé | `5890d27a405e28ce81b9610074039c4a60fd25a6` du 28/12/2025 (dernier commit de la branche par défaut) |
| Licence amont | MIT (`LICENSE` amont, © 2025 louislau86) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/melsoft.lua` | Protocole `MELSOFT`, heuristique sur TCP et UDP : en-tête MELSOFT, commandes de lecture et d'écriture de périphériques (devices) de l'automate, valeurs |

Le script est repris tel quel (fins de ligne CRLF de l'amont conservées), avec l'en-tête de provenance ajouté.

## Utilisation

Copier le script dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `melsoft`.

## Limites constatées à l'import

- d'après l'amont, la connexion et l'authentification, les commandes de pilotage à distance et les transferts de fichiers ne sont pas décodés : seules les lectures et écritures de données le sont
- dissecteur heuristique sur tout TCP et UDP : risque de faux positifs sur d'autres trafics
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée sur du trafic réel.
