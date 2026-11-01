# Avionique / essais en vol (iNet-X, IENA, MIL-STD-1553, IRIG…)

Collection de dissecteurs Wireshark Lua pour l'avionique et les systèmes d'essais : iNet-X/iNet-X/NDP, IENA (AB407, HS-Avionics…), MIL-STD-1553, AFDX, IRIG 106 Ch10/Ch24, TMOIP, Proglink, Axon, et divers formats de télémétrie.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/diarmuidcwc/LuaDissectors |
| Commit importé | `78bf79c9cb5634036b152baa51091c4f3c8de577` du 29/05/2026 (branche `master`) |
| Licence amont | GPLv2 (fichier `LICENSE`, sans clause « or later ») — © Diarmuid Collins (Curtiss Wright) |
| Natif Wireshark 4.6.4 | Partiel — Wireshark embarque `afdx`, `mpegts`, `mil-std-1553` limités et IRIG ch10 ; cette collection couvre iNet-X, IENA, NDP et formats d'essais non natifs |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

35 modules Lua dans `src/` : `inetx.lua`/`inetx_subdissectors.lua`, `iena.lua`/`iena_subtypes.lua`, `ch10.lua` (IRIG 106), `ch24.lua`, `mil-std-1553.lua` (+ variante little endian), `afdx.lua`, `ndp.lua`, `tmoip.lua`, `proglink.lua`, `axon.lua`, `hsavionics.lua`, `abm401.lua`/`dem101.lua`/`mem004.lua`/`mat_101.lua` (télémétrie), `LXRS.lua`, `common.lua`, `bit32_compat.lua`, et autres.

Non importés : `README.md`, `.gitignore`.

## Utilisation

Copier `src/` dans le dossier `plugins` d'un profil Wireshark (ou `~/.config/wireshark/plugins/avionique/`). Plusieurs protocoles disposent de dissector tables heuristiques : Wireshark tente la reconnaissance automatique. Pour attacher un port fixe (ex. iNet-X sur 5566), ajouter l'enregistrement `udp_table:add(5566, inetx_generic_proto)` (voir README amont). « Decode As » fonctionne aussi.

## Limites constatées à l'import

- collection hétérogène de formats d'essais, maintenue par un auteur unique (Curtiss Wright) ;
- `bit32_compat.lua` fournit la compatibilité Lua 5.1 (chargé automatiquement si nécessaire).
