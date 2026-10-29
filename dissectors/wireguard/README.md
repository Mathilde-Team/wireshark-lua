# WireGuard (tunnel protocol)

Dissecteur Wireshark Lua pour le protocole de tunnel WireGuard : messages de handshake (Initiation, Response, Cookie Reply) et données de transport, avec support de déchiffrement optionnel via luagcrypt/Libgcrypt.

> **Obsolète** : d'après le README amont, une version améliorée de ce dissecteur est incluse nativement dans Wireshark depuis la 2.9.x (donc la 3.0) ; ce Lua n'est utile que pour les anciennes versions (2.0.2+).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Lekensteyn/wireguard-dissector |
| Commit importé | `240f0ab22232f33bac55ce3436b56a06042e4614` du 26/08/2018 (branche `master`) |
| Licence amont | GPLv2 (ou toute version ultérieure), selon l'en-tête de `wg.lua` |
| Natif Wireshark 4.6.4 | Oui — un dissecteur WireGuard amélioré est inclus depuis Wireshark 3.0 |

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wg.lua` | Dissecteur : messages de handshake (Type, Sender, Ephemeral, mac1/mac2…) et données de transport |

Le dépôt amont contient aussi `key-extract.py`, `key-probe.sh`, `key-stopprobe.sh` (outils d'extraction de clés), une capture d'exemple (`pcaps/8-trace.pcap`, `8-trace.keys`) et une image : non importés (le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier `src/wg.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Pour la 3.0+, le dissecteur natif est recommandé. Déchiffrement optionnel : installer [luagcrypt](https://github.com/Lekensteyn/luagcrypt) + Libgcrypt 1.7, puis configurer le fichier de clés (Préférences de protocole → Keylog file).
