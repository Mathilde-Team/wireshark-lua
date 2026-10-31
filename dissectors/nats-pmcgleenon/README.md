# NATS (pmcgleenon) — protocole client NATS

Dissecteur Wireshark en Lua du protocole client NATS sur TCP 4222 : commandes
`PUB`, `SUB`, `UNSUB`, `MSG`, `HPUB`, `HMSG`, groupes de files,
auto-désabonnement, accusés `+OK`/`-ERR`, en-têtes et charges JSON décodées
(issue #409).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pmcgleenon/nats-wireshark-dissector |
| Commit importé | `ab81a031477ed198023a3401ae9f747fb190d0e1` du 18/04/2025 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2025 Patrick McGleenon ») ; `dkjson.lua` : MIT (dkjson 2.8, « Copyright (C) 2010-2024 David Heiko Kolf », mention dans le fichier) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur NATS natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont) ; la licence de `dkjson.lua` figure en tête du fichier.

## Fichiers

| Fichier | Licence | Rôle |
|---|---|---|
| `src/nats.lua` | MIT | Protocole `nats` sur TCP 4222 |
| `src/dkjson.lua` | MIT | Bibliothèque JSON de David Heiko Kolf (2.8), chargée par `require("dkjson")` |

Fichiers repris tels quels, en-tête de provenance ajouté.

## Utilisation

Copier `src/nats.lua` et `src/dkjson.lua` dans le dossier des plugins Lua de
Wireshark (l'amont indique Wireshark 4.4.6 ou plus récent). Filtre : `nats`.

## Limites constatées à l'import

- protocole client seulement (pas le protocole de cluster, port 6222) ;
- pas de réassemblage TCP : une commande ou une charge coupée entre deux
  segments est mal découpée ;
- `require("dkjson")` dépend du `package.path` de Wireshark : selon la
  version et l'installation, le dossier des plugins n'y figure pas forcément ;
  `dkjson.lua`, placé dans le dossier des plugins, est aussi chargé comme
  greffon (sans effet, il ne déclare pas de protocole) ;
- l'issue #411 vise un autre dissecteur NATS : si les deux déclarent le
  protocole `nats`, ils ne peuvent pas être chargés ensemble ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
