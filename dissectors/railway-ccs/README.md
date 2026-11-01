# Railway CCS : RaSTA et SCI (signalisation ferroviaire)

Dissecteurs Wireshark Lua de protocoles du réseau de **signalisation
ferroviaire** (contrôle-commande, EULYNX) :

- **RaSTA** (Rail Safe Transport Application) : détection heuristique sur
  TCP et UDP, types de paquets (ConnReq/ConnResp, RetrReq/RetrResp,
  DiscReq, Heartbeat, Data, RetrData), contrôle de la somme CRC et du code
  de sûreté MD4 selon les préférences ;
- **SCI** (Standard Communication Interface) : SCI-P, SCI-LS et SCI-TDS
  (petit-boutiste uniquement), appelé sur la charge utile RaSTA.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Railway-CCS/dissectors |
| Commit importé | `8772051fa22e82850db17e3e95d726b2f63be313` du 09/08/2026 (branche `main`, dernier commit ; version 1.7.0) |
| Licence amont | MIT (`LICENSE` amont et en-têtes de `rasta.lua`, `sci.lua`) ; modules `bit_comp.lua`, `md4.lua`, `queue.lua`, `stream.lua` : MIT, © 2015 James L. (en-têtes des fichiers) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur RaSTA ou SCI natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier
(copie conforme de l'amont). Les modules de James L. portent leur propre
notice MIT dans leur en-tête.

## Fichiers

| Fichier | Rôle |
|---|---|
| `rasta.lua` | Dissecteur RaSTA (heuristique TCP/UDP), appelle `sci` sur les données |
| `sci.lua` | Dissecteur SCI (SCI-P, SCI-LS, SCI-TDS) |
| `rasta_modules/md4.lua`, `bit_comp.lua`, `queue.lua`, `stream.lua` | MD4 en Lua pur et utilitaires (James L.) |
| `rasta_modules/rasta_crc.lua` | Variantes CRC de RaSTA |
| `rasta_modules/test.lua` | Script de test amont du MD4 (hors Wireshark) |
| `captures/rasta_c_ESTW_C.pcapng` | Poste d'enclenchement de démonstration (ESTW) pilotant un signal : établissement, heartbeats, données, fermeture, deux canaux redondants |
| `captures/rasta_from_standard.pcapng` | Six heartbeats tirés de la norme RaSTA (code de sûreté et IV MD4 variés) |
| `captures/sci_tds_test_data.pcapng` | Messages et commandes SCI-TDS de test |

Fichiers importés tels quels (`dissectors/` et `dumps/` amont) ; seule une
en-tête SPDX + provenance de quatre lignes a été ajoutée en tête de chaque
fichier `.lua`. Le profil Wireshark amont (`profiles/RaSTA/`) et les
fichiers d'outillage ne sont pas importés.

## Utilisation

Copier `rasta.lua`, `sci.lua` et le dossier `rasta_modules/` dans le
dossier `plugins` de Wireshark (ex. `~/.local/lib/wireshark/plugins/`),
puis recharger les plugins Lua. Pour `rasta_c_ESTW_C.pcapng`, l'amont
indique de régler : RaSTA « CRC Type » = Option A (aucun), « Safety Code »
= moitié basse, MD4 IV par défaut, pas de « Payload Packetization » ; SCI
« Message Type Endianess » = Big Endian.

## Remarques

- `rasta.lua` charge ses modules par `require("md4")`, `require("stream")`,
  `require("rasta_crc")` sans préfixe : le dossier `rasta_modules/` doit
  figurer dans `package.path` (Wireshark y ajoute les sous-dossiers du
  dossier des plugins ; non vérifié).
- Wireshark charge aussi comme greffons les modules du sous-dossier, dont
  `test.lua`, qui affiche des résultats de test MD4.
- Décodage non vérifié dans Wireshark.
