# plugin-shark (collection de greffons Wireshark/tshark)

Collection de greffons Wireshark/tshark de phreakocious : colonnes L4, statistiques par conversation TCP, TCPextend, TLSextend, HTTP extra, MS-TURN/ICE/RTP pour Lync/Skype for Business.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/phreakocious/plugin-shark |
| Commit importé | `96ff6f044b3d0409bc9a1588c8be912ac3b3f77f` du 05/10/2026 (branche `master`) |
| Licence amont | BSD-2-Clause pour l'outillage du dépôt ; chaque greffon garde la sienne (voir ci-dessous) |
| Natif Wireshark 4.6.4 | Oui et non — voir la section « Natif » |

## Fichiers

| Fichier | Rôle | Licence amont |
|---|---|---|
| `src/gd_l4/gd_l4.lua` | Index de flux L4 et nom de protocole, une colonne pour tous les protocoles | GPL-3.0 (`LICENSE` du dossier) |
| `src/gd_tcflag/gd_tcflag.lua` | Drapeaux et statistiques par conversation TCP (filtre de flux entiers) | GPL-2.0+ (en-tête du fichier) |
| `src/wireshark-tcpextend/TCPextend-post_dissector.lua` | Bytes in flight, bytes since push, delta par émetteur | GPL-2.0 (`LICENSE` du dossier) |
| `src/TLSextend/TLSextend.lua` | État du handshake TLS par flux TCP (`TLSextend.state==1` : ClientHello sans ServerHello) | GPL-3.0+ (en-tête du fichier) |
| `src/wireshark-http-extra/http_response_patcher.lua` | Méthode, URI et hôte sur chaque réponse HTTP ; URL complète | GPL-3.0 (`LICENSE.md` du dossier) |
| `src/Lync-Skype4B-Plugin2_00.lua` | MS-TURN, ICE et RTP/RTCP pour Lync et Skype for Business (James Cussen v2.0.0) | Licence spécifique de l'auteur : redistribution autorisée si copyright/conditions/disclaimer conservés (respecté : fichier importé tel quel), mais **sans usage commercial ni revente sans accord écrit** — conditions 4-5 de l'en-tête |

Les greffons vendored sont les versions patchées par l'amont pour Wireshark 4.x (leur provenance d'origine est nommée en tête de chaque fichier amont).

## Non importé

| Élément | Raison |
|---|---|
| `mpeg_packets_dump.lua` (Cisco) | Aucune licence énoncée : pas de droit de redistribution |
| `tcp_stats.lua.disabled` (Silvio Gissi) | Aucune licence énoncée : pas de droit de redistribution |
| `wireshark-plugins/` (Cap'n Proto RPC) | Sous-module git vers un dépôt amont distinct (kaos/wireshark-plugins) |
| `check.sh`, `test.pcap`, `preferences.plugin-shark`, `README.md` | Outillage du dépôt, pas des scripts Lua |

## Natif Wireshark 4.6.4

L'amont a lui-même abandonné des greffons devenus natifs. Sont importés ici des greffons toujours utiles en 4.6 (gd_l4, gd_tcflag, TCPextend, TLSextend, http-extra, Lync) ; TCPextend et TLSextend remplissent leurs champs au deuxième passage : en tshark, utiliser `-2 -R frame`.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/plugin-shark/`) : Wireshark charge chaque `.lua` du dossier, sous-dossiers inclus. `tcp_stats.lua.disabled` de l'amont se lançait à la demande via `-X lua_script:` — non importé.
