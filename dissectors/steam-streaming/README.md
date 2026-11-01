# Steam In-Home Streaming

Dissecteur Wireshark Lua du transport de Steam In-Home Streaming (Remote
Play), écrit lors de la rétro-ingénierie en salle blanche du projet
[krzys-h/SteamStreaming](https://github.com/krzys-h/SteamStreaming)
(issue #289).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/krzys-h/SteamStreaming |
| Commit importé | `41edfe7c79498b740e9b6b48cf83e8d0909cd39a` du 18/07/2019 (dernier commit de `master`, qui est aussi le dernier changement de `steam_dissector.lua`) |
| Licence amont | GPL-3.0 (`LICENSE.txt` amont, sans mention « or later », d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Partiel — Wireshark décode nativement la découverte (`steam_ihs_discovery`, UDP 27036, cf. https://www.wireshark.org/docs/dfref/s/steam_ihs_discovery.html), pas le flux de streaming couvert ici |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/steam_dissector.lua` | Protocole `steamstream` sur UDP 27031 : type de paquet (SYN, SYN-ACK, données fiables/non fiables, ACK, FIN…), somme de contrôle CRC-32C, compteur de réémissions, sens, canal (`Discovery`, `Control`, `Stats`, données), fragments, séquence, horodatage, type de message (≈ 70 noms tirés de `stream.proto`), tests de MTU ; charge utile protobuf passée au dissecteur `protobuf` de Wireshark |

Seul `steam_dissector.lua` est importé ; le client C# et les protobufs Steam
(sous-module) sont hors périmètre. Le fichier est repris tel quel, en-tête de
provenance ajouté.

## Utilisation

Copier `src/steam_dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `steamstream`. Pour nommer les
champs protobuf, ajouter les `.proto` de
https://github.com/SteamDatabase/Protobufs dans les préférences du protocole
Protobuf de Wireshark.

## Limites constatées à l'import

- la plupart des messages du canal de contrôle sont chiffrés et affichés comme
  « Encrypted data » (déchiffrement non implémenté) ;
- les messages protobuf sont décodés sans type de message : champs numérotés
  seulement, erreurs masquées par `pcall` ;
- fragments non réassemblés ; flux audio/vidéo non décodés ;
- port 27031 codé en dur ; table globale `udp_table` ;
- testé par l'auteur sur `localhost` uniquement (README amont) ; pas de capture
  d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection
  testée sur trafic réel.
