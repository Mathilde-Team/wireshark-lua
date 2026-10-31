# Google Protobuf (dissecteur générique)

Dissecteur Wireshark Lua pour les messages Google Protobuf : décodage générique sans schéma, ou décodage typé à partir de fichiers `.proto` (noms de champs, énumérations, oneof, expert info sur champs requis manquants).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/luamagician/protobuf_dissector |
| Commit importé | `a4a9d7e9fac9ce9fbf38dca2c9b9c0cbafaba028` du 03/09/2015 (branche `master`) |
| Licence amont | MIT (128 Technology, Inc. — fichier `LICENSE.md`) |
| Natif Wireshark 4.6.4 | Partiel — Wireshark 4.x embarque un dissecteur natif `protobuf` (conteneur gRPC/HTTP2) ; ce Lua ajoute le décodage typé depuis `.proto` et le mode générique sans schéma |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

49 modules Lua dans `src/` (arborescence amont conservée) :

| Élément | Rôle |
|---|---|
| `src/protobuf.lua` | Point d'entrée (chargé par Wireshark) |
| `src/settings.lua` | Préférences |
| `src/modules/` | Front-end (lexer/parser `.proto`), compilateur, AST, back-end (décodage des messages), préférences |

Non importés : `test/` (tests), `files/` (emplacement prévu pour les `.proto` de l'utilisateur — vide), `README.md`, `.gitattributes`, `.gitignore`.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`), en conservant `modules/`. Déposer les `.proto` dans `src/files/` puis redémarrer Wireshark (pas de rechargement à chaud). Sans `.proto`, le protocole générique « PROTOBUF » décode n'importe quel flux (« Decode As »).

## Limites constatées à l'import

- Protobuf v2 supporté presque intégralement ; v3 non couvert par cette version (2015) ;
- pas de rechargement des `.proto` à chaud (limitation Wireshark de l'époque) ;
- dépôt amont inactif depuis 2015.
