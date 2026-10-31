# Bitmessage — messages du protocole pair-à-pair Bitmessage

Dissecteur Wireshark en Lua du protocole Bitmessage (messagerie pair-à-pair
chiffrée) sur TCP 8444 : en-tête (magie, commande, longueur), messages
`version`, `verack`, `addr`, `inv`, `getdata`, et objets `getpubkey`,
`pubkey`, `msg`, `broadcast` (parties non chiffrées), avec réassemblage TCP
(issue #405).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jesperborgstrup/bitmessage-wireshark-dissector (archivé par son auteur) |
| Commit importé | `1eb0b4fa4653bc1d09e2e9b24357240752d17493` du 29/01/2014 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2014 Jesper Borgstrup ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Bitmessage natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/bitmessage.lua` | Protocole `bitmessage` sur TCP 8444 |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/bitmessage.lua` dans le dossier des plugins Lua de Wireshark.
Filtre : `bitmessage`. Article de l'auteur :
https://jesper.borgstrup.dk/2014/01/bitmessage-protocol-dissector-for-wireshark/

## Limites constatées à l'import

- écrit pour le protocole Bitmessage de janvier 2014 : les versions
  ultérieures (objets regroupés sous la commande `object`) ne sont pas
  couvertes ;
- seules les parties non chiffrées sont lisibles ;
- aucun `ProtoField` : l'arbre ne contient que des libellés texte, non
  filtrables champ par champ ;
- variables et fonctions globales (`message_commands`, `tcp_table`,
  `parse_var_int`…) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
