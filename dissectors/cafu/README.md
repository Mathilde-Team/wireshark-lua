# Cafu Engine

Dissecteur Wireshark Lua du protocole réseau du moteur de jeu Cafu
(anciennement Ca3D-Engine) sur UDP : messages hors connexion (ping,
connexion, informations, console distante) et messages en connexion
(informations du monde, entités, trames) entre client et serveur (issue #298).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/DNS/Cafu |
| Commit importé | `77b34014cc7493d6015db7d674439fe8c23f6493` du 24/04/2019 (dernier commit de `master`) ; dernier changement de `Ca3DE/wireshark-cafu.lua` : `02abc2501676ea7448c10dc89696b19e4812593f` du 05/06/2012 |
| Licence amont | MIT (`LICENSE.txt` amont, « Copyright (c) Carsten Fuchs and other contributors », pour tout le dépôt sauf `ExtLibs/` ; GitHub l'affiche « NOASSERTION » à cause du préambule) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Cafu natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE.txt` amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark-cafu.lua` | Protocole `Cafu` sur UDP 30000 : marqueur hors bande `0xFFFFFFFF`, types de messages CS0/SC0/CS1/SC1, numéros de séquence et indicateurs d'acquittement, détail de `SC1_WorldInfo`, `SC1_EntityBaseLine`, `SC1_FrameInfo`, `SC1_EntityUpdate`, `SC1_EntityRemove` |

Le fichier est repris tel quel, en-tête de provenance ajouté. Les numéros de
types de messages (à partir de 1) correspondent à `Ca3DE/NetConst.hpp` amont.

## Utilisation

Copier `src/wireshark-cafu.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtre : `cafu`.

## Limites constatées à l'import

- port 30000 codé en dur ; le sens est déduit du port source ;
- côté client vers serveur, seul le premier message en connexion est
  identifié, le reste du datagramme est affiché brut (champ
  `Cafu.Rest`, libellé allemand d'origine « Der noch unbekannte Rest ») ;
- un type de message absent des tables provoque une erreur Lua (concaténation
  d'une valeur `nil` dans la colonne Info) ;
- champ `Cafu.xy` (4 octets après le marqueur hors bande) non identifié par
  l'auteur (« ??? ») ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
