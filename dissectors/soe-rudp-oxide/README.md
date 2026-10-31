# SOE Reliable UDP (oxide-tools)

Version modifiée, maintenue dans soir20/oxide-tools, du dissecteur Wireshark
Lua du protocole « Reliable UDP » de Sony Online Entertainment (version 3,
révision `CGAPI_527`) : décompression par la bibliothèque Lua LibDeflate au
lieu du module C `zlib`, et tolérance des opcodes inconnus (issue #314).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/soir20/oxide-tools (dossier `protocol-dissector/`) |
| Commit importé | `5aff268046b2510de214fe574aebe1158a17e008` du 26/07/2026 (dernier commit de `main`) ; dernier changement de `protocol-dissector/` : `462a68992568d060297f2d5ff43e4b2eb0b6f463` du 23/01/2026 |
| Licence amont | GPL-2.0 (`protocol-dissector/LICENSE`, sans mention « or later » → `GPL-2.0-only`) ; le reste du dépôt oxide-tools est sous AGPL-3.0, mais ce dossier garde la licence de l'œuvre d'origine |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SOE natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `protocol-dissector/LICENSE`, identique au `LICENSE` de
misterupkeep/soe-dissector).

Œuvre d'origine : `dissectors/soe-rudp` (misterupkeep/soe-dissector, #302).
Différences avec celle-ci (3 lignes) : `require('LibDeflate')` et
`zlib:DecompressZlib(...)` au lieu de `require('zlib')` /
`zlib.inflate()(...)`, et `soe_opcodes[...] or ""` pour les opcodes inconnus.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/soerudp.lua` | Protocole `SOE` : sessions, données des canaux A à D (compressées ou non), fragments, ACK, paquets hors ordre et groupés ; heuristique sur tout le trafic `udp` |
| `src/README.md` | Mode d'emploi de l'auteur (dépendance LibDeflate, installation) |

Fichiers repris tels quels, en-tête de provenance ajouté au `.lua`.

## Utilisation

Télécharger `LibDeflate.lua` depuis
[SafeteeWoW/LibDeflate](https://github.com/SafeteeWoW/LibDeflate) (non fourni
ici), puis copier `LibDeflate.lua` et `src/soerudp.lua` dans le dossier
`plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Filtre : `soe`.

## Limites constatées à l'import

- dépendance externe `LibDeflate.lua` (bibliothèque Lua pure, non incluse) ;
  sans elle, le greffon ne se charge pas ;
- même nom de protocole `SOE` et mêmes champs que `dissectors/soe-rudp` : les
  deux greffons ne peuvent pas être chargés ensemble ;
- heuristique très large (opcode inférieur à `0x1E`, 5 octets minimum) :
  faux positifs probables sur d'autres protocoles UDP ;
- le chiffrement XOR n'est pas déchiffré, le CRC n'est pas vérifié et les
  fragments ne sont pas réassemblés ;
- variables globales et ajout de `string.starts_with` à la table `string`
  partagée ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
