# icable (OpenComputers)

Dissecteur Wireshark Lua du protocole « icable », tunnel TCP entre la
bibliothèque `icable` d'ordinateurs OpenComputers (mod Minecraft) et le serveur
Python `icableServer.py`, qui transporte des paquets IPv4
([AR2000AR/openComputers_codes](https://github.com/AR2000AR/openComputers_codes),
issue #290).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/AR2000AR/openComputers_codes |
| Commit importé | `43e58d72a8f08097dbdc14f05f61a278b213c053` du 22/03/2025 (dernier commit de `master`) ; dernier changement de `icable_server/wiresharkDissector.lua` : `3376ffc05cf78efd672ed8791f65b344d1345fd6` du 11/07/2023 |
| Licence amont | MPL-2.0 (`LICENCE` amont ; aucun avis « Incompatible With Secondary Licenses » dans le dépôt ni dans le fichier) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur icable natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENCE`). La MPL-2.0 s'applique fichier par fichier et autorise
la distribution dans une œuvre plus large sous GPL (section 3.3) : les deux
fichiers importés restent sous MPL-2.0.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/icable.lua` | Protocole `icable` sur TCP 4222 : en-tête (magie `ICAB`, type, longueur), authentification (nom d'utilisateur, mot de passe, sels), configuration réseau IPv4 (manuelle ou automatique), erreurs, déconnexion ; paquets `CLIENT_DATA` / `SERVER_DATA` passés au dissecteur `ip` de Wireshark |
| `protocol.txt` | Description du protocole par l'auteur (format de l'en-tête et des messages) |

Seuls ces deux fichiers de `icable_server/` sont importés ; le serveur Python
et les programmes OpenComputers sont hors périmètre. Ils sont repris tels
quels, en-tête de provenance ajouté au `.lua`.

## Utilisation

Copier `src/icable.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `icable`. Préférence « Dissect
server data payload » (désactivée par défaut) pour décoder aussi les paquets IP
envoyés par le serveur.

## Limites constatées à l'import

- un seul message par segment TCP, sans réassemblage ; segment qui ne commence
  pas par `ICAB` ignoré ;
- le champ `icable.client_auth.password` affiche le contenu transmis par le
  client tel quel ;
- port 4222 codé en dur ; tables globales (`CLIENT_NETCONF_KIND_NAME`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
