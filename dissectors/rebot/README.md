# ReBot (ChimeraTK DeviceAccess)

Dissecteur Wireshark Lua du protocole **ReBot**, protocole d'accès distant
aux registres d'un périphérique utilisé par la bibliothèque C++ ChimeraTK
DeviceAccess (DESY) : lecture et écriture de mots à une adresse, poignée
de main `HELLO` avec version, ping (issue #68).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ChimeraTK/DeviceAccess (dossier `wireshark/`) |
| Commit importé | `3ff1cc2cb54291f000c832c885fb3fa5354de93c` du 29/10/2026 (dernier commit de la branche par défaut `master`) ; dernière modification de `wireshark/rebot.lua` : commit `2bd533e3b0e5d4a945129fcaef9ef831cc4f3f7d` du 08/02/2023 |
| Licence amont | LGPL-3.0-or-later (en-tête `SPDX-License-Identifier` du fichier ; « Deutsches Elektronen-Synchrotron DESY, MSK, ChimeraTK Project ») — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont, GNU LGPL version 3 ; la GPLv3 qu'elle complète
est le `LICENSE` à la racine de ce dépôt).

Le script est repris tel quel (aucune modification de code, en-têtes SPDX
d'origine conservés) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le reste de DeviceAccess (bibliothèque
C++) n'est pas importé ; le `wireshark/README.md` amont est résumé
ci-dessous.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rebot.lua` | Protocole `Rebot` (« Rebot Protocol ») sur TCP 5001 : commande sur 32 bits little-endian (`SINGLE_WORD_READ` 0, `SINGLE_WORD_WRITE` 1, `MULTI_WORD_WRITE` 2, `MULTI_WORD_READ` 3, `HELLO` 4, `PING` 5, `SET_SESSION_TIMEOUT` 6 ; réponses `READ_ACK` 1000, `WRITE_ACK` 1001, `PONG` 1005, `TOO_MUCH_DATA` −1010, `UNKNOWN_INSTRUCTION` −1040), puis selon la commande : mot magique et version (`HELLO`), adresse, nombre de mots, données |

## Utilisation

Copier `src/rebot.lua` dans le dossier des plugins Lua personnels de
Wireshark (« Aide › À propos de Wireshark › Dossiers »), puis Ctrl+Maj+L.
Filtre d'affichage : `rebot`, champs `rebot.command`, `rebot.address`,
`rebot.word_count`, `rebot.data`, `rebot.magic`, `rebot.version`.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur (`luac5.4 -p` : OK).
Sur une capture synthétique TCP 5001 :

| Trame | Résultat |
|---|---|
| `HELLO` (mot magique, version 1.0), dans les deux sens | commande 4, `rebot.magic`, `rebot.version` 1 (affiché « (1.0) » dans l'arbre) |
| `MULTI_WORD_READ` adresse `0x100`, 2 mots → `READ_ACK` | adresse `0x00000100`, nombre `2` ; réponse : deux `rebot.data` |
| `SINGLE_WORD_WRITE` adresse `0x200`, valeur `0x2a` → `WRITE_ACK` | adresse et donnée décodées ; réponse 1001 |
| `MULTI_WORD_WRITE` adresse `0x300`, 2 mots → `WRITE_ACK` | adresse, nombre et les deux mots |
| `PING` → `PONG` | commandes 5 et 1005 |
| `MULTI_WORD_READ` suivi d'un `PING` dans le même segment TCP | seul le premier message est décodé |

## Limites constatées

Le `README.md` amont prévient lui-même que le dissecteur ne donne qu'« un
aperçu très basique du protocole brut » et a des défauts liés à la nature
du protocole. Constaté à l'import :

- Port TCP 5001 codé en dur.
- Pas de découpage des messages : un segment TCP contenant plusieurs
  messages n'est décodé que pour le premier ; pas de réassemblage d'un
  message coupé sur plusieurs segments.
- `READ_ACK` ne porte pas de longueur : le nombre de mots est déduit de la
  taille du segment.
- La colonne Info n'est pas renseignée (seule la colonne Protocole).
- Variables globales (`length`, champs, `get_command_name`) : risque de
  collision avec d'autres scripts Lua.
- Non testé sur des captures réelles.
