# Conitel et MD3 (opendatacon)

Dissecteurs Wireshark Lua de deux protocoles de télécontrôle SCADA
propriétaires, livrés avec la passerelle opendatacon (issue #72) :

- **Conitel** (Conitel 2020 / Baker), port `CBPort` d'opendatacon : messages
  en blocs de 32 bits protégés par un code BCH sur 5 bits ;
- **MD3** (Harris / GE), port `MD3Port` : messages en blocs de 6 octets
  (4 octets de données, octet de contrôle avec bits FMT/EOM et CRC sur
  6 bits, octet de bourrage nul).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/neilstephens/opendatacon (`Code/Ports/CBPort/conitel.lua`, `Code/Ports/MD3Port/md3.lua`) |
| Commit importé | `3b6049801563aac799b852524b24be01d9b80260` du 21/09/2026 (dernier commit de la branche par défaut `develop`) ; dernières modifications : `conitel.lua` commit `5dd6a01cbb2e7ffd7845b2b072832b1edcf2e5bf` du 03/08/2025, `md3.lua` commit `051240cfc4939af75d20a1d41b626b2d9c7287d2` du 07/11/2022 |
| Licence amont | Apache-2.0 (`LICENSE.txt` du dépôt ; les deux scripts n'ont pas d'en-tête propre) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Conitel, Baker ou MD3 (`tshark -G protocols`) |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE.txt` amont). Le `NOTICE.txt` amont ne concerne que des
bibliothèques C++ tierces embarquées (jsoncpp, etc.), pas ces scripts.

Les scripts sont repris tels quels (aucune modification de code) ; seule
l'en-tête de provenance est ajoutée en tête (convention du dépôt, issue
#563). Le reste d'opendatacon (C++) n'est pas importé ; aucune capture
n'est fournie en amont.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/conitel.lua` | Protocole `conitel` (« Conitel Protocol »), heuristique TCP : fonction, station, groupe, nombre de blocs, valeurs 1B puis 2A/2B… sur 12 bits, numéro de canal pour Trip/Close, enregistrements SOE pour la fonction 10 (« Send New SOE ») |
| `src/md3.lua` | Protocole `md3` (« MD3 Protocol »), heuristique TCP : fonction (≈ 45 codes nommés), station, sens maître/esclave, module, nombre de modules, numéro de séquence, blocs avec FMT/EOM et contrôle CRC, décodage des blocs DCOS de la fonction 11 |

## Utilisation

Copier le ou les fichiers de `src/` dans le dossier des plugins Lua
personnels de Wireshark (« Aide › À propos de Wireshark › Dossiers »),
puis Ctrl+Maj+L. Les deux dissecteurs sont heuristiques sur TCP : aucun
port à configurer. Les ports opendatacon étant souvent multiples, activer
au besoin « Essayer d'abord les sous-dissecteurs heuristiques » dans les
préférences TCP.

Filtres : `conitel` (champs `conitel.function`, `conitel.station`,
`conitel.group`, `conitel.blockcount`, `conitel.data`, `conitel.soedata`)
et `md3` (`md3.function`, `md3.station`, `md3.mtos`, `md3.module`,
`md3.modulecount`, `md3.md3seq`, `md3.taggedcount`, `md3.data`,
`md3.flags`).

**MD3 sous Wireshark 4.x** : `md3.lua` utilise la bibliothèque `bit32`,
absente de la Lua 5.4 des Wireshark récents (erreur « attempt to index a
nil value (global 'bit32') » sur chaque paquet TCP). Contournement sans
modifier le script : un fichier chargé avant lui (par exemple
`00_bit32.lua` dans le même dossier) contenant

```lua
_G.bit32 = _G.bit32 or bit
```

(`_G` est nécessaire : chaque script Lua a son propre environnement ;
`bit32 = bit` seul est sans effet sur les autres scripts.)

## Vérification à l'import

Avec tshark 4.6.4, les deux fichiers se chargent sans erreur
(`luac5.4 -p` : OK). Captures synthétiques fabriquées à partir des
algorithmes des scripts (BCH Conitel, table CRC MD3), eux-mêmes contrôlés
sur des blocs des tests amont (`CBTest.cpp` : `22290030`, `08080029`,
`0937ffaa`… ; `MD3Test.cpp` : `c406400f0b00`, `d41f00103c00`…) :

| Trame | Résultat |
|---|---|
| Conitel « Master Station Request » (fn 9), station 3, groupe 3 | `conitel.function` 9, station 3, groupe 3, 1 bloc ; Info `Stn: 3 Grp: 3 Fn: Master Station Request 1B:0x000` |
| Conitel « Scan Data » sur 2 blocs | 1B `0x123`, 2A `0x456`, 2B `0x789` |
| Conitel « Trip », 1B `0x800` | « Conitel Channel 01 » |
| Conitel 4 octets nuls | rejeté (bit EOM absent), reste en TCP |
| MD3 « Analog Unconditional » maître puis réponse esclave sur 3 blocs | fonction 5, station `0x7c`, `md3.mtos` True/False, module `0x20` ; blocs « FMT », « EOM », « CRC PASS » |
| MD3 « Digital COS Time Tagged » (fn 11) maître puis esclave | numéro de séquence, nombre de modules, bloc de données DCOS décodé (adresse, décalage ms, `0xAA55`) |
| 5 octets quelconques | rejeté (pas un multiple de 6) |

MD3 vérifié avec le contournement `bit32` ci-dessus ; sans lui, aucune
trame n'est décodée.

Aucun faux positif sur les quatre captures du dépôt.

## Limites constatées

- `md3.lua` : dépendance à `bit32` (voir Utilisation).
- Heuristiques larges : toute charge TCP de 4 à 64 octets multiple de 4
  dont les bits A/B/EOM et le BCH sur 5 bits concordent est prise pour du
  Conitel (de l'ordre d'un segment de 4 octets aléatoire sur 256) ; MD3 est
  plus strict (octet de bourrage nul, CRC du premier bloc). Les deux
  marquent ensuite toute la conversation (`pinfo.conversation`).
- Un segment est traité comme un seul message : pas de découpage de
  plusieurs messages ni de réassemblage ; MD3 ne vérifie le CRC que du
  premier bloc pour l'acceptation.
- Arbre MD3 : l'élément « Decode DCOS » s'affiche `<MISSING>` (champ
  `bytes` ajouté sans valeur) ; l'adresse étendue (station `0x7F`) n'est
  pas décodée (`stationleaf.append_text` appelé avec `.` au lieu de `:`,
  donc erreur Lua sur ce cas).
- Conitel : l'adressage étendu n'est pas décodé ; les SOE de la fonction 11
  (« Repeat SOE ») ne sont pas détaillés.
- Variables globales (`BCH`, `functionnames`, `fcstab`, `CheckMD3CRC`,
  fonctions `Get*`, `DecodeSOERecord`, `dcosbuffer`…) : risque de collision
  avec d'autres scripts Lua.
- Non testé sur des captures réelles.
