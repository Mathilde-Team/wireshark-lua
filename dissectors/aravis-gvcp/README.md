# GVCP — GigE Vision Control Protocol (Aravis)

Dissecteur Wireshark Lua du **GigE Vision Control Protocol (GVCP)**, canal
de contrôle UDP des caméras industrielles GigE Vision (découverte, lecture
et écriture de registres et de mémoire), écrit en 2010 par Emmanuel Pacaud
pour la bibliothèque Aravis (issue #92). Le dépôt importé est un fork
(nzjrs/aravis) du projet AravisProject/aravis.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/nzjrs/aravis (`tools/gvcp.lua`, `tools/wireshark-snapshots/`) |
| Commit importé | `a668657793ef183748b42c1ed44ac0454f87c87d` du 22/10/2013 (dernier commit de la branche par défaut `master`) ; dernière modification de `gvcp.lua` : commit `ed7fd2c4168396901d72a5aa1a5873c99b37b6dc` du 01/03/2011 ; capture : commit `5ac6df905d6a79497673e9696d1473ba08d23700` du 24/02/2010 |
| Licence amont | LGPL-2.0-or-later : `COPYING` (GNU Library GPL v2) et en-têtes des sources d'Aravis (« version 2 of the License, or (at your option) any later version ») ; le script n'a pas d'en-tête propre. GitHub affiche `NOASSERTION`. Compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | **Oui** — `gvcp` (GigE Vision Control Protocol, 235 champs) et `gvsp` pour le flux vidéo |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `COPYING` amont). Le script est repris tel quel (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le `tools/gvcp.README` amont, qui
décrit l'activation de Lua dans les Wireshark de 2010, est résumé
ci-dessous.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/gvcp.lua` | Protocole `gvcp` sur UDP 3956 : type de paquet, commande (14 codes : Discover, Bye, PacketResend, RegisterRead/Write, MemoryRead/Write, commandes et acquittements), taille, compteur ; adresse ou valeur pour la lecture de registre, adresse, taille et 16 octets de valeur pour la lecture mémoire |
| `captures/gc1380-10x20image.wsk` | Capture amont (pcap malgré l'extension, 366 trames, 23/02/2010) : caméra Prosilica GC1380, découverte, lecture du XML GenICam, réglages, acquisition d'une image 10×20 |

La seconde capture amont (`gc1380-snap-320x200.wsk`, 10 Mo, 19 137 trames
essentiellement GVSP) n'est pas importée à cause de sa taille.

## Utilisation

**Le script ne se charge pas avec Wireshark 4.6.4** : il déclare un
protocole nommé `gvcp`, déjà pris par le dissecteur natif (« Proto_new:
there cannot be two protocols with the same name », ligne 2). Utiliser le
dissecteur natif, bien plus complet (filtre `gvcp`) ; le script n'a plus
qu'un intérêt historique (ou pour un Wireshark sans dissecteur GVCP natif).

## Vérification à l'import

- `luac5.4 -p` : OK ; chargement dans tshark 4.6.4 : échec (voir
  ci-dessus).
- Pour comparer, une **copie hors dépôt** dont seuls le nom du protocole
  et le préfixe des champs ont été changés (`gvcplua`) a été chargée sur
  `captures/gc1380-10x20image.wsk` :
  - 334 trames décodées, autant que le natif `gvcp` : 13 Discover
    commande/acquittement, 136 RegisterRead, 15 RegisterWrite, 3
    MemoryRead (commandes et acquittements) ;
  - RegisterReadCmd (trame 3) : adresse 2560 (`0x0a00`), que le natif
    nomme « CCP (Control Channel Privilege) » ;
  - MemoryReadAck : trame 26 donne la valeur `lapp-vicam02`, trame 22 une
    valeur vide (octets binaires commençant par un NUL lus comme chaîne),
    trame 82 une erreur Lua « Range is out of bounds » (acquittement de
    8 octets seulement) ;
  - le natif affiche en plus les drapeaux, le statut, le lien
    requête/réponse et le nom de chaque registre d'amorçage.

## Limites constatées

- Conflit de nom avec le dissecteur natif : inutilisable tel quel.
- « PacketType » mélange octet de clé (`0x42`) et drapeaux pour les
  commandes, et lit le statut pour les acquittements.
- RegisterRead/Write limités au premier registre ; pas de décodage de
  Discover, Bye, PacketResend, Write ni des codes d'erreur.
- MemoryReadAck : 16 octets lus sans contrôle de longueur, valeur
  interprétée comme chaîne.
- Variables globales (`gvcp_proto`, `cmd`, `udp_table`) ; compteur
  `packet_counter` inutilisé.
