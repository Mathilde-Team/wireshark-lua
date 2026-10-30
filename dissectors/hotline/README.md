# Hotline — commandes, transferts, tracker et tunnel HTTP

Dissecteur Wireshark en Lua de la famille de protocoles Hotline classique :
poignée de main `TRTP`/`TRTPHOTL` et transactions, transferts de fichiers
`HTXF`, tracker `HTRK` (requêtes TCP, inscriptions UDP) et enregistrements du
tunnel HTTP, avec réassemblage TCP et champs filtrables (issue #408).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jhalter/hotline-wireshark-dissector |
| Commit importé | `ad8ea6b6c8078e69d4a7136aefec52d0cea8eb7f` du 21/08/2026 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2024-2026 Jeff Halter ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Hotline natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hotline-proto.lua` | Protocoles `HOTL` (TCP 5500), `HTXF` (TCP 5501), `HTRK` (TCP 5498, UDP 5498-5499) et `HLHTTP` (type de média `hotline/protocol`) ; heuristiques TCP/UDP ; ports modifiables dans les préférences |

Fichier repris tel quel, en-tête de provenance ajouté. Non importés : tests
amont (`tests/`, banc d'essai avec simulation de l'API Wireshark), `Makefile`,
`CHANGELOG.md`, workflow GitHub, `README.md`.

## Utilisation

Copier `src/hotline-proto.lua` dans le dossier des plugins Lua de Wireshark.
Filtres : protocoles `hotl`, `htxf`, `htrk`, `hlhttp` ; champs préfixés
`hotline.`, `htxf.`, `htrk.`, `hlhttp.` (par exemple `hotline.tran_id`). Les ports se changent dans les préférences de chaque
protocole ; « Décoder comme » reste disponible pour les ports non standard.

## Limites constatées à l'import

- les tests amont n'ont pas été importés : ils chargent `hotline-proto.lua`
  depuis la racine du dépôt amont ; lancés sur l'arborescence amont au commit
  importé (`lua5.4 tests/test_runner.lua`) : 25 tests, 0 échec ;
- l'option `decode_obfuscated_credentials` (et `show_credentials` pour le
  tracker) affiche des identifiants : à n'activer que sur des captures
  maîtrisées ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée dans Wireshark.
