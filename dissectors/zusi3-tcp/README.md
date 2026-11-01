# Zusi 3 TCP (simulateur ferroviaire)

Dissecteur Wireshark Lua du **protocole TCP de Zusi 3**, simulateur de
conduite ferroviaire, sur TCP 1436 : arbre des nœuds et attributs du
protocole (identifiants, types de données et libellés allemands tirés de la
documentation Zusi, version 3.5.15.0), avec réassemblage des messages
répartis sur plusieurs segments TCP.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/zusitools/tcp_dissector |
| Commit importé | `1f64699a231c91458240919ef22920aa6f62da72` du 23/10/2026 (branche `master`, dernier commit, « Update Zusi 3.5.15.0 ») |
| Licence amont | GPL-3.0-or-later (en-tête du fichier : « either version 3 of the License, or (at your option) any later version » ; `COPYING` amont : GPL v3) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Zusi natif |

Texte complet de la licence amont : fichier `COPYING` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `zusi3_tcp.lua` | Dissecteur `zusi3_tcp` (TCP 1436), filtre d'affichage `zusi3_tcp` |

Fichier importé tel quel ; seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `zusi3_tcp.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), puis recharger les plugins Lua et
filtrer avec `zusi3_tcp`.

## Remarques

- L'auteur amont prévient que le protocole Zusi 3 change régulièrement de
  façon incompatible (identifiants redéfinis avec un autre type) : cette
  version correspond à Zusi 3.5.15.0 ; pour une autre version de Zusi,
  reprendre le commit amont correspondant.
- Variables globales (`zusi3_proto`, `dissector`) ; la variable `dissector`
  conserve le dissecteur précédemment associé au port 1436.
- Pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
