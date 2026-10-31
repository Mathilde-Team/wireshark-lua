# AgOpenGPS

Dissecteur Wireshark Lua du protocole UDP d'[AgOpenGPS](https://github.com/AgOpenGPS-Official/AOG-TaskController)
(agriculture de précision) : trames AgIO/AgOpenGPS échangées avec les modules
de guidage et avec AOG-TaskController, le contrôleur de tâches ISOBUS
(ISO 11783-10) construit sur AgIsoStack++ (issue #61).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/AgOpenGPS-Official/AOG-TaskController |
| Commit importé | `4af9d6f060750c43c0670c7eeaa6edb2f816e1a6` du 18/10/2026 (dernier commit de `develop`) |
| Licence amont | GPL-3.0 (`LICENSE` amont, sans mention « or later » dans le dépôt, d'où `GPL-3.0-only`) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur AgOpenGPS natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/AOGDissector.lua` | Trois protocoles : `AgOpenGPS` (UDP 9999) décode l'en-tête AgIO (`0x80 0x81`, PGN majeur et mineur), les phrases PANDA, les données de direction (Steer module, From AutoSteer), l'état des sections et les messages libres ; `AgOpenGPSRTCM` (UDP 2233) étiquette les corrections RTCM/NTRIP sans les décoder ; `ISOBUSVT` (non enregistré par l'amont) |

Le fichier est repris tel quel (fins de ligne CRLF de l'amont conservées),
avec l'en-tête de provenance ajouté. Le reste du dépôt amont (contrôleur C++,
bibliothèques, outils) n'est pas importé. La référence du protocole se trouve
dans `docs/PROTOCOL.md` de l'amont.

## Utilisation

Copier `src/AOGDissector.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.config/wireshark/plugins/`). Filtres : `AgOpenGPS`, `AgOpenGPSRTCM`.

## Limites constatées à l'import

- **ports codés en dur** : 9999 (diffusion vers AgIO) et 2233 (RTCM). Le trafic
  émis vers les modules sur le port 8888 (`docs/PROTOCOL.md` amont) n'est
  décodé qu'avec « Decode As… » ; l'enregistrement d'`ISOBUSVT` sur 8888 est
  commenté par l'amont ;
- **`ISOBUSVT` inachevé** : la boucle des sections concatène `sectionLabel`,
  une variable jamais définie (son calcul est commenté). Activer ce protocole
  à la main provoque une erreur Lua sur les trames `0x70/0x00` ;
- protocoles et tables globaux (`AOGProtocol_proto`, `RTCMProtocol_proto`,
  `ISOBUS_proto`) ; `print` de débogage dans `ISOBUSVT` ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
