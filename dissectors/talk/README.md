# Talk / ntalk — protocole de contrôle talkd

Dissecteur Wireshark en Lua du protocole de contrôle des programmes BSD UNIX
`talk(1)`, `ntalk` et `ytalk` avec le serveur `talkd(8)`, sur UDP 518 :
version, type de requête (`LEAVE_INVITE`, `LOOK_UP`, `DELETE`, `ANNOUNCE`),
type de réponse, identifiant de message, adresses et ports, PID et noms de
l'appelant, de l'appelé et du terminal, avec résumé dans la colonne Info
(issue #396).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/fabacab/ntalk-dissector |
| Commit importé | `3571e0d24d8042d35efb987fdba23407967d3aa5` du 28/09/2018 (dernier commit de `master`) |
| Licence amont | GPL-3.0-or-later (balise `@license GPL-3.0-or-later` en tête de `talk.lua`) ; le dépôt ne contient pas de fichier de licence |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur talk/ntalk natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier. Faute
de fichier de licence dans l'amont, il s'agit du texte de référence de la GPL
version 3 (https://www.gnu.org/licenses/gpl-3.0.txt).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/talk.lua` | Protocole `talk` sur UDP 518 ; champs `talk.version`, `talk.request_type`, `talk.reply_type`, `talk.msg_id`, `talk.addr`, `talk.ctl_addr`, `talk.pid`, `talk.caller_name`, `talk.callee_name`, `talk.callee_tty_name`… |

Fichier repris tel quel, en-tête de provenance ajouté. Non importées : les
trois captures d'exemple de l'amont (`talk-*.pcap`), qui ne portent pas de
mention de licence.

## Utilisation

Copier `src/talk.lua` dans le dossier des plugins Lua de Wireshark, puis
« Analyse › Recharger les plugins Lua ». Filtre : `talk`.

## Limites constatées à l'import

- ne décode que le protocole de contrôle `talkd` (UDP 518, `ntalk`) : la
  conversation elle-même passe par une connexion TCP distincte, non décodée ;
  l'ancien port `talk` (UDP 517) n'est pas enregistré ;
- la colonne Info s'appuie sur des `Field.new` du protocole lui-même, lus dans
  le même passage de dissection ;
- pas de vérification de longueur avant la lecture des champs (erreur Lua sur
  un paquet tronqué) ;
- captures d'exemple amont non importées : syntaxe vérifiée avec
  `luac5.4 -p`, pas de dissection testée.
