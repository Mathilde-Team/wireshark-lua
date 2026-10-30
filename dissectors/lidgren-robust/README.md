# Lidgren.Network v3 (Robust Toolbox / Space Station 14)

Dissecteur Wireshark Lua du protocole Lidgren.Network v3 tel qu'utilisé par le
moteur Robust Toolbox (Space Station 14 et ses dérivés), sur UDP 1212 :
découpage des messages Lidgren regroupés dans un datagramme, type, séquence,
taille utile, fragmentation (issue #341).

## Import

| | |
|---|---|
| Dépôt cité par l'issue | https://github.com/makura-games/half-life-14 (`RobustToolbox/Lidgren.Network/Lidgren.Network/Tools/wireshark_lidgren.lua`, commit `f0a2b7c6b9116350b66c022a837f48a4a447230b` du 22/09/2025) |
| Dépôt amont importé | https://github.com/space-wizards/SpaceWizards.Lidgren.Network (`Tools/wireshark_lidgren.lua`) |
| Commit importé | `f7ecb5aa384013d920f7925340cc4608ed156e83` du 23/07/2026 (dernier commit de `wizards`) ; dernier changement du fichier : `4b65a0da7a5c1826e6b043fd38529bec66fcfd96` du 28/06/2026 |
| Licence amont | MIT (fichier `LICENSE` de Lidgren.Network, « Copyright (c) 2015 lidgren ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Lidgren natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

Choix de la source : half-life-14 embarque une copie de la bibliothèque
SpaceWizards.Lidgren.Network, dont le dossier porte la licence MIT de Lidgren,
alors que la racine de ce dépôt est sous une licence propriétaire (SUNRISE,
usage personnel et non commercial). Le fichier est donc importé depuis le
dépôt d'origine de la bibliothèque, sous MIT sans ambiguïté ; les deux versions
ne diffèrent que par des espaces en fin de ligne.

Autres implémentations Lidgren : `dissectors/luna-multiplayer`
(`decoder_Lidgren.lua`, #325) ; dwyer95/lidgren_dissector est suivi par #365.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark_lidgren.lua` | Protocole `lidgren` sur UDP 1212 (port par défaut de Robust) : pour chaque message du datagramme, type (table des types Lidgren : non connecté, utilisateur non fiable, séquencé, fiable, ordonné, messages de bibliothèque…), indicateur de fragmentation, numéro de séquence, longueur utile en bits, en-tête de fragment (groupe, taille totale, taille et numéro de morceau, entiers variables) et charge utile ; liste des types en colonne Info |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/wireshark_lidgren.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`), puis Analyse > Recharger les plugins Lua.
Pour un autre jeu Lidgren, changer le port à la fin du fichier ou utiliser
« Décoder comme… ». Filtre : `lidgren`.

## Limites constatées à l'import

- port 1212 codé en dur (Lidgren n'a pas de port fixe) ;
- les fragments ne sont pas réassemblés et la charge utile n'est pas décodée
  (elle dépend du jeu) ;
- pas de contrôle de longueur : un datagramme tronqué provoque une erreur
  Lua ; variables et fonctions globales (`lidgren_proto`,
  `lidgren_message_types`, `udp_table`…) ;
- enregistre le protocole `lidgren` : incompatible avec un autre dissecteur
  Lua utilisant le même nom ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
