# Handshake (blockchain P2P)

Dissecteur Wireshark Lua pour le protocole pair-à-pair de la blockchain Handshake (HNS) : version/verack, addr, inv/getdata, blocks/headers, transactions, filtres bloom, compact blocks, airdrop/claim/proof.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/htools-org/wireshark-handshake-protocol |
| Commit importé | `ba7915c2b788e34d084f7151f2000aa9ff3b305f` du 11/01/2026 (branche `main`) |
| Licence amont | MIT (fichier `LICENSE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Handshake natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

35 modules Lua dans `src/` : `handshake.lua` (point d'entrée), `constants.lua`, `pdu_header.lua`, `utils.lua` et un module `packet_*.lua` par type de message (version, addr, inv, getdata, block, headers, tx, cmpctblock, merkleblock, airdrop, claim, proof, feefilter, filtres bloom…).

Non importés : `README.md` (documentation, reprise ici), `.gitignore`.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/handshake/`) : les modules se chargent tous ensemble. Requiert Lua 5.3+ (opérations binaires natives, dernière MAJ amont).

## Limites constatées à l'import

- les modules s'attendent à être chargés ensemble dans le même dossier (pas de chemin absolu) ;
- non testé contre un trafic Handshake réel dans ce dépôt (captures d'exemple non fournies par l'amont).
