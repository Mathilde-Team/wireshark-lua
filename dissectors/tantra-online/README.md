# Tantra Online

Dissecteur Wireshark Lua du protocole du serveur de jeu de Tantra Online
(MMO) sur TCP : identification du type de paquet (opcode sur 2 octets) échangé
entre le client et le serveur (issue #300).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/cyberinferno/tantra-online-wireshark-dissector |
| Commit importé | `e6bd04d22f672cc37eddcaf5a96318d859a5f392` du 02/12/2017 (dernier commit de `master`) |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2017 Karthik Panjaje ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Tantra Online natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/tantra-dissector.lua` | Protocole `tantra` sur TCP 1000 et 3001 à 3006 : saut du code d'initialisation client `0x1F44F321`, puis opcode petit-boutiste nommé d'après une table d'environ 330 types (requêtes `0x1xxx`–`0x4xxx`, réponses `0x9xxx`–`0xAxxx`), sinon champ « Unknown Packet Type » |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/tantra-dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`) ; adapter si besoin les ports à la fin du
fichier. Filtre : `tantra`.

## Limites constatées à l'import

- seul l'opcode est décodé : le contenu des paquets n'est pas analysé ;
- un seul paquet par segment TCP, sans réassemblage ;
- ports codés en dur (1000, 3001 à 3006) ;
- le champ `tantra.unknown` est déclaré sur 1 octet (`uint8`) mais alimenté
  avec les 2 octets de l'opcode ;
- segments de moins de 6 octets ignorés (arbre vide) ;
- variables globales `tantra` et `tcp_table` ;
- d'après le README amont, la table d'opcodes a été établie en s'appuyant sur
  un code source Kathana 3 divulgué ; seuls les noms et valeurs d'opcodes
  figurent dans le fichier ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
