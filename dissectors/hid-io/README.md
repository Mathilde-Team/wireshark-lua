# HID-IO (RPC hôte ↔ périphérique sur USB HID)

Dissecteur Wireshark en Lua, partiel, du protocole
[HID-IO](https://github.com/hid-io/hid-io/) (RPC entre l'hôte et des
claviers ou périphériques à firmware personnalisé, par exemple Input Club),
transporté dans les transferts USB HID interrupt, issue #51.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/half-duplex/wireshark-hid-io |
| Commit importé | `a04418f0964c9743fe7761cbfde74058fc613d6b` du 11/06/2021 |
| Licence amont | EUPL-1.2 (`LICENSE.txt` amont, © 2021 Trevor Bergeron) — l'annexe de l'EUPL-1.2 liste la GPLv3 parmi les licences compatibles |
| Natif Wireshark 4.6.4 | non (aucun dissecteur HID-IO natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: EUPL-1.2` avec la provenance est ajoutée
(convention du dépôt, issue #563). Le fichier reste sous EUPL-1.2.

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de `LICENSE.txt` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hid-io.lua` | Dissecteur `HID-IO` enregistré dans la table `usb.interrupt` pour la classe d'interface HID (0x03) : en-tête (type, continuation, largeur d'identifiant, longueur sur 2 ou 10 bits), identifiant de commande (table des ID connus), commande terminal en clair ; constats expert pour paquet tronqué, longueur invalide, ID ou type inconnus |

## Utilisation

Copier `src/hid-io.lua` dans le dossier des plugins Lua de Wireshark (ex.
`~/.local/lib/wireshark/plugins/`) et redémarrer Wireshark. Capturer le
trafic USB (usbmon sous Linux, USBPcap sous Windows) en incluant
l'énumération du périphérique, pour que Wireshark connaisse la classe de
l'interface.

## Vérification à l'import

Avec tshark 4.6.4 : chargement sans erreur. Faute de capture USB d'un
périphérique HID-IO, le dissecteur a été appelé directement sur deux charges
synthétiques (rattachement temporaire à un port UDP par un script de test
non importé) : paquet Data « Terminal Command » (`help`) et paquet Sync, tous
champs d'en-tête décodés.

## Limites constatées à l'import

- l'amont le décrit comme « basic, partial » : seule la commande terminal
  (0x31) a un décodage de charge, les autres ID sont affichés bruts ;
- enregistré pour toute la classe HID : il tente d'analyser tout le trafic
  interrupt des claviers, souris, etc. — à désactiver (« Analyse →
  Protocoles activés ») quand il n'est pas utile ;
- HID-IO sur USB uniquement ; non vérifié sur une vraie capture USB.
