# ACM ICN Demo (CCN-lite Publish–Subscribe)

Post-dissecteur Wireshark Lua de la démonstration **« Information-Centric
Networking for the Industrial IoT »** (ACM ICN 2017, HAW Hamburg) : sur les
trames IEEE 802.15.4, il lit la charge utile (`data.data`) et identifie les
messages du plan de contrôle de la version modifiée de CCN-lite v1 (option
Publish–Subscribe : COMPAS PAM/NAM/SOL, Interest, Data, sniffer), avec
l'émetteur, le destinataire et le flux.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/5G-I3/ACM-ICN-17_Demo |
| Commit importé | `7c4870e64e5e2a97f0ecbc3d537ecdfceadbb9ae` du 19/10/2017 (branche `master`, dernier commit) |
| Licence amont | LGPL-2.1 (`LICENSE` amont, texte LGPL v2.1 ; aucune mention « or later » dans le dépôt, d'où `LGPL-2.1-only`) |
| Natif Wireshark 4.6.4 | Non — Wireshark décode IEEE 802.15.4, pas cette variante CCN-lite |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `acmicndemo.lua` | Post-dissecteur `acmicndemo` (champs `acmicndemo.from`, `.to`, `.flow`, `.msg`) |

Fichier importé tel quel ; seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier. Le reste du dépôt amont (correctifs
CCN-lite et RIOT, application de démonstration, sniffer Python, tableau de
bord) n'est pas importé.

## Utilisation

Copier `acmicndemo.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, puis
ouvrir une capture IEEE 802.15.4 de la démonstration. Filtres utiles :
`acmicndemo.msg == "PAM"`, `acmicndemo.from == "NODE_A"`.

## Remarques

- Code propre à la démonstration : la table `MAPPING` associe en dur les
  adresses EUI-64 des trois PhyNodes et de la racine (`ROOT`, `NODE_A`…) ;
  d'autres adresses s'affichent en clair.
- Post-dissecteur : il s'exécute sur chaque trame ayant une charge
  `data.data` et des adresses 802.15.4, sans autre test de protocole.
- Variables globales (`MAPPING`, constantes de types) ; pas de capture
  d'exemple amont ; décodage non vérifié dans Wireshark.
