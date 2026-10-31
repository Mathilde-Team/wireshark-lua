# Dofus 2 (D2Parsers)

Dissecteur Wireshark Lua du protocole réseau du MMO Dofus 2 sur TCP :
en-tête des messages (identifiant sur 14 bits, taille de la longueur,
numéro d'instance côté client), réassemblage TCP et décodage détaillé d'une
partie des messages (connexion, liste des serveurs, personnages, discussion,
carte, échanges) (issue #312).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/lk740/D2Parsers |
| Commit importé | `ea7f1b6860082a15ce2212564b239feedf00d58b` du 13/08/2024 (dernier commit de `main`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Dofus natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`). Autre dissecteur Dofus proposé : #318
(SnaKerMose/dofus-dissector).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/dofus.lua` | Protocole `dofus` sur TCP 5555 : table d'environ 1 200 noms de messages, entiers variables (VarInt, VarShort, VarLong), réassemblage TCP (`desegment_offset` / `desegment_len`), 37 fonctions de décodage détaillé de messages |

Seul le dissecteur Wireshark est importé, tel quel (fins de ligne CRLF
d'origine conservées), en-tête de provenance ajouté. Le dissecteur Scapy
(`dofus.py`, `protocol_scapy.json`) et les captures d'écran du README amont
sont hors périmètre.

## Utilisation

Copier `src/dofus.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/` ; l'auteur indique le dossier `plugins/4.X/epan`
de l'installation). Filtre : `dofus`.

## Limites constatées à l'import

- les identifiants de messages de Dofus changent d'une version du client à
  l'autre : la table figée en 2024 peut ne plus correspondre au jeu actuel ;
- incomplet selon l'auteur : la plupart des messages ne sont que nommés ;
- port 5555 codé en dur (les préférences `default_settings` ne sont pas
  exposées dans Wireshark) ;
- les messages de connexion affichent en clair la clé (`dofus.key`) et le
  ticket d'authentification (`dofus.ticket`) : attention en partageant des
  captures ;
- nombreuses variables et fonctions globales (`DOFUS_MESSAGE_TYPES`,
  `dofus_proto`, `readVarInt`, une fonction par message…) ;
- utilise `bit.band` / `bit.lshift`, fournis par Wireshark (pas par Lua
  standard) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
