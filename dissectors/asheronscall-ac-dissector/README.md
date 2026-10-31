# Asheron's Call (ac-dissector)

Dissecteur Wireshark Lua du protocole réseau d'Asheron's Call sur UDP :
en-tête de paquet (séquence, indicateurs, CRC), champs optionnels,
fragments et une partie des messages de jeu, chargés depuis des fichiers
séparés (issue #301).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/AverageJamz/ac-dissector |
| Commit importé | `b6fe2bcb75cec080ef1b4273e4fec05ac7a131fd` du 16/03/2017 (dernier commit de `master`) |
| Licence amont | MIT (`LICENSE` amont, « Copyright (c) 2017 AverageJamz ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Asheron's Call natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`). Autres implémentations du même protocole : #295
(ccressent/wireshark-asheronscall, sans licence) et #307 (amoeba/gromnie).

## Fichiers

Arborescence amont reprise telle quelle dans `src/` (`LICENSE` déplacé en
`LICENSE.txt`) ; en-tête de provenance ajouté à chaque `.lua`.

| Fichier | Rôle |
|---|---|
| `src/asheronscall.lua` | Protocole `ac` sur UDP 9000 à 9009 : en-tête, indicateurs, champs optionnels (acquittement, synchronisation, écho, flux), fragments ; charge `util.lua` et tous les fichiers de `messages/` |
| `src/util.lua` | Calcul du bourrage (`calc_pad`) |
| `src/messages/msg*.lua` | Décodage de 16 messages (liste de personnages, connexion, infos serveur, sons et effets, saut, objets, actions et événements de jeu…) |
| `src/GameEvents/` | Événements de jeu (`evtMessageBox.lua`), chargés par `msgGameEvent.lua` |
| `src/GameActions/` | Dossier prévu pour les actions de jeu (README seul) |
| `src/README.md` | Mode d'emploi de l'auteur |

## Utilisation

Le code charge ses fichiers depuis `persconffile_path("ac-dissector")` :
copier le contenu de `src/` dans `ac-dissector/` du dossier de configuration
personnel de Wireshark (ex. `~/.config/wireshark/ac-dissector/`, ou
`%APPDATA%\Wireshark\ac-dissector\`), hors du dossier `plugins`. Puis faire
exécuter `asheronscall.lua`, par exemple avec un fichier
`plugins/ac-loader.lua` contenant
`dofile(persconffile_path("ac-dissector") .. "/asheronscall.lua")` (l'auteur
utilise l'`init.lua` personnel). Filtre : `ac`.

## Limites constatées à l'import

- `bit32.btest` (28 appels) : `bit32` n'existe pas dans la Lua 5.4 des
  Wireshark récents et la bibliothèque `bit` de Wireshark n'a pas de `btest`.
  Contournement : définir avant le chargement
  `bit32 = { btest = function(a, b) return (a & b) ~= 0 end }` ;
- `messages/msgGameEvent.lua` ajoute le champ `fields.MsgGameEventEvent`, qui
  n'est pas défini (le champ déclaré s'appelle `MsgGameEventEventID`) : erreur
  Lua sur chaque message d'événement de jeu (`0xF7B0`) ; l'événement
  `evtLoginCharacter` référencé n'existe pas ;
- ports 9000 à 9009 codés en dur ;
- nom de protocole court `ac` et nombreuses variables globales (`fields`,
  `process_flags`, `msg*`, `calc_pad`…) : conflit possible avec un autre
  dissecteur Asheron's Call chargé en même temps ;
- seuls 16 types de messages sont décodés ;
- pas de capture d'exemple amont : syntaxe de chaque `.lua` vérifiée avec
  `luac5.4 -p`, pas de dissection testée sur trafic réel.
