# HEP / HOMER (Homer Encapsulation Protocol)

Dissecteur Wireshark Lua pour HEP (Homer Encapsulation Protocol), versions 2 et 3 : protocole d'encapsulation utilisé par HOMER pour corréler des captures SIP/RTP distribuées sur plusieurs points de capture.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/sipcapture/hep-wireshark |
| Commit importé | `9a087c921ccc841b5bf2c947a5fbd79e772d269f` du 16/10/2026 (branche `master`) |
| Licence amont | GPLv2 ou toute version ultérieure (énoncée dans les en-têtes des fichiers Lua) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur HEP natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hep.lua` | Dissecteur HEP v2/v3 : transports UDP (9060, 9063), TCP (9060, 9062, 9063), HTTP/HTTP2 (media types `application/hep`, `application/vnd.3gpp.hep`) |
| `src/vendors/eep-um.lua` | Dissecteur EEP-UM (protocole embarqué), fourni séparément par l'amont dans `lua/vendors/` |

Le dépôt amont contient aussi `lua/README.md` et `lua/HTTP_SUPPORT.md` (documentation, reprise ci-dessous), et des captures d'exemple (`pcap/hep.pcap`, `pcap/hep3_compressed.pcap.pcapng`) : non importés.

## Utilisation

Copier `src/hep.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Le support HTTP/HTTP2 permet la dissection de HEP dans les environnements 5G où HEP voyage sur des protocoles HTTP.

## Limites constatées à l'import

- `eep-um.lua` est un dissecteur autonome sans lien avec `hep.lua` (l'amont le fournit dans `vendors/`) ;
- spécification HEP3 : `HEP3_rev12.pdf` du dépôt [sipcapture/HEP](https://github.com/sipcapture/HEP) (non importée, format PDF).
