# Luna Multiplayer (LMP)

Dissecteur Wireshark Lua du protocole Luna Multiplayer (mod multijoueur de
Kerbal Space Program) sur UDP, au-dessus de la bibliothèque réseau Lidgren :
en-têtes Lidgren et LMP, poignée de main, introduction, paramètres du serveur,
inscription et liste des serveurs (serveur maître), messages de vaisseaux
(issue #325).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/DasSkelett/LmpWiresharkDissector |
| Commit importé | `78c8093752eb1b0c1ee79f43db091307a7aa5395` du 17/04/2022 (dernier commit de `main`) |
| Licence amont | GPL-2.0-or-later (en-tête de `LmpWiresharkDissector.lua`, « Copyright (c) DasSkelett », « either version 2 of the License, or (at your option) any later version ») ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur LMP ni Lidgren natif |

Texte de la licence : fichier `LICENSE.txt` de ce dossier. L'amont ne fournit
pas de fichier de licence : c'est le texte canonique de la GPLv2 (même copie
que `dissectors/dfsi-cai`), celle que l'en-tête du fichier principal déclare.
Les modules `decoder_*.lua`, `utils.lua` et `shifting.lua` n'ont pas d'en-tête
propre ; ils font partie du même programme et sont importés sous la licence du
fichier principal.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/LmpWiresharkDissector.lua` | Protocole `lunamultiplayer` sur UDP 8700, 8750 et 8800 : charge les modules, enregistre les champs et préférences, aiguille selon le type de message |
| `src/decoder_Lidgren.lua` | En-tête Lidgren (type de message réseau, fragmentation, numéro de séquence, longueur) |
| `src/decoder_Header.lua` | En-tête LMP (types et sous-types, serveur maître et serveur) |
| `src/decoder_ReplyServers.lua`, `src/decoder_RegisterServer.lua`, `src/decoder_Introduction.lua` | Messages du serveur maître : liste des serveurs, inscription, introduction |
| `src/decoder_Handshake.lua`, `src/decoder_Settings.lua`, `src/decoder_Vessel.lua` | Messages du serveur : poignée de main, paramètres, vaisseaux (préférence « Ignore Vessel Messages ») |
| `src/utils.lua`, `src/shifting.lua` | Fonctions utilitaires (VarInt, recherche) et décalage de bits du tampon |

Les fichiers sont repris tels quels, en-tête de provenance ajouté. Non
importés : `x_fpm.lua` (exemple FPM de Hadriel Kaplan, sans rapport avec LMP,
qui enregistrerait un protocole `fpm` concurrent du natif), `x_benchmark.lua`
et `x_bit53.lua` (banc d'essai de `shifting.lua` et substitut de `bit`), le
README, `.gitignore` et `.vscode/`.

## Utilisation

Comme l'indique l'auteur, charger le fichier principal depuis le dossier `src/`
(les `require` sont relatifs) :

```sh
cd dissectors/luna-multiplayer/src
wireshark -X lua_script:LmpWiresharkDissector.lua capture.pcapng
```

Filtre : `lunamultiplayer`.

## Limites constatées à l'import

- travail en cours selon l'auteur (« [WIP] ») : seule une partie des types de
  messages est décodée (TODO dans `decoder_Settings.lua`) ;
- `require 'utils'`, `require 'decoder_…'` supposent que `src/` figure dans
  `package.path` (répertoire courant) ; copiés dans le dossier `plugins`, les
  modules seraient aussi chargés seuls comme plugins et échoueraient
  (`_G.lmp_proto_fields` non encore défini) ;
- nombreuses fonctions et variables globales (`decodeLmpHeader`,
  `lmp_proto_fields`, `nextlen`…) ;
- ports 8700, 8750 et 8800 codés en dur ;
- pas de capture d'exemple amont (les `.pcapng` sont exclus par le
  `.gitignore`) : syntaxe vérifiée avec `luac5.4 -p`, pas de dissection testée
  sur trafic réel.
