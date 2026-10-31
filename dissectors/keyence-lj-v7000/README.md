# Keyence LJ-V7000

Dissecteur Wireshark Lua du protocole Ethernet des profilomètres laser ultra-rapides **Keyence LJ-V7000** (issue #84).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/gavanderhoorn/packet-keyence-lj-v7000 |
| Commit importé | `dcb35bd9563d91da38b4541140c95181f06df154` du 10/06/2015 (dernier commit de la branche par défaut) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « or (at your option) any later version », © G.A. vd. Hoorn) ; `LICENSE` amont = texte de la GPLv2 |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-keyence-lj-v7000.lua` | Protocole `KLJV7E` (« Keyence LJ-V7000 Ethernet »), port de commande TCP 24691 : commandes et réponses utilisées par l'auteur pour son interface |

Les scripts sont repris tels quels, avec l'en-tête de provenance ajouté.

## Utilisation

Copier le script dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `kljv7e`.

## Limites constatées à l'import

- d'après l'amont : seul le port de commande TCP (24691) est décodé, pas le port haute vitesse (24692) ; seules les structures de messages utiles à l'auteur sont décodées et les noms ne suivent pas toujours la documentation Keyence
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée sur du trafic réel.
