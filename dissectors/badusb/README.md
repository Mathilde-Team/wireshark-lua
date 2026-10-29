# BadUSB (Flipper Zero / Rubber Ducky / USB HID keyboard)

Dissecteur Wireshark pour les frappes envoyées par les périphériques BadUSB (Flipper Zero, Rubber Ducky, USBNinja…) et les claviers USB HID : il décode les rapports HID et affiche les touches envoyées.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/agentzex/FlipperZero-BadUSB-Wireshark |
| Commit importé | `450f19de756cf7f17f9a06722907d4e4bedf6afb` du 18/08/2023 (branche `main`) |
| Licence amont | MIT |
| Natif Wireshark 4.6.4 | Non — il s'agit de frappes clavier ; le dissecteur USB HID natif existe mais n'affiche pas les touches décodées |

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/badusb_dissector.lua` | Dissecteur des rapports HID clavier : touches de modification (masque de bits), mappage des touches vers `normal`/`shifted`, affichage du texte tapé |

Le dépôt amont contient aussi `reconstructor/reconstructor.py` et `packets.json` (reconstruction du payload DuckyScript à partir des paquets exportés) ainsi que des captures d'écran : non importés ici (le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier `src/badusb_dissector.lua` dans le dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins` sous Linux), puis capturer le trafic USB (ex. via USBPcap) : les frappes décodées apparaissent dans les paquets. Pour reconstruire un payload DuckyScript, voir le `reconstructor` du dépôt amont (script Python).
