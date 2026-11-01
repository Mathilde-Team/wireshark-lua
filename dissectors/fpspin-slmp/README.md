# SLMP — sPIN Lightweight Messaging Protocol (FPsPIN)

Dissecteur Wireshark Lua du **sPIN Lightweight Messaging Protocol (SLMP)**,
petit protocole de messagerie sur UDP de la démonstration FPGA FPsPIN
(ETH Zurich, laboratoire SPCL) : un message est découpé en paquets portant
un identifiant de message et un décalage, avec des drapeaux de
synchronisation, de fin de message et d'acquittement (issue #91).

**À ne pas confondre** avec le SLMP de Mitsubishi Electric (SeamLess
Message Protocol, CC-Link IE) : malgré le même sigle et l'étiquette
« industriel » de l'issue, il s'agit d'un protocole de recherche pour le
calcul dans le réseau (« sPIN » / PsPIN), sans rapport avec les automates.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/spcl/FPsPIN (`fpga/app/pspin/utils/slmp.lua`) |
| Commit importé | `f5feca170a84c9236edf4ecd1d34c23261d7787c` du 26/05/2024 (dernier commit de la branche par défaut `main`) ; dernière modification de `slmp.lua` et de la capture : commit `c3ba3025555008660fbbfbe74a3fbcdb45b152fe` du 15/04/2024 |
| Licence amont | BSD-3-Clause, « Copyright 2024 ETH Zurich » (`LICENSE` du dépôt ; GitHub affiche `NOASSERTION` car le fichier reproduit aussi la licence BSD de Corundum, qui ne concerne pas ce script) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur `slmp` ni sPIN (`tshark -G protocols`) |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont). Le script est repris tel quel (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le reste de FPsPIN (Verilog, C) n'est
pas importé.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/slmp.lua` | Protocole `slmp` sur UDP 9330 : drapeaux sur 16 bits (`EOM` 0x8000, `SYN` 0x4000, `ACK` 0x2000, bits réservés), identifiant de message et décalage sur 32 bits gros-boutistes, charge utile ; Info du type `[S] MsgId=… Off=… Len=…` |
| `captures/slmp.pcap` | Capture amont (banc de test `fpga/app/pspin/tb/pspin_pkt_match/slmp.pcap`, 13/07/2023) : 41 trames, dont un message de 54 984 octets en 38 paquets et un acquittement |

## Utilisation

Copier `src/slmp.lua` dans le dossier des plugins Lua personnels de
Wireshark (« Aide › À propos de Wireshark › Dossiers »), puis Ctrl+Maj+L.
Filtres : `slmp`, `slmp.flags`, `slmp.eom`, `slmp.syn`, `slmp.ack`,
`slmp.msgid`, `slmp.offset`, `slmp.payload`.

**Sous Wireshark 4.x** : le script utilise `bit32`, absent de la Lua 5.4
des Wireshark récents ; sans contournement il **ne se charge pas**
(« attempt to index a nil value (global 'bit32') », ligne 6). Contournement
sans modifier le script : un fichier chargé avant lui (par exemple
`00_bit32.lua` dans le même dossier) contenant

```lua
_G.bit32 = _G.bit32 or bit
```

(même contournement que pour `dissectors/opendatacon/`.)

## Vérification à l'import

Avec tshark 4.6.4 et le contournement `bit32`, `luac5.4 -p` : OK.

Capture amont `captures/slmp.pcap` : 39 trames SLMP (+ 2 ARP), toutes du
même message (`MsgId=1413282924`) : premier paquet `[S]` à `Off=0`, un
acquittement `[A]` de 0 octet en retour, 36 paquets intermédiaires de
1 462 octets, dernier paquet `[ES]` à `Off=54094`, `Len=890` ; décalages
consécutifs.

Capture synthétique (UDP 9330) :

| Trame | Résultat |
|---|---|
| `SYN`, msg 7, décalage 0, 32 octets | `[S] MsgId=7 Off=0 Len=32` |
| sans drapeau, décalage 32 | `MsgId=7 Off=32 Len=32` |
| `EOM`, décalage 64, 16 octets | `[E] … Len=16`, `slmp.eom` = 1 |
| `ACK` sans charge | `[A] … Len=0` ; `slmp.payload` vide (`<MISSING>`) |
| `EOM`+`SYN`+bit réservé 0x0001 | `[ES]`, `slmp.reserved` = `0x0001` |
| 3 octets | erreur Lua « Range is out of bounds » (pas de contrôle de longueur) |

## Limites constatées

- Dépendance à `bit32` (voir Utilisation).
- Port UDP 9330 codé en dur.
- Pas de contrôle de longueur minimale (10 octets) : erreur Lua sur un
  paquet plus court.
- Pas de réassemblage des messages ; l'ACK n'est pas rapproché du paquet
  acquitté.
