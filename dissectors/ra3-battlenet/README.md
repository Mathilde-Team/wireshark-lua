# RA3 BattleNet (GameSpy)

Dissecteurs Wireshark Lua du trafic en ligne de Command & Conquer: Red Alert 3
via les services de type GameSpy de RA3 BattleNet : GPCM (présence et
connexion), PeerChat (salons IRC chiffrés) et QueryMaster (liste des serveurs)
(issue #339).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/RA3BattleNet/Dissectors |
| Commit importé | `ecc04fa452951de4607dd5884da3bbb66a3b718f` du 21/10/2022 (dernier commit de `main`) |
| Licence amont | GPL-2.0-only (fichier `LICENSE` amont, texte de la GPLv2 ; aucune mention « or later » dans le dépôt) |
| Natif Wireshark 4.6.4 | Non — Wireshark n'a pas de dissecteur GPCM, PeerChat chiffré ni QueryMaster (le dissecteur IRC natif ne déchiffre pas PeerChat) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

Voir aussi `dissectors/gamespy-natneg` (#309) pour la traversée NAT GameSpy.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/gpcm.lua` | Protocole `gpcm` sur TCP 29900 : messages clé-valeur `\clé\valeur…\final\`, suivi par flux TCP et par sens, colonne Info |
| `src/peerchat.lua` | Protocole `peerchat` sur TCP 6667 et 16667 : déchiffrement des deux sens (chiffrement PeerChat dérivé de la clé de jeu RA3 `uBZwpf` et des défis échangés), lignes IRC en champ `peerchat.payload` |
| `src/querymaster.lua` | Protocole `querymaster` sur TCP 28910 : requêtes de liste de serveurs, réponses déchiffrées (défi, clé du serveur), adresses IP et ports, clés et valeurs des serveurs, données ad hoc |
| `src/index.lua` | Fonction qui charge les trois fichiers avec `dofile` depuis un chemin donné |

Les fichiers sont repris tels quels, en-tête de provenance ajouté. Le README
amont n'est pas importé.

## Utilisation

Soit copier `gpcm.lua`, `peerchat.lua` et `querymaster.lua` dans le dossier
`plugins` de Wireshark, soit, comme l'indique l'auteur, laisser `src/` en place
et créer dans `plugins` un fichier `ra3.lua` :

```lua
local base_path = [[/chemin/vers/dissectors/ra3-battlenet/src/]]
dofile(base_path .. 'index.lua')(base_path)
```

Ne pas copier `index.lua` lui-même dans `plugins`. Filtres : `gpcm`,
`peerchat`, `querymaster`.

## Limites constatées à l'import

- PeerChat occupe TCP 6667, port IRC standard : il remplace le dissecteur IRC
  natif sur ce port, pour tout le trafic ;
- clé de jeu codée en dur (RA3 uniquement) ; ports codés en dur ;
- `querymaster.lua` crée ses champs pendant la dissection (`add_to_tree`),
  après l'enregistrement du protocole : ces champs risquent de ne pas être
  enregistrés auprès de Wireshark (non filtrables, voire erreur Lua) ;
- pas de `dissect_tcp_pdus` : le réassemblage est fait à la main par flux,
  à partir de l'état conservé dans des tables Lua ;
- `print(...)` à chaque nouveau flux et à chaque anomalie : sortie console ;
  nombreuses variables globales (`GpcmProtocol`, `GPCM_PORT`,
  `RA3_GAMEKEY`, `add_to_tree`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
