# OpenTTD

Dissecteur Wireshark Lua du protocole réseau de jeu d'OpenTTD (client ↔
serveur, TCP 3979) : longueur et type de paquet, et décodage d'une partie des
messages (connexion, informations des clients, carte, trames,
synchronisation, configuration, commandes) (issue #328).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/erenes/wireshark-openttd-dissector |
| Commit importé | `4b5375a43d284eb5a100e913485d30bc2799aeaa` du 28/11/2021 (dernier commit de `main`) |
| Licence amont | GPL-2.0-only (fichier `LICENSE` amont, texte de la GPLv2 ; aucune mention « or later » dans le dépôt) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur OpenTTD natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/openttd.lua` | Protocole `ottd` sur TCP 3979 : longueur (16 bits petit-boutiste), type de message (énumération des paquets réseau d'OpenTTD), décodage de `CLIENT_JOIN`, `SERVER_WELCOME`, `SERVER_CLIENT_INFO`, `SERVER_MAP_BEGIN`, `SERVER_MAP_SIZE`, `SERVER_FRAME`, `CLIENT_ACK`, `SERVER_SYNC`, `SERVER_JOIN`, `SERVER_CONFIG_UPDATE`, `SERVER_COMPANY_UPDATE` et `SERVER_COMMAND` (drapeaux de commande, paramètres, case, texte) |

Le fichier est repris tel quel (fins de ligne CRLF d'origine conservées),
en-tête de provenance ajouté. Le README et le `.gitignore` amont ne sont pas
importés.

## Utilisation

Copier `src/openttd.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `ottd`.

## Limites constatées à l'import

- projet d'apprentissage selon l'auteur (« May or may not work on your
  machine ») ;
- un seul paquet OpenTTD par segment : si la longueur annoncée diffère de la
  taille du tampon, le segment est ignoré (pas de réassemblage TCP ni de
  découpage de plusieurs paquets) ;
- seuls une douzaine de types de messages sont décodés, les autres affichent
  uniquement longueur et type ;
- le niveau de débogage est fixé à 2 : `print(...)` pour chaque champ décodé,
  sortie console abondante ;
- port 3979 codé en dur (pas de préférence) ; le protocole UDP (découverte des
  serveurs) n'est pas traité ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
