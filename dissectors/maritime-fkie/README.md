# Maritime (Fraunhofer FKIE) — IEC 61162-450, NMEA 0183/2000, radars Navico BR24 et Furuno

Dissecteurs Wireshark en Lua de Fraunhofer FKIE pour les protocoles des
réseaux de bord, issue #40 :

- `maritime-dissector.lua` : IEC 61162-450 (Lightweight Ethernet, trames
  NMEA et fichiers binaires), NMEA 0183 sur UDP, NMEA 2000 (PGN) sur CAN ;
- `br24-dissector.lua` : radar Navico BR24 (image, registres, rapports) ;
- `furuno-dissector.lua` : radars Furuno (image, encodages niveau 3 et 0).

Complète `dissectors/nmea0183/` (kmpm, #24) avec IEC 61162-450, NMEA 2000 et
les radars ; les deux se chargent ensemble sans conflit de nom de protocole
(`NMEA0183`/`NMEA` d'un côté, `nmea-0183` de l'autre).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/fkie-cad/maritime-dissector |
| Commit importé | `8fdd466580ef6279971a9090c542284ea7959869` du 24/03/2026 |
| Licence amont | « MIT License (supplemented) » (`LICENSE` amont) : texte MIT complété d'une clause précisant qu'aucun droit de propriété intellectuelle de tiers n'est concédé — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non pour IEC 61162-450, NMEA 2000 sur IP, Navico BR24 et Furuno |

Fichiers Lua importés tels quels (aucune modification de code), structure
amont conservée (`*-modules/` chargés par `require` relatif au dossier des
plugins) ; seule une en-tête `SPDX-License-Identifier:
LicenseRef-FKIE-MIT-supplemented` avec la provenance est ajoutée (convention
du dépôt, issue #563). Identifiant `LicenseRef-` car la clause ajoutée
empêche la correspondance exacte avec l'identifiant SPDX `MIT`.

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Chemin | Rôle |
|---|---|
| `src/maritime-dissector.lua` | Point d'entrée IEC 61162-450 / NMEA 0183 / NMEA 2000 |
| `src/maritime-modules/` | Analyseurs (`parser/`), protocoles (`proto/`, dont 245 PGN NMEA 2000 générés dans `proto/pgn/`), tables d'identifiants (`knownids/`), heuristiques et utilitaires |
| `src/br24-dissector.lua`, `src/br24-modules/` | Radar Navico BR24 |
| `src/furuno-dissector.lua`, `src/furuno-modules/` | Radars Furuno |

Non importés : `tests/` (238 Mo de captures, JSON et scripts Python de
test), `docs/` (documentation des protocoles BR24/Furuno, images),
`install.sh` et les générateurs Python des PGN (`pgn.py`, `lua_codegen.py`,
`field_handlers.py`) ; ils restent disponibles dans le dépôt amont.

## Utilisation

Copier le contenu de `src/` (fichiers `*-dissector.lua` et dossiers
`*-modules/`) dans le dossier des plugins Lua personnels de Wireshark (ex.
`~/.local/lib/wireshark/plugins/`), puis redémarrer Wireshark ou recharger
les plugins Lua (Ctrl+Maj+L). Wireshark 4.0 ou plus récent (Lua 5.4) requis
selon l'amont.

## Vérification à l'import

Avec tshark 4.6.4, plugins installés comme ci-dessus, sur les 15 captures
`tests/*.pcap` de l'amont (non importées) : aucune erreur Lua ; les trames
sont décodées en `navicobr24-img`/`-reg`/`-rep`, `furuno-img`,
`iec-61162-450-binary` et `nmea-0183` (dont les cas d'erreur : somme de
contrôle fausse, phrase ou balise trop longue). Chargement simultané avec
`dissectors/nmea0183/` vérifié.

## Limites constatées à l'import

- NMEA 2000 non vérifié ici : l'amont génère ses captures de test à partir
  de JSON par script (`tests/nmea2000/`), non rejoué ;
- encodage Furuno niveau 0 non testé par l'amont (pas d'échantillon) ;
- la clause ajoutée à la licence rappelle que les droits de tiers
  (spécifications NMEA/IEC, protocoles constructeurs) ne sont pas concédés.
