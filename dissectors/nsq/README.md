# NSQ — protocole TCP de la messagerie NSQ

Dissecteur Wireshark en Lua du protocole TCP de NSQ (plateforme de messagerie
distribuée) sur le port 4150 : commandes `IDENTIFY`, `SUB`, `PUB`, `MPUB`,
`RDY`, `FIN`, `REQ`, `TOUCH`, `CLS`, `NOP`, `AUTH`, et réponses (JSON,
`_heartbeat_`, `OK`) (issue #390).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/detailyang/wireshark-nsq |
| Commit importé | `5884a805077248d7e3ea887f9c510974961c0182` du 06/02/2016 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2016 detailyang ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur NSQ natif (rien dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/nsq.lua` | Protocole `nsq` sur TCP 4150 ; champs `nsq.type` (commande ou réponse) et `nsq.content` (paramètres, données) |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/nsq.lua` dans le dossier des plugins Lua de Wireshark (ou
`tshark -X lua_script:nsq.lua`). Exemple de l'amont :

```sh
tshark -i lo0 -Y 'nsq' -T fields -e nsq.type -e nsq.content
```

## Limites constatées à l'import

- l'amont n'a testé que `PUB`, `MPUB`, `FIN`, `RDY`, `IDENTIFY` et le
  heartbeat ;
- `REQ` et `TOUCH` concatènent la variable non définie `messageid` (au lieu de
  `message_id`) : erreur Lua sur ces commandes ;
- `MPUB` : boucle `for i=0,nmessage` qui lit un message de trop ;
- une seule commande décodée par segment TCP, sans réassemblage ni contrôle
  de longueur ; les messages poussés par le serveur (trames `FrameTypeMessage`)
  ne sont pas décodés ;
- `AUTH` affiche le secret d'authentification en clair dans l'arbre ;
- variable globale `tcp_table` ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
