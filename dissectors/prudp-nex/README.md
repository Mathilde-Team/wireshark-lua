# PRUDP (Nintendo NEX)

Dissecteur Wireshark en Lua de PRUDP, couche de transport fiable sur UDP des
services en ligne Nintendo NEX : en-têtes V0 (source, destination, type,
drapeaux, session, signatures, séquence, fragment, taille, somme de contrôle)
et V1 (en-tête et hachage) (issue #348).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/andreluis034/prudp-wireshark-dissector |
| Commit importé | `fdd31e80933b138d793376493b73898414078edf` du 20/03/2018 (dernier commit de `master`) |
| Licence amont | GPLv3 (fichier `LICENSE`, aucune mention « or later » dans le code) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur PRUDP/NEX natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/prudp-dissector.lua` | Protocole `prudp`, dissecteur heuristique UDP : reconnaissance par les premiers octets (`AF A1` / `A1 AF` pour V0, `EA D0 01` pour V1), puis dissection V0 ou V1 |

Fichier repris tel quel, en-tête de provenance ajouté.

## Utilisation

Copier `src/prudp-dissector.lua` dans le dossier des plugins Lua de Wireshark
puis redémarrer. Le dissecteur s'active seul sur UDP (heuristique). Filtre :
`prudp`.

## Limites constatées à l'import

- heuristique sur 2 ou 3 octets seulement : risque de faux positifs sur
  d'autres trafics UDP ; un paquet plus court que le motif provoque une
  erreur Lua ;
- `prudp.dissector` utilise la table `dissectors` déclarée en `local` plus
  loin dans le fichier : appelé via « Décoder comme… », il échoue ; seul le
  chemin heuristique fonctionne ;
- V1 : seuls l'en-tête et le hachage sont décodés
  (données supplémentaires et charge utile non découpées) ;
- charge utile non déchiffrée ni décodée (RMC/NEX) ;
- dépôt sans activité depuis 2018, pas de capture d'exemple : syntaxe
  vérifiée avec `luac5.4 -p`, pas de dissection testée sur trafic réel.
