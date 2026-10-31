# ENet

Dissecteur Wireshark Lua du protocole [ENet](http://enet.bespin.org/) 1.3
(couche réseau UDP fiable très utilisée par les jeux vidéo), écrit par
[cgutman/wireshark-enet-dissector](https://github.com/cgutman/wireshark-enet-dissector)
(issue #273).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/cgutman/wireshark-enet-dissector |
| Commit importé | `3c6830d4ab998c84b90df8e72322f5ad72e05502` du 25/07/2023 (dernier commit de `master`) |
| Licence amont | GPL-3.0 (`LICENSE` amont ; en-tête du fichier : « Licensed under GPLv3 », sans « ou ultérieure ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur ENet natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). L'amont ne mentionne pas « or any later version » : la
licence est conservée en `GPL-3.0-only` (en-tête SPDX), comme pour `lifx` ou
`redis-cluster`, compatible avec la distribution de ce dépôt sous GPL-3.0.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/enet.lua` | Protocole `enet` : en-tête (identifiant de pair, horodatage d'envoi facultatif) puis chaque commande (en-tête, canal, numéro de séquence fiable) et ses champs pour les commandes 1 à 11 (`Acknowledge`, `Connect`, `VerifyConnect`, `Disconnect`, `Ping`, `SendReliable`, `SendUnreliable`, `SendFragment`, `SendUnsequenced`, `BandwidthLimit`, `ThrottleConfigure`) |

Seul `enet.lua` est importé ; il est repris tel quel, en-tête de provenance
ajouté.

## Utilisation

Copier `src/enet.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), ou lancer
`wireshark -X lua_script:/chemin/enet.lua`. Le dissecteur n'est associé à
aucun port réel (enregistrement sur le port UDP 0) : sélectionner le flux UDP
puis « Décoder comme… » → `ENET`, comme l'indique le README amont.

## Limites constatées à l'import

- la commande 12 (`SendUnreliableFragment`) n'est pas décodée (TODO amont) :
  les commandes qui la suivent dans le même datagramme sont mal découpées ;
- les options d'en-tête de compression et de somme de contrôle (CRC32) ne sont
  pas prises en compte ;
- la charge utile applicative des commandes d'envoi est affichée en octets
  bruts (champs `*.data`), sans sous-dissecteur ;
- variables globales (`pf_*`, `pktsubtree`, `cmdsubtree`, `command`, `i`…) :
  comportement amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
