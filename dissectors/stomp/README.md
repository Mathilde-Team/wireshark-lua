# STOMP — Simple Text Oriented Messaging Protocol

Dissecteur Wireshark en Lua du protocole STOMP (messagerie orientée texte,
ActiveMQ, RabbitMQ…) : commande, en-têtes (clé / valeur), corps (délimité par
`content-length` ou par l'octet nul), sur TCP, sur TLS et dans les charges
WebSocket (issue #392).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/ficoos/wireshark-stomp-plugin |
| Commit importé | `32f276d56d83c9181f1d134e980882a8138abdb9` du 12/02/2024 (dernier commit de `master`) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « either version 2 of the License, or (at your option) any later version » ; fichier `COPYING`) — « Copyright 2009-2012 Red Hat, Inc. », modifications de Hadriel (2015) et Ethan Reesor (2019) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur STOMP natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme du `COPYING` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/stomp.lua` | Protocole `stomp` ; champs `stomp.command`, `stomp.header`, `stomp.header.key`, `stomp.header.value`, `stomp.body` ; préférences de ports TCP, TLS et WebSocket |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/stomp.lua` dans le dossier des plugins Lua de Wireshark. Ports par
défaut du script : TCP 54321, TLS 61614, WebSocket 9000 ; ils se règlent dans
Préférences › Protocols › STOMP (0 pour désactiver). Le port STOMP standard
(61613) n'est pas celui par défaut : l'indiquer dans les préférences ou
utiliser « Décoder comme… ». Filtre : `stomp`.

## Limites constatées à l'import

- la préférence « STOMP-over-SSL TCP Port » a pour valeur par défaut le port
  TCP (54321) au lieu de 61614 : au premier changement de préférences, les deux
  ports sont égaux et le script affiche son message d'erreur sans appliquer les
  changements, tant que le port TLS n'a pas été corrigé ;
- enregistrements sur les tables `ssl.port` et `ws.port` : noms hérités des
  anciennes versions de Wireshark, leur disponibilité sous 4.6.4 n'est pas
  vérifiée (la table TLS s'appelle `tls.port` depuis Wireshark 3.0) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
