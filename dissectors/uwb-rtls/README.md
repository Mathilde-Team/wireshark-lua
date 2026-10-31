# UWB RTLS (Nozomi Networks)

Dissecteurs Wireshark Lua des protocoles propriétaires échangés entre les
ancres et le serveur de trois systèmes de localisation temps réel par
ultra-large bande (UWB RTLS) : **Avalue**, **Sewio** et **Ubisense**. Ils ont
été publiés par Nozomi Networks avec sa présentation Black Hat USA 2022
« UWB Real Time Locating Systems: How Secure Radio Communications May Fail in
Practice » (issue #75).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/NozomiNetworks/blackhat22-uwb-rtls |
| Commit importé | `ce2df47ebc7b41a20ca962f74c2ee3358a6159a2` du 27/06/2023 (dernier commit de `main`) |
| Licence amont | BSD-3-Clause (`LICENSE` amont, © 2022 Nozomi Networks) |
| Natif Wireshark 4.6.4 | Non — aucun de ces trois protocoles (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/avalue_uwb.lua` | `avalue_uwb` (heuristique UDP), sous-dissecteurs `avalue_uwb.tdoa` (type 17) et `avalue_uwb.ccp` (type 19) |
| `src/sewio_uwb.lua` | `sewio_uwb` (heuristique UDP) : messages `syncEmission`, `syncArrival` et `blink` (horodatages en unités DW1000 de 1/(128 × 499,2 MHz)) |
| `src/ubisense_uwb.lua` | `ubisense_uwb` (heuristique UDP), sous-dissecteur `ubisense_uwb.d4tagloc` (type 0x26b) |

Les scripts sont repris tels quels, avec l'en-tête de provenance ajouté. Les
trois captures de référence de l'amont (`*_backhaul_traffic.pcapng`, 9 Mo au
total) ne sont pas copiées : on les trouve dans le dépôt amont.

## Utilisation

Copier les scripts voulus dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtres : `avalue_uwb`, `sewio_uwb`,
`ubisense_uwb`. Les dissecteurs sont heuristiques : aucun port à configurer.

## Vérification à l'import

Avec `tshark` 4.6.4, sur les captures amont, aucune erreur Lua :

| Script | Capture amont | Trames décodées |
|---|---|---|
| `avalue_uwb.lua` | `avalue_backhaul_traffic.pcapng` | 16 655 `AVALUE_UWB` |
| `sewio_uwb.lua` | `sewio_backhaul_traffic.pcapng` | 3 476 `SEWIO_UWB` |
| `ubisense_uwb.lua` | `ubisense_backhaul_traffic.pcapng` | 763 `UBISENSE_UWB` |

Les trames marquées malformées dans ces captures (181 pour Sewio, 1 pour
Ubisense) le sont aussi sans les scripts : elles viennent des dissecteurs
natifs, pas de ces imports.

## Limites constatées à l'import

- l'amont décrit seulement les messages observés pendant ses tests. Pour
  Ubisense, la plupart des trames UDP de la capture ne sont pas reconnues ;
- protocoles déclarés en variables globales (`proto_avalue_uwb`, etc.).
