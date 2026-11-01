# BACnet Secure Connect (BACnet/SC)

Dissecteur Wireshark en Lua de la couche BVLC de BACnet Secure Connect
(ASHRAE 135, addendum 135-2016bj) transportée sur WebSocket, pour les
connexions nœud ↔ hub et les connexions directes entre nœuds, issue #64.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/natebenes/sc-dissector (archivé par son auteur) |
| Commit importé | `f2954c3eaf9dd557a386e39831a10ed2554eb782` du 05/10/2022 (dernier commit de la branche par défaut `main`) |
| Licence amont | GPL-2.0-or-later (en-tête du fichier : « either version 2 of the License, or (at your option) any later version », © 2020 Nate Benes) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | oui : le dissecteur natif `bscvlc` (« BACnet Secure Connect Virtual Link Control », `epan/dissectors/packet-bvlc.c`) s'enregistre sur les mêmes sous-protocoles WebSocket `hub.bsc.bacnet.org` et `dc.bsc.bacnet.org` ; ce fichier est redondant. L'auteur a d'ailleurs archivé son dépôt à la sortie de Wireshark 4.0 |

Fichier importé tel quel (aucune modification de code, fins de ligne CRLF
de l'amont conservées) ; seule une en-tête
`SPDX-License-Identifier: GPL-2.0-or-later` avec la provenance est ajoutée
avant l'en-tête d'origine (convention du dépôt, issue #563).

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont, GPL version 2).

Non importés : `README.md` amont (installation) et les captures d'écran de
`docs/images/`.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/bsc.lua` | Protocole `bsc` (« BACnet Secure Connect Protocol »), enregistré dans la table `ws.protocol` pour `hub.bsc.bacnet.org` et `dc.bsc.bacnet.org` : fonction BVLC (BVLC-Result, Encapsulated-NPDU, Address-Resolution(-ACK), Advertisement(-Solicitation), Connect-Request/Accept, Disconnect-Request/Accept, Heartbeat-Request/ACK, Proprietary-Message), octet de contrôle, identifiant de message, adresses virtuelles (VMAC) d'origine et de destination, options d'en-tête (Secure Path, option propriétaire), charge utile de chaque fonction ; le NPDU encapsulé est passé au dissecteur natif `bacnet` |

## Utilisation

Copier `src/bsc.lua` dans le dossier des plugins Lua personnels de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L. Le
trafic BACnet/SC est en général chiffré (TLS, `wss://`) : il faut le
déchiffrer (fichier de clés TLS) pour que la couche WebSocket, puis BVLC,
soit visible. Filtre d'affichage : `bsc`, champs `bsc.*`.

Une fois chargé, le plugin remplace le dissecteur natif `bscvlc` sur les
deux sous-protocoles. Le dissecteur natif suffit dans la plupart des cas ;
ce fichier sert surtout de référence ou de comparaison.

## Vérification à l'import

Avec tshark 4.6.4, le fichier se charge sans erreur (`luac5.4 -p` : OK).
Sur une capture synthétique (poignée de main HTTP avec
`Sec-WebSocket-Protocol: hub.bsc.bacnet.org`, puis trames WebSocket
binaires masquées côté client) :

| Trame | Natif (`bscvlc`) | Avec le plugin (`bsc`) |
|---|---|---|
| Connect-Request, VMAC `0a:0b:0c:0d:0e:0f`, UUID `00010203-0405-0607-0809-0a0b0c0d0e0f` | `Function Connect-Request Message-ID 1` | `Connect-Request (vmac=0a:0b:0c:0d:0e:0f,uuid=00010203-0405-0607-0809-a0b0c0de0f)` ; arbre : VMAC, UUID, longueurs maximales BVLC et NPDU 1497 |
| Connect-Accept | `Function Connect-Accept Message-ID 1` | `Connect-Accept (vmac=…,uuid=…)` |
| Heartbeat-Request / Heartbeat-ACK | `Function Heartbeat-Request Message-ID 2`, puis `Heartbeat-ACK` | `Heartbeat-Request`, puis `Heartbeat-ACK` |

## Limites constatées

- Redondant avec le dissecteur natif `bscvlc` de Wireshark 4.6.4.
- UUID mal formaté dans la colonne Info : `format_uuid` lit les 6 derniers
  octets en deux entiers (4 + 2 octets) mais les écrit avec `%04x%02x`, sans
  zéros de tête suffisants (ex. `0a0b0c0d0e0f` affiché `a0b0c0de0f`).
  L'arbre de détail (champ `bsc.connect_request.uuid` de type GUID) reste
  correct. Non corrigé : import tel quel.
- Version annoncée par l'amont : v0.1.0 (2020), sans évolution depuis
  l'archivage.
- Non testé sur des captures réelles.
