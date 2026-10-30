# ShogiClub24 (将棋倶楽部24) — export des parties

Script Wireshark Lua pour le service de shogi en ligne ShogiClub24 : il repère
dans le trafic TCP 9999 le début de partie (`StartGameCommand`), les coups et
la fin de partie, et écrit automatiquement la partie dans un fichier local
(issue #338).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/wiereS/shogi24kif_output |
| Commit importé | `9bd41ce24fee66f5bfed66b9e297591af8be86c1` du 11/05/2018 (dernier commit de la branche par défaut `shogi24kif-patch-1`) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « Copyright (C) 2018 wiereS », « either version 2 of the License, or (at your option) any later version » ; `LICENSE` amont : texte de la GPLv2) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur ShogiClub24 natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/shogi24kif_output.lua` | Protocole `shogi24_proto` sur TCP 9999 : recherche de motifs (`StartGameCommand`, classes Java `com.shogidojo.shogi.common.*`) dans les segments de plus de 100 octets, extraction des noms des joueurs et des coups, écriture de fichiers temporaires puis du fichier final `<date>_<joueur1>_vs_<joueur2>.csa` |

Le fichier est repris tel quel, en-tête de provenance ajouté. Le README amont
(en japonais) n'est pas importé.

## Utilisation

Selon l'auteur (testé avec Wireshark 2.4.5 sous Windows 10) :

```sh
tshark -X lua_script:shogi24kif_output.lua
```

Les parties sont écrites dans `%USERPROFILE%\Desktop\shogi24kif\` (dossier à
créer au préalable).

## Limites constatées à l'import

- outil d'export plutôt que dissecteur : aucun champ n'est ajouté à l'arbre
  de dissection, seule la colonne Protocole est renseignée ;
- dépend de Windows : le chemin de sortie est construit avec
  `os.getenv("USERPROFILE")` au chargement ; sans cette variable (Linux,
  macOS), le script échoue dès son chargement ;
- écrit des fichiers sur le disque à chaque segment reconnu (effets de bord
  pendant la dissection, y compris lors des relectures de Wireshark) ;
- les fichiers produits sont au format CSA (extension `.csa`), malgré le nom
  « kif » du projet ;
- extraction par positions fixes dans la sérialisation Java du client : toute
  évolution du client casse le script ; port 9999 codé en dur ; variables
  globales (`userprofile`, `folderpath`, `tcp_table`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
