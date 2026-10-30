# Valheim — zsocket2 (AvlWireshark)

Dissecteur Wireshark en Lua du protocole réseau zsocket2 du jeu vidéo Valheim
sur TCP (port 2456 par défaut) : en-tête et type de message, RPC et RPC
routés, ZDOData, noms de prefabs (issue #347).

Implémentation qui succède à celle de `dissectors/valheim-zsocket2` (dépôt
crazicrafter1 archivé, « consolidated into https://github.com/Avledet ») :
code réorganisé (générateurs de champs, RPC routés, table de prefabs étendue)
et protocole nommé `zs2` au lieu de `valheimzs2`.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Avledet/AvlWireshark |
| Commit importé | `8559f0ddc3ec3082081eaffcccd4bfd29f10e3a2` du 07/04/2026 (dernier commit de `main`) |
| Licence amont | GNU AGPLv3 ou ultérieure (`LICENSE.md` : « either version 3 of the License, or (at your option) any later version ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Valheim natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (avis
`LICENSE.md` amont, suivi du texte canonique de l'AGPLv3, l'amont ne
fournissant que l'avis).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/init.lua` | Protocole `zs2`, préférence « Port Range » (2456), réassemblage TCP, dissection de l'en-tête et du type de message, enregistrement sur `tcp.port` |
| `src/zs2_constants.lua` | Nom du protocole, port, taille d'en-tête |
| `src/zs2_types.lua` | Lecture des types Valheim (entiers encodés, chaînes, vecteurs…) et fabriques de champs |
| `src/zs2_field_wrappers.lua` | Enveloppes de champs (ProtoField + analyseur) |
| `src/zs2_rpcs2.lua` | RPC (version refondue) |
| `src/zs2_routed_rpcs.lua` | RPC routés |
| `src/zs2_prefabs.lua` | Table hachage → nom de prefab |
| `src/zs2_util.lua` | Extensions de `string` (`contains`, `startswith`…) |

Fichiers repris tels quels, en-tête de provenance ajouté. Non importés :
`zs2_readers.lua_` et `zs2_rpcs.lua_` (anciennes versions désactivées par
l'amont, chargées par aucun fichier), `README.md` et `LICENSE.md` (repris
ci-dessus).

## Utilisation

Copier les fichiers de `src/` dans un sous-dossier (ex. `zsocket2`) du
dossier des plugins Lua personnels (« Aide → À propos de Wireshark →
Dossiers → Plugins Lua personnels »), puis redémarrer Wireshark. Les modules
sont chargés par `require("zs2_…")`.

Filtre proposé par l'amont pour masquer le trafic fréquent :
`zs2 and !(zs2.zdodata.id.id) and !(zs2.msg_type==0) and !(zs2.routedrpc.setevent.name == "") and !(zs2.nettime)`.

## Limites constatées à l'import

- ne pas charger en même temps que `dissectors/valheim-zsocket2` : les deux
  s'enregistrent sur TCP 2456 ;
- variables ZDOData non exposées en champs (signalé par l'amont) ;
- TCP uniquement ; la capture doit commencer avant la connexion au jeu ;
- `zs2_util.lua` ajoute des méthodes à la table globale `string`, partagée
  avec les autres plugins Lua ;
- la préférence « Port Range » n'est lue qu'au chargement (pas de
  `prefs_changed`) : un changement demande un redémarrage ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
