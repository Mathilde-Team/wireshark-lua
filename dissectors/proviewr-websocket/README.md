# ProviewR WebSocket (PwrWebSocket)

Dissecteurs Wireshark Lua du protocole binaire que le système de
supervision et de contrôle-commande open source **ProviewR** fait passer
dans une WebSocket (port 4448) entre le serveur d'exécution et les clients
web (opérateur, Xtt web) : lecture et écriture d'attributs d'objets,
abonnements, authentification, alarmes et événements (« MH »), menus de la
fenêtre opérateur (issue #80). Deux variantes, selon la version de ProviewR.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/proviewr/WiresharkPlugins |
| Commit importé | `6acd820d1f7f60b9f62b551c8604a875a62a59e1` du 12/08/2020 (dernier commit de la branche par défaut `master`) ; dernière modification de `PwrWebSocket5_6.lua` : commit `f6fb4466e97ecd357fc5dada518ac70d0d7bd677` du 10/08/2020 |
| Licence amont | GPL-3.0 (`LICENSE` amont, sans mention « or later » dans le dépôt, d'où `GPL-3.0-only`) — compatible avec la licence du dépôt |
| Natif Wireshark 4.6.4 | Non — Wireshark décode la WebSocket mais pas son contenu ProviewR (`tshark -G protocols`) |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont). Les scripts sont repris tels quels (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le `README.md` amont se limite à une
ligne ; aucune capture n'est fournie en amont.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/PwrWebSocket5_7.lua` | ProviewR 5.7 et suivantes : tout en gros-boutiste, en-tête identique dans les deux sens (code d'opération sur 1 octet, identifiant de message et statut sur 4 octets), longueurs de chaînes sur 4 octets |
| `src/PwrWebSocket5_6.lua` | ProviewR 5.6 et antérieures : requêtes en petit-boutiste (code d'opération, octet inutilisé, identifiant de message), réponses avec identifiant et statut gros-boutistes, longueurs de chaînes sur 2 octets |

Protocole `pwr` (« Proview WebSocket Protocol »), sous-arbres `pwr.header`,
`pwr.getobjectinfo`, `pwr.setobjectinfo`, `pwr.refobjectinfo`,
`pwr.checkuser`, `pwr.mhsync`, `pwr.getopwindmenu`, etc. 23 codes
d'opération nommés (`setObjectInfoBool` 1 … `getObjectFromARef` 68). Une
réponse n'est détaillée que si le statut est impair (succès ProviewR).

## Utilisation

Copier **un seul** des deux fichiers (selon la version de ProviewR) dans le
dossier des plugins Lua personnels de Wireshark (« Aide › À propos de
Wireshark › Dossiers »), puis Ctrl+Maj+L : les deux déclarent le même
protocole et ne peuvent pas être chargés ensemble (« there cannot be two
protocols with the same description »).

Le dissecteur s'inscrit dans la table `ws.port` sur le port 4448 : il faut
que la poignée de main HTTP `Upgrade: websocket` figure dans la capture
(reconnue sans réglage par tshark 4.6.4). Les requêtes sont repérées par
le port source ≠ 4448. Filtres : `pwr`, `pwr.opcode`, `pwr.messageID`,
`pwr.sts`, `pwr.getobjectinfo.attrname`, `pwr.checkuser.username`, etc.

## Vérification à l'import

Avec tshark 4.6.4, les deux fichiers se chargent sans erreur (`luac5.4 -p` :
OK). Captures synthétiques (poignée de main WebSocket sur TCP 4448, trames
binaires masquées côté client), construites d'après la disposition décrite
par les scripts :

| Trame (5.7) | Résultat |
|---|---|
| `getObjectInfoFloat` (6), attribut `H1-Temp.ActualValue` → réponse statut 1 | nom d'attribut ; réponse `pwr.getobjectinfo.floatdata` 21.5 |
| `checkUser` (29) `op` / `secret` → réponse statut 1 | nom d'utilisateur et **mot de passe en clair** ; privilège 7 |
| `refObjectInfo` (10) | identifiant d'abonnement 5, nom de l'attribut |
| Réponse 6 avec statut 2 (pair, erreur) | en-tête seul, charge non détaillée |
| `getMsg` (50) | requête : `pwr.getmsg.msgid` 123 ; **réponse : erreur Lua** (voir Limites) |
| code 99 inconnu | Info `99`, charge brute dans `pwr.data` |

| Trame (5.6) | Résultat |
|---|---|
| `getObjectInfoFloat` (6) en petit-boutiste → réponse | nom d'attribut ; 21.5 |
| `checkUser` (29) → réponse | utilisateur, mot de passe ; privilège 7 |

## Limites constatées

- Réponse `getMsg` (50) avec texte : « first argument to TreeItem:add is
  nil » — le script utilise `gom.msgText` (champ inexistant) au lieu de
  `gmt.msgText` ; la trame retombe en WebSocket.
- Port 4448 codé en dur ; nécessite la poignée de main dans la capture ;
  sens requête/réponse déduit du port uniquement.
- Une trame WebSocket = un message ; pas de gestion des messages
  fragmentés.
- Plusieurs champs déclarés `uint16` sont alimentés par 4 octets (longueurs
  en 5.7) et deux champs partagent l'abréviation
  `pwr.getopwindmenu.disableproview` ; le sous-arbre « Protocol Header »
  couvre 6 octets alors que l'en-tête 5.7 en fait 9.
- `getObjectRefInfoAll` est marqué « TODO » en amont.
- Variable globale `subtree` et fonctions de décodage globales
  (`checkUserReq`, `getObjectRes`…) : risque de collision avec d'autres
  scripts Lua.
- Disposition non vérifiée contre le code de ProviewR ni sur une capture
  réelle.
