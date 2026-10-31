# ZMTP — ZeroMQ Message Transport Protocol

Dissecteur Wireshark en Lua du protocole ZMTP de ZeroMQ, versions 2 et 3.0 et
suivantes, avec réassemblage TCP, mécanismes d'authentification NULL et PLAIN,
et table de sous-dissecteurs `zmtp.protocol` indexée par port TCP (issue #386).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/whitequark/zmtp-wireshark |
| Commit importé | `5b801ddce38bdaa45811ea70f71911fe78eb901e` du 09/01/2024 (dernier commit de `master`) |
| Licence amont | MIT (fichier `LICENSE.txt` : Viveris Technologies 2019-2020, whitequark 2014, Robert G. Jakabosky 2011) |
| Natif Wireshark 4.6.4 | Oui — `packet-zmtp.c`, protocole natif enregistré sous le même nom `zmtp` (voir les limites) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/zmtp-dissector.lua` | Protocole `zmtp` : salutation et négociation (versions 2 et 3.x), commandes (`READY`, `HELLO`, `WELCOME`, `INITIATE`, `ERROR`…), trames et drapeaux `MORE`/`LONG`/`COMMAND`, métadonnées ; table `zmtp.protocol` ; « Décoder comme » sur `tcp.port` |

Fichier repris tel quel, en-tête de provenance ajouté. Non importés :
`README.md` amont (résumé ici) et la capture d'écran référencée.

## Utilisation

Copier `src/zmtp-dissector.lua` dans le dossier des plugins Lua de Wireshark,
puis « Décoder comme… › ZMTP » sur le port TCP concerné (les ports ZeroMQ
dépendent de l'application). Filtre : `zmtp`.

Un sous-dissecteur applicatif peut s'enregistrer dans la table `zmtp.protocol`
avec le port TCP comme clé :

```lua
local zmtp = DissectorTable.get("zmtp.protocol")
zmtp:add(1234, my_subdissector_proto)
```

## Limites constatées à l'import

- Wireshark 4.6.4 intègre un dissecteur ZMTP natif enregistré sous le même nom
  `zmtp` : sans désactivation possible de ce nom, `Proto("zmtp", …)` échoue au
  chargement (protocole déjà enregistré). Ce script ne sert donc qu'avec les
  versions de Wireshark sans dissecteur ZMTP natif, ou après renommage local
  du protocole ;
- utilise la bibliothèque `bit` (LuaBitOp), dont la disponibilité dépend de la
  version de Lua embarquée par Wireshark ; l'amont indique « Lua 5.2 or
  newer » ;
- table globale `vs_stype` ;
- mécanisme CURVE : champs CurveZMQ affichés bruts (nonces, « box »), sans
  déchiffrement ; GSSAPI non pris en charge ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
