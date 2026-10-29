# LIFX (LAN Protocol)

Dissecteur Wireshark Lua pour le LIFX LAN Protocol (ampoules et
périphériques LIFX) : il décode l'en-tête de trame, l'adresse de trame,
l'en-tête de protocole et les charges utiles des messages (état du service,
informations hôte/wifi, alimentation, couleur, infrarouge, tuiles…).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mab5vot9us9a/WiresharkLIFXDissector |
| Commit importé | `cf3a97bd777426fbf561baf71b48ee18b58334b1` du 24/02/2018 (branche `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissector LIFX natif dans Wireshark (`packet-lifx.c` absent de l'arborescence amont) |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/lifx.lua` | Dissecteur LIFX LAN Protocol : s'attache au port UDP 56700 (port par défaut des ampoules LIFX), décode trame, adresse, en-tête de protocole et charges utiles (messages device, light, infrarouge, tuiles…) |

Le dépôt amont contient aussi `README.md` et `.gitignore` : non importés
ici (le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier `src/lifx.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.local/lib/wireshark/plugins` sous Linux), puis capturer le trafic UDP
port 56700. Les filtres d'affichage pour Set/State et Get sont documentés
dans l'en-tête du fichier.

## Limites constatées à l'import

- testé par l'auteur avec Wireshark 2.4.3 (2017) ; les messages les plus
  récents du protocole LIFX (postérieurs à 2018) ne sont pas couverts ;
- le dissecteur couvre les « Tile Messages » ajoutés juste avant le
  dernier commit amont (février 2018).
