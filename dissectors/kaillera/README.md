# Kaillera

Dissecteur Wireshark Lua du protocole Kaillera 0.83 (jeu en réseau pour
émulateurs), livré avec le serveur Rust
[direlera-rs](https://github.com/caromdreamer/direlera-rs) (issue #278).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/caromdreamer/direlera-rs |
| Commit importé | `7b53eabd856461e6df96f9c2badb9249afcf73f0` du 08/07/2026 (dernier commit de `main`) ; dernier changement de `kaillera.lua` : `9f154218656284bb6651cd31fd1bf1f0f2f11a61` du 26/10/2025 |
| Licence amont | MIT (`LICENSE` amont, Copyright (c) 2025 Han Gyoung-Su) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Kaillera natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence MIT est conservée (en-tête SPDX `MIT`),
compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/kaillera.lua` | Protocole `kaillera` : paquets UDP regroupant plusieurs messages (nombre, puis séquence, longueur et type de chaque message) ; 23 types de messages (`0x01` à `0x17` : connexion, discussion, création/entrée/fermeture de partie, `Game Data`, `Game Cache`…) et leurs champs (utilisateur, ping, type de connexion, état de partie…) |

Seul `kaillera.lua` est importé ; le serveur Rust et la documentation
(`GAME_SYNC_PROTOCOL.md`) sont hors périmètre. Le fichier est repris tel quel,
en-tête de provenance ajouté.

## Utilisation

Copier `src/kaillera.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le dissecteur n'est lié à aucun port : il
s'enregistre comme **heuristique UDP** et reconnaît les paquets Kaillera sur
n'importe quel port (le README amont cite les ports 27888 et 8080). Filtre :
`kaillera`.

## Limites constatées à l'import

- l'heuristique ne vérifie que le nombre de messages (1 à 10), leurs
  longueurs et leurs types : des datagrammes UDP sans rapport peuvent être pris
  pour du Kaillera (désactivable via « Analyser → Protocoles activés ») ;
- l'échange initial en texte (`HELLO0.83` / `HELLOD00D`, ping) n'est pas
  décodé ;
- les champs texte (noms, discussion) sont lus avec `stringz()` sans encodage
  précisé (ASCII) : les noms en EUC-KR, que le serveur amont prend en charge,
  s'affichent mal ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
