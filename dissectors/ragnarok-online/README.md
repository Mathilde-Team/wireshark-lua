# Ragnarok Online

Dissecteurs Wireshark Lua du protocole de Ragnarok Online (jeu de rôle en
ligne) : serveurs de connexion, de personnages et de carte, écrits par
[alxbl/ro-wireshark](https://github.com/alxbl/ro-wireshark) (issue #272).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/alxbl/ro-wireshark |
| Commit importé | `f3258408a6786dcb0101dc7501b223e7b368dd3d` du 15/06/2015 (dernier commit de `master`) |
| Licence amont | GPL-3.0-or-later (notice en tête de `ro.lua` : « either version 3 of the License, or (at your option) any later version ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Ragnarok Online natif |

Le dépôt amont n'a pas de fichier de licence (l'API GitHub renvoie
`license: null`) et seul `ro.lua` porte une notice. Les quatre fichiers ont le
même auteur unique (Alexandre Beaulieu, seul auteur des 7 commits) et la notice
de `ro.lua`, point d'entrée qui charge les trois modules, porte sur « this
program » : la GPL-3.0-or-later est appliquée aux quatre fichiers (en-tête SPDX
`GPL-3.0-or-later`), même licence que ce dépôt. Faute de texte de licence
amont, `LICENSE.txt` est une copie du texte de la GPL-3.0 (`LICENSE` à la
racine de ce dépôt).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ro.lua` | Point d'entrée : protocole `ro`, table de dissecteurs `ro.port`, charge les trois modules par `dofile` et les associe aux ports TCP 6900 et 6901 (connexion), 6121 (personnages), 5121 (carte) |
| `src/RO/login.lua` | Serveur de connexion (`ro.login`) : types de messages nommés, détail de la connexion, de l'authentification réussie ou refusée et de la liste des serveurs de personnages |
| `src/RO/char.lua` | Serveur de personnages (`ro.char`) : type de message et charge utile |
| `src/RO/map.lua` | Serveur de carte (`ro.map`) : type de message (plusieurs centaines de noms) et charge utile |

Les fichiers sont repris tels quels (fins de ligne CRLF amont conservées),
en-tête de provenance ajouté.

## Utilisation

Le README amont demande de copier les fichiers dans le dossier racine de
Wireshark et d'ajouter `dofile("/ro.lua");` à la fin de `init.lua` : `ro.lua`
charge ensuite les modules par des **chemins absolus** `/RO/login.lua`,
`/RO/map.lua` et `/RO/char.lua`. Avec un Wireshark récent :

- copier `src/ro.lua` dans le dossier `plugins` (ex.
  `~/.config/wireshark/plugins/`) ;
- placer le dossier `src/RO/` à l'emplacement attendu par les `dofile`
  (`/RO/` sous Linux et macOS, racine du lecteur courant sous Windows), ou
  adapter localement ces trois chemins ;
- ne **pas** placer `RO/` dans le dossier `plugins` : Wireshark charge les
  sous-dossiers de `plugins` avant les fichiers, donc les modules seraient
  chargés seuls, avant `ro.lua` (table `ro.port` encore absente), puis une
  seconde fois par `dofile`.

Pour d'autres ports, ajouter les ports à la table `tcp.port` ou utiliser
« Décoder comme… ».

## Limites constatées à l'import

- projet amont marqué « work in progress » (2015) : la plupart des messages sont
  seulement nommés, sans décodage de leur contenu ; pas de prise en charge du
  chiffrement utilisé par certains serveurs (TODO amont) ;
- chargement par chemins absolus (voir « Utilisation ») ;
- variables globales (`dissectors`, fonctions `void_d`, `login_connect`,
  `login_auth_ok`, `login_failed`…, `void_d` redéfinie par chaque module) :
  comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
