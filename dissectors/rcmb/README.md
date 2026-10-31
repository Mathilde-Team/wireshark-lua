# RCmb (Redis Cluster Message Bus)

Dissecteur Wireshark Lua pour RCmb, le bus de messages interne des nœuds
[Redis Cluster](https://redis.io/docs/latest/operate/oss/stack/architecture/components/) (issue #462).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MohammadAlavi1986/rcmb-wireshark |
| Commit importé | `6174ff12473c86cd9c079635e0cfb9ea78fa8cff` du 09/02/2024 |
| Licence amont | MIT (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur RCmb natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/RCmb-dissector.lua` | Dissecteur RCmb : paquets TCP 17000-17005 (PING, PONG, MEET, FAIL, PUBLISH, UPDATE…) du bus de cluster |

Le dépôt amont contient aussi `screenshot.png` (capture d'écran) : non
importé.

## Utilisation

Copier `src/RCmb-dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le dissecteur s'enregistre sur les ports TCP
17000 à 17005 (bus de cluster Redis).

## Limites constatées à l'import

- le dissecteur décode la structure des messages (version, type, port, slots)
  mais pas la charge utile gossip complète (nœuds, epoch) ;
- les ports sont codés en dur dans l'amont (pas de préférence modifiable).
