# Minetest / MultiCraft

Dissecteur Wireshark Lua du protocole réseau UDP de Minetest (aujourd'hui
Luanti), tel que livré par le fork [MultiCraft](https://github.com/MultiCraft/MultiCraft)
(jeu voxel open source) : couche de transport (contrôle, messages fiables,
découpés, originaux) et commandes client → serveur (`TOSERVER_*`) et serveur →
client (`TOCLIENT_*`) (issue #257).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MultiCraft/MultiCraft |
| Commit importé | `1ea2a934ce5e0e4187065ccb9d03ffc07b395f18` du 28/10/2026 ; dernier changement de `util/wireshark/minetest.lua` : `5176442200c22b3409f631495720f6e8638fa611` du 05/12/2021 |
| Licence amont | GPL-3.0-or-later (en-tête du fichier : « either version 3.0 of the License, or (at your option) any later version ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Minetest/Luanti natif |

Le fichier importé porte sa propre notice GPL-3.0-or-later (Copyright (C) 2011
celeron55, Perttu Ahola), conservée telle quelle : même licence que ce dépôt
(texte complet dans `LICENSE` à la racine). `LICENSE.txt` est la copie conforme
du `LICENSE.txt` amont, qui décrit les licences des médias (CC BY-SA) et place le
code source C++ sous LGPL-3.0 ; il ne mentionne pas le dissecteur, dont seul
l'en-tête fait foi. L'API GitHub affiche « NOASSERTION ».

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/minetest.lua` | Protocoles `minetest` (en-tête, identifiant `0x4f457403`, pair, canal), `minetest.control`, `minetest.split`, `minetest.client` et `minetest.server` (101 commandes décrites, dont certaines marquées obsolètes) ; enregistré sur UDP 30000 et 30001 |

Seul `util/wireshark/minetest.lua` est importé ; le reste du dépôt amont
(moteur C++, jeux, médias) est hors périmètre. Le fichier est repris tel quel,
en-tête de provenance ajouté.

## Utilisation

Copier `src/minetest.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic UDP 30000/30001 (ports par défaut
des serveurs) est décodé automatiquement ; pour un autre port, utiliser
« Décoder comme… » → `MINETEST`.

## Limites constatées à l'import

- le dissecteur date de 2021 (protocole de l'époque) : les commandes ajoutées
  depuis par Minetest/Luanti ou MultiCraft ne sont pas décodées ;
- aucune détection heuristique : tout trafic UDP 30000/30001 est décodé comme
  Minetest (FIXME amont) ;
- tables et fonctions globales (`minetest_client_commands`,
  `minetest_server_commands`, `minetest_check_length`…) : comportement amont
  conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
