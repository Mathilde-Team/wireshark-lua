# Xbox Live (Xombie)

Dissecteurs Wireshark Lua de deux services de l'Xbox Live d'origine (Xbox
première génération), écrits par le projet de réimplémentation
[Xombie](https://github.com/XombieOnline/xombie) : présence (« XBox Live
Presence ») et matchmaking (issue #261).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/XombieOnline/xombie |
| Commit importé | `7a1ef08045271437efc5938c996cb0c209a31408` du 13/08/2022 (dernier commit de la branche par défaut) |
| Licence amont | AGPL-3.0 (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Xbox Live présence/matchmaking natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). L'amont ne précise pas de version au-delà du texte de
l'AGPL-3.0 joint ; comme pour `aerospike`, la licence AGPL est conservée telle
quelle avec l'en-tête SPDX `AGPL-3.0-or-later` (section 14 de l'AGPL : sans
version précisée, toute version publiée par la FSF peut être choisie). Elle ne
peut pas être re-licenciée en GPL.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/xblive_presence_dissector.lua` | Protocole `xblive-presence` : corps HTTP de type MIME `xon/1` (table `media_type`) ; en-tête `BASE_MSG_HEADER` (type, longueur, séquence, adresse SG) et messages `P_ALIVE`, `P_ALIVE_2`, `P_ALIVE_REPLY` |
| `src/xblive_matchmaking_dissector.lua` | Post-dissecteur `http_resp` : rattache chaque réponse HTTP à sa requête (méthode, URI, version, hôte) et ajoute le champ `xblive-matchmaking` (URL complète) aux échanges vers `/xmatch/xmatchclient.srf` |

Seuls les deux scripts de `scripts/` sont importés (le script
`install_dissectors.sh` et le serveur Rust sont hors périmètre). Les fichiers
sont repris tels quels, en-tête de provenance ajouté.

## Utilisation

Copier les deux fichiers de `src/` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Les deux dissecteurs s'appuient sur le
dissecteur HTTP natif : le trafic doit être en HTTP clair (ou déchiffré).

## Limites constatées à l'import

- `xblive_matchmaking_dissector.lua` est un **post-dissecteur** : il s'exécute
  sur chaque paquet de la capture et garde en mémoire les requêtes HTTP de tous
  les flux TCP (tables vidées à chaque rechargement) ;
- il déclare le champ `http.request.URL` dans le protocole
  `xblive-matchmaking` (espace de noms `http.`), et ajoute une méthode
  `string:endswith` à la table globale `string` : comportement amont conservé ;
- seuls trois types de messages de présence sont détaillés ; pour les autres,
  seul l'en-tête de 32 octets est décodé, le reste n'est pas affiché ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
