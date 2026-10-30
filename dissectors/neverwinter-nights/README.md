# Neverwinter Nights

Dissecteur Wireshark Lua du protocole réseau multijoueur de Neverwinter Nights
(et en partie Neverwinter Nights 2) : protocole de lobby (découverte des
parties et informations de serveur) et ébauche du protocole de jeu
(issue #317).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Nostritius/nwn-wireshark |
| Commit importé | `f64ad7243b51567ffb13a9e18777ad15cfdc59f4` du 08/06/2019 (dernier commit de `master`) |
| Licence amont | GPL-3.0-or-later (en-tête des deux fichiers : « either version 3 of the License, or (at your option) any later version » ; README : « GNU General Public License version 3 (or later) ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Neverwinter Nights natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/nwn_lobby.lua` | Protocole `nwn_lobby` (heuristique UDP, premier octet `B`) : code message FourCC et sa description, source, nom du serveur (`BNER`), niveaux, joueurs, PvP et options de partie (`BNXR`) |
| `src/nwn_game.lua` | Protocole `nwn_game` (heuristique UDP, premier octet `M`) : nombre et taille des charges utiles |

Les fichiers sont repris tels quels, en-tête de provenance ajouté. Le README et
le `.gitignore` amont ne sont pas importés.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtres : `nwn_lobby`, `nwn_game`.

## Limites constatées à l'import

- travail incomplet selon l'auteur : seul le protocole de lobby est lisible,
  le protocole de jeu se limite à deux champs ;
- heuristiques très larges (un seul octet testé, `B` ou `M`, sans contrôle de
  longueur ni de port) : risque de faux positifs sur d'autres trafics UDP et
  d'erreurs Lua sur des paquets courts ;
- `pktlen` n'est pas défini (variable globale `nil`) : `tvbuf:range(0, pktlen)`
  couvre donc tout le tampon, comportement correct mais involontaire ;
- plusieurs codes de message restent « Unknown Message Type » ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
