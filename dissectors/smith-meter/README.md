# SMITH (compteurs industriels)

Dissecteur Wireshark Lua du protocole de communication **SMITH** des
compteurs industriels Smith Meter, sur TCP
7734 : distingue requêtes du maître et réponses des compteurs, adresse du
compteur et commande à deux lettres (une quarantaine de commandes nommées).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MarkoBursic/SMITH-meter-Wireshark-dissector |
| Commit importé | `e9964f7d82e98c9fd15b50284532ab47788df145` du 17/04/2024 (branche `main`, dernier commit, « Update smith-dissector.lua ») |
| Licence amont | « GPL according to Wireshark Foundation ToS » (en-tête de `smith-dissector.lua`, sans version précisée ; interprétée à la Wireshark — GPL-2.0-or-later, compatible GPL-3.0-or-later, comme pour `mysql-x-protocol`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SMITH natif |

Le dépôt amont ne contient pas de fichier de licence : la mention d'en-tête
est la seule déclaration de licence (pas de `LICENSE` dans ce dossier).

## Fichiers

| Fichier | Rôle |
|---|---|
| `smith-dissector.lua` | Dissecteur SMITH (TCP 7734), filtres `SMITH`, `SMITH.Addr`, `SMITH.start` |

Fichier importé tel quel. Seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `smith-dissector.lua` dans le dossier des plugins Lua personnels de
Wireshark (Aide → À propos de Wireshark → Dossiers), puis recharger les
plugins Lua. Exemples de filtres (README amont) :

- `SMITH` : uniquement les échanges avec les compteurs ;
- `SMITH.Addr==n` : échanges avec le compteur d'adresse `n` ;
- `SMITH.start==Query` / `SMITH.start==Resp` : requêtes du maître / réponses.

## Remarques

- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
- L'adresse du compteur est calculée à partir de deux chiffres ASCII ; une
  trame mal formée donne une adresse incohérente, sans erreur.
