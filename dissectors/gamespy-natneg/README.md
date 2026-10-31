# GameSpy NAT Negotiation (NatNeg)

Dissecteur Wireshark Lua du protocole GameSpy NAT Negotiation sur UDP, utilisé
par les jeux en ligne GameSpy pour établir des connexions pair à pair à
travers les NAT : en-tête (magie, version, type, cookie) et paquets INIT,
CONNECT, REPORT, PREINIT et accusés de réception (issue #309).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/XeR/gamespy-wireshark (archivé par l'auteur) |
| Commit importé | `731ce0373fabe1e9be54cd79746630d3d6e31469` du 30/09/2017 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur GameSpy natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/natneg.lua` | Protocole `natneg` : heuristique UDP sur la magie `FD FC 1E 66 6A B2`, version, 17 types de paquets nommés, cookie ; détail des paquets INIT (type de port, index client, IP et port locaux, nom du jeu), CONNECT, REPORT (type de NAT, schéma de correspondance), PREINIT et ACK |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/natneg.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Détection automatique sur tout le trafic UDP.
Filtre : `natneg`.

## Limites constatées à l'import

- dans `parse_natneg`, la variable locale `cookie` (valeur numérique) masque
  le champ global `cookie` : `subtree:add(cookie, cookie)` reçoit un nombre
  au lieu d'un `ProtoField`, ce qui devrait provoquer une erreur Lua après
  l'en-tête, avant le détail du paquet ;
- deux champs différents partagent l'abréviation `natneg.report.type`
  (type de port sur 1 octet et type de NAT sur 4 octets) ;
- de nombreuses variables globales (`p_natneg`, `enum_*`, champs, fonctions
  `parse_*`) ;
- libellé « Sever result » (coquille amont) conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
