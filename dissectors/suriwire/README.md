# Suriwire (alertes Suricata dans Wireshark)

Greffon Wireshark Lua pour afficher les alertes et informations de protocole Suricata (sortie EVE JSON) comme éléments de la dissection des paquets : alertes, HTTP, fileinfo, TLS, SSH, SMB.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/regit/suriwire |
| Commit importé | `21a50fb6235b60a7806c8312988769abc2c3914d` du 04/11/2021 (branche `master`) |
| Licence amont | GPLv3 (fichier `LICENSE`, sans clause « or later ») |
| Natif Wireshark 4.6.4 | Non — pas d'équivalent natif (intégration Suricata) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/suriwire.lua` | Greffon (15 Ko) : lecture des événements EVE JSON de Suricata et rattachement aux paquets |

Non importés : `doc/` (capture d'écran), `README.rst`, `INSTALL`, `ChangeLog`, `TODO`.

## Utilisation

Copier `src/suriwire.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Nécessite une capture PCAP avec un fichier EVE JSON de Suricata correspondant : le greffon lit `suriwire.eve` (à générer depuis Suricata en mode offline avec `-l`) et affiche alertes/protocoles sur les paquets appariés.

## Limites constatées à l'import

- la correspondance pcap ↔ EVE repose sur le montage décrit dans le README amont (génération de deux fichiers liés) ;
- événements supportés : alerts, HTTP, fileinfo, TLS, SSH, SMB (limites amont).
