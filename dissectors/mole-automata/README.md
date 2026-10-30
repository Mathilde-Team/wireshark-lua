# Mole: Automata (摩爾莊園)

Dissecteur Wireshark Lua du protocole du jeu en ligne Flash 摩爾莊園 (« Mole »,
version taïwanaise), écrit pour le projet d'automatisation
[Mole-Automata](https://github.com/mikucat0309/Mole-Automata) (issue #283).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mikucat0309/Mole-Automata |
| Commit importé | `87e6938da33faeed193de6d89186ce09a1214e9c` du 19/07/2023 (dernier commit de `main`) ; dernier changement de `reverse/dissector.lua` : `b36eb7669f770a93fe188fed562d38b4db46dea0` du 18/07/2023 |
| Licence amont | GPL-3.0 (`LICENSE` amont, sans mention « or later » dans le fichier, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mole.lua` | Protocole `Mole` sur TCP 1201 (serveurs 1-6) et 1202 (serveurs 7-30) : en-tête de 17 octets (longueur, nonce, commande, utilisateur, code d'erreur), nom de la commande ou de l'erreur (≈ 1 800 entrées, en grande partie en chinois traditionnel), déchiffrement de la charge utile avec la clé du client ; réassemblage TCP via `dissect_tcp_pdus` |

Seul `reverse/dissector.lua` est importé, renommé `mole.lua` ; le programme Go
et les outils de rétro-ingénierie sont hors périmètre. Le fichier est repris
tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/mole.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `mole`.

## Limites constatées à l'import

- **`bit32` absent des Wireshark récents** : le déchiffrement appelle
  `bit32.rshift`, `bit32.lshift`, `bit32.bor` et `bit32.bxor`, bibliothèque de
  Lua 5.2 absente par défaut de Lua 5.3 et 5.4, seules versions prises en
  charge depuis Wireshark 4.4 (qui fournit `bit` à la place). Sans `bit32`
  global, la dissection d'un paquet avec charge utile échoue (« attempt to
  index a nil value (global 'bit32') ») ; contournement local : ajouter
  `bit32 = bit` en tête du fichier (code amont non modifié ici) ;
- la charge utile déchiffrée est affichée en octets (`mole.plain`), sans
  décodage des champs ;
- clé de chiffrement et ports codés en dur ; variables et fonctions globales
  (`MAPPING`, `KEY`, `decrypt`, `tcp_table`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
