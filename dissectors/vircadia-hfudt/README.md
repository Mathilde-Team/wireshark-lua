# Vircadia HFUDT

Dissecteurs Wireshark Lua des protocoles réseau de
[Vircadia](https://github.com/vircadia/vircadia-native-core) (monde virtuel 3D,
fork open source de High Fidelity) : transport HFUDT et ses charges utiles
HF Audio, HF Avatar, HF Entity et HF Domain (issue #253).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/vircadia/vircadia-native-core |
| Commit importé | `a6872176fa27c5951ba9f6e208c5ac58decb4759` du 01/07/2025 (dernier commit de `master`) ; dernier changement de `tools/dissectors/` : `51f4320911689ae36685f92abb02df051490c4cf` du 26/04/2021 |
| Licence amont | Apache-2.0 (`LICENSE` amont, préfixé des mentions de copyright ; l'API GitHub l'affiche « NOASSERTION ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur HFUDT ou High Fidelity natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence Apache-2.0 est conservée (en-tête SPDX
`Apache-2.0`), compatible avec la GPL-3.0-or-later du dépôt.

Le README amont indique que le projet est déprécié au profit de Vircadia World.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/1-hfudt.lua` | Transport HFUDT : en-tête (contrôle, fiabilité, message, numéros de séquence), paquets de contrôle, désobfuscation, aiguillage vers les sous-protocoles selon le type de paquet |
| `src/2-hf-audio.lua` | HF Audio : séquence, codec, stéréo, échantillons silencieux |
| `src/3-hf-avatar.lua` | HF Avatar : données d'avatar (identifiant, tailles des sections, position, regard, parent, rotations et translations des articulations) et traits d'avatar |
| `src/4-hf-entity.lua` | HF Entity : trafic du serveur d'entités (séquence, horodatage, code octal, identifiant d'entité) |
| `src/5-hf-domain.lua` | HF Domain : trafic du serveur de domaine (identifiants de domaine) |

Seul `tools/dissectors/*.lua` est importé ; le reste du dépôt amont (moteur C++)
est hors périmètre. Les fichiers Lua sont repris tels quels, en-tête de
provenance ajouté.

## Utilisation

Copier les cinq fichiers de `src/` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`), **en gardant leurs préfixes numériques** :
Wireshark charge les plugins par ordre alphabétique et `1-hfudt.lua` appelle les
sous-dissecteurs par leur nom (`Dissector.get("hf-audio")`, etc.) au moment de
la dissection.

## Limites constatées à l'import

- `1-hfudt.lua` s'enregistre sur **tous les ports UDP de 1000 à 65000**
  (`p_hfudt.init`) : tout trafic UDP sur ces ports est décodé comme HFUDT tant
  que le plugin est chargé. À n'installer que pour analyser une capture
  Vircadia, ou à restreindre localement la boucle aux ports utilisés.
- les scripts écrivent « Loading hfudt »… sur la console Lua au chargement
  (`print` amont) ;
- `deobfuscate` utilise la bibliothèque `bit` (Lua BitOp), toujours fournie par
  Wireshark 4.4 et suivants ; une variable `start` y est redéclarée en `local`
  dans un bloc (`message_bit == 1`), si bien que le décalage de 12 octets n'est
  jamais appliqué (comportement amont conservé) ;
- variables globales (`p_hfudt`, `p_hf_audio`…, `deobfuscate`) : comportement
  amont conservé ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
