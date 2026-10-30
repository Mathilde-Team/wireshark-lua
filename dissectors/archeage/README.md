# ArcheAge

Dissecteur Wireshark Lua du trafic serveur → client du jeu en ligne ArcheAge :
découpage des messages, déchiffrement de leur charge utile et affichage des
messages de discussion (canal, personnage, texte), écrit par
[Ingramz/archeage](https://github.com/Ingramz/archeage) (`aa-packetsniffer`)
(issue #271).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Ingramz/archeage |
| Commit importé | `e3bd96af3a927779a96f4a8a71e573886311d158` du 24/06/2026 (dernier commit de `master`) ; dernier changement de `aa-packetsniffer/wireshark-plugin.lua` : `2c676019a53a533e4bb17622651c203a73819c00` du 28/04/2024 |
| Licence amont | Unlicense (`LICENSE.md` amont, domaine public) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur ArcheAge natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de `LICENSE.md` amont). L'Unlicense (domaine public) est conservée
(en-tête SPDX `Unlicense`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/archeage.lua` | Protocole `archeage` sur TCP 1239 : longueur et type de chaque message, déchiffrement XOR (`StoCEncrypt`), CRC, numéro de séquence, second type ; pour les messages de type `F900` (discussion), canal, nom du personnage et texte affichés aussi dans la colonne Info |

Le fichier amont `aa-packetsniffer/wireshark-plugin.lua` est importé sous le
nom `archeage.lua` (nom amont trop générique) ; son contenu est repris tel quel,
en-tête de provenance ajouté. L'outil .NET `aa-packetsniffer` et le reste du
dépôt sont hors périmètre.

## Utilisation

Copier `src/archeage.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le trafic TCP 1239 est décodé automatiquement.

## Limites constatées à l'import

- **`bit32` absent des Wireshark récents** : le script appelle
  `bit32.rshift`, `bit32.band` et `bit32.bxor`, bibliothèque de Lua 5.2 absente
  par défaut de Lua 5.3 et 5.4, seules versions prises en charge depuis
  Wireshark 4.4 (qui fournit `bit` à la place). Sans `bit32` global, la dissection échoue (« attempt to index a nil
  value (global 'bit32') ») ; contournement local : ajouter `bit32 = bit` en
  tête du fichier (code amont non modifié ici) ;
- le code d'opération des messages de discussion (`F900`) change à chaque mise
  à jour du jeu : d'après le README amont, il faut l'ajuster à la main ;
- seul le sens serveur → client est déchiffré, sans réassemblage TCP ;
- nombreux `print` de débogage sur la console Lua à chaque paquet ;
- le texte des discussions et les noms des personnages apparaissent en clair
  dans l'arbre et la colonne Info : attention au partage des captures ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
