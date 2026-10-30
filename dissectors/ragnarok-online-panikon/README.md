# Ragnarok Online (panikon)

Dissecteur Wireshark Lua des paquets de Ragnarok Online (jeu de rôle en ligne
massivement multijoueur), version de
[panikon/ragnarok-online-packet-dissector](https://github.com/panikon/ragnarok-online-packet-dissector)
fondée sur une table de paquets générée (issue #279). Autre implémentation du
même protocole : `dissectors/ragnarok-online/` (alxbl/ro-wireshark, #272).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/panikon/ragnarok-online-packet-dissector |
| Commit importé | `950d1e55bc4d992952b09249018dd6bc4779c0cb` du 15/01/2019 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (`LICENCE` amont ; notices « licensed under GNU/GPL » sans version, d'où `GPL-3.0-only`) ; `table_serialize.lua` : « same terms as Lua itself » (MIT) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Ragnarok Online natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENCE`). `table_serialize.lua` est un extrait du wiki
lua-users (http://lua-users.org/wiki/SaveTableToFile) sous les termes de Lua
(MIT), d'où son en-tête SPDX `MIT`.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ro_dissector.lua` | Protocole `RO` sur TCP 6900-6901 (connexion), 7000-7001 (monde) et 4501-4502 (zone) : en-tête (`ro.header`), nom du paquet, type de serveur et contenu décrit par la table |
| `src/ro_packet_table.lua` | Table des paquets générée (≈ 710 Ko) : nom, serveur, longueur et champs de chaque en-tête |
| `src/ro_tap.lua` | Écouteur qui recopie les paquets `ro` dans `ro_extracted.pcap` |
| `src/table_serialize.lua` | `table.save` / `table.load` utilisés pour charger la table |

Les scripts de génération de la table (`table/update_packet.lua`,
`table/packet_dissect.lua`, `table/bracket.lua`) ne sont pas importés. Les
fichiers sont repris tels quels, en-tête de provenance ajouté.

## Utilisation

Le README amont demande de copier les quatre fichiers dans le dossier
principal de Wireshark puis d'ajouter `dofile('/ro_dissector.lua')` à la fin
de `init.lua` : `ro_dissector.lua` charge les trois autres avec des chemins
relatifs (`dofile("table_serialize.lua")`, `dofile("ro_tap.lua")`,
`table.load("ro_packet_table.lua")` qui passe par `loadfile`, donc relatif au
dossier courant). Filtre : `ro`.

## Limites constatées à l'import

- non utilisable en l'état depuis le dossier `plugins` : Wireshark chargerait
  chaque fichier comme greffon (doublon de `ro_tap.lua`) et
  `table.load("ro_packet_table.lua")` échoue si Wireshark n'est pas lancé
  depuis le dossier qui contient la table ;
- `ro_tap.lua` écrit `ro_extracted.pcap` dans le dossier courant à chaque
  analyse ;
- les champs du contenu sont créés pendant la dissection (`ProtoField.new`
  dans `field`) et affichés comme texte : pas de filtre par champ ;
- en-tête absent de la table : `packet[header]` est rempli au lieu de
  `packet`, si bien que le nom et le serveur s'affichent `nil` au lieu de
  « Unknown packet » / « Unknown server » ;
- variables globales (`packet_table`, `port_list`, `header`, `pos`…) et ports
  codés en dur ; un seul paquet par segment TCP, sans réassemblage ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
