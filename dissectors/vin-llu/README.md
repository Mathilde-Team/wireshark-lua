# VIN-LLU (robot humanoïde VIN v2)

Dissecteur Wireshark Lua du protocole UDP **VIN-LLU** (version 2) entre le
PC de test et la carte bas niveau (LLU, STM32) d'un robot humanoïde :
commandes et états des 32 moteurs, centrale inertielle, batteries,
branches d'alimentation, mains et LED (issue #99). Il reprend la logique
de l'outil de test WPF du même dépôt
(`Modules/ModuleNetwork/Models/NucProtocol.cs`, `PacketHeader.cs`,
`Packets.cs`).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/DinhNguyen34/tool-test-robot (`tools/wireshark/vin_llu_dissector.lua`) |
| Commit importé | `e71f4d3bffc0fa79ee7ce19aeadec60e9e4fa93b` du 07/09/2026 (dernier commit de la branche par défaut `main`) ; dernière modification du fichier : commit `bf19b9a1aa6d1d6aad46cb967fb09b8e45617c0f` du 29/08/2026 |
| Licence amont | MIT, « Copyright (c) 2026 DinhNguyen34 » (`LICENSE` du dépôt) — compatible avec la licence de ce dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur équivalent (`tshark -G protocols`), rien d'enregistré sur UDP 8888, 8889, 12345 et 12346 |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont). Le script est repris tel quel (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le reste du dépôt (application C#) et
ses bibliothèques ne sont pas importés ; aucune capture n'est fournie en
amont.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/vin_llu_dissector.lua` | Protocole `vinllu` (« VIN LLU Protocol ») : en-tête de 26 octets (marqueur `0xAA55`, version, type, carte, drapeaux, séquence, horodatage en µs, longueur), `LowCmd` / `LowState` (1 280 octets : 32 moteurs, IMU, 2 batteries, 6 branches), `HandCmd` / `HandState` (1 024 octets), `LedCmd` / `LedState` (48 octets), CRC-32 final recalculé et comparé |

## Utilisation

Copier `src/vin_llu_dissector.lua` dans le dossier des plugins Lua
personnels de Wireshark (« Aide › À propos de Wireshark › Dossiers »),
puis Ctrl+Maj+L. Le dissecteur s'attache aux ports UDP 8888, 8889, 12345
et 12346 et, sur les autres ports, à l'heuristique UDP (marqueur
`0xAA55` et version 2). Filtres : `vinllu`, `vinllu.msg_type`,
`vinllu.seq`, `vinllu.crc32_ok == 0`, `vinllu.motor.error_code != 0`…

## Vérification à l'import

Avec tshark 4.6.4, le script se charge sans erreur (52 champs
`vinllu.*`) et n'écrit aucune variable globale. Capture synthétique
construite selon `NucProtocol.cs` (CRC-32 MSB-first, polynôme
`0x04C11DB7`, calculé sur tout sauf les 4 derniers octets) :

| Trame | Résultat |
|---|---|
| `LowCmd` 1 280 octets | `LowCmd len=1280 seq=1` ; 32 moteurs (position, vitesse, couple, kp, kd) ; CRC OK |
| `LowState` 1 280 octets, moteur 3 en erreur `0x400` | `Motor[3] [ERROR 0x400]` avec information experte ; IMU (quaternion, gyroscope, accéléromètre), 2 batteries (tension 48,2 V, SoC, SoH, courant, température), 6 branches ; CRC OK |
| `HandCmd` 1 024 octets | côté, interface, 990 octets de données |
| `LedCmd` 48 octets | index, R, V, B, luminosité, mode |
| `LedCmd` avec CRC faux | `[CRC BAD]`, CRC annoncé et calculé affichés |
| type `0x42` inconnu | `Unknown(0x42)`, charge brute |
| `LowCmd` de 100 octets | en-tête et charge brute, sans erreur |
| 12 octets sur UDP 8888 | refusé, laissé à UDP |
| `LedState` sur UDP 9999 | reconnu par l'heuristique |

## Limites constatées

- Version 2 du protocole uniquement (l'heuristique exige la version 2).
- Charge des mains (`HandCmd` / `HandState`) affichée en bloc brut de
  990 octets.
- Les éléments du quaternion, du gyroscope et de l'accéléromètre sont
  tous libellés `quaternion[]`, `gyroscope[]`… sans indice.
- Signification des bits de `error_code` des moteurs non décodée (seul
  un renvoi vers les sources du micrologiciel est affiché).
- Les ports UDP 8888 et 12345, très courants, sont pris par défaut.
- Non testé sur des captures réelles.
