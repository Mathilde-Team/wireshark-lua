# SMO Multi (Super Mario Odyssey Online)

Dissecteur Wireshark Lua du protocole de Super Mario Odyssey Online, mod
multijoueur de Super Mario Odyssey, tel qu'implémenté par le serveur Rust
smo-multi-rs : identifiant du joueur, type et taille du paquet, position et
action du joueur (issue #315).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/speyejack/smo-multi-rs |
| Commit importé | `70b0af699db1a5a7a1b32911e749d12f443f562b` du 20/04/2025 (dernier commit de `main`) ; dernier changement de `smo-wireshark.lua` : `c2dd19f6d6c9040454ea1fa278ceaacc4bc71646` du 27/10/2022 |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2022 Speyejack ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SMO Online natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/smo-wireshark.lua` | Protocole `smo` sur TCP 1027 et UDP 41553 / 41554 : identifiant (16 octets), type parmi 14 (Init, Player, Cap, Game, Tag, Connect, Disconnect, Costume, Shine, Capture, ChangeStage, Command, UdpInit, HolePunch), taille ; pour `Player`, position (x, y, z) et action / sous-action |

Seul ce fichier est importé (le serveur Rust est hors périmètre). Il est
repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/smo-wireshark.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `smo`.

## Limites constatées à l'import

- aucun champ filtrable : les valeurs sont ajoutées comme texte dans l'arbre ;
- un seul paquet par segment TCP, sans réassemblage ;
- seul le type `Player` est détaillé ;
- ports codés en dur (TCP 1027, UDP 41553 et 41554) ;
- variables globales (`smo_proto`, `packet_names`, `tcp_table`,
  `udp_table`) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
