# Clash Royale (match)

Dissecteur Wireshark Lua du protocole UDP des parties de Clash Royale (jeu
mobile de Supercell), écrit par
[nfirvine/croy-shark](https://github.com/nfirvine/croy-shark) (issue #277).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nfirvine/croy-shark |
| Commit importé | `cf3cf4cc9940a9be863c9aa4d0cc3914dbecee83` du 28/03/2016 (dernier commit de la branche par défaut) |
| Licence amont | MIT (`LICENSE` amont, Copyright (c) 2016 Nick Irvine) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Clash Royale natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence MIT est conservée (en-tête SPDX `MIT`),
compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/croy_match.lua` | Protocole `croy_match` sur UDP 9339 : jeton de session (10 octets), commande (`op`/`ack`), sous-commande (`init`/`delta`), numéro de séquence ; pour `delta`, émetteur, sens et longueur ; reste affiché en octets bruts |

Le fichier amont `dissect.lua` est importé sous le nom `croy_match.lua` (nom
amont trop générique) ; son contenu est repris tel quel, en-tête de provenance
ajouté.

## Utilisation

Copier `src/croy_match.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic UDP 9339 est décodé
automatiquement.

## Limites constatées à l'import

- protocole de 2016, déduit de captures (plusieurs champs marqués TODO) : il a
  probablement changé depuis avec les mises à jour du jeu ;
- seul le trafic de partie (UDP) est couvert, pas la connexion au serveur
  principal ;
- le port 9339 est codé en dur (pas de préférence) ;
- variables globales `croy_match_proto` et `udp_table` : comportement amont
  conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
