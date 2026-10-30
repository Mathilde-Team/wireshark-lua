# PangYa

Dissecteur Wireshark Lua du protocole réseau du jeu de golf en ligne PangYa
(serveurs de connexion, de jeu et de messagerie officiels) : détection de la
clé de session dans le message de bienvenue, déchiffrement des paquets client
et serveur, identifiant de message (issue #345).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pangbox/wireshark-dissector |
| Commit importé | `88a3aa0a140200f52baaee22411669994cce6464` du 14/06/2023 (dernier commit de `master`) |
| Licence amont | ISC (fichier `LICENSE.md`, « Copyright © 2023, John Chadwick ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur PangYa natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE.md` amont). La licence ISC est conservée (en-tête SPDX `ISC`),
compatible avec la GPL-3.0-or-later du dépôt.

Selon le README amont, le projet n'est ni approuvé par ni lié à Ntreev Soft
Co., Ltd. ; « PangYa » est une marque de cette société, citée uniquement pour
identifier le protocole.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/pangya.lua` | Protocole `pangya` sur les ports TCP connus (connexion 10101, 10201, 10103 ; jeu 20201-20203 ; messagerie 10102, 30303) et trois ports supplémentaires réglables : clé de session par flux TCP (`tcp.stream`), sel, longueur, réassemblage, déchiffrement client et serveur (tables de chiffrement, décompression LZO en Lua), identifiant de message et données déchiffrées dans un onglet « Decrypted Data », préfixe `[LS/GS/MS C/S id]` en colonne Info ; préférences : activation, niveau de débogage, ports |

Le fichier est repris tel quel, en-tête de provenance ajouté. Non importés :
README, `prefs.png` (capture d'écran des préférences) et `.vscode/`.

## Utilisation

Copier `src/pangya.lua` dans le dossier « Personal Lua Plugins » ou « Global
Lua Plugins » de Wireshark (Aide > À propos de Wireshark > Dossiers).
Préférences : Édition > Préférences > Protocols > PangYa. Filtre : `pangya`.

## Limites constatées à l'import

- qualité « alpha » selon l'auteur, peu testé ; seuls les clients et serveurs
  officiels sont visés, pas les serveurs non officiels ;
- le contenu des messages n'est pas décodé champ par champ : identifiant et
  données déchiffrées brutes seulement ;
- le flux doit être capturé depuis le message de bienvenue (clé de session) ;
  sans lui, les paquets ne sont pas déchiffrés ;
- l'aperçu « type » du suffixe des paquets serveur lit l'identifiant en
  gros-boutiste alors que le champ et la colonne Info le lisent en
  petit-boutiste ;
- un changement de ports dans les préférences appelle `reload()`, fonction de
  l'interface graphique (indisponible dans `tshark`) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
