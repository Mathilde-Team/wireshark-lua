# D-TACQ WRTD et HUDP (White Rabbit PULSE Generator)

Deux dissecteurs Wireshark Lua fournis avec le paquet **CUSTOM_WRPG** de
D-TACQ (générateur d'impulsions White Rabbit pour les numériseurs ACQ2106) :

- **WRTD** (White Rabbit Trigger Distribution), UDP 5044 : messages de
  déclenchement (`hw_detect` « LXI », domaine, identifiant d'évènement,
  masque, numéro de séquence, horodatage seconde/nanoseconde) ;
- **HUDP** (format `32s_8l`), UDP 53676 : trames de données UDP du
  numériseur, voies 16 bits et mots « spad » 32 bits.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/D-TACQ/CUSTOM_WRPG |
| Commit importé | `f1af2f5a0fa72fd260ffa13aaaa5f82bb004f095` du 10/05/2023 (branche `master`, dernier commit) |
| Licence amont | GPL-3.0 (`LICENSE` amont, texte GPL v3 ; aucune mention « or later » dans le dépôt, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur WRTD ou HUDP natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont).

## Fichiers

| Fichier | Fichier amont | Rôle |
|---|---|---|
| `wrtd.lua` | `CARE/dot.wireshark.plugins.wrtd.lua` | Dissecteur WRTD (UDP 5044) |
| `hudp32s_8l.lua` | `CARE/dot.wireshark.plugins.hudp32s_8l.lua` | Dissecteur HUDP 32s_8l (UDP 53676) |

Le contenu est importé tel quel ; seule une en-tête SPDX + provenance de
quatre lignes a été ajoutée en tête de chaque fichier. Les noms amont
encodent le chemin d'installation (`~/.wireshark/plugins/<nom>.lua`) : ils
sont raccourcis ici à ce nom final. Le reste du paquet (scripts et firmware
du générateur) n'est pas importé.

## Utilisation

Copier `wrtd.lua` et/ou `hudp32s_8l.lua` dans le dossier `plugins` de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis recharger les
plugins Lua.

## Remarques

- `hudp32s_8l.lua` : les voies 5 à 28 sont commentées dans le code amont ;
  seules les voies 1 à 4 et 29 à 32 et les mots « spad » sont affichés.
- `hudp32s_8l.lua` crée son arbre avec `tree:add(<nom du protocole>, …)`
  (une chaîne au lieu de l'objet `Proto`) : l'arbre s'affiche comme un
  simple texte, sans filtrage `hudp` sur la racine.
- Variables globales (`wrtd_protocol`, `hudp32s_8l_protocol`, champs) ;
  pas de capture d'exemple amont ; décodage non vérifié dans Wireshark.
