# JGroups 3.2.12 — communication de groupe (JBoss)

Dissecteur Wireshark en Lua des paquets JGroups 3.2.12 (version livrée avec
JBoss EAP 6), sur UDP et TCP, détectés par heuristique : en-tête de message,
adresses, vues, digests et en-têtes des protocoles de la pile (PING, FD,
FD_ALL, FD_SOCK, MERGE3, UNICAST2, NAKACK, STABLE, GMS, RSVP…) (issue #414).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nak3/jgroups-wireshark-dissector |
| Commit importé | `5031dd04392cebe64d6ff8aa4e6eb45b4c23d30c` du 29/03/2014 (dernier commit de `master`) |
| Licence amont | GPL-2.0-or-later (en-tête de chacun des 33 fichiers Lua : « either version 2 of the License, or (at your option) any later version », © 2014 Kenjiro Nakayama) ; fichier `LICENSE` : texte GPLv2 |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur JGroups natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

33 modules Lua dans `src/jgroups-dissector/` (arborescence amont conservée) :

| Fichier ou dossier | Rôle |
|---|---|
| `jgroups-dissector.lua` | Point d'entrée : protocole `jgroups_proto`, heuristiques UDP et TCP |
| `head.lua`, `jgroups-field.lua` | Fonctions communes et `ProtoField`, chargés par `dofile` |
| `Message.lua`, `View.lua`, `ViewId.lua`, `Bits.lua`, `protocol_id.lua`, `supported_version.lua` | Message JGroups et structures de base |
| `protocols/` | En-têtes des protocoles de la pile (dont `pbcast/`, `relay/`) |
| `blocks/`, `stack/`, `util/` | Corrélateur de requêtes, connexions TCP, adresses IP, UUID, digests, utilitaires |

Fichiers repris tels quels, en-tête de provenance ajouté. Non importés : `demo/`
(captures pcap TCP et UDP, configuration JBoss, capture d'écran), `README.md`.

## Utilisation

Copier le dossier `src/jgroups-dissector/` tel quel dans le dossier des plugins
Lua personnels de Wireshark : `jgroups-dissector.lua` charge `head.lua` et
`jgroups-field.lua` par
`dofile(Dir.personal_plugins_path() .. "/jgroups-dissector/…")`. Filtre :
`jgroups_proto`.

## Limites constatées à l'import

- `jgroups-dissector.lua` appelle `package.prepend_path(…)`, fonction Lua que
  Wireshark définissait dans son `init.lua` jusqu'à la version 4.0 ; elle
  n'existe plus depuis la 4.2 : erreur au chargement sous 4.6.4. Wireshark
  ajoute lui-même les sous-dossiers du dossier des plugins à `package.path` ;
  supprimer ces quatre appels devrait suffire, non vérifié ;
- seule la version 3.2.12 de JGroups est reconnue ; testé par l'amont sous
  Wireshark 1.11.3 ;
- Wireshark charge aussi comme greffons tous les modules `.lua` des
  sous-dossiers ; nombreuses variables globales (`Util`, `ViewId`,
  `plugin_path`, `subtree`…) ;
- pas de réassemblage TCP explicite ;
- pas de capture d'exemple dans ce dépôt (celles de l'amont, dans `demo/`, ne
  sont pas importées) : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection
  testée.
