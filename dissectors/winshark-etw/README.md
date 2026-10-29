# Winshark — ETW (Event Tracing for Windows)

Dissecteurs Wireshark en Lua pour les événements ETW (Event Tracing for
Windows) capturés via le backend ETW de libpcap du projet Winshark, issue #1.
Le plugin principal (`0winshark.lua`) dissèque l'en-tête des événements ETW
(taille, type, processus, fil, horodatage, provider, descripteur d'événement),
puis délègue aux dissecteurs de provider (`Microsoft_Windows_NDIS_PacketCapture`,
`Microsoft_Windows_PktMon`) ; `Tracelogging.lua` gère les événements
TraceLogging dont le schéma est porté par les données étendues.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/airbus-cert/Winshark |
| Commit importé | `d56586da8474975421651f16905d7e76023b5872` (28/01/2022, « Fix documentation » — dernier commit du dépôt amont, inactif depuis) |
| Licence amont | Apache-2.0 (`LICENSE` amont) — compatible GPLv3, donc avec la licence du dépôt (GPL-3.0-or-later) ; les fichiers importés conservent leur identifiant SPDX amont |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent) |

Fichiers importés tels quels (aucune modification de code, y compris les fins
de ligne CRLF de `Microsoft_Windows_PktMon.lua`) ; seule une en-tête
`SPDX-License-Identifier: Apache-2.0` avec la provenance est ajoutée
(convention du dépôt, issue #563).

## Fichiers

- `src/0winshark.lua` — dissecteur principal « winshark » : en-tête ETW, table
  de délégation par provider ;
- `src/Microsoft_Windows_NDIS_PacketCapture.lua` — provider
  Microsoft-Windows-NDIS-PacketCapture (2ed6006e-4729-4609-b423-3ee7bcd678ef) ;
- `src/Microsoft_Windows_PktMon.lua` — provider Microsoft-Windows-PktMon
  (4d4f80d9-c8bd-4d73-bb5b-19c90402c5ac) ;
- `src/Tracelogging.lua` — événements TraceLogging (schéma auto-décrit dans
  les données étendues).

Le dépôt amont contient aussi le générateur C# (« transluator », qui produit
des dissecteurs Lua à partir de manifests ETW), l'infrastructure CMake et les
images de documentation — non importés (hors périmètre Lua).

## Utilisation

Placer les fichiers `src/*.lua` dans un dossier de plugins Lua de Wireshark,
ou lancer explicitement, par exemple :
`tshark -X lua_script:src/0winshark.lua -X lua_script:src/Tracelogging.lua -V`.
La capture des événements ETW eux-mêmes suppose le backend ETW de libpcap
décrit dans le README amont (named pipe `winshark`), fourni par le projet
Winshark hors fichiers Lua.
