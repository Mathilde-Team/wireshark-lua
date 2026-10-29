# EPICS — Channel Access et PV Access (cashark)

Deux dissecteurs Wireshark Lua pour les protocoles de contrôle-commande EPICS (utilisés pour les accélérateurs de particules et les instruments scientifiques) : `ca.lua` pour Channel Access, `pva.lua` pour PV Access.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mdavidsaver/cashark |
| Commit importé | `20ffcc19b5576d40ff4c9074b36f1a6031f5982e` du 22/08/2025 (branche `master`) |
| Licence amont | EPICS Open License (BSD 3 clauses, Regents of the University of California) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur CA/PVA natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ca.lua` | Dissecteur Channel Access (30 Ko) : recherche de canaux, lectures/écritures, moniteurs, types DBR |
| `src/pva.lua` | Dissecteur PV Access (20 Ko) : recherche, canaux, opérations get/put/monitor, TLS |

Non importés : `test/` (captures pcap/pcapng d'exemple) et `test-all.sh` (harnais de test), `.github/`, `.gitattributes`.

## Utilisation

Copier `src/ca.lua` et/ou `src/pva.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Les deux greffons écrivent « Loading CA… » / « Loading PVA… » sur stderr au chargement (comportement amont).

## Limites constatées à l'import

- `pva.lua` décode le trafic PV Access en clair ; le trafic TLS (captures `pva-tls`) n'est pas déchiffré ;
- les captures de test amont documentent les cas couverts (DBR, tableaux, énumérés, moniteurs, pipeline v2) — voir `test/` de l'amont.
