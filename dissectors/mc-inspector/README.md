# MC-Inspector (exports PCAP Minecraft)

Dissecteur Wireshark Lua des fichiers PCAP exportés par le mod Minecraft
MC-Inspector (Fabric) : chaque trame contient la direction, l'identifiant
d'enregistrement MC-Inspector et le paquet Minecraft brut, décompressé et
déchiffré (issue #323).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Nano112/MC-Inspector |
| Commit importé | `24a352abdd74bc79b5d9cfbd83cbe8471177071e` du 08/09/2026 (dernier commit de `main`) ; dernier changement du fichier : `b67e431201fd8b2bc4afaa151a97555df8736caa` du 22/08/2026 |
| Licence amont | MIT (fichier `LICENSE`, « Copyright (c) 2026 Harrison ») |
| Natif Wireshark 4.6.4 | Non — Wireshark n'a pas de dissecteur Minecraft Java natif, ni pour ce format d'export |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont).

Seul le dissecteur (`docs/wireshark-mcinspector.lua`) est importé ; le reste du
dépôt (mod Kotlin/Java) n'est pas concerné.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark-mcinspector.lua` | Protocole `mcinspector` sur l'encapsulation `wtap.USER0` (type de lien 147, DLT_USER0) : direction (serveur→client ou client→serveur), identifiant d'enregistrement (32 bits gros-boutiste), identifiant de paquet (VarInt) et corps brut |

Le fichier est repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/wireshark-mcinspector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/` ou `~/.config/wireshark/plugins/`),
puis ouvrir un PCAP exporté par MC-Inspector (`<gameDir>/packet-exports/`).
Filtre : `mcinspector`.

## Limites constatées à l'import

- ne lit que les exports PCAP de MC-Inspector, pas le trafic Minecraft capturé
  sur le réseau ;
- les champs du paquet ne sont pas décodés : identifiant et corps brut
  seulement (les champs décodés sont dans l'export JSON Lines du mod) ;
- occupe `wtap.USER0`, au risque d'entrer en conflit avec un autre usage de
  DLT_USER0 ;
- pas de contrôle de longueur : une trame de moins de 6 octets provoque une
  erreur Lua ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
