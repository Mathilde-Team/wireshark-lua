# Among Us

Dissecteur Wireshark Lua du protocole UDP du jeu
[Among Us](https://github.com/cybershard/wireshark-amongus) (issue #284).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/cybershard/wireshark-amongus |
| Commit importé | `380cca03b0f4eb10a59875e8008be7b692462567` du 24/04/2021 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (`LICENSE` amont, sans mention « or later » dans le fichier, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Among Us natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/among_us_dissector.lua` | Protocole `amongus` sur UDP 22023 à 22923 (pas de 100) : format de paquet (`Unreliable`, `Reliable`, `Hello`, `Disconnect`, `Acknowledgement`, `Ping`), type de charge utile (`CreateGame`, `JoinGame`, `GameData`…), parties `GameData` (`Data`, `RPC`, `Spawn`…), codes de partie, votes et état des joueurs |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/among_us_dissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtres d'après le README amont :
`amongus`, `amongus.packet_format eq Reliable`, `amongus.payload_type eq
GameData`.

## Limites constatées à l'import

- **`bit32` absent des Wireshark récents** : le décodage des entiers compactés,
  des codes de partie et des drapeaux de joueur appelle `bit32.band`,
  `bit32.bor`, `bit32.bxor`, `bit32.lshift` et `bit32.rshift`, bibliothèque de
  Lua 5.2 absente par défaut de Lua 5.3 et 5.4, seules versions prises en
  charge depuis Wireshark 4.4 (qui fournit `bit` à la place). Sans `bit32`
  global, la dissection de ces champs échoue (« attempt to index a nil value
  (global 'bit32') ») ; contournement local : ajouter `bit32 = bit` en tête du
  fichier (code amont non modifié ici) ;
- dissecteur sans état (README amont) : identifiants de joueurs et d'objets
  non résolus en noms ;
- protocole de 2021 : les versions plus récentes du jeu peuvent différer ;
- ports codés en dur ; tables et variables globales (`Packet_Format`,
  `Payload_Type`, `udp_table`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
