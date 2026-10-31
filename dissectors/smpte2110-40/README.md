# SMPTE ST 2110-40 (données ancillaires sur RTP)

Dissecteur Wireshark en Lua de la charge RTP SMPTE ST 2110-40 / RFC 8331
(paquets de données ancillaires SMPTE ST 291 : sous-titres, AFD, time code,
SCTE 104…), issue #42.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/NEOAdvancedTechnology/smpte2110-40-dissector (ancien nom d'organisation : FOXNEOAdvancedTechnology, redirigé) |
| Commit importé | `c766fd7e790e487d327b84e3270447a42749e451` du 02/06/2020 |
| Licence amont | GPL-2.0-or-later (en-tête de `ST2110-40.lua` et README amont, « either version 2 of the License, or (at your option) any later version ») — compatible GPL-3.0-or-later ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | non (aucun dissecteur ST 2110-40 / RFC 8331 natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: GPL-2.0-or-later` avec la provenance est ajoutée
(convention du dépôt, issue #563). L'amont ne fournit pas de texte de
licence séparé (avertissement attendu de `scripts/valider_imports.py`) ; le
texte de la GPLv2 est publié sur
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ST2110-40.lua` | Dissecteur `st_2110_40` : en-tête RFC 8331 (numéro de séquence étendu, longueur, nombre de paquets ANC, champ), puis pour chaque paquet ANC : C, ligne, décalage horizontal, flux, DID/SDID (table ST 291 nommée), Data Count, mots utilisateur et somme de contrôle recalculée ; décodage détaillé des CDP (EIA-708/608), des SDP OP-47 (RDD 8) et du télétexte WST |

Non importés : `parse_CC.sh` (script shell d'extraction des sous-titres
via tshark) et la capture d'écran `ScreenShot.png` de l'amont.

## Utilisation

1. Copier `src/ST2110-40.lua` dans le dossier des plugins Lua de Wireshark
   (ex. `~/.local/lib/wireshark/plugins/`).
2. Préférences → Protocols → ST 2110_40 : indiquer le type de charge utile
   RTP dynamique du flux (valeur > 95).
3. « Decode As » des paquets UDP du flux en RTP.

En ligne de commande :
`tshark -r flux.pcap -d udp.port==5006,rtp -o st_2110_40.dyn_pt:100`.

## Vérification à l'import

Avec tshark 4.6.4, sur une capture synthétique (`text2pcap`, RTP type 100,
port 5006, un paquet ANC AFD DID 0x41/SDID 0x05 ligne 9) : en-tête RFC 8331,
champs du paquet ANC, nom DID/SDID « AFD and Bar Data (S2016-3) », mot
utilisateur et somme de contrôle (lue = calculée, 0x24f) décodés.

## Limites constatées à l'import

- un seul type de charge utile dynamique à la fois (préférence unique) ;
- seuls CDP, SDP OP-47 et WST sont décodés en détail ; les autres DID/SDID
  sont nommés mais leurs mots utilisateur restent bruts ;
- le champ « UDW Bytes » affiche les octets bruts recouvrant les mots de
  10 bits ; la valeur des mots est dans « UDW Array » ;
- dépôt amont sans activité depuis 2020.
