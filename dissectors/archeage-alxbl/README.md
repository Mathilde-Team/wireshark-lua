# ArcheAge (alxbl)

Dissecteur Wireshark Lua du protocole réseau du jeu ArcheAge sur TCP :
découpage des PDU (longueur petit-boutiste, indicateur de réponse serveur,
type de message, octet de bourrage), avec un sous-dissecteur pour les messages
de discussion (issue #308).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/alxbl/archeage |
| Commit importé | `9d35c71fde257c608ab45f183d72913764bbea50` du 26/06/2014 (dernier commit de `master`) |
| Licence amont | GPL-3.0-or-later (en-tête de `dissect/aa.lua`, « Copyright (c) 2014 Alexandre Beaulieu », « either version 3 of the License, or (at your option) any later version ») ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur ArcheAge natif |

Texte de la licence : fichier `LICENSE.txt` de ce dossier. L'amont ne fournit
pas de fichier de licence : c'est le texte de la GPLv3 (copie du `LICENSE` à
la racine de ce dépôt), celle que l'en-tête du fichier déclare.

Autre dissecteur ArcheAge du dépôt : `dissectors/archeage` (Ingramz/archeage,
#271), indépendant de celui-ci (protocole `archeage`, champs distincts).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/aa.lua` | Protocole `aa` sur TCP 1239 : boucle sur les PDU d'un segment avec réassemblage TCP (`desegment_len`), champs longueur, réponse serveur, type (Ping, Pong, Chat), bourrage et charge utile ; protocole `aa.chat` (pseudonyme et texte du message) |

Le fichier est repris tel quel (fins de ligne CRLF d'origine conservées),
en-tête de provenance ajouté. Les deux README amont (une ligne chacun) ne sont
pas importés.

## Utilisation

Copier `src/aa.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`) ; l'auteur indique aussi
`dofile("<chemin>/aa.lua")` dans `init.lua`. Filtre : `aa`.

## Limites constatées à l'import

- travail préliminaire selon l'auteur (« very early work in progress ») :
  seuls trois types de messages sont nommés et le bourrage comme l'indicateur
  de réponse sont des hypothèses ;
- le message de discussion (`0xCC01`) appelle `d:call(...)` sur une fonction
  Lua (`aa_chat.dissector`) et non sur un objet `Dissector` : erreur Lua au
  lieu du décodage du message ;
- trafic chiffré non pris en charge (port 1250 commenté par l'auteur) ;
- port 1239 codé en dur ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
