# Network Gamepads

Dissecteur Wireshark Lua du protocole de
[network-gamepads](https://github.com/kitinfo/network-gamepads) (clavier, souris, manette ou autre périphérique d'entrée branché sur un poste
Linux, utilisé depuis un autre poste via le réseau) (issue #265).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/kitinfo/network-gamepads |
| Commit importé | `ccd044f78fb128c8eec3a64faf20a3b6c5937b10` du 21/11/2022 (dernier commit de la branche par défaut) ; dernier changement de `wireshark/` : `cab0a2642d0b6e383d5f26c6b4f0aa90ce7c5c5c` du 20/11/2022 |
| Licence amont | BSD-2-Clause (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur network-gamepads natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence BSD-2-Clause est conservée (en-tête SPDX
`BSD-2-Clause`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/network_gamepads.lua` | Protocole `ngamepads` sur TCP 9292 : messages `HELLO`, `PASSWORD`, `ABSINFO`, `DEVICE`, `SETUP_END`, `REQUEST_EVENT`, `DATA` et réponses du serveur (`SUCCESS`, `VERSION_MISMATCH`, `INVALID_PASSWORD`…) ; réassemblage TCP ; préférences « Dissector enabled » et « Debug » |

Le fichier amont `wireshark/dissectors.lua` est importé sous le nom
`network_gamepads.lua` (nom amont trop générique pour un dossier `plugins`
partagé) ; son contenu est repris tel quel, en-tête de provenance ajouté.
`wireshark/show_struct_size.c` (utilitaire C qui affiche la taille des
structures de `protocol.h`) n'est pas importé.

## Utilisation

Copier `src/network_gamepads.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic TCP 9292 (port par défaut) est
décodé automatiquement.

## Limites constatées à l'import

- le script écrit « Hello World » sur la console Lua au chargement (`print`
  amont), et le niveau de débogage par défaut est `LEVEL_1` ;
- le port 9292 est codé en dur (pas de préférence de port) ;
- les champs sont nommés `ng.*` alors que le protocole s'appelle `ngamepads` :
  filtrer avec `ngamepads` pour le protocole et `ng.<champ>` pour les champs ;
- le champ `ng.password` affiche en clair le mot de passe envoyé par le client :
  selon le README amont, le mot de passe et toutes les saisies circulent en
  clair sur le réseau ;
- variable globale `tvbs` : comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
