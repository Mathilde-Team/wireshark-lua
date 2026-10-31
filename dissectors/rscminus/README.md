# rscminus (RuneScape Classic RSC235)

Dissecteur Wireshark Lua du protocole RuneScape Classic (version 235) tel
qu'exporté en `.pcap` par [rscminus](https://github.com/RSCPlus/rscminus),
outil d'édition de rediffusions RuneScape Classic (issue #286).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/RSCPlus/rscminus |
| Commit importé | `e42342fcddded6ea6534db9531ad62fc948db740` du 01/03/2021 (dernier commit de `master`) ; dernier changement de `plugins/rscminus.lua` : `f25fb215fe5fa4797671f46cdc7b8c4ddb6939dd` du 08/01/2021 |
| Licence amont | GPL-3.0 (`LICENSE` amont, sans mention « or later », d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur RuneScape Classic natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rscminus.lua` | Protocole `rsc235` (version « 2021-01-08 ALPHA ») : sens du paquet (`rsc235.packetSource`), code d'opération serveur (67 noms) ou client (70 noms) et champs détaillés par code (inventaire, mises à jour de joueurs et de PNJ, discussion, métadonnées du serveur…), noms d'objets et de PNJ |
| `colouring_rules` | Règles de coloration Wireshark fournies en amont (maintenance du monde, interface, objets, client, discussion) |

Seuls les fichiers de `plugins/` sont importés ; l'outil Java est hors
périmètre. Les fichiers sont repris tels quels, en-tête de provenance ajouté
au `.lua`.

## Utilisation

Copier `src/rscminus.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), puis importer les règles de coloration via
« Affichage → Règles de coloration… → Importer… → `colouring_rules` ».
Ouvrir ensuite un `.pcap` produit par rscminus (export de rediffusion,
`ReplayEditor.exportPCAP`). Filtre : `rsc235`, ex.
`rsc235.opcode == 149`.

## Limites constatées à l'import

- ne dissèque pas le trafic réseau réel : le protocole est enregistré sur
  `ethertype` `0x0000`, format des trames Ethernet factices écrites par
  l'export `.pcap` de rscminus (paquets déjà déchiffrés, en-tête rscminus
  d'un octet de sens et d'un code d'opération sur 4 octets) ;
- version alpha d'après l'amont : certains codes d'opération incomplets ou
  mal interprétés ; prévu pour les données des serveurs Jagex RSC235, pas
  pour les serveurs privés ;
- certains champs dépendent d'un état reconstitué au fil des paquets
  (inventaire, options) : résultat dépendant de l'ordre de dissection ;
- nombreuses tables et variables globales (`ITEM_NAMES`, `NPC_NAMES`,
  `SERVER_OPCODES`, `thisDebugging`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
