# Steam P2P

Dissecteur Wireshark en Lua du protocole P2P de Steam sur UDP (multiplexé
avec STUN) : mode non fiable (canal, données) et mode fiable (numéros de
séquence envoyé/reçu, type de paquet, taille du tampon de réception,
horodatages, messages de données fragmentés et commandes), avec suivi d'état
par connexion pour réassembler les messages fiables (issue #352).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Benjamin-Dobell/steam-p2p-wireshark |
| Commit importé | `91d9ac8cd3d4f8dbb4b788ce3c7c6e1aa2123966` du 22/11/2025 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2019 Benjamin Dobell ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Steam P2P natif (`steam-streaming` de ce dépôt couvre un autre protocole) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/udp-steam-p2p-dissector.lua` | Protocole `steamp2p`, dissecteur heuristique UDP : modes non fiable (`0x00`) et fiable (`0x01`, en-tête de 25 octets), validation du contenu, réassemblage des messages de données, renvoi vers Classic STUN des paquets qui ressemblent à du STUN |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/udp-steam-p2p-dissector.lua` dans le dossier des plugins Lua de
Wireshark puis redémarrer. Le dissecteur s'active seul sur UDP (heuristique).
Filtre : `steamp2p`.

## Limites constatées à l'import

- mode fiable : `dissect_time` appelle `math.round`, qui n'existe pas en Lua
  standard (ni en 5.4 ni dans l'API Lua de Wireshark) : sans définition
  ajoutée par ailleurs, l'affichage des horodatages lève une erreur Lua et la
  dissection du paquet s'arrête après l'en-tête ;
- `Dissector.get('classicstun-heur')` : ce nom n'est plus enregistré depuis
  Wireshark 4.4 (seul `classicstun` subsiste, vérifié dans les sources
  `release-4.4` et `release-4.6`) ; la fonction renvoie alors `nil` et un
  paquet non fiable ayant l'allure d'un message STUN provoque une erreur Lua ;
- protocole très dépendant de l'état : les messages fiables ne se décodent
  correctement que si tous les paquets précédents de la connexion sont
  présents dans la capture ;
- code de diagnostic de l'amont laissé actif : affichage d'une table de
  diagnostic dans la console à la trame 2340 (`LAST_FRAME`) ; fonctions et
  tables globales (`dump_table`, `dump`, `TYPE_STRINGIFIERS`,
  `CONTENT_DISSECTORS`) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
