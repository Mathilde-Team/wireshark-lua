# GIP (Game Input Protocol)

Dissecteur Wireshark Lua du protocole GIP de Microsoft utilisé par les
manettes Xbox sur USB : en-tête (commande, client, acquittement, découpage en
morceaux, séquence, longueur LEB128), état d'alimentation et boutons, avec
détection heuristique sur les transferts USB d'interruption (issue #296).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/xpadneo/gip-dissector |
| Commit importé | `e9e19530fa9690de9766a4a2361c5e1e884221f5` du 05/04/2022 (dernier commit de `main`) |
| Licence amont | GPL-3.0 (fichier `LICENSE` seul, sans mention « or later » → `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur GIP natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/gip-dissector.lua` | Protocole `GIP` : commandes internes (GIP) et externes (ACC), champs d'en-tête, paramètres de morceaux, rapports d'état (alimentation, charge, batterie) et de boutons ; heuristique `usb.interrupt` qui vérifie la commande et la longueur attendue |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/gip-dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), puis ouvrir une capture USB (usbmon,
USBPcap) d'une manette Xbox. Filtre : `gip`.

## Limites constatées à l'import

- décodage minimal, annoncé comme tel par l'auteur : seule une partie des
  commandes a un décodage détaillé, le reste est affiché en « Unknown Data » ;
- USB uniquement (heuristique `usb.interrupt`) : pas de prise en charge du
  GIP sur la liaison sans fil Xbox ni sur Bluetooth ;
- pas de réassemblage des messages découpés en morceaux ;
- utilise `bit.band` / `bit.bor` / `bit.lshift`, fournis par Wireshark (pas
  par Lua standard) ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
