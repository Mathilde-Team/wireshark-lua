# LIFX LAN (ampoules connectées)

Dissecteur Wireshark Lua pour le protocole LAN des ampoules connectées LIFX : messages Set/State, attaches sur le port UDP 56700 (port par défaut des lampes LIFX).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mab5vot9us9a/WiresharkLIFXDissector |
| Commit importé | `cf3a97bd777426fbf561baf71b48ee18b58334b1` du 24/02/2018 (branche `master`) |
| Licence amont | GPLv3 (README et fichier `LICENSE`) — sans clause « or later » |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur LIFX natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/lifx.lua` | Dissecteur (50 Ko) : en-tête LIFX, messages Set/State et types du protocole LAN |

Non importés : `README.md` (documentation, reprise ici), `.gitignore`.

## Utilisation

Copier `src/lifx.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`), puis redémarrer Wireshark. Le dissecteur s'attache à l'UDP 56700. Filtres utiles : `lifx.type` pour les messages Set/State (voir commentaires en tête du fichier).

## Limites constatées à l'import

- non maintenu depuis 2018, testé contre Wireshark 2.4.3 par son auteur ;
- couvre la partie LAN du protocole (port 56700) ; pas de gestion du mode broadcast sur d'autres ports.
