# Portail Skylanders (USB)

Dissecteur Wireshark Lua du protocole USB du portail Skylanders (VID 0x1430,
PID 0x0150) : commandes de l'hôte et réponses du portail (activation,
couleurs et lumières, musique, état des figurines, lecture et écriture de
blocs) (issue #335).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pop-emu/portal-dissector |
| Commit importé | `91d0ae7d66dd65451b64728fc3d3d19abccd4bbd` du 26/11/2022 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2022 Marijn Kneppers ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif du portail Skylanders |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/usb_portal_protocol.lua` | Protocole `portal` enregistré dans `usb.product` pour `0x14300150` : caractère de commande (`A` Activate, `C` Color, `J`, `L` Light, `M` Music, `Q` Query, `R` Reset, `S` Status, `V` Version?, `W` Write), sens requête/réponse, champs par commande (RVB et côté, position de lumière, compteur et index des figurines présentes, ajoutées ou retirées, index de figurine et de bloc, données) |

Le fichier est repris tel quel (fins de ligne CRLF d'origine conservées),
en-tête de provenance ajouté. Le README amont n'est pas importé.

## Utilisation

Copier `src/usb_portal_protocol.lua` directement dans le dossier `plugins` de
Wireshark (pas dans un sous-dossier, selon l'auteur), puis capturer le trafic
USB du portail (USBPcap, usbmon). Filtre : `portal`.

## Limites constatées à l'import

- un code de commande absent de la table provoque une erreur Lua
  (`string.upper` appelé sur `nil`) ;
- les champs d'écriture réutilisent les noms de filtre de la lecture
  (`portal.query.figure_index`, `portal.query.block_index`,
  `portal.query.data`) : impossible de filtrer séparément lectures et
  écritures ;
- plusieurs commandes ou octets restent mal identifiés (`J`, « Version? »,
  champs `portal.unknown`) ;
- seul le portail VID/PID 0x1430/0x0150 est reconnu ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
