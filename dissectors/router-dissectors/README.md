# Matrices de routage vidéo broadcast (roddypratt/router_dissectors)

Dissecteurs Wireshark en Lua des protocoles de contrôle de matrices de
routage vidéo (grilles de commutation broadcast), issue #43.

| Protocole | Fichier | Port TCP par défaut | Protocole Wireshark |
|---|---|---|---|
| Grass Valley Native | `src/gvg_native_dissector.lua` | 12345 | `GVGNative` |
| Harris LRC | `src/harris_lrc_dissector.lua` | 52116 | `LRC` |
| Leitch Pass-Through | `src/leitch_dissector.lua` | 23 | `Leitch` |
| Nevion MRP | `src/nevion_mrp_dissector.lua` | 4381 | `Nevion` |
| NVision NP0017 | `src/np0017_dissector.lua` | 9193 | `NP0017` |
| Pro-Bel SW-P-08 | `src/probel_swp08_dissector.lua` | 2007, 2008 | `SWP08` |
| Pro-Bel SW-P-02 | `src/probel_swp02_dissector.lua` | 2006 | `SWP02` |
| Evertz/Quartz RCP | `src/quartz_dissector.lua` | 4000 | `Quartz` |
| Utah RCP3-A | `src/utah_rcp3a_dissector.lua` | 5001 | `RCP3A` |

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/roddypratt/router_dissectors |
| Commit importé | `5c6e9f9a4345fcf050d1481f695ae502d549dd74` du 29/10/2026 |
| Licence amont | GPLv2 (fichier `LICENSE`, sans clause « or later ») — © Rascular Technology Ltd. (en-têtes des fichiers) |
| Natif Wireshark 4.6.4 | non (aucun de ces protocoles n'a de dissecteur natif) |

Les neuf fichiers `*_dissector.lua` sont importés tels quels (aucune
modification de code) ; seule une en-tête `SPDX-License-Identifier:
GPL-2.0-only` avec la provenance est ajoutée (convention du dépôt, issue
#563). La licence GitHub du dépôt amont n'est pas détectée par l'API, mais
le fichier `LICENSE` (GPLv2, présent depuis le premier commit) s'applique.

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

Non importés : `wireshark.lua` (annotations EmmyLua pour l'éditeur, pas un
dissecteur), `skeleton.lua` (squelette d'exemple sur le port 12345, en
conflit avec GVG Native), la capture `gvgnative.pcapng` et
`screenshot.png`.

## Utilisation

Copier les fichiers `src/*_dissector.lua` voulus dans le dossier des plugins
Lua de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), ou les charger à
la demande : `wireshark -X lua_script:src/gvg_native_dissector.lua`. Pour un
port différent, utiliser « Decode As ».

## Vérification à l'import

Avec tshark 4.6.4, les neuf dissecteurs installés ensemble : chargement sans
erreur Lua ; sur la capture amont `gvgnative.pcapng` (99 trames, non
importée), 46 trames décodées en GVG Native, sans trame malformée ni
constat expert « error ». Les autres protocoles n'ont pas d'échantillon
amont : non vérifiés sur trafic.

## Limites constatées à l'import

- Leitch est enregistré sur le port TCP 23 : installé, il remplace le
  dissecteur Telnet pour tout le trafic de ce port — ne l'installer que pour
  analyser une matrice Leitch ;
- les ports par défaut sont fixes (pas de préférence) ;
- les éléments de l'arbre sont ajoutés à la racine, sans sous-arbre de
  protocole ;
- une trame Quartz synthétique (`.SVA001,002` + CR) reste en attente de
  réassemblage dans tshark : décodage Quartz non confirmé.
