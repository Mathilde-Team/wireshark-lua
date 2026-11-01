# Ethernet SmoothStepper (ess-ws)

Dissecteur Wireshark Lua pour le protocole UDP de l'**Ethernet SmoothStepper**
(ESS, contrôleur de mouvement pour machines à commande numérique) : réveil et
découverte de la carte (port source 4096), puis trafic du contrôleur de
mouvement (port 9) avec en-têtes, commandes et trames d'exécution.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Saskatoon-SkunkWorx/ess-ws |
| Commit importé | `175fc078768bceae1e19ef689d725e6086b79895` du 29/12/2021 (branche `main`, dernier commit) |
| Licence amont | MIT (`LICENSE` amont, © 2021 Saskatoon-SkunkWorx) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SmoothStepper natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `ess-udp.dissector.lua` | Point d'entrée : protocole `ess-udp`, enregistré sur UDP 9 et 4096 |
| `ess/SmoothStepperDissector.lua` | Messages de la carte (réveil, nom, adresses Ethernet/IP) |
| `ess/MotionControllerDissector.lua` | Trafic du contrôleur de mouvement, délègue aux trois modules suivants |
| `ess/MotionControllerHeaderDissector.lua` | En-tête des messages du contrôleur |
| `ess/RunCommandsDissector.lua` | Commandes d'exécution |
| `ess/RunFramesDissector.lua` | Trames d'exécution |

Fichiers importés tels quels, arborescence amont conservée. Seule une
en-tête SPDX + provenance de quatre lignes a été ajoutée en tête de chaque
fichier `.lua`.

## Utilisation

Copier `ess-udp.dissector.lua` **et** le dossier `ess/` dans le dossier
`plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis
recharger les plugins Lua. Le point d'entrée charge les modules par
`require 'ess.<Module>'`.

## Remarques

- Résolution de `require 'ess.…'` : Wireshark ajoute le dossier des plugins
  à `package.path`, ce qui devrait suffire avec l'arborescence ci-dessus ;
  non vérifié dans Wireshark.
- Wireshark charge aussi comme greffons les modules du sous-dossier `ess/` ;
  ils se contentent de renvoyer une table, sans effet de bord.
- UDP 9 est le port « discard » standard : le dissecteur peut s'appliquer à
  du trafic sans rapport avec l'ESS sur ce port.
- Le dépôt amont n'a pas de capture d'exemple ; inactif depuis décembre 2021.
