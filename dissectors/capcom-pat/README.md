# Capcom PAT (Monster Hunter Tri)

Dissecteur Wireshark Lua du protocole PAT de Capcom, utilisé par les serveurs
en ligne de Monster Hunter Tri (Wii), écrit par le projet de rétro-ingénierie
[sepalani/MHTrIDA](https://github.com/sepalani/MHTrIDA) (issue #274).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/sepalani/MHTrIDA |
| Commit importé | `2abeb4a8bae2fbaf07571ea45a796a04c571e291` du 02/11/2022 (dernier commit de `master`) |
| Licence amont | AGPL-3.0-or-later (en-tête du fichier : « Copyright (C) 2022 Sepalani » et `SPDX-License-Identifier: AGPL-3.0-or-later`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur PAT natif |

Le dépôt amont n'a pas de fichier de licence (l'API GitHub renvoie
`license: null`), mais le fichier importé porte sa propre notice SPDX. La
licence AGPL est conservée telle quelle (en-tête SPDX `AGPL-3.0-or-later`) et
ne peut pas être re-licenciée en GPL. Faute de texte amont, `LICENSE.txt` est
le texte de l'AGPL-3.0 publié par la FSF (copie reprise du dépôt XombieOnline/xombie).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/pat_dissector.lua` | Protocole `PAT` (champs `pat.*`) sur TCP 8200 à 8299 : réassemblage par `dissect_tcp_pdus`, en-tête de 8 octets (longueur, numéro de séquence, identifiant), 301 identifiants de messages nommés (`ReqLineCheck`, `AnsLoginInfo`…, d'après `mh/constants.py` du serveur MH3SP), corps affiché en brut ; informations expertes pour une longueur suspecte (> `0x1000`) ou un identifiant inconnu |

Seul `server/pat_dissector.lua` est importé ; le reste du dépôt amont
(documentation, outils Ghidra, formats de fichiers du jeu) est hors périmètre.
Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/pat_dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Selon la documentation amont
(`server/README.md`), le jeu se connecte au premier serveur Capcom en SSL sur le
port 8200 : le dissecteur ne voit le protocole PAT que sur un trafic en clair
(serveur de test comme MH3SP) ou déchiffré par Wireshark (clé ou fichier de
secrets TLS, et association du port au protocole `pat` dans les préférences
TLS).

## Limites constatées à l'import

- tout le trafic TCP 8200-8299 est attribué à PAT, ce qui masque le dissecteur
  TLS natif sur ces ports pour une capture chiffrée ;
- le corps des messages n'est pas décodé (champ `message` affiché en octets
  bruts, hors de l'espace de noms `pat.`) ;
- `PAT_MAX_LEN = 0x1000` est une valeur non vérifiée (TODO amont) ;
- variable globale `pat_protocol` : comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
