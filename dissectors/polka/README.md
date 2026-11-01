# PolKA (routage par la source à clé polynomiale)

Dissecteur Wireshark en Lua de l'en-tête PolKA (Polynomial Key-based
Architecture for Source Routing), architecture de routage par la source où
la route est encodée dans un identifiant calculé par restes chinois sur des
polynômes (et non un schéma cryptographique, contrairement à ce qu'indiquait
l'issue), issue #52.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/eversonscherrer/dissector-polka |
| Commit importé | `850002ae0887d6f60a66533720b51fe08153eca5` du 26/10/2022 |
| Licence amont | GPL-3.0-or-later (en-tête de `polka_dissector.lua`, « either version 3 of the License, or (at your option) any later version ») ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | non (aucun dissecteur PolKA natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: GPL-3.0-or-later` avec la provenance est ajoutée
(convention du dépôt, issue #563). L'amont ne fournit pas de texte de
licence séparé (avertissement attendu de `scripts/valider_imports.py`) ; le
texte de la GPLv3 est le fichier `LICENSE` à la racine de ce dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/polka_dissector.lua` | Dissecteur `polka` sur l'EtherType `0x8842` : version, TTL, type du protocole suivant, identifiant de route (16 octets), puis passage de la suite au dissecteur IP |

Non importée : la capture d'exemple `polka-dissector.pcapng` (39 trames,
contient aussi du trafic mDNS avec des noms de machines personnels).

## Utilisation

Copier `src/polka_dissector.lua` dans le dossier des plugins Lua personnels
de Wireshark (ex. `~/.local/lib/wireshark/plugins/`) puis « Analyse →
Recharger les plugins Lua ». Les trames Ethernet d'EtherType 0x8842 sont
décodées automatiquement (le README amont évoque aussi une configuration
DLT USER, inutile dans ce cas).

## Vérification à l'import

Avec tshark 4.6.4, sur la capture amont (non importée) : les 10 trames PolKA
(encapsulées en ERSPAN) sont décodées — version, TTL, type 0x0800,
identifiant de route — puis l'ICMP/IPv4 qu'elles transportent ; aucune trame
malformée.

## Limites constatées à l'import

- noms de champs génériques (`version.addr`, `ttl.addr`, `type.addr`,
  `routeid`) au lieu de `polka.*` : à utiliser tels quels dans les filtres ;
- la suite est toujours passée au dissecteur IPv4, quel que soit le champ
  « Type » (IPv6 non géré) ;
- aucune vérification de longueur : une trame de moins de 20 octets
  déclenche une erreur Lua ;
- le fichier définit des variables globales (`polka_proto`, `proto_handle`,
  `subtree`).
