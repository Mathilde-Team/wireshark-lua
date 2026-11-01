# Soapbox Race World

Dissecteur Wireshark Lua des protocoles UDP de Soapbox Race World (serveur
communautaire de Need for Speed World) : mode « freeroam » et mode course,
avec sous-dissecteurs hello, id, player, pos, statepos et synchronisation
(keep-alive, session) (issue #310).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nilzao/soapbox-race-dissector |
| Commit importé | `728072f5fe1c5292efa6c29e9d368b3184d3289d` du 04/02/2018 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Soapbox Race World natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

Arborescence amont reprise telle quelle dans `src/` ; en-tête de provenance
ajouté à chaque `.lua`. Non importés : `.gitignore` et les sept captures
`example/*.pcapng` (environ 15 Mo de trafic de parties, dont des sessions
sur le serveur officiel), disponibles dans le dépôt amont.

| Fichier | Rôle |
|---|---|
| `src/loader.lua` | Point d'entrée : calcule son dossier, ajoute `src/modules` au chemin de recherche et charge les modules |
| `src/src/modules/soapbox/boot.lua` | Charge les modes freeroam et course |
| `src/src/modules/soapbox/freeroam/boot.lua` | Protocole `SB-FREEROAM` (UDP 9999) |
| `src/src/modules/soapbox/race/boot.lua` | Protocole `SB-RACE` (UDP 9998) |
| `src/src/modules/soapbox/common/fields.lua` | Protocole `SBRW` et champs communs (`soapbox.*`) |
| `src/src/modules/soapbox/dissector-*.lua` | Sous-dissecteurs hello, id, player, pos, statepos, sync, sync-keep-alive, sync-session |
| `src/src/modules/soapbox/packet-types.lua` | Aiguillage des types de paquets |
| `src/README.md` | Mode d'emploi de l'auteur |

## Utilisation

L'auteur charge `loader.lua` par `dofile("<chemin>/loader.lua")` dans
`init.lua`. Copier le contenu de `src/` hors du dossier `plugins` (les modules
ne sont pas des greffons autonomes), puis créer par exemple
`plugins/soapbox-loader.lua` contenant `dofile("<chemin>/loader.lua")`.
Filtres : `sb-freeroam`, `sb-race`.

## Limites constatées à l'import

- `loader.lua` appelle `package.prepend_path("modules")`, fonction Lua que
  Wireshark définissait dans son `init.lua` (modèle `template-init.lua`,
  présent jusqu'à la branche 4.0 et absent depuis la 4.2) ; les versions
  actuelles ne la fournissent plus : erreur au chargement. Contournement : remplacer cet appel par
  `package.path = __DIR__ .. __DIR_SEPARATOR__ .. "modules" .. __DIR_SEPARATOR__ .. "?.lua;" .. package.path` ;
- `loader.lua` redéfinit les globales `__DIR__` et `__DIR_SEPARATOR__`
  fournies par Wireshark, ainsi que `script_path` ; tout le code utilise des
  variables globales ;
- deux champs de types différents partagent l'abréviation `soapbox.personaid`
  (nom en chaîne, identifiant sur 2 octets) ;
- ports 9998 et 9999 codés en dur ;
- nombreux champs encore inconnus (« Uknown », libellé amont conservé) ;
- syntaxe de chaque `.lua` vérifiée avec `luac5.4 -p` ; pas de dissection
  testée ici (les captures d'exemple restent dans le dépôt amont).
