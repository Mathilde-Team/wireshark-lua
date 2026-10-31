# SuiteLink

Dissecteur Wireshark Lua partiel du protocole **SuiteLink** (Wonderware,
aujourd'hui AVEVA). Ce protocole propriétaire relie les applications SCADA
InTouch et les serveurs d'E/S sur TCP 5413 (issue #74).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/finngineering/suitelink-dissector |
| Commit importé | `3637f062bf5deca9d16c161e509880769815981b` du 08/12/2024 (dernier commit de `master`) |
| Licence amont | MIT (`LICENSE` amont, © 2024 finngineering) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SuiteLink natif (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/suitelink.lua` | Protocole `Suitelink` (TCP 5413). Il couvre les deux familles de messages décrites par l'amont : l'échange de données (longueur sur 2 octets, type sur 2 octets, fin `0xa5`) et AlarmMgr (alarmes et événements, longueur variable sur 1, 3 ou 7 octets, message initial implicite de 48 octets) |

Le script est repris tel quel (fins de ligne CRLF de l'amont conservées), avec
l'en-tête de provenance ajouté. Le moniteur d'alarmes Python `almmon.py` et
la capture d'écran de l'amont ne sont pas importés.

## Utilisation

Copier `src/suitelink.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `suitelink`.

## Limites constatées à l'import

- l'amont prévient que le décodage est partiel : il vient de la rétro-ingénierie
  et l'auteur ne le maintient plus ;
- le port TCP 5413 est codé en dur. Les échanges qui continuent sur d'autres
  ports ne sont pas reconnus ;
- en cas d'incohérence, le script écrit sur la console Lua avec `print`
  (« ERROR: handle_message() returned 0 ») ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur du trafic réel.
