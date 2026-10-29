# Lightning Network (BOLT) — messages P2P entre nœuds

Dissecteur Wireshark en Lua pour la couche 2 de Bitcoin : messages BOLT du
Lightning Network (init, open/accept-channel, funding, update-*-htlc,
commitment-signed, revoke-and-ack, shutdown, gossip channel/node
announcement, ping/pong, etc.), avec déchiffrement des charges utiles
via les secrets de nœuds (c-lightning, Eclair, LND) issus d'un keylog.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nayutaco/lightning-dissector |
| Commit importé | `8aa07e8fa1554b371997e28d26713b5c393f797f` du 11/05/2019 (branche `master`, dernier commit du dépôt) |
| Sous-module `plc` | https://github.com/nayutaco/plc, branche `lua5.2`, commit `f1ddd31104c848c677d7c312c6d2307ed2e96e91` (épinglé par l'amont) |
| Licence amont | MIT — dépôt : © 2018 Nayuta, Inc. ; plc : © 2017 Phil Leblanc (textes dans `LICENSE` et `plc/LICENSE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Lightning natif |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée (`src/`, `plc/plc/`) ; seule une en-tête `SPDX-License-Identifier`
avec la provenance est ajoutée à chaque fichier (convention du dépôt, issue
#563). De `plc`, seuls les deux modules mappés par le rockspec amont sont
importés (`plc52.bin`, `plc52.chacha20`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark-plugin.lua` | point d'entrée : registre TCP, greffon des protocoles Bitcoin/Lightning |
| `src/pdu-analyzer.lua` | analyse des PDU (dé-chiffrement, désérialisation) |
| `src/secret*.lua` | secrets de nœuds (keylog c-lightning/Eclair/LND), cache et fabriques |
| `src/constants.lua` | champs et constantes ProtoField |
| `src/utils.lua` | utilitaires (middleclass, plc52.bin) |
| `src/deserializers/*.lua` (29 fichiers) | un désérialiseur par message BOLT |
| `plc/plc/bin.lua`, `plc/plc/chacha20.lua` | bibliothèque plc (binaire, chacha20) — seuls modules utilisés |

Non importés : `lightning-dissector-scm-1.rockspec` (documenté ici),
`CONTRIBUTING.md`, `.gitignore`, `.gitmodules`, le README amont ; du
sous-module plc : les autres modules et tests (`poly1305.lua` du commit
épinglé est syntaxiquement invalide en l'état — `local function` sans nom —
et n'est pas requis par le dissecteur, cf. rockspec), rockspecs et
`.luacheckrc`.

À noter : le dissecteur dépend aussi de rocks externes (non présents dans les
dépôts amont, donc non importés) : `compat53 == 0.7`, `inspect`, `basexx`,
`middleclass`, `lua-zlib`, `lrexlib-pcre`, `poly1305 == 1.0` — installation
documentée dans le README amont (Lua 5.2 + luarocks).

## Utilisation

Cet import est une archive documentaire : le rockspec et les dépendances
rocks externes ne sont pas inclus. Pour une installation fonctionnelle,
utiliser le dépôt amont (README amont, Lua 5.2 + luarocks) :

```bash
git clone --recurse-submodules https://github.com/nayutaco/lightning-dissector
cd lightning-dissector
luarocks install lightning-dissector-scm-1.rockspec
```

(Le rockspec référence les fichiers du sous-module `plc` : un clone simple
sans `--recurse-submodules` — ou sans `git submodule update --init` — ne
permet pas l'installation.)

Puis configurer Wireshark pour charger le module (dossier `plugins` ou
`init.lua`) et fournir un keylog de nœud (c-lightning hsm_secret, Eclair,
LND) pour déchiffrer les charges utiles.

À noter : la syntaxe Lua 5.4 des fichiers importés est validée, mais le
fonctionnement de l'ensemble n'est pas établi — le rockspec amont exige
Lua 5.2 et des rocks externes (`compat53`, `middleclass`, `plc52`…, cf.
ci-dessus), non testés ici.
