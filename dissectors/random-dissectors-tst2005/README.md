# Dissecteurs divers (TeamViewer, Oracle Net8)

Dissecteurs Wireshark en Lua du dépôt « random-wireshark-dissectors » (export
GitHub d'un projet Google Code) : protocole TeamViewer et couche Oracle
SQL*Net / Net8 au-dessus de TNS, issue #54.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/tst2005googlecode/random-wireshark-dissectors (export Google Code) |
| Commit importé | `3896597ada9e6ddd024f2a8a5c4148e465450869` du 13/03/2015 |
| Licence amont | Apache-2.0 (déclarée par le README amont : « Code license : Apache License 2.0 ») — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | TeamViewer : non. Net8 : partiel (TNS natif, sans décodage des appels TTC/TTI). NMF : oui (MC-NMF natif) |

Fichiers importés tels quels (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: Apache-2.0` avec la provenance est ajoutée
(convention du dépôt, issue #563).

Le dépôt amont ne fournit pas de fichier de licence : le fichier `LICENSE` de
ce dossier est le texte officiel de la licence Apache 2.0
(https://www.apache.org/licenses/LICENSE-2.0.txt), ajouté pour accompagner
les fichiers importés.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/teamviewer.lua` | Protocole `TeamViewer`, port TCP 5938 ; décode l'en-tête (magic `0x1724` / `0x1130`), la commande et la longueur |
| `src/oracle_net8.lua` | Protocole `Net8` et sous-protocoles (`net8.setproto`, etc.) ; remplace le dissecteur natif sur le port TNS (TCP 1521) et lui délègue l'en-tête TNS avant de décoder les opérations Net8 (Set protocol, TTI call, etc.) |

Non importé : `nmf.lua` (MC-NMF / MC-NBFSE). Il échoue au chargement sous
Wireshark 4.6.4 (« there cannot be two protocols with the same description »)
car le protocole « .NET Message Framing Protocol » existe désormais en natif.

## Utilisation

Copier les fichiers de `src/` dans le dossier des plugins Lua personnels de
Wireshark (« Aide → À propos de Wireshark → Dossiers → Plugins Lua
personnels », ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L.
Filtres d'affichage : `teamviewer`, `net8`.

## Vérification à l'import

Avec tshark 4.6.4, les deux fichiers se chargent sans erreur. Sur des captures
synthétiques (text2pcap) :

| Capture | Résultat |
|---|---|
| TCP 5938, trame `17 24 10 04 00 …` (CMD_PING) | En-tête décodé (Magic `0x1724 command1`, Command `CMD_PING (16)`, Length 4), puis erreur Lua (voir Limites) |
| TCP 1521, paquet TNS Data contenant une opération Net8 « Set protocol » | Colonne Protocole `NET8`, Info « Oracle Set protocol (Java_TTC-8.2.0) », chaîne de version décodée |

## Limites constatées

- `teamviewer.lua` : pour toutes les commandes de type « command1 » autres que
  46, la ligne 154 (`if orig_data > 0`) compare un `ByteArray` à un nombre et
  provoque l'erreur Lua « attempt to compare number with ByteArray » ; seul
  l'en-tête est alors affiché. Le décodage du contenu chiffré n'est pas géré.
- `oracle_net8.lua` : prend la place du dissecteur TNS natif sur le port 1521
  (le natif reste appelé pour l'en-tête). Décodage partiel des opérations,
  écrit pour des versions anciennes d'Oracle (2015).
- Code non maintenu depuis 2015 ; non testé sur des captures réelles.
