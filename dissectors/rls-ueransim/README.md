# RLS — Radio Link Simulation Protocol (UERANSIM)

Dissecteur Wireshark Lua pour le protocole RLS (Radio Link Simulation) d'UERANSIM, simulateur open source de réseau 5G (RAN) : versions 3.1.x et 3.2.x du protocole.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/louisroyer/RLS-wireshark-dissector (désormais https://github.com/nextmn/RLS-wireshark-dissector) |
| Commit importé | `616ed507c7152b909edf53514335bb04308f44ed` du 24/08/2026 (branche `main`) |
| Licence amont | CC0-1.0 (Creative Commons Zero v1.0 Universal) — énoncée dans les en-têtes SPDX des fichiers |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur RLS natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rls.lua` | Point d'entrée : version du greffon, sélection de version de protocole, attachement |
| `src/protocol/rls-3-1.lua` | Protocole RLS v3.1.x |
| `src/protocol/rls-3-2.lua` | Protocole RLS v3.2.x |

Non importés : `pcap/` (captures d'exemple), `.github/`, `.luacheckrc`, `.pre-commit-config.yaml`, `.gitattributes`.

## Utilisation

Copier le contenu de `src/` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`), en conservant l'arborescence `protocol/`. Nécessite Wireshark ≥ 3.0 (dissecteurs `nr-rrc`). Un paquet Debian `wireshark-ueransim-rls` existe côté amont (dépôt deb-royer.irit.fr).

## Limites constatées à l'import

- les fichiers amont portent déjà leurs en-têtes SPDX (CC0-1.0) : l'en-tête d'import est ajouté au-dessus ;
- le décodage dépend des dissecteurs `nr-rrc` de Wireshark pour les messages RRC encapsulés.
