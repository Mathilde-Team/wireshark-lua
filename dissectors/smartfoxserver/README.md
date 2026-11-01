# SmartFoxServer

Dissecteur Wireshark Lua pour le protocole SmartFoxServer 2X transporté sur
TCP (ports 9933 et 9339) : réassemblage des paquets répartis sur plusieurs
segments TCP, décompression DEFLATE des messages et décodage des objets
SFSObject/SFSArray (types, champs, valeurs).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/xuwaters/wireshark-smartfoxserver |
| Commit importé | `039e9612b1fc5ca834adc2dfa01fed924441e912` du 19/05/2017 (branche `master`, commit unique — dépôt archivé) |
| Licence amont | MIT (`sfs.lua`, `deps/sfsio.lua` : « Copyright (c) 2015 xuwaters ») ; `deps/crc32lua.lua` et `deps/deflatelua.lua` : MIT (David Manura, 2008-2011) ; `deps/json.lua` : CC-BY-3.0 (Jeffrey Friedl) |
| Natif Wireshark 4.6.4 | Non — aucun dissector SmartFoxServer natif dans Wireshark |

Texte complet de la licence MIT amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont). Les en-têtes de chaque module conservent leur
licence propre (voir les fichiers).

## Fichiers

| Fichier | Rôle |
|---|---|
| `sfs.lua` | Dissecteur SmartFoxServer (ports 9933/9339, réassemblage TCP, DEFLATE, SFSObject) |
| `deps/sfsio.lua` | Lecture des flux binaires SFS |
| `deps/json.lua` | JSON (Jeffrey Friedl) utilisé pour l'affichage |
| `deps/deflatelua.lua` | Décompression DEFLATE (David Manura) |
| `deps/crc32lua.lua` | CRC-32 (David Manura) |
| `docs/SFSObjectFormat.txt` | Documentation amont du format SFSObject |

## Utilisation

Copier `sfs.lua` et le dossier `deps/` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua
(`sfs.lua` fait `require "deps.sfsio"` etc. — conserver l'arborescence).

## Remarques

Dépôt amont archivé (créé et figé en mai 2017, commit unique) : pas de mise à
jour amont attendue. Le port 9933 est le port par défaut de SmartFoxServer 2X ;
9339 est également écouté par le dissecteur.
