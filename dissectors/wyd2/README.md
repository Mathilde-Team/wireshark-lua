# WYD2 (With Your Destiny)

Dissecteur Wireshark en Lua du protocole TCP du jeu en ligne WYD2 (With Your
Destiny), avec déchiffrement à la volée : en-tête (taille, clé, somme de
contrôle, opcode, identifiant client, horodatage), vérification de la somme de
contrôle, nom des opcodes documentés, octets déchiffrés et charge utile en
texte (issue #376).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jhonatanruelo/wyd-decrypt-plugin |
| Commit importé | `7aba0a8a8315ac1d533059a15a60670ef6006570` du 05/08/2026 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2026 Daniel ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur WYD natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wyd.lua` | Protocole `wyd` : TCP 8281 (préférence « TCP port », prise en compte à chaud via `prefs_changed`) et heuristique TCP (code d'initialisation `0x1f11f311` ou première trame à somme de contrôle valide), saut du code d'initialisation, découpage et réassemblage des paquets, déchiffrement à partir de l'octet 4, vérification de la somme de contrôle (info expert), noms d'opcodes |
| `src/key_table.lua` | Table de clés de 512 octets (hexadécimal), chargée par `require("key_table")`, à remplacer si le jeu change ses clés |

Fichiers repris tels quels, en-tête de provenance ajouté. Non importés :
`README.md` (repris ci-dessus) et la capture d'écran `decrypt-plugin.jpeg`.

## Utilisation

Copier `src/wyd.lua` et `src/key_table.lua` côte à côte dans le dossier des
plugins Lua personnels de Wireshark, puis redémarrer (ou « Analyse →
Recharger les plugins Lua »). Filtres proposés par l'amont : `wyd`,
`wyd.opcode == 0x036c`, `wyd.opcode.name == "MOVE"`,
`wyd.checksum.status == "FAIL"`.

## Limites constatées à l'import

- heuristique TCP active par défaut : hors code d'initialisation, elle
  accepte un flux dès qu'une première trame a une somme de contrôle valide,
  sur un seul octet (de l'ordre d'une chance sur 256 de faux positif par flux
  examiné) ;
- nom de module générique `key_table` : conflit possible avec un autre
  plugin qui fournirait un module du même nom ;
- opcodes non documentés affichés « Unknown » ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel (l'amont indique des tests sous
  Wireshark 4.6.7).
