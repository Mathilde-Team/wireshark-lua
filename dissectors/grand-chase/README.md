# Grand Chase

Dissecteur Wireshark en Lua du protocole réseau du jeu en ligne Grand Chase
sur TCP 9400, 9500 et 9501 : en-tête chiffré (taille, SPI, séquence, IV,
ICV), déchiffrement DES-CBC des paquets, en-tête de charge utile (opcode,
taille, compression zlib) et décodage de quelques messages (ACK, mise en
place du chiffrement, connexion, liste des serveurs…) (issue #370).

## Import

| | |
|---|---|
| Dépôt amont | https://codeberg.org/gcarlos/gc-wireshark-dissector |
| Commit importé | `b75e846d20aa7da7081432f283dc0f2ae1da5ee6` du 18/11/2025 (dernier commit de `main`) |
| Licence amont | GPLv3 (fichier `LICENSE`, aucune mention « or later » dans le code) |
| Dépendance | sous-module `lib/lua-lockbox` : https://github.com/gcarlos64/lua-lockbox (fork de somesocks/lua-lockbox), commit `26287732d3f3fc1f2d1c701f762d2391ecb0cba0` du 05/10/2025 épinglé par l'amont, licence MIT |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Grand Chase natif |

Texte complet des licences amont : `LICENSE.txt` de ce dossier (GPLv3, copie
conforme de l'amont) et `src/lib/lua-lockbox/LICENSE` (MIT, copie conforme
de lua-lockbox).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/main.lua` | Protocole `grandchase` sur TCP 9400/9500/9501 : découpage et réassemblage des paquets, champs chiffrés, table des clés DES par client et SPI (clé initiale fixe, puis clé reçue dans la mise en place du chiffrement), déchiffrement, décompression zlib, appel du décodeur de charge utile |
| `src/payload.lua` | Décodeurs de charge utile par opcode : `UNKNOWN`, `ACK`, `CRYPT_SETUP`, `LOGIN`, `LOGIN_RESPONSE`, `SERVER_LIST`, `CRYPT_SETUP_VALIDATION` |
| `src/utf16.lua` | Conversion UTF-16LE → UTF-8 des chaînes |
| `src/lib/lua-lockbox/` | Bibliothèque cryptographique en Lua pur (DES, CBC, PKCS7, utilitaires) ; le fork ajoute à `lockbox/util/bit.lua` un repli sur les opérateurs binaires natifs de Lua 5.3+ |

Fichiers repris tels quels, en-tête de provenance ajouté. De lua-lockbox,
seuls `lockbox.lua`, le dossier `lockbox/` et `LICENSE` sont repris (tests,
mesures de performance, scripts et rockspecs exclus). Non importés de l'amont
Grand Chase : `.gitignore`, `.gitmodules`, `README.md`.

## Utilisation

1. Copier le contenu de `src/` dans un dossier hors du dossier des plugins
   Wireshark (sinon Wireshark exécute chaque module comme un plugin).
2. Dans `main.lua`, remplacer la valeur de `project_path` (chemin absolu
   figé par l'amont, `/home/mim/projects/gc/wireshark-dissector`) par ce
   dossier : le code ajoute `project_path/?.lua` et
   `project_path/lib/lua-lockbox/?.lua` à `package.path`.
3. Charger `main.lua` comme plugin (copie ou lien dans le dossier des
   plugins Lua), puis redémarrer Wireshark. Filtre : `grandchase`.

## Limites constatées à l'import

- chemin d'installation codé en dur (`project_path`) : modification
  obligatoire avant usage ;
- déchiffrement dépendant de l'état : la clé de session n'est connue que si la
  capture contient l'échange de mise en place du chiffrement (SPI 0) du
  client ; à défaut, seuls les champs chiffrés sont affichés ;
- plusieurs paquets par segment traités par appels récursifs sur de nouveaux
  tampons : `desegment_len` y est positionné sur un tampon dérivé, sans effet
  sur le réassemblage TCP ;
- noms de champs en `gc.*` alors que le protocole s'appelle `grandchase` ;
  nombreuses variables globales (`gc_protocol`, `key_table`, `server_addr`,
  champs…) ;
- DES en Lua pur : déchiffrement lent sur de grosses captures ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
