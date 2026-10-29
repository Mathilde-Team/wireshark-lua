# Aristoteles — ARI (Apple Radio Interface, baseband Intel)

Dissecteur Wireshark en Lua pour le protocole ARI (Apple Radio Interface) du
baseband Intel des iPhone, issu du projet Aristoteles du Seemoo Lab, issue #4.
`ari.lua` dissèque l'en-tête ARI et délègue aux analyseurs TLV ;
`ari_data_loader.lua` charge dynamiquement les analyseurs de `parsers/`
(codecs et TLV) et les tables de `types/` (structures extraites de la
bibliothèque `libARI.dylib` via Ghidra, tables « as string ») ; `ari_utils.lua`
porte les utilitaires.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/seemoo-lab/aristoteles |
| Commit importé | `25cb9bb5c35993ed0c74248b96f0065d5479f447` (30/09/2026, « Merge pull request #19 … feat/ios27 ») |
| Licence amont | MIT (`LICENSE` amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent) |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée (`src/parsers/`, `src/types/` chargés par chemin relatif) ; seule une
en-tête `SPDX-License-Identifier: MIT` avec la provenance est ajoutée
(convention du dépôt, issue #563).

## Fichiers

- `src/ari.lua` — dissecteur principal (en-tête ARI, délégation TLV) ;
- `src/ari_data_loader.lua` — chargeur des analyseurs et tables ;
- `src/ari_utils.lua` — utilitaires ;
- `src/parsers/codec/` (26 fichiers) — analyseurs de codecs IBI/Uta ;
- `src/parsers/tlv/` (1 fichier) — analyseur TLV ;
- `src/types/asstring/` (3 fichiers) — tables d'affichage ;
- `src/types/structure/` (2 fichiers) — tables de structures, dont
  `libari_dylib.lua` (1,3 Mo, générée depuis `libARI.dylib`).

Le dépôt amont contient aussi des exemples (captures pcapng, fichiers de
crash), des images et la documentation de développement — non importés.

## Utilisation

Placer l'ensemble de `src/` (y compris `parsers/` et `types/`) dans un dossier
de plugins Lua de Wireshark — le chargeur parcourt les sous-dossiers relatifs
au fichier. Lancer explicitement : `tshark -X lua_script:src/ari.lua -V` depuis
le dossier parent de `src/` (les chemins de `parsers/` et `types/` sont
résolus relativement aux scripts).
