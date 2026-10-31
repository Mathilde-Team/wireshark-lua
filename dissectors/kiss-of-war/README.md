# Kiss of War — discussion Jabber (Mr. Owl)

Dissecteur Wireshark Lua des données de discussion Jabber du jeu mobile Kiss
of War (Tap4Fun) sur TCP 30052 : extraction du contenu des messages, du tag
d'alliance, du rang de guilde, du nom et de l'identifiant du joueur et de
l'horodatage (issue #336).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/N0N0/KoW-Mr_Owl |
| Commit importé | `abdc122c231d428a4e1fdec05c9f20176bd3bf8a` du 05/02/2022 (dernier commit de `main`) ; script en version 0.97 du 04/04/2021 (jeu 1.39.0) |
| Licence amont | GPL-3.0-only (en-tête du fichier et README : « licensed under the GNU General Public License Version 3.0 », « Copyright (c) 2021 nono », sans mention « or later ») ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | Non — Wireshark a un dissecteur XMPP, mais pas pour ce format de discussion encodé |

Texte de la licence : fichier `LICENSE.txt` de ce dossier. L'amont ne fournit
pas de fichier de licence : c'est le texte canonique de la GPLv3 (copie du
`LICENSE` du dépôt), celle que l'en-tête du fichier déclare.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/Mr_Owl-KoW_Jabber_Dissector.lua` | Protocole `kow` sur TCP 30052 : champs `kow.message_length`, `kow.message_data`, `kow.chat_content`, `kow.chat_alliance_tag`, `kow.chat_guild_rank`, `kow.chat_player_name`, `kow.chat_player_id`, `kow.chat_timestamp`, extraits par recherche de chaînes dans les 1 356 premiers octets |

Le fichier est repris tel quel (fins de ligne CRLF d'origine conservées),
en-tête de provenance ajouté. Le README amont (copie de l'en-tête du fichier)
n'est pas importé.

## Utilisation

Copier `src/Mr_Owl-KoW_Jabber_Dissector.lua` dans le dossier `plugins` de
Wireshark (ex. `%APPDATA%\Wireshark\plugins`). Filtre conseillé par l'auteur :
`tcp.port == 30052 || (tcp contains "original_from" || tcp contains
"type='chat'")`, ou `kow`.

## Limites constatées à l'import

- lecture fixe de 1 356 octets (`CONST_BUFFER_LENGTH`) : les segments plus
  courts provoquent une erreur « Range is out of bounds » ;
- `kow.message_length` est un `int32` appliqué à ces 1 356 octets : Wireshark
  signale une erreur de longueur sur ce champ ;
- limites connues de l'auteur : messages privés sans nom de joueur, nom et
  identifiant parfois répartis sur plusieurs paquets, caractères Unicode des
  noms non pris en charge ;
- port 30052 codé en dur, pas de réassemblage TCP ; variables et fonctions
  globales (`length`, `register_proto_fields`, `kow_jabber_protocol`…) ;
- le dissecteur affiche des données personnelles des joueurs (pseudonymes,
  identifiants, messages) : réserver son usage à des captures légitimes ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
