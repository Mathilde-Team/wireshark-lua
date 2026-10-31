# Pokémon Revolution Online (PRO)

Dissecteur Wireshark Lua du protocole texte de Pokémon Revolution Online sur
TCP : instructions `EN-TÊTE|.|PARAM1|.|PARAM2|.\` échangées entre le client et
le serveur, chaque octet étant masqué par un XOR 1 (issue #291).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/g0ldPRO/PROWireshark |
| Commit importé | `ca56d6ef8f7e516a309df84047f9a4c15fd6de31` du 17/11/2018 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur PRO natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/pro.lua` | Protocole `pro` sur TCP 800 : démasquage XOR 1, découpage des instructions multiples d'un segment, en-tête et paramètres nommés pour 108 types d'instructions (client → serveur et serveur → client), résumé des en-têtes dans la colonne Info |

Le fichier est repris tel quel, en-tête de provenance ajouté. `deploy.bat`
(copie locale vers le dossier Wireshark de l'auteur) n'est pas importé.

## Utilisation

Copier `src/pro.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre de capture : `port 800` ; filtre
d'affichage : `pro`.

## Limites constatées à l'import

- port 800 codé en dur ; le sens est déduit uniquement du port source
  (`pinfo.src_port == 800` → serveur vers client) ;
- pas de réassemblage TCP : une instruction coupée entre deux segments n'est
  pas reconnue ;
- liste d'instructions figée en 2018 : le protocole actuel du jeu peut avoir
  évolué ; les en-têtes inconnus sont affichés « UNKNOWN » ;
- libellé du protocole amont « Pokemon Revolution Offline protocol » conservé
  tel quel ;
- variables globales (`pro_proto`, `Packet`, `clientToServerPacketInfos`,
  `serverToClientPacketInfos`, `tcp_table`) ;
- utilise `bit.bxor`, fourni par Wireshark (pas par Lua standard) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
