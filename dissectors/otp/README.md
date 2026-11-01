# OTP (Tale-Studios)

Dissecteur Wireshark Lua pour le protocole **OTP** de la suite serveur
OTP-Server (Tale-Studios, issu d'Astron) : objets distribués, champs, zones
et mises à jour — longueur de message, canaux destinataire/émetteur, type de
message, IDs d'objets et de zones.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Tale-Studios/OTP-Server |
| Commit importé | `61ce5ff17ede64b1fdabf89bc4d7f103aebed0a7` du 18/04/2021 (branche `master`) |
| Licence amont | BSD-3-Clause (`LICENSE.md` amont, « Copyright (c) 2014, the Astron Authors ») |
| Natif Wireshark 4.6.4 | Non — aucun dissector OTP natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.md` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `otp.lua` | Dissecteur OTP (objets distribués, champs, zones) |

## Utilisation

Copier `otp.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua.
Le script requiert la bibliothèque `bit` (Lua BitOp, incluse dans LuaJIT et
dans les builds Wireshark modernes).

## Remarques

Dépôt amont figé depuis avril 2021. Le dissecteur ne déclare pas de port :
à associer manuellement (Decode As) au transport concerné.
