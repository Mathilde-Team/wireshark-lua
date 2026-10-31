# HK4E KCP (Genshin Impact)

Dissecteur Wireshark Lua de la couche KCP du protocole réseau de Genshin
Impact (nom de code « HK4E »), livré avec le serveur Go
[Hk4eOfficial/hk4e](https://github.com/Hk4eOfficial/hk4e) (protocole client
3.2) (issue #287).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Hk4eOfficial/hk4e |
| Commit importé | `06a5136321777d99921d62e901543475b3fb5d20` du 22/11/2023 (dernier commit de `main`, qui est aussi le dernier changement de `docs/wireshark_hk4e_kcp.lua`) |
| Licence amont | Apache-2.0 (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur HK4E ni KCP natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont ; pas de fichier `NOTICE` en amont). L'Apache-2.0 est
compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark_hk4e_kcp.lua` | Protocole `HK4E_KCP` sur UDP 22222 : poignée de main « ENET » de 20 octets (session, conversation, type) résumée dans la colonne Info ; segments KCP (session, conversation, commande `PSH`/`ACK`/`ASK`/`TELL`, fragment, fenêtre, horodatage, numéros de séquence et d'acquittement, longueur, données), plusieurs segments par datagramme |

Seul `docs/wireshark_hk4e_kcp.lua` est importé : le serveur Go, les données de
jeu (`gdconf/`) et les binaires de `docs/` (DLL et `luac.exe` du client) sont
hors périmètre. Le fichier est repris tel quel, en-tête de provenance ajouté
(commentaires amont en chinois).

## Utilisation

Copier `src/wireshark_hk4e_kcp.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `hk4e_kcp`.

## Limites constatées à l'import

- couche KCP seulement : les données (`hk4e_kcp.data`) restent chiffrées et
  ne sont ni réassemblées ni décodées (pas de déchiffrement ni de protobuf) ;
- commande KCP inconnue : `get_cmd_name` renvoie `nil` et la concaténation
  `" (" .. cmd_name .. ")"` provoque une erreur Lua ; segment tronqué : erreur
  de plage hors limites ;
- chaque segment ajoute un sous-arbre couvrant tout le datagramme ;
- port 22222 codé en dur ; variables globales (`length`, `len`, `data`,
  `sess`…) et fonction globale `get_cmd_name` ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
