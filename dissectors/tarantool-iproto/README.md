# Tarantool IProto

Dissecteur Wireshark en Lua du protocole binaire IProto de
[Tarantool](https://www.tarantool.io/en/) (base de données en mémoire),
issue #450.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mikhainin/tarantool-dissector (archivé) |
| Commit importé | `c3bcd830b24c44de0ddd3364bae74958721c50ba` (16/12/2021) |
| Licence amont | BSD-2-Clause (`LICENSE.txt` amont) ; `MessagePack.lua` : lua-MessagePack 0.3.3 de Francois Perrad, MIT/X11 |
| Successeur officiel amont | https://github.com/tarantool/tarantool-dissector |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent) |

Fichiers importés tels quels (aucune modification de code), seule une en-tête
`SPDX-License-Identifier: GPL-3.0-or-later` avec la provenance est ajoutée
(convention du dépôt, issue #563) ; les licences amont (BSD-2-Clause, MIT/X11)
sont compatibles GPL et leurs mentions sont conservées.

## Fichiers

- `tarantool.dissector.lua` — protocole IProto courant (Tarantool > 1.5) ;
  décode le TCP sur le port 3301 par défaut (modifiable dans Wireshark) ;
- `tarantool15.dissector.lua` — variante pour Tarantool ≤ 1.5 ;
- `MessagePack.lua` — dépendance (encodage MessagePack) ;
- `test.lua` — générateur de paquets IProto pour tester le dissecteur
  (nécessite le runtime Tarantool : `tarantool test.lua`).

## Utilisation

Placer `tarantool.dissector.lua` et `MessagePack.lua` dans un dossier de
plugins Lua de Wireshark (voir [Plugin
folders](https://www.wireshark.org/docs/dfref/d/DOC.html)), ou lancer
explicitement : `tshark -X lua_script:tarantool.dissector.lua -V`.
Pour Tarantool ≤ 1.5, utiliser `tarantool15.dissector.lua` à la place.
