# Marvell EDSA, Realtek DSA et tunnel iodine

Trois dissecteurs Wireshark en Lua de luizluca, issue #56 : étiquettes DSA
(Distributed Switch Architecture) des commutateurs Marvell (EtherType
`0xDADA`) et Realtek (EtherType `0x8899`), et tunnel IP sur DNS iodine.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/luizluca/wireshark-dissectors |
| Commit importé | `efed334ffe8bc5ab361fb84fcc7db4ace72186d2` du 18/01/2026 |
| Licence amont | GPL-3.0 (fichier `LICENSE` amont, sans en-tête dans les fichiers ni mention « or later » ; retenue : `GPL-3.0-only`) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Marvell EDSA : non. Realtek : partiel (RRCP, REP, RLDP natifs sur `0x8899`, sans étiquette DSA). iodine : non |

Fichiers importés tels quels (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: GPL-3.0-only` avec la provenance est ajoutée
(convention du dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/Marvell_EDSA.lua` | Protocole `Marvell_EDSA` sur l'EtherType `0xDADA` : commande (To CPU, From CPU, To Sniffer, Forward), périphérique et port source, VLAN, puis EtherType encapsulé |
| `src/RealtekL2.lua` | Protocole `RealtekL2` sur l'EtherType `0x8899` : étiquette DSA Realtek protocole 4 (8 octets et 4 octets, rtl8_4 / rtl4_4) ; protocoles 9 et `0xA` (RTL8366RB) signalés « Not implemented yet » |
| `src/iodine.lua` | Post-dissecteur `IODINE` : repère les requêtes et réponses DNS du tunnel iodine, décode les types (VERSION, LOGIN, données…), l'encodage base32/base64/base128 et les champs (version, défi de connexion, adresses, MTU, fragments) |

Non importées : les captures d'écran du README amont.

## Utilisation

Copier les fichiers de `src/` dans le dossier des plugins Lua personnels de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L. Filtres
d'affichage : `marvell_edsa`, `realtekl2`, `iodine`.

Pour les captures DSA Realtek rtl8_4, le README amont indique que libpcap ne
connaît pas le type de lien : remplacer les octets `0x14`–`0x15` du fichier
pcap par `0x01 0x00` (Ethernet).

## Vérification à l'import

Avec tshark 4.6.4, les trois fichiers se chargent sans erreur. Sur des captures
synthétiques (text2pcap) :

| Capture | Résultat |
|---|---|
| Ethernet `0xDADA`, étiquette `00 00 00 00` + IPv4 | Étiquette décodée (DSA Command : To CPU, Source Device/Port 0, Ethernet Type `0x0800`), IPv4 encapsulé décodé |
| Ethernet `0x8899`, étiquette protocole 4 sur 8 octets + IPv4 | Tag Version `0x04`, Reason Forward, Transmitter Port 1, Receiver Port Mask `0x0001`, IPv4 encapsulé décodé |
| DNS UDP 53, requête `vaaaakardaa.t.example.com` | Trame `IODINE`, domaine `t.example.com`, type VERSION, version `0x00000502`, compteur de cache |

## Limites constatées

- `RealtekL2.lua` remplace le dissecteur natif sur l'EtherType `0x8899` :
  une trame RRCP « Hello Request » (protocole 1), décodée en natif, n'est plus
  reconnue avec le plugin (« Unknown Realtek Ethertype DSA Tag »). Retirer le
  fichier pour analyser RRCP, REP ou RLDP.
- `Marvell_EDSA.lua` et `RealtekL2.lua` utilisent la même variable globale
  `edsa` : lorsque les deux sont chargés, l'arbre des trames Marvell est
  intitulé « Realtek Layer 2 Protocols 2 » (le décodage des champs reste
  correct).
- `iodine.lua` : une requête VERSION de moins de 6 octets décodés provoque
  l'erreur Lua « Range is out of bounds » (le test de longueur amont
  `if not buffer:len() == 6` est toujours faux).
- Non testé sur des captures réelles.
