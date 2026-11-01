# Signal — protobufs dans les WebSockets de Signal

Post-dissecteur Wireshark en Lua qui interprète les données des WebSockets
(une fois le TLS déchiffré) comme des messages protobuf Signal
`signalservice.WebSocketMessage`. Il enchaîne ensuite sur les corps de
requête et de réponse (JSON ou `textsecure.Envelope`) et sur le contenu
« sealed sender » (`UnidentifiedSenderMessage`), au moyen du dissecteur
`protobuf` natif et des fichiers `.proto` de Signal (issue #419).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jtracey/UseSignalUseTor (dossier `Traffic-Analysis/`) |
| Commit importé | `02ff7d87875088fbc83b7cd8d81b09cc222bc4d0` du 04/03/2026 (dernier commit de `main`, qui ajoute la licence MIT) ; `signal_protobuf.lua` inchangé depuis `a97dbfeb40095bbb1cdd313bdd61d0e4624b13ca` du 20/04/2024 |
| Licence amont | MIT pour `signal_protobuf.lua` (fichier `LICENSE` à la racine, « Copyright (c) 2026 Justin Tracey ») ; AGPL-3.0-only pour les `.proto` (© Signal Messenger, LLC, `SPDX-License-Identifier: AGPL-3.0-only` dans chaque fichier, `Traffic-Analysis/protobufs/LICENSE`) |
| Natif Wireshark 4.6.4 | Partiel — WebSocket, TLS, JSON et Protobuf natifs ; aucun dissecteur Signal natif |

Textes complets des licences amont : `LICENSE.txt` (copie conforme du `LICENSE`
amont, MIT) et `LICENSE-AGPL-3.0.txt` (copie conforme de
`Traffic-Analysis/protobufs/LICENSE`, GNU AGPL v3).

## Fichiers

| Fichier | Licence | Rôle |
|---|---|---|
| `src/signal_protobuf.lua` | MIT | Protocoles `signal_protobuf` (post-dissecteur), `signal_body`, `signal_content` ; liaisons dans la table `protobuf_field` |
| `proto/WebSocketProtocol.proto` | AGPL-3.0-only | `signalservice.WebSocketMessage` |
| `proto/TextSecure.proto` | AGPL-3.0-only | `textsecure.Envelope` |
| `proto/sealed_sender.proto` | AGPL-3.0-only | `signal.proto.sealed_sender.UnidentifiedSenderMessage` |

Le fichier Lua est repris tel quel, avec un en-tête de provenance ajouté. Les
`.proto` sont des copies conformes : ils portent déjà leur mention SPDX et
copyright, et l'amont les avait lui-même recopiés sans modification depuis
Signal. Non importés : le reste du dépôt (scripts d'émulateur, de MITM et
d'analyse, `README.md`).

## Utilisation

D'après le README amont :

1. Dans les préférences TLS, indiquer le fichier de clés (« (Pre)-Master-Secret
   log filename ») et activer le réassemblage TCP et TLS.
2. Dans les préférences ProtoBuf, ajouter le dossier `proto/` aux chemins de
   recherche et activer « Dissect Protobuf fields as Wireshark fields ».
3. Copier `src/signal_protobuf.lua` dans le dossier des plugins Lua, puis
   activer `signal_protobuf`, `signal_body` et `signal_content` dans
   « Protocoles activés ».

## Limites constatées à l'import

- nécessite le déchiffrement TLS (fichier de clés obtenu sur un client
  instrumenté) : sans lui, rien n'est décodé ;
- toutes les données WebSocket sont traitées comme des messages Signal, y
  compris celles d'autres applications : les champs affichés peuvent alors
  être faux (mise en garde de l'amont) ;
- le contenu chiffré de bout en bout des messages reste chiffré ;
- `signal_body` repère le JSON par ses deux premiers caractères (`{"`) ;
  l'extraction du champ `content:` utilise `sub(8)`, qui conserve le
  caractère `:` avant le décodage base64 ;
- variables globales (`wsField`, `wsDataField`, `jsonMembers`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
