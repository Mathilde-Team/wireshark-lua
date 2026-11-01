# Minecraft Forge (Java Edition 1.12.2) — LaysDragon

Dissecteur Wireshark en Lua du protocole réseau de Minecraft Java Edition
1.12.2 (protocole 340), avec les canaux de plugins Forge (`REGISTER`,
`FML|HS`), issue #354.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/LaysDragon/wireshark-lua-minecraft-dissector |
| Commit importé | `e56022715ab2adedecf2b65de9eb26c739d8a67c` du 01/08/2021 |
| Licence amont | MIT (`LICENSE` amont) — compatible avec la licence du dépôt |
| Natif Wireshark 4.6.4 | non (aucun dissecteur natif équivalent via `tshark -G protocols`) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: MIT` avec la provenance est ajoutée (convention du
dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/minecraft-forge.lua` | Dissecteur `MCForge` sur le port TCP 25565 : longueur et identifiant (VarInt), compression zlib, états Handshaking/Status/Login/Play, canaux de plugins Forge |

L'image `assets/wireshark.jpg` du dépôt amont (capture d'écran) n'est pas
importée.

## Utilisation

Le fichier amont commence par un bloc de test pour
[wirebait](https://github.com/MarkoPaul0/WireBait) exécuté quand les
variables globales `disable_lua` et `enable_lua` sont toutes deux absentes —
ce qui est le cas avec Wireshark 4.x (elles venaient de l'ancien `init.lua`).
Sans précaution, le chargement échoue (« module 'wirebaitlib' not found »).

Contournement sans modifier le fichier importé : créer dans le dossier des
plugins Lua personnels un fichier chargé avant lui (ordre alphabétique), par
exemple `00-enable-lua.lua`, contenant la seule ligne :

```lua
enable_lua = true
```

puis copier `src/minecraft-forge.lua` dans le même dossier (ex.
`~/.local/lib/wireshark/plugins/`).

## Vérification à l'import

Avec tshark 4.6.4, contournement ci-dessus en place, sur une capture
synthétique (`text2pcap`, port 25565) : le Handshake (protocole 340, adresse,
port, état suivant `login`) et le Login Start (nom du joueur) sont décodés
quand chaque paquet Minecraft occupe son propre segment TCP.

## Limites constatées à l'import

- l'amont se déclare « work in progress and buggy » ;
- plusieurs paquets Minecraft dans un même segment TCP : le deuxième est mal
  découpé (longueur 0, identifiants « Unknown ») ;
- seuls quelques paquets sont décodés (Handshake, Login Start/Success, Set
  Compression, Plugin Message) ; le reste est affiché comme données brutes ;
- le dissecteur écrit des traces de débogage (`print`) sur la sortie standard
  de tshark ;
- version 1.12.2 uniquement ; pour d'autres versions, voir les implémentations
  citées dans l'issue (MC-Inspector, 500IQIdea…).
