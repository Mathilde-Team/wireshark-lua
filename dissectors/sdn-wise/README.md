# SDN-WISE (capteurs sans fil)

Dissecteur Wireshark Lua pour SDN-WISE (Software Defined Networking for WIreless Sensor networks) : protocole des réseaux de capteurs sans fil définis par logiciel.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/sdnwiselab/sdn-wise-dissector |
| Commit importé | `66f8e3b2b497cb10420cdbe051429a449cb61e25` du 20/02/2018 (branche `master`) |
| Licence amont | GPLv3 (fichier `LICENSE`, sans clause « or later ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur SDN-WISE natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/sdn-wise.lua` | Dissecteur (4,4 Ko) : identifiant réseau, adresses, types de messages SDN-WISE, support TSCH |

Non importés : `README.md` (documentation, reprise ici), `.gitignore`.

## Utilisation

Copier `src/sdn-wise.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`). Ajuster la valeur d'offset dans le fichier selon le scénario et (dé)commenter les lignes 109 à 116 en conséquence (instructions amont).

## Limites constatées à l'import

- configuration par offset à éditer dans le fichier selon le scénario (pas de préférence) ;
- non maintenu depuis 2018 ; support TSCH ajouté en dernier commit.
