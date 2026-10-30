# Nintendo DS Download Play

Dissecteur Wireshark Lua du protocole Download Play de la Nintendo DS sur
802.11 : annonces (élément vendor-specific des balises), requêtes et réponses
de téléchargement d'un jeu (nom de la console, signature RSA, morceaux de ROM)
et messages keep-alive (issue #311).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/LiEnby/wireshark-download-play |
| Commit importé | `ed1a6a72761eb071dc5c12b1579598985b4f620d` du 18/08/2025 (dernier commit de `master`) |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2025 Li ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Download Play natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ds_download_play.lua` | Protocole `dsdownloadplay` : heuristique `wlan_data` selon l'adresse de destination (`03:09:bf:00:00:10` requêtes, `03:09:bf:00:00:00` réponses, `03:09:bf:00:00:03` keep-alive) ; en-tête (magie, indicateur, port, opcode, séquence), nom de la console (UTF-16), offset des morceaux de ROM, bloc de signature RSA (points d'entrée et adresses ARM9/ARM7) ; élément 802.11 `0xDD` affiché comme annonce |

Le fichier est repris tel quel (fins de ligne CRLF d'origine conservées),
en-tête de provenance ajouté.

## Utilisation

Copier `src/ds_download_play.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), puis ouvrir une capture 802.11 en mode
moniteur d'une session Download Play. Filtre : `dsdownloadplay`.

## Limites constatées à l'import

- le greffon s'enregistre pour tout l'élément 802.11 `0xDD` (vendor-specific)
  dans `wlan.tag.number` : il remplace le décodage natif des éléments
  vendor-specific de tous les fabricants (WPS, WMM, Microsoft…) par une
  « annonce » Download Play brute ;
- l'annonce elle-même n'est pas décodée (dissecteur `data`) ;
- utilise l'opérateur `>>` (Lua 5.3 et plus) : ne se charge pas dans un
  Wireshark lié à Lua 5.1 ou 5.2 ;
- variables globales `dlplay` et `g_opcodes` ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
