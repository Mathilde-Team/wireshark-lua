# FruityMesh / BlueRange Mesh Community Edition

Dissecteur Wireshark en Lua des annonces Bluetooth Low Energy du maillage
FruityMesh (BlueRange Mesh Community Edition, BlueRange GmbH, ex-M-Way
Solutions) : paquets de découverte du maillage (« JOIN_ME »), paquets de
débogage, annonces MeshAccess et annonces d'actifs (« Asset »), issue #158.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/bluerange-io/bluerange-mesh |
| Commit importé | `7131ad137182ea0bf429c63a816fb0e2e694df64` du 19/08/2026 (dernière modification de `util/wireshark/fruitymesh.lua` : commit `1a11251ca94250a8fac30f72c517d2e582a2aa20` du même jour) |
| Licence amont | GPL-3.0 avec permission additionnelle (article 7 : combinaison avec les SDK Nordic) pour l'édition communautaire, double licence commerciale (fichier `LICENCE.txt` amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) ; identifiant retenu : `LicenseRef-BlueRange-Mesh-GPL-3.0-exception` |
| Natif Wireshark 4.6.4 | non (BLE natif, sans FruityMesh) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier` avec la provenance est ajoutée (convention du dépôt,
issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de `LICENCE.txt` amont : présentation de la double licence, texte de
l'exception, texte de la GPL v3).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/fruitymesh.lua` | Protocoles `fruitymesh`, `fruitymesh_debug`, `fruitymesh_ma` et `fruitymesh_asset`, enregistrés sur l'encapsulation `wtap_encap` 55 (`USER10`, DLT 157, utilisée par l'ancien nRF Sniffer de Nordic) ; appelle d'abord le dissecteur existant de cette encapsulation, puis décode les données constructeur (identifiant `0x024D`, octet `0xF0` maillage ou `0xDE` débogage) et le service UUID16 `0xFE12` (MeshAccess, Asset) à des positions fixes |

## Utilisation

Le fichier amont appelle `debug("…")`, fonction de journalisation des
anciennes versions de Wireshark ; dans Wireshark 4.x, `debug` est la
bibliothèque standard Lua (une table) : le chargement s'interrompt sur la
dernière ligne (« attempt to call a table value (global 'debug') ») et chaque
paquet provoque ensuite une erreur Lua après la partie « maillage ».

Contournement sans modifier le fichier importé : créer dans le dossier des
plugins Lua personnels un fichier chargé avant lui (ordre alphabétique), par
exemple `00-debug.lua`, contenant :

```lua
setmetatable(debug, { __call = function() end })
```

puis copier `src/fruitymesh.lua` dans le même dossier (ex.
`~/.local/lib/wireshark/plugins/`) et recharger (Ctrl+Maj+L). Filtres
d'affichage : `fruitymesh`, `fruitymesh_debug`, `fruitymesh_ma`,
`fruitymesh_asset`.

## Vérification à l'import

Avec tshark 4.6.4, contournement `debug` en place, sur des captures
synthétiques (text2pcap `-l 157`, 34 octets d'en-tête de remplissage puis
les données constructeur) :

| Trame | Résultat |
|---|---|
| `4D 02 F0 …` (paquet maillage) | `FruityMesh Protocol` : Network Id 4660, Message Type 1, Sender Id 5, Cluster Id `0x00020001`, Cluster Size 3, FreeIn 2 / FreeOut 3, batterie, puissance d'émission −4, Hops to Sink 2… |
| `12 FE …` puis message type 3 (MeshAccess) | `FruityMesh MeshAccess` : Network Id 4660, drapeaux, Serial index 12345, Module Id 1/2/3 |

Aucune erreur Lua avec le contournement ; sans lui, erreur au chargement et
sur chaque paquet (voir Utilisation).

## Limites constatées

- Positions fixes (octets 34 à 61) calquées sur l'en-tête de l'ancien
  nRF Sniffer (DLT 157) : les captures du nRF Sniffer actuel (encapsulation
  native `NORDIC_BLE`, DLT 272) ne sont pas décodées.
- Pas de contrôle de longueur : une trame plus courte provoque une erreur
  « Range is out of bounds ».
- La fonction globale `print_r` (débogage) est définie au niveau global.
- Non testé sur des captures réelles.
