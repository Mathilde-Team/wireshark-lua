# GoIM — protocole binaire de la messagerie GoIM

Dissecteur Wireshark en Lua du protocole binaire de GoIM (serveur de
messagerie instantanée en Go) sur TCP 8071 : longueur du paquet, taille
d'en-tête, version, opération (handshake, heartbeat, envoi de message,
authentification…), séquence et charge utile (issue #397).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/kim4apple/goim-dissector |
| Commit importé | `81390137da8e4a17c9cf398b039c11adf9c17763` du 04/03/2017 (dernier commit de `master`, Kim Huang) |
| Licence amont | MIT — déclarée dans le README (« available free of change under the Open Source license, along with the MIT license ») ; l'amont ne fournit pas de fichier de licence |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur GoIM natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier. Faute
de fichier de licence dans l'amont, il s'agit du texte MIT de référence SPDX
(https://spdx.org/licenses/MIT.html) ; le titulaire du droit d'auteur est
l'auteur du dépôt, kim4apple (Kim Huang).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/goim.lua` | Protocole `goim-bin` (« GO IM Binary Protocol. ») sur TCP 8071 ; champs `Goim.length`, `Goim.header_len`, `Goim.version`, `Goim.op`, `Goim.squence`, `Goim.payload` |

Fichier repris tel quel, en-tête de provenance ajouté. Non importée : la
capture d'écran `snap.jpg`.

## Utilisation

Copier `src/goim.lua` dans le dossier des plugins Lua de Wireshark
(`~/.config/wireshark/plugins/`). Le port 8071 se change dans le code
(`tcp_encap_table:add(8071, goim_proto)`) ou avec « Décoder comme… ».

## Limites constatées à l'import

- le test de complétude est inversé (`package_length < buf:len()` rejette les
  segments contenant plus d'un message) et un message plus long que le
  segment provoque une erreur Lua : pas de réassemblage TCP ;
- une opération absente de `op_codes` provoque une erreur Lua dans la colonne
  Info (concaténation de `nil`) ;
- charge utile affichée comme chaîne, sans décodage du JSON des messages ;
- nom de champ `Goim.squence` (faute de frappe amont conservée) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
