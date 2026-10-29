# Battle.net classique (protocol bnetp)

Dissecteur Wireshark Lua pour le protocole Battle.net classique (bnetp) :
décodage des paquets du client/serveur Battle.net (v1.0/1.1x), y compris
les messages spécifiques Warcraft III (W3GS), en mode complet ou « lite »
(en-têtes seulement).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/BNETDocs/packet-bnetp (fork de diegonc/packet-bnetp) |
| Commit importé | `5b4abd619bc292be6db78878d4cf56011c65b450` du 19/02/2018 (branche `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE.md` amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissector bnetp natif dans Wireshark (`packet-bnetp.c` absent de l'arborescence amont) |

Texte complet de la licence amont : fichier `LICENSE.md` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-bnetp.lua` | Plugin monofichier généré par l'amont (concaténation des modules via filepp, « build on Mon Feb 19 03:59:29 2018 ») : s'attache au port TCP 6112 par défaut, décode en-têtes et charges utiles bnetp/W3GS |

L'amont conserve ses sources modulaires (`src/core.lua`, `src/api/*.lua`,
`src/cpackets*.lua`, `src/spackets*.lua`…) qui sont des entrées de build
filepp (directives `#include`), le `Makefile` et les outils (`tools/`,
`web/`) : non importés ici — seul le fichier Lua distribué est importé.

## Utilisation

Copier `src/packet-bnetp.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.local/lib/wireshark/plugins` sous Linux), ou lancer
`wireshark -X lua_script:/chemin/packet-bnetp.lua`. Port par défaut
configurable (`server_port = 6112`) et mode « lite » via l'objet `Config`
en tête de fichier.

## Limites constatées à l'import

- la bibliothèque BitOp embarquée du plugin est un repli 32 bits pour les
  Wireshark anciens (le fichier recommande de l'activer si besoin) ;
- couvre le protocole Battle.net classique tel qu'en février 2018 ;
  les messages « SID_ » plus récents ne sont pas couverts.
