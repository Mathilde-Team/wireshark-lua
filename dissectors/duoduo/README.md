# DuoDuo

Dissecteur Wireshark Lua du protocole de jeu binaire du framework serveur
DuoDuo : en-tête de jeu (magie `fast`, longueur, identifiant de protocole,
CRC) sur TCP, et en-tête KCP sur UDP, sur des ports saisis par l'utilisateur
(issue #299).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/qiunet/DuoDuo |
| Commit importé | `e7c70968987fb72d5a4187b62c99d5fd1e92b5ff` du 24/09/2026 (dernier commit de `master`) ; dernier changement de `FlashHandler/wireshark-plugins/` : `9465c6291d88e6c872076ac20eeb134dce585522` du 19/12/2023 |
| Licence amont | Apache-2.0 (`LICENSE` à la racine du dépôt ; aucun fichier `NOTICE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur DuoDuo natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

Contenu de `FlashHandler/wireshark-plugins/` repris tel quel dans `src/` ;
en-tête de provenance ajouté au `.lua`.

| Fichier | Rôle |
|---|---|
| `src/duoduo_protocol.lua` | Protocoles `Game` (TCP : requête avec magie `fast`, longueur, identifiant, CRC ; réponse avec longueur et identifiant) et `Kcp` (UDP : en-tête KCP de 24 octets, commandes PUSH/ACK/WASK), charge utile passée au dissecteur `data` ; entrée de menu « Outils › 游戏协议分析 » qui demande les ports TCP et KCP du serveur et applique le filtre |
| `src/README.md` | Mode d'emploi de l'auteur (en chinois) |
| `src/pics/*.png` | Captures d'écran du mode d'emploi |

## Utilisation

Copier `src/duoduo_protocol.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), redémarrer, puis ouvrir le menu Outils ›
« 游戏协议分析 » et saisir le port TCP du serveur et, si besoin, son port KCP.
Filtres : `game`, `kcp`.

## Limites constatées à l'import

- aucun port par défaut : rien n'est décodé tant que les ports n'ont pas été
  saisis dans la boîte de dialogue (Wireshark avec interface graphique
  uniquement, pas `tshark`) ;
- noms de protocoles génériques `Game` et `Kcp` : conflit possible avec un
  autre greffon qui utiliserait les mêmes noms ;
- libellés des champs et du menu en chinois ;
- le corps des messages de jeu n'est pas décodé (dissecteur `data`) ;
- les commandes KCP WINS (84) sont rejetées par le test d'en-tête
  (`command > 83`) et WASK n'a pas de colonne Info (`TODO` amont) ;
- variables globales (`createGameProto`, `createKcpProto`,
  `game_protocol_proto`, `kcp_proto`, `magic`) ; message « magic error! »
  écrit dans la console pour chaque segment client sans magie ;
- pas de réassemblage TCP ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
