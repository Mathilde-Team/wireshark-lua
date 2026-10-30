# Illarion

Dissecteur Wireshark Lua du protocole client-serveur
d'[Illarion](https://github.com/Illarion-eV/Illarion-Server) (jeu de rôle en
ligne massivement multijoueur) : en-tête des messages et noms des commandes
serveur et client (issue #267).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Illarion-eV/Illarion-Server |
| Commit importé | `7158dcffa8ff11d61828608512bfdb5b0828f06c` du 14/05/2026 (dernier commit de `master`) ; dernier changement de `tools/wireshark/` : `47b43be223ee16979089eae8d64537cf34ecdc46` du 18/06/2024 |
| Licence amont | AGPL-3.0-or-later (`COPYING` amont ; en-têtes des sources : « either version 3 of the License, or (at your option) any later version ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Illarion natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `COPYING` amont). Le script lui-même n'a pas d'en-tête de licence :
il relève de la licence du dépôt amont, AGPL-3.0-or-later, conservée telle
quelle (en-tête SPDX `AGPL-3.0-or-later`). Elle ne peut pas être re-licenciée
en GPL.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/illarion.lua` | Protocole `Illarion` sur TCP 3012 : sens serveur → client ou client → serveur selon le port source, en-tête (identifiant de commande, complément, longueur, CRC), 53 commandes serveur et 42 commandes client nommées ; seul `MOVEACK` (personnage, position, mode et vitesse de déplacement) est détaillé |

Seul `tools/wireshark/illarion.lua` est importé ; le reste du dépôt amont
(serveur C++) est hors périmètre. Le fichier est repris tel quel, en-tête de
provenance ajouté.

## Utilisation

Copier `src/illarion.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic TCP 3012 est décodé
automatiquement ; le sens est déduit du port source (3012 = serveur).

## Limites constatées à l'import

- un seul message décodé par segment TCP, sans réassemblage : les messages
  regroupés ou découpés par TCP sont mal découpés ;
- hormis `MOVEACK`, la charge utile des commandes n'est pas décodée ;
- le port 3012 est codé en dur (pas de préférence) ;
- variable globale `position_tree` dans `add_position` : comportement amont
  conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
