# MySQL X Protocol

Dissecteur Wireshark en Lua du protocole X de MySQL (MySQL X Protocol /
X Plugin, port 33060 par défaut — configurable dans les préférences du
protocole, 8000 dans l'exemple amont), issue #451.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/naoto-ogawa/wireshark-plugin-mysql-xprotocol |
| Commit importé | `97d72a700e6a62ffb4c38ee0acf011eded54c68f` (22/02/2018) |
| Licence amont | « GPL » (en-tête de `xprotocol.lua` et README amont, sans version précisée ; interprétée à la Wireshark — GPL-2.0-or-later, compatible GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent) |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée ; seule une en-tête `SPDX-License-Identifier: GPL-3.0-or-later`
avec la provenance est ajoutée (convention du dépôt, issue #563).

## Fichiers

- `src/xprotocol.lua` — dissecteur du protocole X (protocole « XProtocol »,
  port du serveur configurable dans les préférences) ;
- `src/test/Test01.lua` — squelette de test amont (essentiellement
  commenté).

Le dépôt amont contient aussi des captures de test (`data/*.pcapng`) non
importées ici.

## Utilisation

Placer `src/xprotocol.lua` dans un dossier de plugins Lua de Wireshark, ou
lancer explicitement : `tshark -X lua_script:src/xprotocol.lua -V`. Le port
du serveur se règle dans les préférences du protocole XProtocol.
