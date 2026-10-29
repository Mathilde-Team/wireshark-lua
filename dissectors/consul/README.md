# HashiCorp Consul (RPC, gossip, Yamux, Serf)

Dissecteur Wireshark Lua pour HashiCorp Consul et Yamux : communication RPC (TLS, gRPC, Raft, snapshot), gossip Serf, multiplexage Yamux.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/blake/wireshark-consul-dissector |
| Commit importé | `fb7e81872ee5c27476b9af7db75bac94c51f6588` du 27/07/2023 (branche `master`) |
| Licence amont | Apache-2.0 (fichier `LICENSE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Consul/Yamux natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

11 modules Lua dans `src/` (arborescence amont conservée) :

| Dossier | Rôle |
|---|---|
| `src/consul/` | Dissecteur principal (`consul.lua`), RPC TLS/gRPC/Raft/snapshot/gossip, MessagePack, utilitaires |
| `src/yamux/yamux.lua` | Multiplexage Yamux |
| `src/serf/serf.lua` | Protocole gossip Serf |
| `tests/test_decode.lua`, `tests/test_utils.lua` | tests amont (luaunit) |
| `tests/tshark_tests/` | données des tests amont : sources txt, résultats attendus JSON, script de génération des PCAP (bash) |

Non importés : `img/`, `docs/`, `README.md`, `.gitignore`. Les tests exigent
luaunit, tshark et text2pcap (`tests/README.md` amont) ; leurs données
(`tshark_tests/`) sont importées pour rester utilisables.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), en conservant les sous-dossiers `consul/`, `yamux/`, `serf/`. Requiert Wireshark ≥ 3.5 avec Lua.

## Limites constatées à l'import

- le déchiffrement TLS n'est pas opéré : les RPC chiffrées apparaissent comme charges brutes (`rpc_tls_insecure.lua` ne décode que le handshake) ;
- la version MessagePack embarquée est celle de l'amont (non interchangeable avec un MessagePack global) ;
- expert info Yamux ajoutée à des fins de débogage (comportement amont).
