# SOE Reliable UDP

Dissecteur Wireshark Lua du protocole « Reliable UDP » de Sony Online
Entertainment (révision `CGAPI_527`, celle de Free Realms) : ouverture de
session, données par canal, fragments, acquittements, paquets hors ordre et
paquets groupés, avec décompression zlib des charges utiles (issue #302).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/misterupkeep/soe-dissector |
| Commit importé | `bbaaa32735aa1e447224630499f69bbb37514ec2` du 31/12/2020 (dernier commit de `master`) |
| Licence amont | GPL-2.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-2.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SOE natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/soerudp.lua` | Protocole `SOE` : opcodes `0x0001` à `0x001C`, requête et réponse de session (graine CRC, compression, chiffrement, taille UDP), données des canaux A à D (compressées ou non), fragments, ACK et paquets hors ordre, paquets `SOE_MULTI_SOE` décodés récursivement ; heuristique sur tout le trafic `udp` |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Installer le module `lua-zlib` pour la Lua de Wireshark (ex.
`luarocks install lua-zlib`, nom de module `zlib`), puis copier
`src/soerudp.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `soe`.

## Limites constatées à l'import

- `require('zlib')` au chargement : sans le module C `zlib`, le greffon ne se
  charge pas du tout. Wireshark sait pourtant décompresser lui-même
  (`TvbRange:uncompress()`, renommée `uncompress_zlib()` dans les versions
  récentes) ;
- heuristique très large (opcode sur 2 octets inférieur à `0x1E`, 5 octets
  minimum) : faux positifs probables sur d'autres protocoles UDP ; l'opcode
  `0x0000` ou `0x001D`, non répertoriés, provoque une erreur Lua
  (`opcode:starts_with` sur `nil`) ;
- le chiffrement XOR (graine CRC) n'est pas déchiffré et le CRC n'est pas
  vérifié ;
- les fragments ne sont pas réassemblés ;
- révision `CGAPI_527` uniquement, d'après l'auteur ;
- variables globales (`soe_protocol`, `soe_opcodes`, champs, fonctions
  `parse_packet`, `inflate`…) et ajout de `string.starts_with` à la table
  `string` partagée ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
