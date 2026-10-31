# CLOU/Hopeland HRP

Dissecteur Wireshark Lua du protocole **HRP** des lecteurs et antennes RFID
UHF CLOU/Hopeland sur TCP (issue #78).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/kurenai-ryu/hrp (fichier `clou.lua`) |
| Commit importé | `6f0f2845924aef56c4ecce5aae19cc9d6ceea416` du 19/12/2019 (dernier commit de `master`) |
| Licence retenue | BSD-3-Clause, d'après l'en-tête de `clou.lua` : « This code is in the Public Domain, or the BSD (3 clause) license if Public Domain does not apply in your country », © 2018 Arturo Hernandez |
| Licence du dépôt amont | `LICENCIA` : Licencia Pública General de Bolivia (LPG-Bolivia) v1, adaptation de la GNU GPL. Son article 17 autorise à relicencier sous la GNU GPL. L'API GitHub indique `null` |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur CLOU/HRP natif (`tshark -G protocols`) |

L'en-tête du fichier, plus précis et plus permissif, est retenu. La licence du
dépôt (LPG-Bolivia, relicenciable en GPL) reste compatible avec la
GPL-3.0-or-later de ce dépôt. `LICENSE.txt` reproduit l'en-tête amont et le
texte de la BSD 3 clauses.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/clou.lua` | Protocoles `clou` (« Clou/Hopeland HRP Protocol », TCP 9090, port réglable dans les préférences) et `clou_udp`. Il décode la trame `0xAA`, le type et l'identifiant du message, les paramètres (table des MID) et la somme de contrôle |

Seul le dissecteur est importé ; la bibliothèque Python `clou_reader`,
l'article et les exemples de l'amont ne le sont pas.

## Utilisation

Copier `src/clou.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `clou`.

## Limites constatées à l'import

- les MID inconnus sont signalés « pid not found » ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur du trafic réel.
