# Tic-Tac-Toe (jeu de démonstration)

Dissecteur Wireshark en Lua, à visée pédagogique, du protocole d'un petit jeu
de morpion (« jogo da velha ») en réseau sur TCP 2000 : le premier octet de
chaque segment est traduit en case jouée (ligne, colonne) ou fin de partie,
avec indication du joueur (issue #367).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/emmonks/TicTacToe_dissector |
| Commit importé | `ad48368be5cc303962eb046d75ab3c2aa022038c` du 12/02/2022 (dernier commit de `main`) |
| Licence amont | GPLv3 (fichier `LICENSE`, aucune mention « or later » dans le code) |
| Natif Wireshark 4.6.4 | Non — protocole propre à ce jeu de démonstration |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/tictactoe_dissector.lua` | Protocole `tictactoe` sur TCP 2000 : champ `tictactoe.position` (1 octet), case correspondante (`Line1_Column1` à `Line3_Column3`, `End_Game` pour 0), adresse et port source, joueur |

Fichier repris tel quel (commentaires en portugais, fins de ligne CRLF),
en-tête de provenance ajouté. Non importés : la capture
`jogo_da_velha.pcapng` et le README amont (liens vers le jeu Windows et une
vidéo).

## Utilisation

Copier `src/tictactoe_dissector.lua` dans le dossier des plugins Lua de
Wireshark puis redémarrer. Filtre : `tictactoe`.

## Limites constatées à l'import

- port du serveur figé à 2000 (enregistrement et identification du joueur) ;
- « Server Port » n'est renseigné que si la capture passe par la trame n° 7
  (hypothèse liée à la capture d'exemple de l'amont) ;
- un seul octet décodé par segment, sans contrôle de longueur ni de
  direction ; les lignes d'information sont des éléments texte, non
  filtrables ;
- variables et fonctions globales (`tictactoe_protocol`, `position`,
  `get_position_name`, `server_port`, `client_port`…) ;
- syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée.
