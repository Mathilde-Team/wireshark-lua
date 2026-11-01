# Fluke NetDAQ

Dissecteur Wireshark Lua du protocole **NetDAQ** des centrales
d'acquisition Fluke 2640A et 2645A (NetDAQ) : protocole TCP propriétaire
rétro-conçu, requêtes et réponses précédées du marqueur `FELX`, d'un
numéro de séquence, d'un code de commande et d'une longueur (issue #93).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Doridian/NetDAQ (`wireshark/netdaq.lua`) |
| Commit importé | `e9f60be6fad7a892158ae656b911503900deb1a9` du 14/10/2026 (dernier commit de la branche par défaut `main`) ; dernière modification de `wireshark/netdaq.lua` : commit `ad88fcc868b81e7a767ccc7a5d91116dd9df79b3` du 18/03/2025 |
| Licence amont | BSD-3-Clause, « Copyright (c) 2024, Mark Dietzer » (`LICENSE` du dépôt) ; le script porte la mention « (c) fenugrec 2025 » et a été versé au dépôt par ses PR #58 et #64, donc sous la licence du dépôt — compatible avec la licence de ce dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur NetDAQ ni Fluke (`tshark -G protocols`) |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont). Le script est repris tel quel (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). La bibliothèque Python et le
`PROTOCOL.md` amont ne sont pas importés ; aucune capture n'est fournie
en amont.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/netdaq.lua` | Protocole `netdaq` (« Fluke NetDAQ protocol ») sur TCP 4369 : marqueur, `seq_id`, `cmd` (34 commandes nommées : `PING`, `STATUS_QUERY`, `START`, `GET/SET_TIME`, `GET_VERSION_INFO`, `GET/SET_CONFIG`, `ERROR`…), `pkt_len` ; détail de `START` différé, `GET/SET_TIME`, `ERROR` et du bloc de configuration de 2 492 octets (drapeaux, trois intervalles, 30 voies avec mode, calibre et bits supplémentaires) ; réassemblage TCP d'un message coupé |

## Utilisation

Copier `src/netdaq.lua` dans le dossier des plugins Lua personnels de
Wireshark (« Aide › À propos de Wireshark › Dossiers »), puis Ctrl+Maj+L.
Filtres : `netdaq`, `netdaq.seq_id`, `netdaq.cmd`, `netdaq.pkt_len`,
`netdaq.payload`. Le `PROTOCOL.md` amont documente le format.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur (`luac5.4 -p` : OK).
Capture synthétique sur TCP 4369, charges construites avec les fonctions
d'encodage de la bibliothèque amont (`netdaq/utils/encoding.py` :
`make_time`, `make_int`, `make_timedelta`) :

| Trame | Résultat |
|---|---|
| `PING` et réponse | `seq=1, CMD=0x00 (PING)` dans les deux sens |
| `STATUS_QUERY` → réponse de 4 octets | réponse affichée `CMD=0x00 (PING), STATUS:00 00 00 00, pl_len=4` |
| `SET_TIME` 01/11/2026 9:30:15 | `TIME=9:30:15, 26-11-1` |
| `START` différé | `DELAYED START @9:35:15, 26-11-1` |
| `GET_VERSION_INFO` → chaînes | réponse brute `pl_len=35` (chaînes non décodées) |
| `SET_CONFIG` (2 508 octets sur 2 segments TCP) | réassemblé ; bloc de configuration : drapeaux, intervalles `00:00:02.500` et `00:01:00.000`, voie 1 (mode, calibre, bits), voies 2 à 30 « disabled » |
| `ERROR` code `0x1234` | `CMD=0xFFFFFFFF (ERROR):0x1234` |
| `GET_CONFIG` (requête vide) → réponse de 2 492 octets | requête marquée « unexpected payload length ! » ; réponse brute |
| commande `0x6B` (absente de la table) | erreur Lua « attempt to index a nil value » (ligne 172) |

## Limites constatées

- Port TCP 4369 codé en dur (c'est aussi le port d'Erlang EPMD : le
  dissecteur Lua prend le pas sur le natif `epmd`).
- Les réponses ont toutes le code `0x00` (ou `0xFFFFFFFF`) : elles sont
  affichées comme `PING` et leur contenu n'est pas interprété (pas de
  suivi de conversation par numéro de séquence) ; seul le bloc de
  configuration envoyé par `SET_CONFIG` est détaillé.
- Les requêtes `GET_CONFIG` (vides) sont signalées à tort comme de
  longueur inattendue (`expected_pl` porte sur la réponse).
- Commande inconnue : erreur Lua (pas de valeur par défaut dans la table).
- Un seul message par segment TCP (hypothèse écrite dans le script).
- Variables globales (`netdaq_protocol`, champs, `cmd_table`, `dis`,
  `tvbs`, `length`, `cfg_t`…).
- Non testé sur des captures réelles.
