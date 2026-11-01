# Hello Peer — TCU (Transmission Control over UDP)

Dissecteur Wireshark en Lua du protocole TCU de l'application de messagerie
pair-à-pair Hello Peer, transporté sur UDP 5000/5001 : numéro de séquence
(24 bits), drapeaux (SYN, ACK, FIN, NACK, DF, MF, FL, KA), longueur de la
charge et checksum, avec le type de paquet en colonne Info (connexion,
déconnexion, keep-alive, acquittements, messages texte ou fichier, fragments)
(issue #402).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/admtrv/HelloPeer (fichier `wireshark/tcu.lua`) |
| Commit importé | `195da1fa0d15dfeb981241747f7468fdfd45ffb5` du 05/12/2024 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2024 Anton Dmitriev ») |
| Natif Wireshark 4.6.4 | Non — protocole propre à Hello Peer |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/tcu.lua` | Protocole `tcu` sur UDP 5000 et 5001 ; champs `tcu.seq_num`, `tcu.flags`, `tcu.length`, `tcu.checksum` |

Fichier repris tel quel, en-tête de provenance ajouté. Le reste du dépôt
(application C++) est hors périmètre.

## Utilisation

Copier `src/tcu.lua` dans le dossier des plugins Lua de Wireshark. Les ports
5000 et 5001 (ceux des exemples du README amont) se changent dans le code ou
avec « Décoder comme… ». Filtre : `tcu`.

## Limites constatées à l'import

- ports UDP 5000/5001 très courants : risque de faux positifs avec d'autres
  applications ;
- la charge utile n'est pas ajoutée à l'arbre ; le checksum n'est pas vérifié ;
- utilise `bit.band` (bibliothèque `bit`), dont la disponibilité dépend de la
  version de Lua embarquée par Wireshark ;
- protocole déclaré en global (`tcu_proto`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
