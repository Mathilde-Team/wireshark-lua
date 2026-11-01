# Donet

Dissecteur Wireshark Lua des protocoles de
[Donet](https://github.com/donet-server/donet), moteur réseau pour jeux en
ligne massivement multijoueurs inspiré du « Distributed Networking » de
Panda3D (issue #282).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/donet-server/donet (miroir GitHub ; dépôt principal : https://git.maxrdz.com/donet/donet) |
| Commit importé | `95d87cc49a5498df0f2d65314c71d99a4c9801a2` du 14/03/2026 (dernier commit de `master`) ; dernier changement de `donet_protocol.lua` : `ef8f99aa2ae1dcc692f0bfdfbc2523fbbf1a8d8c` du 16/11/2024 |
| Licence amont | AGPL-3.0-or-later (README amont : « either version 3.0 or, at your option, any later version » ; `license = "AGPL-3.0-or-later"` dans `Cargo.toml`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Donet natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `COPYING`). Le fichier `.lua` ne porte pas de notice propre : la
licence du dépôt s'applique.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/donet_protocol.lua` | Deux protocoles : `donet_internal` (« Message Director », TCP 7199) — longueur, canaux destinataire/émetteur, type de message et champs d'objets distribués (DoId, champ, parent, zone, contexte), plusieurs messages par segment avec réassemblage TCP ; `donet_client` (« Client Agent », TCP 7198) — longueur et type de message seulement |

Seul `tools/wireshark/donet_protocol.lua` est importé ; le moteur Rust est
hors périmètre. Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/donet_protocol.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`) ; guide amont :
https://docs.donet-server.org/master/internal/debugging#network-analysis.
Filtres : `donet_internal`, `donet_client`.

## Limites constatées à l'import

- port TCP 7199 également enregistré par `dissectors/astron/` : si les deux
  greffons sont installés, le dernier chargé l'emporte (choix possible via
  « Décoder comme… ») ;
- ports 7199 et 7198 codés en dur (variables globales `donet_md_port`,
  `donet_ca_port`), enregistrés dans `init()` ;
- sans fichier `.dc`, les classes et champs sont affichés de façon générique
  (`DistributedObject`, `FIELD_<n>`) et leurs valeurs en octets bruts ;
  plusieurs messages sont marqués « TODO: Dissect » en amont ;
- `donet_client` : un seul message par segment, charge utile non décodée,
  sans réassemblage ;
- fonctions globales (`dissect_one`, `pretty_msgtype`…) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
