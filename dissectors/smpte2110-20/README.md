# SMPTE ST 2110-20 (vidéo non compressée sur RTP)

Dissecteur Wireshark en Lua de la charge RTP SMPTE ST 2110-20 (essence
vidéo non compressée, en-têtes SRD de la RFC 4175), issue #41.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/NEOAdvancedTechnology/smpte2110-20-dissector (ancien nom d'organisation : FOXNEOAdvancedTechnology, redirigé) |
| Commit importé | `a62b4b1e5475aa9d7047db4d2fef82a12e55b583` du 28/04/2020 |
| Licence amont | GPL-2.0-or-later (en-tête de `ST2110-20.lua` et README amont, « either version 2 of the License, or (at your option) any later version ») — compatible GPL-3.0-or-later ; pas de fichier de licence dans l'amont |
| Natif Wireshark 4.6.4 | non (aucun dissecteur ST 2110-20 natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: GPL-2.0-or-later` avec la provenance est ajoutée
(convention du dépôt, issue #563). L'amont ne fournit pas de texte de
licence séparé (avertissement attendu de `scripts/valider_imports.py`) ; le
texte de la GPLv2 est publié sur
https://www.gnu.org/licenses/old-licenses/gpl-2.0.html.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ST2110-20.lua` | Dissecteur `st_2110_20` : numéro de séquence étendu, puis pour chaque segment SRD la longueur, le champ (F), le numéro de ligne, la continuation et le décalage, et les données vidéo |

La capture d'écran `ScreenShot.png` de l'amont n'est pas importée.

## Utilisation

1. Copier `src/ST2110-20.lua` dans le dossier des plugins Lua de Wireshark
   (ex. `~/.local/lib/wireshark/plugins/`).
2. Préférences → Protocols → ST 2110_20 : indiquer le type de charge utile
   RTP dynamique du flux (valeur > 95).
3. « Decode As » des paquets UDP du flux en RTP.

En ligne de commande :
`tshark -r flux.pcap -d udp.port==5004,rtp -o st_2110_20.dyn_pt:96`.

## Vérification à l'import

Avec tshark 4.6.4, sur une capture synthétique (`text2pcap`, RTP type 96,
port 5004) : numéro de séquence étendu, longueur SRD, champ, ligne,
continuation, décalage et données vidéo décodés.

## Limites constatées à l'import

- un seul type de charge utile dynamique à la fois (préférence unique) ;
- le contrôle « SRD Segments length sum not n*180 - GPM » ne vaut que pour
  le cas d'un mode de paquetisation GPM (180 octets par groupe de pixels) ;
- pas d'interprétation des pixels (format d'échantillonnage, profondeur) :
  la charge vidéo reste brute ;
- dépôt amont sans activité depuis 2020.
