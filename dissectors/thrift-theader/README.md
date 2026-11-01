# Apache Thrift — THeader + TBinary (eaceaser)

Dissecteur Wireshark en Lua générique des messages Apache Thrift transportés
avec le protocole THeader et sérialisés en TBinary : en-tête THeader (taille,
magie, drapeaux, séquence, en-têtes clé/valeur), puis message TBinary (nom de
méthode, type CALL/REPLY/EXCEPTION/ONEWAY, numéro de séquence, champs par
identifiant et type, structures, listes, maps, ensembles), avec réassemblage
TCP (issue #394).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/eaceaser/wireshark-thrift-dissector |
| Commit importé | `447890b8f8896f4169ff6a3ff550a18008428161` du 15/06/2021 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2019 Ed Ceaser » ; en-tête du fichier : « licensed under MIT license ») |
| Natif Wireshark 4.6.4 | Partiel — `packet-thrift.c` (protocole `thrift`) décode TBinary et TCompact, mais ne mentionne pas le transport THeader |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/thrift-generic.lua` | Protocoles `theader` (TCP 9090) et `tbinary` |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

```sh
wireshark -X lua_script:thrift-generic.lua capture.pcap
```

ou copier `src/thrift-generic.lua` dans le dossier des plugins Lua. Le port
9090 est décodé par défaut (table `default_settings` du script) ; ajouter
d'autres ports avec « Décoder comme… ». Filtres : `theader`, `tbinary`.

## Limites constatées à l'import

Limites signalées par l'amont :

- seuls les noms de méthodes sont connus : les champs n'ont que leur
  identifiant (voir l'IDL Thrift) ;
- THeader obligatoire (pas de TFramed sans en-tête), types UTF8/UTF16 non
  pris en charge ;
- lenteur sur les gros messages fragmentés (mise en mémoire jusqu'au message
  complet) ;
- pas de préférences : le port se change dans le code.

Constatées à l'import :

- utilise `bit32`, disponible selon la version de Lua embarquée par Wireshark ;
- globales (`ThriftBuffer`, constantes `THRIFT_*`) ;
- sur le port 9090, entre en concurrence avec le dissecteur `thrift` natif si
  celui-ci y est configuré ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
