# Astron

Dissecteur Wireshark Lua pour le trafic du Message Director
d'[Astron](https://github.com/Astron/Astron) (suite serveur d'objets distribués
pour jeux MMO) : en-têtes de messages (longueur, canaux destinataires et
expéditeur, type) et décodage de quelques messages State Server, Client Agent et
DB Server (issue #255).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Astron/Astron |
| Commit importé | `9a8ebc1449dc15ae69c2f1ef3176b674e656a2a0` du 26/10/2026 ; dernier changement de `contrib/wireshark/` : `f56b191db47c5ce09cea2cd7316c427dc20cede2` du 22/09/2017 |
| Licence amont | BSD-3-Clause (`LICENSE.md` amont ; l'API GitHub l'affiche « NOASSERTION ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Astron natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE.md` amont). La licence BSD-3-Clause est conservée (en-tête
SPDX `BSD-3-Clause`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/astron.lua` | Protocole `astron` sur TCP 7199 (seul port enregistré par le script) : découpage des messages multiples par segment TCP, réassemblage, en-tête, et sous-dissecteurs pour `CLIENTAGENT_UNDECLARE_OBJECT`, `STATESERVER_OBJECT_SET_FIELD`, `STATESERVER_OBJECT_GET_ZONE(S)_OBJECTS`, `STATESERVER_OBJECT_GET_ZONE(S)_COUNT(_RESP)` et `DBSERVER_OBJECT_GET_FIELDS` |

Seul `contrib/wireshark/astron.lua` est importé ; le reste du dépôt amont
(serveur C++) est hors périmètre. Le fichier est repris tel quel, en-tête de
provenance ajouté.

## Utilisation

Copier `src/astron.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic sur TCP 7199 est décodé
automatiquement ; pour un autre port, utiliser « Décoder comme… » → `ASTRON`.

## Limites constatées à l'import

- les autres types de messages ne sont pas décodés (charge utile affichée en
  brut) ; les noms de classes et de champs ne sont pas lus depuis un fichier
  `.dc` : les fonctions d'aide renvoient `DistributedObject` et `FIELD_<n>` ;
- dans `STATESERVER_OBJECT_SET_FIELD`, le champ « Field ID » est surligné sur
  les octets 0-1 au lieu de 4-5 (valeur affichée correcte) : comportement amont
  conservé ;
- `require ("bit")` en tête de fichier : la bibliothèque est fournie par
  Wireshark (enregistrée via `luaL_requiref`), elle n'est pas utilisée ensuite ;
- variables et fonctions globales (`p_astron`, `dissect_one`, `pretty_msgtype`,
  `pretty_channel`…) : comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
