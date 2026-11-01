# Chess MCP : JSON-RPC 2.0 sur WebSocket (jeu d'échecs)

Dissecteur Wireshark Lua du protocole MCP (Model Context Protocol, JSON-RPC 2.0
sur WebSocket) du serveur MCP du jeu d'échecs web `premkumardevadason/chess`
(issue #383).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/premkumardevadason/chess (dossier `wireshark/`) |
| Commit importé | `5b9a6b8b586f13d54b479b6b4081ca3f691d21eb` du 23/09/2025 (dernier commit de la branche par défaut) |
| Licence amont | MIT, déclarée dans le `README.md` amont (section « License » : « This project is open source and available under the MIT License »), sans fichier `LICENSE` |
| Natif Wireshark 4.6.4 | Non |

Le dépôt amont n'a pas de fichier `LICENSE` : `LICENSE.md` dans ce dossier
reprend le texte standard de la licence MIT, au nom du titulaire du dépôt
(`premkumardevadason`). Le fichier `.lua` est repris sans modification ;
seule une en-tête SPDX et de provenance a été ajoutée. La version C du
dissecteur (`mcp_dissector.c`, `CMakeLists.txt`) n'est pas importée.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mcp_dissector.lua` | Protocoles `mcp` et `mcp_ws` : requêtes, réponses et erreurs JSON-RPC du serveur MCP (méthode, identifiant, paramètres, agent, messages chiffrés) |

## Utilisation

Copier `src/mcp_dissector.lua` dans le dossier des plugins Lua personnels de
Wireshark (`~/.local/lib/wireshark/plugins/` sous Linux).

## Licence

`MIT`, licence amont conservée. Le reste du dépôt est en GPL-3.0-or-later ;
la licence MIT est compatible avec la GPL-3.0.
