# NMEA 0183 (marine/GPS)

Dissecteur Wireshark Lua pour le protocole NMEA 0183 sur Ethernet : phrases GPS/marine (GGA, RMC…), multi-phrases, sur TCP/UDP.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/kmpm/wireshark-nmea |
| Commit importé | `6f539fc8408d3069b967a8d024908bca348cf0bb` du 04/10/2023 (branche `master`) |
| Licence amont | Apache-2.0 (énoncée dans l'en-tête du fichier et le fichier `LICENSE`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur NMEA natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/nmea0183.lua` | Dissecteur (19 Ko) : phrases NMEA 0183, en-tête/type/champs (`nmea.header`, `nmea.type`, `nmea.fields`, `nmea.message`) |

Non importés : `samples/` (captures d'exemple), `tests/` (harnais Makefile), `Makefile`, `README.md`.

## Utilisation

Copier `src/nmea0183.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`), ou lancer en ponctuel : `tshark -X lua_script:nmea0183.lua -T fields -e nmea.message -r capture.pcapng`.

## Limites constatées à l'import

- conçu pour NMEA 0183 sur Ethernet (TCP/UDP), pas pour la liaison série brute ;
- les captures d'exemple amont (`samples/`) documentent les cas couverts, dont les paquets multi-phrases (sim2) — non importées.
