# SOME/IP et SOME/IP-SD (Ethernet automobile)

Dissecteurs Wireshark en Lua pour SOME/IP (Scalable service-Oriented
MiddlewarE over IP) et son protocole de découverte de services SOME/IP-SD,
issue #3. `someip.lua` dissèque l'en-tête SOME/IP (message ID, longueur,
identifiant de requête, type de message, etc.) et délègue la découverte de
services à `sd.lua`, aidé de `sd_entries.lua` (entrées de service/instance
et événements) et `sd_options.lua` (options de configuration).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jamores/eth-ws-someip |
| Commit importé | `39c7529577e27c80f18d7362204eadf026b42ec9` (22/06/2025, « Update sd_entries.lua ») |
| Licence amont | MIT (`LICENSE` amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | oui (dissecteurs natifs SOME/IP et SOME/IP-SD depuis Wireshark 3.2.0 ; ce plugin Lua reste utilisable en complément ou sur des installations plus anciennes) |

Fichiers importés tels quels (aucune modification de code) ; seule une
en-tête `SPDX-License-Identifier: MIT` avec la provenance est ajoutée
(convention du dépôt, issue #563).

## Fichiers

- `src/someip.lua` — dissecteur SOME/IP (en-tête, tables de délégation) ;
- `src/sd.lua` — SOME/IP-SD (en-tête de message de découverte) ;
- `src/sd_entries.lua` — entrées de services/instances et événements ;
- `src/sd_options.lua` — options de configuration.

Le dépôt amont contient aussi des antisèches SOME/IP-SD (PNG/Dia), les
spécifications AUTOSAR (PDF, ~3,7 Mo) et un README — non importés (les
spécifications AUTOSAR ne sont pas sous licence libre).

## Utilisation

Placer `src/someip.lua`, `src/sd.lua`, `src/sd_entries.lua` et
`src/sd_options.lua` dans un dossier de plugins Lua de Wireshark (ils se
chargent ensemble), ou lancer explicitement :
`tshark -X lua_script:src/someip.lua -X lua_script:src/sd.lua -X lua_script:src/sd_entries.lua -X lua_script:src/sd_options.lua -V`.
