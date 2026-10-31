# GNU gzochi

Dissecteurs Wireshark en Lua des deux protocoles du framework de jeux
multijoueurs GNU gzochi (issue #372) :

- `gzochi` (TCP 8001) : protocole de jeu entre les clients et le serveur
  d'application gzochid (connexion, déconnexion, messages de session) ;
- `gzochi-meta` (TCP 9001) : méta-protocole entre gzochid et le méta-serveur
  gzochi-metad (connexion, requêtes et réponses de données, jeux de
  modifications, verrous de clés, relais de sessions et de canaux).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/gitGNU/gnu_gzochi (dossier `gzochi-server/contrib/`) |
| Commit importé | `0487854b5a8f4f573c2d83035770bfc8271b77fe` du 20/04/2017 (dernier commit de `master`) |
| Licence amont | GPLv3 ou ultérieure (en-tête des deux fichiers : « Copyright (C) 2017 Julian Graham », « either version 3, or (at your option) any later version ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur gzochi natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `gzochi-server/COPYING`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/game-protocol.lua` | Protocole `gzochi` sur TCP 8001 : PDU préfixées par une longueur sur 2 octets (réassemblage par `dissect_tcp_pdus`), types `LOGIN_REQUEST`, `LOGIN_SUCCESS`, `LOGIN_FAILURE`, `LOGOUT_REQUEST`, `LOGOUT_SUCCESS`, `SESSION_DISCONNECTED`, `SESSION_MESSAGE` |
| `src/meta-protocol.lua` | Protocole `gzochi-meta` sur TCP 9001 : connexion au méta-serveur, requêtes OID/valeur/clé suivante, jeux de modifications, libération de clés et d'intervalles, relais de sessions et de canaux |

Fichiers repris tels quels, en-tête de provenance ajouté. Le reste du dépôt
(serveur, clients, exemples, en C, Scheme…) est hors périmètre.

## Utilisation

Copier un des deux fichiers de `src/` dans le dossier des plugins Lua de
Wireshark (ou `wireshark -X lua_script:game-protocol.lua`), puis redémarrer.
Filtres : `gzochi`, `gzochi-meta`. Hors des ports par défaut, utiliser
« Décoder comme… ».

## Limites constatées à l'import

- les deux fichiers définissent les mêmes fonctions et tables globales
  (`get_len`, `dissect`, `msg_type_dissectors`,
  `dissect_session_disconnected`) : chargés ensemble, le dernier chargé
  remplace celles de l'autre, qui décode alors avec la mauvaise table de
  messages ; charger un seul des deux à la fois ;
- `game-protocol.lua` nomme ses champs `gzochi-meta.*` (et non `gzochi.*`),
  les mêmes noms que ceux de `meta-protocol.lua` ;
- type de message inconnu : rien n'est affiché ;
- dépôt amont (miroir GNU) sans activité depuis 2017, pas de capture
  d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée.
