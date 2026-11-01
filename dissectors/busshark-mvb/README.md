# BusShark MVB / WTB (bus ferroviaires TCN)

Dissecteurs Wireshark Lua du projet **BusShark** pour les bus ferroviaires
du TCN (IEC 61375) : **MVB** (Multifunction Vehicle Bus) et **WTB** (Wire
Train Bus). Les trames sont encapsulées dans un en-tête Ethernet BusShark
(EtherType `0xC001` / `0xC002`, protocole `busshark`), puis décodées en
trames maître/esclave MVB, en-têtes liaison/réseau WTB et données de
processus/messages. Un post-dissecteur (`register_postdissector`) ajoute une
analyse (périodes, métadonnées, cache).

## Import

| | |
|---|---|
| Dépôt amont | https://gitlab.com/busshark/busshark.dissectors.mvb |
| Commit importé | `25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c` du 11/07/2025 (branche `master`, dernier commit ; `VERSION` amont : v0.10.0) |
| Licence amont | GPL-2.0-only (fichier `LICENSE` amont : texte de la GPL v2, sans mention « or any later version » ; aucune en-tête de licence dans les fichiers Lua) |
| Natif Wireshark 4.6.4 | Non — pas de dissecteur MVB/WTB natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

L'arborescence du plugin amont (`plugins/busshark.dissectors/`) est
conservée dans `busshark.dissectors/`, car `busshark-dissector.lua` charge
ses modules avec `require("mvb/mvb-slaveframe")`, etc., relativement à son
propre dossier.

| Fichier | Rôle |
|---|---|
| `busshark.dissectors/busshark-dissector.lua` | Point d'entrée : protocoles `busshark`, `mvb`, `wtb`, enregistrement EtherType et post-dissecteur |
| `busshark.dissectors/busshark-fillheader.lua` | En-tête BusShark (« fill header ») |
| `busshark.dissectors/busshark-mtc.lua` | Trames MTC |
| `busshark.dissectors/mvb/*.lua` | Trames esclaves, métadonnées et analyse MVB |
| `busshark.dissectors/wtb/*.lua` | Dissecteur et analyse WTB |
| `busshark.dissectors/meta/meta-analyse.lua` | Analyse des métadonnées |
| `busshark.dissectors/types/chache.lua` | Petit cache utilitaire (nom amont conservé) |
| `captures/*.pcapng` | 11 captures d'exemple amont (`example-pcap-files/`) |

Fichiers Lua importés tels quels ; seule une en-tête SPDX + provenance de
quatre lignes a été ajoutée en tête de chaque fichier. Les captures sont des
copies binaires conformes.

## Utilisation

Copier le dossier `busshark.dissectors/` entier dans le dossier `plugins`
de Wireshark (ex. `~/.local/lib/wireshark/plugins/busshark.dissectors/`),
recharger les plugins Lua, puis ouvrir une capture de `captures/` et
filtrer avec `mvb` ou `wtb`.

## Remarques

- Seul `busshark-dissector.lua` doit être chargé comme point d'entrée ; les
  autres fichiers sont des modules. Wireshark chargeant tous les `.lua` des
  sous-dossiers de `plugins`, le comportement en double chargement n'a pas
  été vérifié (non vérifié dans Wireshark).
- Non repris : les deux plus grosses captures amont
  (`test_mvb2net-period+msg--f0-f1-f2-f3-f4--f9-f12-f15.pcapng`, 4,6 Mo ;
  `test_mvb2net-period-f1-f2-f3-f4-f15.pcapng`, 1,4 Mo), les profils
  Wireshark, la documentation et le test unitaire amont
  (`test/lua/test-chache.lua`) — disponibles dans le dépôt amont.
- Le matériel d'acquisition BusShark (passerelle MVB/WTB → Ethernet) n'est
  pas fourni ; décodage non vérifié sur trafic réel.
