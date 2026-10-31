# GE-SRTP

Dissecteur Wireshark Lua du protocole **GE-FANUC Service Request Transfer
Protocol** (SRTP), le protocole privé des automates GE Fanuc / Emerson
(séries 90-30, 90-70, RX3i) sur TCP (issue #62).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/PalaIndustrial/packet-ge-srtp (anciennement `Palatis/packet-ge-srtp`) |
| Commit importé | `76d606d7d149a4752fd2e6dc24b02d1b44f6cf18` du 27/09/2026 (dernier commit de `main`, v0.0.1) |
| Licence amont | BSD-3-Clause (`LICENSE` amont, © 2022 Victor Tseng) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SRTP natif (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/packet-ge-srtp.lua` | Protocole `GE-SRTP` : en-tête de 56 octets, type de message, numéro de séquence, codes de service (lecture et écriture de mémoire, état de l'automate, etc.) et charge utile. Port TCP réglable (préférence « TCP Ports », 18245 par défaut) |

Le fichier est repris tel quel, avec l'en-tête de provenance ajouté.

## Utilisation

Copier `src/packet-ge-srtp.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtre : `ge-srtp`.

## Limites constatées à l'import

- d'après l'amont : pas de réassemblage des réponses sur plusieurs paquets,
  pas de décodage SNPX (texte) ;
- pas de capture d'exemple amont : chargement vérifié avec `tshark` 4.6.4
  (`-X lua_script:` sans erreur, protocole `ge-srtp` enregistré), pas de
  dissection testée sur du trafic réel.
