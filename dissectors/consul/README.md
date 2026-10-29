# HashiCorp Consul — RPC, Gossip (Serf) et Yamux

Dissecteur Wireshark en Lua pour les communications internes de HashiCorp
Consul : le RPC multiplexé sur le port 8300 (Coddec-Lambda-Codded,
TLS-insecure, gRPC, Raft, snapshot), le gossip Serf sur le port 8301
(TCP/UDP) et la trame Yamux qui les transporte. Le décodage TLS nécessite
l'activation de « Enable TLS decryption » dans les préférences du
dissecteur.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/blake/wireshark-consul-dissector |
| Commit importé | `fb7e81872ee5c27476b9af7db75bac94c51f6588` du 27/07/2023 (branche `main`, dernier commit du dépôt) |
| Licence amont | Apache-2.0 (© 2022 Blake Covarrubias) ; `src/consul/MessagePack.lua` : MIT (lua-MessagePack, © 2012-2019 Francois Perrad) |
| Natif Wireshark 4.6.4 | Non — le dissecteur d'en-têtes TCP existe, mais aucun dissecteur des protocoles internes Consul/Serf/Yamux |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée (`src/consul`, `src/serf`, `src/yamux`, `tests`) ; seule une en-tête
`SPDX-License-Identifier` avec la provenance est ajoutée à chaque fichier
(convention du dépôt, issue #563). Texte complet de la licence amont :
fichier `LICENSE` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Licence | Rôle |
|---|---|---|
| `src/consul/consul.lua` | Apache-2.0 | point d'entrée du RPC Consul (port 8300) : répartition Coddec-Lambda-Codded, TLS-insecure, gRPC, Raft, snapshot |
| `src/consul/rpc_gossip.lua` | Apache-2.0 | décodage des messages gossip binaire |
| `src/consul/rpc_grpc.lua` | Apache-2.0 | greffon du dissecteur gRPC/HTTP2 pour Consul |
| `src/consul/rpc_raft.lua` | Apache-2.0 | messages Raft (entries, vote, heartbeat) |
| `src/consul/rpc_snapshot.lua` | Apache-2.0 | messages de snapshot Raft |
| `src/consul/rpc_tls.lua` | Apache-2.0 | greffon TLS générique sur le port Consul |
| `src/consul/rpc_tls_insecure.lua` | Apache-2.0 | messages TLS-insecure (handshake RPC) |
| `src/consul/MessagePack.lua` | MIT | MessagePack (lua-MessagePack de Francois Perrad), utilisé pour le RPC |
| `src/consul/util.lua` | Apache-2.0 | utilitaires (hashs HTTP2, validation de la version de Wireshark) |
| `src/serf/serf.lua` | Apache-2.0 | point d'entrée du gossip Serf (ports 8301 TCP/UDP) |
| `src/yamux/yamux.lua` | Apache-2.0 | trame Yamux (nom, flux, gestion) |
| `tests/test_decode.lua`, `tests/test_utils.lua` | Apache-2.0 | tests amont (luaunit) |

Non importés : `docs/` et `img/` (documentation et captures d'écran), le
`README.md` amont (remplacé par ce README), `.gitignore`, et
`tests/tshark_tests/` (harnais bash + données JSON/txt d'expectation pour
tshark — pas des scripts Lua). Les tests importés exigent luaunit et tshark
(`tests/README.md` amont).

## Utilisation

Copier `src/consul/`, `src/serf/` et `src/yamux/` dans le dossier `plugins`
de Wireshark (ex. `~/.local/lib/wireshark/plugins/`) — le plugin amont
documente l'installation dans `src/consul/consul.lua`. Le décodage des
messages TLS chiffrés nécessite d'activer « Enable TLS decryption » dans
`Analyze → Enabled Protocols → Consul` et de renseigner les préférences
TLS.
