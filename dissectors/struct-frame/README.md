# Struct Frame

Dissecteur Wireshark Lua pour le protocole « Struct Frame » de
[mylonics](https://github.com/mylonics/struct-frame) : protocole de
sérialisation structurée (messages à champs typés, trames « tiny » et
normales), utilisé par leurs outils d'ingénierie (issue #458).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mylonics/struct-frame |
| Commit importé | `7e94eb19d2bbc7a00730f6e89441c8d2d5e5f7e3` du 22/10/2026 |
| Licence amont | MIT (`LICENSE` amont) |
| Natif Wireshark 4.6.4 | Non — protocole propriétaire, aucun équivalent natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/struct_frame.lua` | Dissecteur du protocole Struct Frame (en-tête, champs typés, messages) |

Le dépôt amont est un paquet Python (struct-frame) qui embarque ce dissecteur
Wireshark dans `wireshark/` : seul le fichier Lua est importé.

## Utilisation

Copier `src/struct_frame.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le dissecteur s'enregistre sur l'encapsulation
pcap LINKTYPE_USER0 (wtap encap 45) et comme dissecteur heuristique UDP ;
l'enregistrement explicite sur un port UDP est fourni en commentaire dans le
fichier.

## Limites constatées à l'import

- l'enregistrement sur port UDP est laissé en commentaire amont (code fourni
  avec un port à renseigner) ;
- les trames sont aussi détectées par heuristique UDP : des faux positifs sont
  possibles sur d'autres flux.
