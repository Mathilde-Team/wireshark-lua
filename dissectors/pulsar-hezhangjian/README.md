# Apache Pulsar (protocole binaire)

Dissecteur Wireshark en Lua du protocole binaire d'Apache Pulsar (messagerie
distribuée pub-sub) : découpe des trames `[TOTAL_SIZE][CMD_SIZE][CMD]`
(et métadonnées des messages) et décodage des commandes protobuf
`pulsar.proto.BaseCommand` par le dissecteur Protobuf natif, issue #55.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/hezhangjian/wireshark-lua-dissector |
| Commit importé | `86d18e1757acbf6f3847e0fe390e14fa29a22266` du 09/03/2023 |
| Licence amont | Apache-2.0 (en-tête ASF de `pulsar/pulsar_dissector.lua` et de `proto/PulsarApi.proto` ; le dépôt n'a pas de fichier de licence) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur Pulsar natif) |

Fichier Lua importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: Apache-2.0` avec la provenance est ajoutée
(convention du dépôt, issue #563). `proto/PulsarApi.proto` est copié tel quel
(il porte déjà son en-tête de licence ASF).

Le dépôt amont ne fournit pas de fichier de licence : le fichier `LICENSE` de
ce dossier est le texte officiel de la licence Apache 2.0
(https://www.apache.org/licenses/LICENSE-2.0.txt).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/pulsar_dissector.lua` | Protocole `Pulsar` sur le port TCP 6650 (préférence « Pulsar TCP port ») ; crée aussi `protobuf_tcp` et `protobuf_udp` (« Decode As » de Protobuf brut) |
| `proto/PulsarApi.proto` | Définition protobuf des commandes Pulsar (copie de celle du projet Apache Pulsar) |

Non importés :

- `bookkeeper/bookkeeper_dissector.lua` : aucune licence déclarée ;
- `zookeeper/zookeeper_dissector.lua` : copie de ceache/zab_dissector, traité
  par l'issue #448 (et qui échoue au chargement sous Wireshark 4.6.4 dans cette
  version, voir Limites) ;
- `proto/BookkeeperProtocol.proto`, documentation et scripts de déploiement.

## Utilisation

1. Ajouter le dossier `proto/` aux chemins de recherche Protobuf
   (« Préférences → Protocols → ProtoBuf → Protobuf search paths », cocher
   « Load all files »).
2. Copier `src/pulsar_dissector.lua` dans le dossier des plugins Lua
   personnels (ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L.

Filtre d'affichage : `pulsar`, ou les champs protobuf
(`protobuf.field.name == "type"`), voire `pbf.pulsar.proto.*` si l'option
« Dissect Protobuf fields as Wireshark fields » est cochée.

## Vérification à l'import

Avec tshark 4.6.4 : chargement sans erreur. Sur une capture synthétique
(text2pcap, TCP 6650, trame `00 00 00 09 00 00 00 05 08 12 92 01 00`), la
trame est attribuée à `Pulsar` et décodée en
`pulsar.proto.BaseCommand type=PING ping` (champ 1 `type = PING(18)`, champ
18 `ping` de type `pulsar.proto.CommandPing`).

## Limites constatées

- Une seule commande par segment TCP ; pas de réassemblage (si la trame est
  plus longue que le segment, le dissecteur ne fait rien).
- Sans `PulsarApi.proto` dans les chemins Protobuf, seules les données brutes sont
  affichées.
- `zookeeper_dissector.lua` amont (non importé) appelle `error()` sur
  l'argument que Wireshark 4.x passe aux scripts Lua, d'où un échec au
  chargement.
- Non testé sur des captures réelles ; amont non maintenu depuis 2023.
