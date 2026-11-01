# Rockwell CIP — extensions privées Rockwell Automation

Post-dissecteur Wireshark Lua des **extensions privées Rockwell
Automation de CIP** échangées entre Studio 5000 et les automates
ControlLogix (firmwares v18 à v36), au-dessus des dissecteurs natifs
`enip` / `cip` (issue #95) : enveloppe signée HMAC-SHA1 (services
`0x36` / `0xB6`), transport de téléversement de corps compilés
(`0x3A` / `0xBA`, service interne `0x5D`), poignée de main « Path-A »
(classe `0x0064`), enregistrements de descriptions Logix (classe
`0x0349`) et attributs des classes `0x6C`, `0x8D` et `0x338`.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/complacentsee/wireshark-rockwell-cip (`plugins/lua/`) |
| Commit importé | `70e9bfb9dadb8e16bfa25b517b51d65dcb35ca01` du 25/05/2026 (dernier commit de la branche par défaut `main`) ; dernière modification de chaque fichier indiquée dans son en-tête (20/05/2026 ou 25/05/2026) |
| Licence amont | GPL-2.0-or-later (`LICENSE` du dépôt et en-têtes SPDX des fichiers ; l'API GitHub affiche « NOASSERTION » parce que le `LICENSE` amont n'est qu'un avis renvoyant au texte de la GPL v2) — compatible avec la licence de ce dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Partiel — `enip` et `cip` décodent l'encapsulation et la requête, mais les services `0x36`, `0x3A` et `0x5D` restent affichés comme « Service (0x36) » sans détail ; ce script les complète sans remplacer les natifs |

Le `LICENSE` de ce dossier est la copie conforme de l'avis amont (18
lignes) ; le texte intégral de la GPL v2 est à
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html. Les 14 fichiers
Lua sont repris tels quels (aucune modification de code) ; seule l'en-tête
de provenance est ajoutée en tête de chacun (convention du dépôt,
issue #563). Les tests Python, le port C en projet et les outils amont ne
sont pas importés ; le dépôt amont ne fournit aucune capture (choix
documenté dans son README).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rockwell_cip.lua` | Point d'entrée : protocole `rockwell_cip`, ajoute `lua/` et `util/` à `package.path`, charge les modules, déclare les champs en une fois et s'enregistre en post-dissecteur |
| `src/lua/service_36_signed.lua` | Enveloppe signée `0x36` / `0xB6` : chemin externe, CIP interne redécodé par le natif, numéro de séquence, contrôle du HMAC-SHA1 (préférence `rockwell_cip.hmac_key`) |
| `src/lua/service_3a_upload.lua` | Téléversement `0x3A` / `0xBA` : état, jeton, opération `0x5D`, flux zlib et décompression facultative (préférence `rockwell_cip.inflate`) |
| `src/lua/class_0064_handshake.lua` | Poignée de main « Path-A » et dérivation de la clé HMAC (préférence `rockwell_cip.client_rsa_key_file`) |
| `src/lua/class_0349_docs.lua` | Enregistrements de commentaires et descriptions (classe `0x0349`) |
| `src/lua/class_attrs.lua` | Noms d'attributs des classes `0x6C` et `0x8D`, paramètres `UDIParameters` de la classe `0x338` |
| `src/util/*.lua` | Bibliothèques pures Lua : `sha1`, `bigint`, `rsa`, `pem`, `inflate`, `session`, `modexp_cache`, `valstr` |

## Utilisation

Copier tout le contenu de `src/` (avec `lua/` et `util/`) dans le dossier
des plugins Lua personnels de Wireshark, ou lancer directement
`tshark -X lua_script:src/rockwell_cip.lua -r capture.pcapng`. Clé HMAC
connue : `-o rockwell_cip.hmac_key:<128 caractères hexadécimaux>`.
Filtres : `rockwell_cip`, `rockwell_cip.signed.hmac_status`,
`rockwell_cip.upload.state`, `rockwell_cip.docs.text`… (liste complète
dans le README amont).

## Vérification à l'import

Avec tshark 4.6.4 : les 14 fichiers passent `luac5.4 -p`, le script se
charge sans erreur (102 champs `rockwell_cip.*`), et aussi une fois
copié dans un dossier de plugins (Wireshark y charge aussi les modules
de `lua/` et `util/` comme scripts, sans effet de bord). Le test amont
`tests/test_lua_crypto.lua` (bigint, RSA, PEM) passe avec `lua5.4`
(« ALL OK »).

Capture synthétique EtherNet/IP (TCP 44818, `SendRRData`), trames
signées avec une clé de 64 octets passée en préférence :

| Trame | Résultat |
|---|---|
| `0x36` enveloppant `Get Attribute Single` Identity/1/7 | arbre « Rockwell signed-CIP wrapper (0x36) », CIP interne décodé par le natif, `[Signed Send]`, séquence 1, HMAC `OK` |
| `0xB6` réponse | statut général, CIP interne (réponse `0x8E`), HMAC `OK` |
| `0x36` signé avec une autre clé | HMAC `MISMATCH`, HMAC attendu affiché, `[BAD HMAC]` |
| `0x3A` INIT avec `0x5D` op 3 | état `0x01`, opération 3, CIP interne `Class (0x68) - Service (0x5d)` |
| `0xBA` INIT final avec en-tête de 16 octets + zlib | flux zlib repéré à l'offset 16, décompression : 51 octets (le XML d'origine) |
| `0x3A` / `0xBA` continuation | jeton `0xCAFE` et écho |
| sans clé | `(no key — set rockwell_cip.hmac_key preference)` |
| CIP standard non signé | rien d'ajouté au natif |

Résultats identiques en deux passes (`tshark -2`).

## Limites constatées

- Poignée de main `0x0064`, descriptions `0x0349` et attributs de classes
  non vérifiés : il faudrait une capture réelle Studio 5000 et, pour la
  dérivation de clé, la clé RSA privée du client.
- Préférence `hmac_key` : seule une clé de 64 octets exactement est
  acceptée ; toute autre valeur est ignorée sans avertissement.
- La dérivation de clé met en cache sur disque
  (`~/.cache/rockwell_cip/hmac_modexp_cache.bin`) et coûte 2 à 3 s par
  exponentiation modulaire RSA en Lua pur (README amont).
- Les échecs de chargement ou de dissection d'un module sont écrits sur
  la sortie d'erreur et masqués dans l'arbre.
- Colonne Info : les réponses `0xBA` cumulent `[Upload INIT reply]
  [Upload Reply]`.
- Projet amont marqué « early scaffolding » ; non testé sur des captures
  réelles.
