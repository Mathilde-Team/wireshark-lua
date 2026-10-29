# Fanuc Stream Motion (option J519, robotique)

Dissecteur Wireshark Lua pour le protocole Fanuc Stream Motion (option J519) : streaming de mouvement des robots industriels Fanuc.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/fanuc-stream-motion/packet-fanuc-stream-motion-j519 |
| Commit importé | `237e0f025b96ddbad292ddce231016631fd131a6` du 20/03/2020 (tag `0.1.1`, branche `master`) |
| Licence amont | GPLv2 ou toute version ultérieure (énoncée dans l'en-tête du fichier Lua) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Fanuc natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-fanuc-stream-motion-j519.lua` | Dissecteur (25 Ko) : messages du protocole de streaming de mouvement |

Non importés : `readme.md` (documentation, reprise ici) et `sshot.png` (capture d'écran).

## Utilisation

Copier `src/packet-fanuc-stream-motion-j519.lua` dans le dossier `plugins` de Wireshark (global ou par utilisateur). Développé pour Wireshark 2.2.x, attendu compatible avec la plupart des versions supportant Lua. Se référer à la documentation Fanuc de l'option J519 pour le protocole.

## Limites constatées à l'import

- dissector « quick-and-dirty » selon son auteur, non maintenu depuis 2020 ;
- pas de captures d'exemple fournies (seule une capture d'écran dans `sshot.png`, non importée).
