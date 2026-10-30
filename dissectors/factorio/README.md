# Factorio

Dissecteur Wireshark Lua du protocole de jeu multijoueur de
[Factorio](https://www.factorio.com/) (« Factorio Game Protocol »), écrit par
[Hornwitser/factorio_dissector](https://github.com/Hornwitser/factorio_dissector)
(issue #270).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Hornwitser/factorio_dissector |
| Commit importé | `9e89be7a481d731792978c4d821a7aa5b8c752a2` du 12/09/2026 (dernier commit de `master`, protocole de Factorio 2.0.76 d'après le commit `b9f1387` du 17/03/2026) |
| Licence amont | GPL-2.0-or-later (en-tête SPDX du fichier, section « License » du README amont, `LICENSE.md` = texte de la GPL-2) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Factorio natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE.md` amont). La GPL-2.0-or-later est conservée (en-tête
SPDX `GPL-2.0-or-later`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/factorio.lua` | Protocole `Factorio` (champs `fgp.*`) sur UDP 34196 (diffusion LAN) et 34197 (jeu) : en-tête (type, drapeaux de fragmentation, identifiant de message), 19 types de messages réseau (`Ping`, `ConnectionRequest`…, battements de cœur client/serveur, `NatPunch`, `TransferBlock`, `LANBroadcast`, `GameInformationRequest`…), actions d'entrée et du synchroniseur ; informations expertes `fgp.*.expert` pour les paquets trop courts, malformés ou non décodés |

Seul `factorio.lua` est importé (la capture d'écran du README amont est hors
périmètre). Le fichier est repris tel quel, en-tête de provenance ajouté
au-dessus de l'en-tête SPDX amont.

## Utilisation

Copier `src/factorio.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic UDP 34196/34197 est décodé
automatiquement.

## Limites constatées à l'import

- seule la version récente de Factorio est prise en charge ; les versions
  antérieures du dissecteur sont dans les étiquettes git amont
  (`factorio-1.1.63`…) ;
- selon le README amont, la plupart du protocole n'est pas disséqué et de
  nombreux champs ne sont pas décodés ou le sont incorrectement ;
- les ports 34196 et 34197 sont codés en dur (`default_settings`, pas de
  préférence) ;
- variables globales (`bit32`, `dprint`, `input_actions`, `GameActionType`,
  `SynchronizerActionType`…) : comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
