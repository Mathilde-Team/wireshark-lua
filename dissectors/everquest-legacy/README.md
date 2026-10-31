# EverQuest (protocole historique)

Dissecteur Wireshark Lua du protocole réseau historique d'EverQuest sur UDP :
couche de transport (indicateurs, acquittements, séquences, fragments
réassemblés, CRC32), puis opcodes des serveurs de connexion et de jeu
(issue #306).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nickgal/eq-wireshark |
| Commit importé | `8b84a0281fad47ee29e34197613238e4c6134bf2` du 24/07/2026 (dernier commit de `main`) |
| Licence amont | GPL-2.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-2.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur EverQuest natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/eq-legacy-protocol.lua` | Protocoles `everquest` (jeu, UDP 9000) et `everquest_login` (connexion, UDP 5998 à 6000) : en-tête et indicateurs, numéros de séquence et d'acquittement, réassemblage des fragments, CRC32 ; 670 opcodes de jeu et 44 de connexion nommés, dont 22 avec décodage détaillé ; le port de zone annoncé par `MSG_ZONE_ADDRESS` est ajouté à la volée |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/eq-legacy-protocol.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtres : `everquest`,
`everquest_login`. Référence du protocole citée par l'auteur :
[Protocol.txt (archive)](https://web.archive.org/web/20010504111746/http://xylor.dhs.org:80/Protocol.txt).

## Limites constatées à l'import

- protocole historique (vers 2001) : sans rapport avec les versions actuelles
  du jeu ;
- ports codés en dur (9000, 5998 à 6000), plus les ports de zone ajoutés
  pendant la dissection ;
- fragments suivis par une clé adresse, port et numéro de séquence, dans une
  table Lua vidée seulement au chargement d'une capture ; selon l'auteur,
  cette méthode peut échouer sur de longues captures ;
- le CRC32 est affiché, pas vérifié ;
- nombreuses variables et fonctions globales (`Flags`, `SHARED_FIELDS`,
  `GAME_OPCODES`, `LOGIN_OPCODES`, `shared_dissector`…) ;
- utilise `bit.band`, fourni par Wireshark (pas par Lua standard) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
