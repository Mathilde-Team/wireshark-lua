# Valheim — zsocket2

Dissecteur Wireshark en Lua du protocole réseau zsocket2 du jeu vidéo
[Valheim](https://www.valheimgame.com/), sur TCP uniquement (port 2456
disséqué automatiquement), issue #353.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/crazicrafter1/Valheim-Wireshark-zsocket2 (archivé) |
| Commit importé | `2a639fae5158a5bd4083388621a7208089b78ef7` du 07/04/2026 |
| Licence amont | GPLv3 (fichier `LICENSE`, sans clause « or later ») |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent via `tshark -G protocols`) |

Fichiers importés tels quels (aucune modification de code) depuis le dossier
amont `zsocket2/` ; seule une en-tête `SPDX-License-Identifier: GPL-3.0-only`
avec la provenance est ajoutée (convention du dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/zsocket2_main.lua` | Dissecteur principal : réassemblage TCP, en-tête, aiguillage par type de message, enregistrement sur le port TCP 2456 |
| `src/zsocket2_constants.lua` | Constantes (nom du protocole, taille d'en-tête) |
| `src/zsocket2_fields.lua` | Déclaration des champs (`valheimzs2.*`) |
| `src/zsocket2_readers.lua` | Lecteurs des types sérialisés (chaînes, vecteurs, ZDO…) |
| `src/zsocket2_rpcs.lua` | Décodage des RPC connus |
| `src/zsocket2_prefabs.lua` | Table des prefabs (hash → nom) |

Le dépôt amont contient aussi deux captures d'exemple (`samples/*.pcapng`) —
non importées (trafic de jeu réel de l'auteur, utilisé seulement pour la
vérification ci-dessous).

## Utilisation

Copier les six fichiers de `src/` dans un sous-dossier `zsocket2` du dossier
des plugins Lua personnels de Wireshark (« Aide → À propos de Wireshark →
Dossiers → Plugins Lua personnels », ex. `~/.local/lib/wireshark/plugins/zsocket2/`),
puis redémarrer Wireshark. Les modules sont chargés par `require` : le dossier
doit être dans `package.path`, ce que Wireshark 4.6 fait pour le dossier des
plugins.

Filtre d'affichage proposé par l'amont pour masquer le trafic périodique :
`valheimzs2 and not valheimzs2.pingpong.type and not valheimzs2.playerlist.host and not valheimzs2.nettime.time and not valheimzs2.zdodata.datarev`.

## Vérification à l'import

Avec tshark 4.6.4, installé comme ci-dessus : les deux captures d'exemple de
l'amont sont décodées (1 488 et 4 185 trames `valheimzs2`), sans erreur Lua,
sans trame malformée ni constat expert de sévérité « error ».

## Limites constatées à l'import

- dépôt amont archivé (« Project retired and consolidated into
  https://github.com/Avledet ») ; autre implémentation :
  https://github.com/Avledet/AvlWireshark ;
- l'amont signale lui-même un dissecteur en retard sur le jeu (nouveaux RPC
  absents, `ServerHandshake` à corriger) : certains messages s'affichent
  « Unknown (n) » ;
- TCP uniquement : le transport Steam (UDP) n'est pas couvert ;
- la capture doit commencer avant la session de jeu, sinon le flux n'est pas
  resynchronisé.
