# Terraria

Dissecteur Wireshark Lua du protocole multijoueur de Terraria 1.4.5.8
(version réseau 326, chaîne de poignée de main `Terraria326`) sur TCP 7777 :
découpage des trames (en-tête de 3 octets), routage par identifiant de
message et un décodeur par message, avec experts sur les octets restants
(issue #331).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/BeInBloom/terraria-wireshark-dissector |
| Commit importé | `c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d` du 26/10/2026 (dernier commit de `main`) |
| Licence amont | GPL-3.0-only (fichier `LICENSE` amont, texte de la GPLv3 ; aucune mention « or later » dans le dépôt) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Terraria natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

## Fichiers

L'arborescence amont est reprise sous `src/` (en-tête de provenance ajouté à
chaque `.lua`, contenu inchangé) :

| Chemin | Rôle |
|---|---|
| `src/src/terraria.lua` | Point d'entrée : protocole `terraria` sur TCP 7777, « Décoder comme… » |
| `src/src/terraria/dissector.lua`, `context.lua`, `fields.lua` | Réassemblage TCP (`dissect_tcp_pdus`), en-tête longueur + identifiant, colonne Info, champs et experts d'en-tête |
| `src/src/terraria/game/` | Catalogue des paquets (identifiants et noms « vanilla ») et propriétés des tuiles |
| `src/src/terraria/payload/` | Registre identifiant → décodeur, lecteur `PayloadReader`, structures partagées (raison de décès, NetworkText, clé de projectile), curseur d'octets |
| `src/src/terraria/payload/builders/` | 133 fichiers : un décodeur par identifiant de message (`init.lua` les liste), champs `terraria.<message>.*` |
| `src/plugin/terraria.lua.in` | Modèle du chargeur installé par `make install` (complète `package.path` puis charge `terraria.lua`) |
| `src/Makefile`, `src/tests/` | Installation, tests amont (`tests/run.sh`, captures texte `fixtures/*.txt` et sorties attendues `*.expected`, générateur `build_fixtures.py`) |
| `src/README.md`, `src/.editorconfig` | README et configuration d'éditeur amont |

Non importés : `.gitignore`, `types/wireshark.lua` (annotations LuaLS de
l'API Wireshark, d'origine non indiquée), `.luarc.json` et `mise.toml`
(configuration de l'analyse LuaLS qui en dépend).

## Utilisation

Depuis `src/` : `make install` écrit le chargeur `terraria.lua` dans
`~/.local/lib/wireshark/plugins` (modifiable avec `PLUGIN_DIR=…`) ; les
modules restent dans `src/src/` (ou sont copiés vers `MODULE_DIR=…`). Ne pas
copier `src/src/terraria/` dans le dossier `plugins` : Wireshark exécuterait
chaque module comme un plugin. Filtre : `terraria` (champs `terraria.length`,
`terraria.id`, `terraria.payload`, `terraria.<message>.*`).

## Limites constatées à l'import

- une seule version du jeu prise en charge (1.4.5.8, réseau 326) : selon
  l'auteur, les captures d'autres versions ne sont que partiellement décodées
  (par exemple 1.4.5.6 échoue sur les paquets 7, 22, 27, 29 et 39) ;
- une dizaine de paquets sans structure connue sont affichés en octets bruts
  (141, 142, 145, 148, 150, 152, 158, 161, 93, 94) ; les structures suivent le
  projet terrustia, faute de documentation officielle du protocole ;
- `make check-lua` ne fonctionne pas tel quel (annotations `types/` et
  configuration LuaLS non importées) ;
- les tests amont (`make test`) demandent `tshark` et `text2pcap`, absents de
  l'environnement d'import : seule la syntaxe a été vérifiée avec
  `luac5.4 -p` (149 fichiers), pas de dissection testée sur trafic réel ;
- port 7777 codé en dur (« Décoder comme… » disponible pour un autre port).
