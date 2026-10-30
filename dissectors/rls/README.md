# RLS — Radio Link Simulation Protocol (UERANSIM)

Dissecteur Wireshark Lua pour le RLS (Radio Link Simulation Protocol)
d'[UERANSIM](https://github.com/aligungr/UERANSIM), simulateur open-source
de RAN 5G : le protocole RLS simule la liaison radio (gNB ↔ UE) entre les
processus d'UERANSIM. Un module par version de protocole (3.1.x et 3.2.x),
sélectionnés par un point d'entrée commun.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/louisroyer/RLS-wireshark-dissector (miroir : nextmn/RLS-wireshark-dissector) |
| Commit importé | `616ed507c7152b909edf53514335bb04308f44ed` du 24/08/2026 (branche `master`) |
| Licence amont | CC0-1.0 (fichier `LICENSE` amont, en-têtes SPDX dans les fichiers) — compatible GPL-3.0-or-later |
| Natif Wireshark 4.6.4 | Non — protocole spécifique à UERANSIM, aucun dissector natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rls.lua` | Point d'entrée : lit la version dans l'en-tête du paquet et délègue au module correspondant, avec repli sur la version la plus proche (port UDP 4997 par défaut, configurable en préférence, avec « Decode as… ») |
| `src/protocol/rls-3-1.lua` | Dissecteur RLS version 3.1.x (enregistrement dans la table `rls`) |
| `src/protocol/rls-3-2.lua` | Dissecteur RLS version 3.2.x (enregistrement dans la table `rls`) |

Le dépôt amont contient aussi `pcap/` (captures d'exemple), `.luacheckrc`,
`.pre-commit-config.yaml`, `.github/` et `.gitattributes` : non importés ici
(le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier `src/rls.lua` et le dossier `src/protocol/` dans le dossier
`plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins` sous Linux),
en conservant l'arborescence : les trois scripts sont chargés séparément
par Wireshark et coopèrent via la table de dissecteurs `rls`. Le port UDP
se règle dans les préférences du protocole RLS.

## Limites constatées à l'import

- les versions couvertes sont 3.1.x et 3.2.x (versions gérées par l'amont
  au moment de l'import) ; une version plus récente sera repliée sur la
  plus proche connue avec l'info « Unsupported version » ;
- l'arborescence `src/protocol/` doit être conservée pour que le point
  d'entrée trouve les modules de version.
