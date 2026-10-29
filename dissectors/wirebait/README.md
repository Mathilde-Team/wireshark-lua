# WireBait — framework de test de dissecteurs Lua

Framework de test pour dissecteurs Wireshark en Lua, importé pour référence
(issue #5). WireBait permet de tester un dissecteur hors Wireshark : il fournit
des implémentations des API Wireshark (Proto, ProtoField, Tvb, TreeItem,
dissector tables…) sur lesquelles exécuter les mêmes scripts Lua, avec lecture
de fichiers pcap et vérifications. Le dissecteur testé n'a pas besoin d'être
modifié.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MarkoPaul0/WireBait |
| Commit importé | `47e46acef0b4dff447ef18289084c9c03a075afa` (24/02/2021, « Update README.md » — dernier commit du dépôt, inactif depuis) |
| Licence amont | GNU GPL v2 (`LICENSE.txt` amont : « All the files in that repository are licensed under GNU GPL v2 ») — interprétée GPL-2.0-or-later à la Wireshark, compatible GPL-3.0-or-later |
| Natif Wireshark 4.6.4 | sans objet (outil de test, pas un dissecteur) |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée ; seule une en-tête `SPDX-License-Identifier: GPL-2.0-or-later` avec
la provenance est ajoutée (convention du dépôt, issue #563).

## Fichiers

- `src/wirebaitlib/` (19 fichiers) — bibliothèque : API Wireshark simulée
  (`dissector/`, `packet_data/`, `packet_info/`, `primitives/`), `init.lua` ;
- `src/tests/` (10 fichiers) — tests unitaires et fonctionnels amont,
  `runall_tests.lua` ;
- `src/example/` (3 fichiers) — dissecteurs de démonstration.

Le dépôt amont contient aussi des captures d'exemple (`example/captures/*.pcap`)
et des captures d'écran — non importées.

## Utilisation

Depuis le dossier parent de `src/` : `lua src/tests/runall_tests.lua` (nécessite
Lua 5.x). Pour tester un dissecteur : écrire un script de test qui charge
`wirebaitlib` puis le dissecteur, sur le modèle de
`src/tests/functional_tests/test_examples.lua`.
