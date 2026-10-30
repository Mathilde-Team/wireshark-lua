# Kaillera et Open Kaillera P2P (smash64-dev)

Dissecteur Wireshark Lua du protocole Kaillera middleware (jeu en réseau pour
émulateurs, mode serveur) et du protocole Open Kaillera P2P, avec détection
heuristique des connexions (issue #321).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/smash64-dev/kaillera-dissector |
| Commit importé | `96e5fc77a1aa29510b24394144d0820541e85488` du 01/05/2021 (dernier commit de `main`) |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2021 Smash64 Development ») ; `lib/middleclass.lua` : MIT, « Copyright (c) 2011 Enrique García Cota » (texte dans le fichier) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Kaillera natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont). La licence de middleclass figure dans l'en-tête de
`src/lib/middleclass.lua`.

Autre dissecteur Kaillera du dépôt : `dissectors/kaillera` (direlera-rs,
#278), implémentation indépendante.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/kaillera.lua` | Protocole `kaillera` (Kaillera Middleware) : heuristique UDP sur l'échange « HELLO » / « HELLOD00D », ajout dynamique des ports dans `udp.port`, découpage des messages (nombre, identifiant, longueur, type) |
| `src/okai.lua` | Protocole `okai` (Open Kaillera P2P) : heuristique UDP sur la demande de connexion, ajout dynamique des ports |
| `src/constants.lua` | Définition déclarative des types de messages et de leurs champs pour les deux protocoles |
| `src/lib/field.lua`, `src/lib/arrayfield.lua`, `src/lib/message.lua` | Classes génériques de champ, de tableau de champs et de message, génération des `ProtoField` |
| `src/lib/middleclass.lua` | Bibliothèque de classes middleclass v4.1.1 |

Les fichiers sont repris tels quels (arborescence amont conservée), en-tête de
provenance ajouté. Le README amont n'est pas importé.

## Utilisation

Copier le contenu de `src/` (avec le sous-dossier `lib/`) dans le dossier des
plugins Lua personnels de Wireshark (Aide > À propos de Wireshark > Dossiers >
Personal Lua Plugins). Sans paquets de connexion, utiliser « Décoder comme… »
avec `Kaillera` ou `Okai`. Filtres : `kaillera`, `okai`.

## Limites constatées à l'import

- `require "constants"` et `require "lib.…"` supposent que le dossier des
  plugins figure dans `package.path` de Wireshark ; Wireshark charge aussi
  `constants.lua` et `lib/*.lua` comme plugins à part entière (sans effet
  visible, ce sont des modules) ;
- conflit avec `dissectors/kaillera` : les deux enregistrent le protocole
  `kaillera` (et des champs `kaillera.*`), ils ne peuvent pas être installés
  ensemble ;
- `KAILLERA_PROTOCOL`, `OKAI_PROTOCOL`, etc. sont des variables globales ;
- quelques champs encore inconnus et pas de décodage des données de jeu par
  émulateur (liste « Todo » amont) ;
- les ports ajoutés dynamiquement ne sont jamais retirés ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
