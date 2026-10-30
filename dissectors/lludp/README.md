# LLUDP (Second Life)

Dissecteur Wireshark Lua du protocole Linden UDP (LLUDP) de Second Life et
OpenSimulator : en-tête, décompression « zero-coded » et décodage des messages
à partir du fichier `message_template.msg` du client
([Neopallium/lludp_dissector](https://github.com/Neopallium/lludp_dissector),
issue #288).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Neopallium/lludp_dissector |
| Commit importé | `221e98da12cc3ce804330cb975c617f2bf1a480d` du 12/09/2020 (dernier commit de `master`) |
| Licence amont | double licence au choix : « Simplified BSD License » (`LICENSE_BSD.txt`, BSD-2-Clause) ou GPL (`LICENSE_GPL.txt`, GPL v3, sans mention « or later »), d'après la section « License » du README amont, d'où `BSD-2-Clause OR GPL-3.0-only` ; l'API GitHub affiche `NOASSERTION` faute de reconnaître cette double licence |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur LLUDP natif |

Textes complets des licences amont : `LICENSE_BSD.txt` et `LICENSE.txt`
(copie de `LICENSE_GPL.txt`) dans ce dossier, copies conformes de l'amont.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/init.lua` | Chargeur amont : associe le dissecteur HTTP aux ports TCP 8000-8010 et 9000 (capacités et services web d'OpenSimulator), puis `require("lludp.dissector")` et `require("lludp.stats_tap")` |
| `src/lludp/dissector.lua` | Protocole `lludp` sur UDP 9000-9100 et 12030-12040 : drapeaux, numéro de séquence, octets supplémentaires, accusés de réception ajoutés, décompression zero-coded, identifiant, nom et blocs/variables du message ; préférences du fichier modèle et de la plage de ports |
| `src/lludp/message_template.lua` | Analyseur du fichier `message_template.msg` (messages, blocs, variables) |
| `src/lludp/lexer.lua` | Analyseur lexical du fichier modèle |
| `src/lludp/tap.lua` | Utilitaire de fenêtre texte pour les écouteurs (menu « Outils ») |
| `src/lludp/stats_tap.lua` | Écouteur « LLUDP stats tap » : statistiques d'accusés de réception par extrémité |

L'arborescence `lludp/` est conservée pour que les `require("lludp.…")`
fonctionnent. Les fichiers sont repris tels quels, en-tête de provenance
ajouté (fichiers `.luacheckrc` et `README` amont non repris).

## Utilisation

Placer le contenu de `src/` (`init.lua` et le dossier `lludp/`) dans un dossier
présent dans le `package.path` de Lua de Wireshark, puis charger `init.lua`
(par exemple `wireshark -X lua_script:init.lua` depuis ce dossier). Renseigner
ensuite la préférence « Message template file » (chemin complet du
`message_template.msg` fourni avec le client Second Life ou OpenSimulator)
et, si besoin, la plage de ports UDP. Filtre : `lludp`.

## Limites constatées à l'import

- `message_template.msg` n'est pas fourni (fichier du client) : sans lui,
  seuls l'en-tête et l'identifiant des messages sont décodés ;
- copié tel quel dans le dossier `plugins`, Wireshark chargerait chaque
  fichier de `lludp/` comme greffon en plus des `require` : double
  enregistrement possible du protocole ; `require("lludp.…")` suppose aussi
  que le dossier parent est dans `package.path` ;
- `init.lua` détourne les ports TCP 8000-8010 et 9000 vers HTTP, et la plage
  UDP 9000-9100 enregistrée par défaut est large (la plage 13000-13050 du README
  amont n'est que la valeur par défaut des préférences, son enregistrement est
  commenté dans le code) ;
- README amont écrit pour Lua 5.1 et d'anciens noms de fichiers
  (`lludp.lua`, `llmessage.lua`) ; syntaxe valide en Lua 5.4 ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
