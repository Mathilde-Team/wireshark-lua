# Nintendo Switch LDN

Dissecteurs Wireshark en Lua de la communication sans fil locale (LDN) de la
Nintendo Switch (issue #371) :

- `ldn` : trames d'annonce Wi-Fi (action « vendor specific », OUI Nintendo) —
  en-tête, informations de session, participants, données applicatives
  (Mii, en-tête Pia, Mario Kart 8 Deluxe), avec déchiffrement AES des
  données d'annonce si les clés sont fournies ;
- `ldn_mitm` : protocole LAN du module ldn_mitm de spacemeowx2 (TCP et UDP
  11452) — en-tête, décompression, informations réseau et nœuds.

## Import

| | |
|---|---|
| Dépôt amont | https://codeberg.org/TSRBerry/ldn_utils (dossier `wireshark/`) |
| Commit importé | `1ee820b4f068e2ef85d2c227222b04996961b3dd` du 17/10/2022 (dernier commit de `master`) |
| Licence amont | GPLv2 (fichier `LICENSE`, aucune mention « or later » dans le code) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur LDN ni ldn_mitm natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ldn/ldn.lua` | Protocole `ldn` sur `wlan.action.vendor_specific` (OUI Nintendo) : identifiant de protocole, type de paquet, renvoi vers la table `ldn.packets` |
| `src/ldn/common/init.lua` | Table globale `GLOBALS`, création des tables de dissecteurs `ldn.appdata`, `ldn.appdata.common`, `ldn.packets` |
| `src/ldn/common/utils.lua` | Lecture des clés, dérivation et déchiffrement AES-128 (ECB, CTR), SHA-256 (via lua-lockbox) |
| `src/ldn/common/tables.lua` | Constantes et tables de valeurs |
| `src/ldn/dissectors/*.lua` | Trame d'annonce, données d'annonce, informations de session, participants |
| `src/ldn/appdata/mario_kart_8.lua` | Données applicatives de Mario Kart 8 Deluxe |
| `src/ldn/appdata/mii/*.lua` | Décodage des Mii (visage, cheveux, yeux…) |
| `src/ldn/appdata/pia/*.lua` | En-tête Pia |
| `src/ldn_mitm/ldn_mitm.lua` | Protocole `ldn_mitm` sur TCP/UDP 11452 (magie `0x11451400`) |
| `src/ldn_mitm/decompress.lua` | Décompression des données ldn_mitm |
| `src/ldn_mitm/types/*.lua` | Informations réseau, identifiants, nœuds |

Les 31 fichiers Lua du dossier amont `wireshark/` sont repris tels quels, en
conservant l'arborescence, en-tête de provenance ajouté. Non importés : le
dossier `python/` (outils hors Wireshark et sous-module kinnay/LDN),
`.gitignore`, `.gitmodules`, `README.md`.

## Utilisation

1. Copier les dossiers `src/ldn` et `src/ldn_mitm` dans le dossier des
   plugins Lua personnels de Wireshark : les modules sont chargés par
   `require("ldn.common.init")`, `require("ldn_mitm.decompress")`…, relatifs
   à ce dossier.
2. Installer la bibliothèque lua-lockbox (MIT, non fournie par l'amont), de
   sorte que `require("lockbox")` la trouve dans `package.path` ; une copie
   adaptée à Lua 5.3+ est disponible dans `dissectors/grand-chase/src/lib/lua-lockbox`.
3. Pour le déchiffrement des annonces, créer `~/.switch/wireshark-ldn.keys`
   (une clé hexadécimale par ligne : `MASTER_KEY`, `AES_KEY_GEN_SOURCE1`,
   `AES_KEY_GEN_SOURCE2`, `ADVERTISEMENT_KEY_SOURCE`) ; ces clés propres à la
   console ne sont pas fournies.
4. Capturer en mode moniteur Wi-Fi pour `ldn` ; filtres : `ldn`, `ldn_mitm`.

## Limites constatées à l'import

- seules les trames d'annonce LDN sont décodées (README amont, « WIP ») ;
- dépendance externe lua-lockbox non fournie : sans elle, le chargement de
  `ldn/common/utils.lua` échoue ;
- chemin des clés construit avec `os.getenv("HOME")` au chargement : si
  `HOME` n'est pas défini (cas courant sous Windows), erreur Lua au
  chargement ; sans fichier de clés, le déchiffrement échoue ;
- Wireshark charge aussi chaque module comme un plugin autonome ; l'amont
  s'en protège par la table globale `GLOBALS`, mais l'ordre de chargement
  n'a pas été vérifié ;
- nombreuses variables globales (`GLOBALS`, `DecompressData`,
  `MASTER_KEY`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
