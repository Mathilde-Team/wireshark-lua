# Veloren

Dissecteur Wireshark Lua de la couche réseau du jeu Veloren sur TCP 14004 :
poignée de main (magie, version), initialisation (PID, secret), ouverture de
flux (identifiant, priorité, promesses, bande passante garantie), en-têtes de
données et données (issue #346).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/cpetig/wireshark-veloren |
| Commit importé | `f06113e903a932b05a072cf923051db272f4b3f2` du 28/12/2024 (dernier commit de `main`) ; dernier changement de `lua/veloren.lua` : `e81204462c69185b5807a9c8375ecd3d3c9c5573` du 07/01/2024 |
| Licence amont | BSD-3-Clause pour `lua/veloren.lua` (en-tête du fichier : « Copyright (c) 2023, Christof Petig », « covered by the BSD (3 clause) license » ; fondé sur l'exemple FPM de Hadriel Kaplan, domaine public ou BSD-3-Clause). Le `LICENSE` du dépôt amont est la GPLv3 et couvre le reste du dépôt (dissecteur C et Rust, non importé) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Veloren natif |

Texte de la licence : fichier `LICENSE.txt` de ce dossier, texte canonique
SPDX de la BSD-3-Clause précédé des deux mentions de copyright de l'en-tête
(l'amont ne fournit pas de fichier de licence BSD).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/veloren.lua` | Protocole `veloren` sur TCP 14004 : types `HANDSHAKE`, `INIT`, `OPEN_STREAM`, `DATA_HEADER`, `DATA`, `RAW`, calcul de longueur par type et réassemblage TCP, résumé en colonne Info ; préférences : activation, niveau de débogage |

Seul le dissecteur Lua est importé ; le dissecteur C (`plugin.c`,
`veloren.c`) et la bibliothèque Rust de décodage des flux sont hors périmètre
(code natif, et sous GPLv3). Le fichier est repris tel quel, en-tête de
provenance ajouté.

## Utilisation

Copier `src/veloren.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `veloren`.

## Limites constatées à l'import

- le contenu des flux n'est pas décodé en Lua (doublement encodé côté Rust :
  compression puis bincode ; c'est l'objet de la partie C/Rust de l'amont) ;
- `CalcLength` compare la longueur attendue à la taille totale du tampon sans
  tenir compte du décalage : avec plusieurs messages par segment, le
  réassemblage peut lire au-delà des données disponibles ;
- un type inconnu consomme tout le reste du segment ;
- fonctions globales (`CalcLength`, `dissectVeloren`) ; le protocole est
  nommé `fpm_proto` dans le code (reprise de l'exemple FPM) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
