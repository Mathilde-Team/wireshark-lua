# Solana P2P (blockchain)

Dissecteur Wireshark Lua pour le réseau pair-à-pair de la blockchain Solana : protocole gossip (pull/push/prune/ping/pong, CRDS), shreds (legacy, Merkle, chaînés), repair, TPU (UDP et partiellement QUIC).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/firedancer-io/solana_dissector |
| Commit importé | `1341a3a3d25d14dc9313c1ec2a9f5478abcde934` du 18/04/2025 (branche `main`) |
| Licence amont | GPL-2.0-only (énoncée dans `solana.lua` et le fichier `LICENSE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Solana natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/solana.lua` | Dissecteur (46 Ko) : gossip, shreds, repair, TPU UDP/QUIC, avec décodage optionnel des transactions via `mev-protos` |

Non importés : `protos/*.proto` (méta-données gRPC mev-protos, sourcées du dépôt distinct [jito-labs/mev-protos](https://github.com/jito-labs/mev-protos), régénérables via `update_protos.sh`), `tools/` (scripts shell/Python de conversion de captures), `README.md`.

## Utilisation

Copier `src/solana.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Ports codés en dur : 8000 (gossip), 8001/8002 (shreds), 8008/8009 (repair) — sinon utiliser « Decode As ». Pour le décodage des transactions des bundles gRPC, fournir `mev-protos` dans le chemin de recherche Wireshark.

## Limites constatées à l'import

- TPU/QUIC en chantier côté amont (recharger les greffons Lua si le trafic QUIC ne se dissèque pas) ;
- pas de mappings de ports dynamiques (codés en dur, « Decode As » sinon) ;
- transaction v0 et vote program data non couvertes (limites amont, voir son README).
