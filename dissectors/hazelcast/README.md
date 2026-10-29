# Hazelcast Client Protocol

Dissecteur Wireshark Lua pour le protocole client
[Hazelcast](https://hazelcast.com/) (grille de données en mémoire
distribuée) (issue #468).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/pmcgleenon/hazelcast-wireshark-plugin |
| Commit importé | `559ca1349222092b5786ffd2d3be2070f7a3e3db` du 14/12/2024 |
| Licence amont | MIT (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Hazelcast natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/hz_client.lua` | Point d'entrée : connexion client (TCP 5701), trames du protocole client |
| `src/hz_decoders.lua` | Décodeurs des types de messages |
| `src/hz_message_types.lua` | Tables des types de messages (opcode → nom) |

`hz_client.lua` charge les deux autres fichiers via `require` : les trois
fichiers doivent rester ensemble dans le même dossier. Le dépôt amont contient
aussi `documentation.md`, `pcaps/` et `tools/` : non importés.

## Utilisation

Copier les trois fichiers `src/hz_*.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Le port TCP (5701) est modifiable en
tête de `hz_client.lua`.

## Limites constatées à l'import

- couvre le protocole client (port 5701), pas le protocole membre-à-membre ;
- la version du protocole décodée correspond à celle de l'amont (2024) : les
  messages plus récents peuvent apparaître non décodés.
