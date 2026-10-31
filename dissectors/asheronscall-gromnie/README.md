# Asheron's Call (gromnie)

Dissecteur Wireshark Lua du protocole réseau d'Asheron's Call sur UDP, fourni
avec le client sans interface gromnie : en-tête de paquet, indicateurs,
champs optionnels et fragments, avec résumé des types de messages et
d'actions dans la colonne Info (issue #307).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/amoeba/gromnie |
| Commit importé | `956881a58c027f790d0ffa2a649901e4a690214e` du 30/10/2026 (dernier commit de `main`) ; dernier changement de `etc/ac_proto.lua` : `dd2ea2bfd120938c2fbab99c333c9a1e5df9a012` du 23/07/2026 |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2025 Bryce Mecum ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Asheron's Call natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`). Autres implémentations du même protocole : #295
(ccressent/wireshark-asheronscall, sans licence) et #301
(`dissectors/asheronscall-ac-dissector`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ac_proto.lua` | Protocole `ac` sur UDP 9000 à 9051 : séquence, 22 indicateurs, somme de contrôle, identifiant, taille, champs optionnels (renvoi, rejet, ACK, synchronisation, écho, flux), fragments (séquence, compte, index, groupe, type) ; type d'action affiché pour les messages `0xF7B0` / `0xF7B1` |

Seul ce fichier est importé : le reste du dépôt (client Rust gromnie) est hors
périmètre. Il est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/ac_proto.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `ac`.

## Limites constatées à l'import

- même nom de protocole `ac` (et donc même préfixe de champs `ac.`) que
  `dissectors/asheronscall-ac-dissector` : les deux greffons ne peuvent pas
  être chargés ensemble ;
- plage de ports 9000 à 9051 codée en dur ;
- le contenu des messages n'est pas décodé (octets bruts), les fragments ne
  sont pas réassemblés et la somme de contrôle n'est pas vérifiée ;
- fonction globale `add_packet_flags` ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
