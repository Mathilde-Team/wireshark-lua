# Growatt v6 — PyGrowatt (onduleurs solaires)

Dissecteur Wireshark Lua du **protocole Growatt v6** (variante Modbus
propriétaire) échangé entre les onduleurs solaires Growatt équipés d'un
module ShineWiFi-X et leur serveur, sur TCP 5279. Le contenu est
désobscurci (XOR avec la clé `Growatt`) puis décodé selon le code
fonction : annonce (0x03), énergie (0x04), ping (0x16), configuration
(0x18), requête (0x19), énergie en tampon (0x50).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/aaronjbrown/PyGrowatt (fichier `scripts/Growatt.lua`) |
| Commit importé | `738c111a59afc2a2110b236fa7fa8a34be468a33` du 06/11/2022 (branche `master`, dernier commit ; dernière modification du dissecteur : `5bd15e0` du 28/05/2021) |
| Licence amont | BSD-3-Clause (`LICENSE` amont, © 2020 Aaron Brown ; pas d'en-tête de licence dans le fichier Lua) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Growatt natif |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `Growatt.lua` | Dissecteur `growatt` (TCP 5279) |

Fichier importé tel quel ; seule une en-tête SPDX + provenance de quatre
lignes a été ajoutée en tête du fichier.

## Utilisation

Copier `Growatt.lua` dans le dossier `plugins` de Wireshark
(ex. `~/.local/lib/wireshark/plugins/`), recharger les plugins Lua, puis
filtrer avec `growatt`.

## Remarques

- **`bit32` absent des Wireshark récents** : le désobscurcissement et la
  date de l'onduleur appellent `bit32.bxor` / `bit32.band` (7 appels),
  bibliothèque de Lua 5.2 absente de Lua 5.4, seule version prise en charge
  par Wireshark 4.6 (qui fournit `bit`). Sans `bit32` global, la dissection
  du contenu échoue ; contournement local : ajouter `bit32 = bit` en tête du
  script (non fait ici, fichier conservé tel quel ; non vérifié).
- **Conflit de nom** : `dissectors/wireshark-growatt/` (s'il est importé,
  issue #144) déclare aussi `Proto("growatt", …)` sur TCP 5279 ; ne charger
  qu'un des deux scripts à la fois.
- Pas de capture d'exemple amont ; non vérifié dans Wireshark.
