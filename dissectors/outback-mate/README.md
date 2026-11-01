# OutBack MATE / MateNET (énergie solaire)

Dissecteur Wireshark Lua du **protocole série MateNET d'OutBack Power**,
échangé entre une console MATE et les équipements OutBack (hub, onduleurs
FX, contrôleurs de charge MX, moniteurs FLEXnet DC) sur une liaison série
TTL : commandes (lecture, écriture, statut, pages de journal), registres
nommés, décodage des trames de statut par type d'équipement.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/jorticus/pymate (dossier `pymate/packet_capture/`) |
| Commit importé | `a90c973e54f71852bc3f1bb075b3d0a3599c8883` du 16/03/2021 (branche `master`, dernier commit ; dernière modification du dossier : `cfebaa9` du 01/04/2020) |
| Licence amont | GPL-2.0-only (`LICENSE` amont : texte de la GPL v2, sans mention « or any later version » ; pas d'en-tête de licence dans le fichier Lua) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur MateNET natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `mate_dissector.lua` | Dissecteur `matenet` (filtres `matenet.port`, `matenet.cmd`, `matenet.register`…) |
| `captures/capture-hub-fx-cc-dc.pcapng` | Capture d'exemple amont (`Capture Hub FX CC DC.pcapng`, renommée sans espaces) : hub, FX, CC et DC |

Fichier Lua importé tel quel ; seule une en-tête SPDX + provenance de
quatre lignes a été ajoutée en tête. La capture est une copie binaire
conforme.

## Utilisation

1. Copier `mate_dissector.lua` dans le dossier `plugins` de Wireshark
   (ex. `~/.local/lib/wireshark/plugins/`) et recharger les plugins Lua.
2. Le dissecteur ne s'accroche pas tout seul à l'encapsulation : comme le
   décrit l'amont, ajouter dans Préférences → Protocols → DLT_USER une
   entrée `User 0 (DLT = 147)` avec le protocole `matenet`.
3. Ouvrir `captures/capture-hub-fx-cc-dc.pcapng` ; filtre utile :
   `matenet.cmd != 4` (masque les trames STATUS).

## Remarques

- La capture en direct passe par un Arduino Mega (sketch `Sniffer.ino`) et
  le script amont `pymate/packet_capture/wireshark_tap.py` (Windows
  uniquement, tube nommé) : non repris ici, voir le dépôt amont.
- Le script utilise des variables globales (`mate_proto`, `device_table`…),
  comme l'amont.
- Non vérifié dans Wireshark, y compris sur la capture fournie.
