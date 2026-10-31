# VoltDB Client Wire Protocol

Dissecteur Wireshark Lua pour le protocole filaire client de
[VoltDB](https://www.voltactivedata.com/) (base de données in-memory
distribuée) (issue #456).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/VoltDB/voltdb-wireshark (archivé) |
| Commit importé | `3f0dd8c7c0a075da70b3764198a1c3d392d27deb` du 24/02/2023 |
| Licence amont | MIT (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur VoltDB natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/voltcw.lua` | Dissecteur du protocole client VoltDB : paquets TCP 21212 (login, appel de procédures, résultats) |

Le dépôt amont contient aussi `example.pcap` (capture d'exemple) : non
importé.

## Utilisation

Copier `src/voltcw.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le port (21212) est modifiable dans les
préférences du protocole.

## Limites constatées à l'import

- dépôt amont archivé (VoltDB, devenu Volt Active Data, ne le maintient plus) ;
- le dissecteur décode la structure des messages mais pas les procédures
  stockées spécifiques d'une application.
