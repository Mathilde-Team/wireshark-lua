# Sony SAPARi — VSCP/VSAP

Dissecteur Wireshark en Lua, inachevé, du protocole VSCP/VSAP de Sony
SAPARi / « Community Places » (monde virtuel en ligne de Sony) sur TCP 5126 :
messages « hello » (client et serveur), type de méthode, et en-tête des
messages de type 0 (type, taille, charge utile) (issue #378).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/modeco80/saparid (fichier `tools/wireshark/sapari.lua`) |
| Commit importé | `bafa7b574ef942c0e5b7f505ce2fbc12234ae5ae` du 17/03/2023 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2023 modeco80/Lily Tsuru ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur VSCP natif (pas de `packet-vscp.c` dans les sources `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/sapari.lua` | Protocole `vscp` sur TCP 5126 : « hello » (magie, inconnus côté serveur, version VSCP côté client), méthode (`TYPE0`, `TYPE1`, `TYPE2`, `HELLO/HELLA`, `REJECT`, `UNK6`), deux champs inconnus, en-tête des messages `TYPE0` |

Fichier repris tel quel, en-tête de provenance ajouté. Le reste du dépôt
(serveur C++ saparid) est hors périmètre.

## Utilisation

Copier `src/sapari.lua` dans le dossier des plugins Lua de Wireshark (ou
`wireshark -X lua_script:sapari.lua`). Filtre : `vscp`.

## Limites constatées à l'import

- dissecteur qualifié de « fairly WIP » par l'auteur : seuls les messages de
  type 0 sont détaillés, plusieurs champs restent « Unknown » ;
- détection du sens du « hello » sur un seul octet (signalée comme fragile par
  l'auteur) ;
- pas de réassemblage TCP ni de découpage de plusieurs messages par segment ;
  pas de contrôle de longueur (erreur Lua sur un segment court) ;
- variables et fonctions globales (`vscp_protocol`, champs,
  `vscp_method_name`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
