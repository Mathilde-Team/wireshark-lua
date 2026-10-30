# Lineage 2

Dissecteurs Wireshark Lua des protocoles réseau de Lineage 2 sur TCP : serveur
de connexion (`lineage2login`, port 2106, versions 785a et c621) et serveur de
jeu (`lineage2game`, port 7777, versions 419, 660, 709, 746 et 851), avec
déchiffrement Blowfish / XOR et décodage des paquets décrits en fichiers INI
(issue #293).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/eldarkg/lineage2wireshark |
| Commit importé | `44762d9fa378b5f0b23d5346dfbd854fc5c5eb41` du 19/10/2025 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` et en-têtes « License: GPL3 », sans mention « or later » → `GPL-3.0-only`) ; `thirdparty/ini.lua` (lua-ini modifié, auteur uriid1) : « GNU GPLv3 » |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Lineage 2 natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

Arborescence amont reprise telle quelle dans `src/` (seul `.gitignore` est
omis, `LICENSE` est déplacé en `LICENSE.txt`) ; en-tête de provenance ajouté à
chaque fichier `.lua`.

| Fichier | Rôle |
|---|---|
| `src/lineage2login.lua` | Protocole `LINEAGE2LOGIN` (TCP 2106) : choix de version, clé Blowfish en préférence, déchiffrement et décodage |
| `src/lineage2game.lua` | Protocole `LINEAGE2GAME` (TCP 7777) : choix de version, clé XOR en préférence, déchiffrement et décodage |
| `src/common/` | Modules partagés : décodage des champs (`decode.lua`), opcodes, identifiants, champs et alertes Wireshark, utilitaires |
| `src/decrypt/` | Blowfish ECB (via `GcryptCipher` de Wireshark), XOR, désembrouillage du module RSA |
| `src/login/`, `src/game/` | Chargement des tables d'identifiants par protocole |
| `src/thirdparty/ini.lua` | Lecteur INI (lua-ini modifié) |
| `src/content/` | Descriptions des paquets par version (`packets/*.ini`) et tables d'identifiants en anglais et en russe (objets, PNJ, compétences, messages système…) |
| `src/doc/` | Notes amont (identifiants, format des paquets) et captures d'écran des préférences |
| `src/README.md`, `src/TODO.md` | Documentation et liste de tâches de l'auteur |

## Utilisation

Le code cherche ses fichiers dans
`Dir.personal_plugins_path() .. "/lineage2wireshark/"` : copier le contenu de
`src/` dans `~/.config/wireshark/plugins/lineage2wireshark/` (nom de dossier
obligatoire). Installer `lua-iconv` (`luarocks install lua-iconv`) pour la
Lua de Wireshark. Activer dans les préférences TCP le réassemblage par les
sous-dissecteurs, puis choisir la version et saisir la clé dans les
préférences des protocoles (voir `src/README.md`). Filtres : `lineage2login`,
`lineage2game`.

## Limites constatées à l'import

- dépendance externe `lua-iconv` (module C, non fourni par Wireshark) pour le
  décodage des chaînes UTF-16 ;
- `GcryptCipher` (Blowfish) n'existe que dans les versions récentes de
  Wireshark ; l'auteur indique Wireshark 4.6.0 comme dernière version testée ;
- `common/decode.lua` appelle `require("rsa")` alors que le module est
  `decrypt/rsa.lua` : l'action `unscramble` (paquet contenant le module RSA)
  échoue si `decrypt/` n'est pas dans `package.path` ;
- limites annoncées par l'auteur : choix manuel de la version, une seule
  connexion client-serveur déchiffrée à la fois, rechargement du fichier de
  capture nécessaire après « Reload Lua Plugins » ;
- clés de chiffrement à extraire du client par l'utilisateur (non fournies) ;
- volume : environ 6,6 Mo, surtout les tables d'identifiants de `content/` ;
- pas de capture d'exemple amont : syntaxe de chaque `.lua` vérifiée avec
  `luac5.4 -p`, pas de dissection testée sur trafic réel.
