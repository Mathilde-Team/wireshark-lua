# LIFX (ampoules Wi-Fi, protocole v1 historique)

Dissecteur Wireshark en Lua du protocole LAN historique des ampoules Wi-Fi
LIFX (première génération, 2013) écrit lors de la rétro-ingénierie du
projet lifxjs : en-tête (taille, protocole, adresse cible et de site,
horodatage, type de paquet) et contenu d'une cinquantaine de types de
paquets (état et réglage de la lumière, alimentation, Wi-Fi, étiquettes,
horloge, version…), issue #159.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/magicmonkey/lifxjs |
| Commit importé | `cfb4814d447d119a4db410274499d8ee77f66d96` du 08/03/2015 (dernière modification de `wireshark/lifx.lua` : commit `42075d53237f65ea2b960c165da494648cd3511f` du 24/12/2013) |
| Licence amont | MIT (fichier `LICENSE` amont, © 2013 Kevin Bowman) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (aucun dissecteur LIFX natif) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: MIT` avec la provenance est ajoutée (convention du
dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/lifx.lua` | Protocole `lifx` sur les ports TCP et UDP 56700 ; en-tête de 36 octets puis contenu selon le type de paquet (Get/Set light state, Light status, Set power, Wifi state, Tags, Time, Version, Mesh info…) ; enchaîne plusieurs paquets LIFX d'un même segment |

## Utilisation

Le fichier date de Wireshark 1.x : il déclare des champs `ProtoField.bytes`,
`string`, `ether` et `float` avec `base.HEX` ou `base.DEC`, refusés par
Wireshark 4.x. Le chargement échoue alors (« bad argument #3 to 'bytes'
(Display must be either base.NONE, …) »).

Contournement sans modifier le fichier importé : créer dans le dossier des
plugins Lua personnels un fichier chargé avant lui (ordre alphabétique), par
exemple `00-lifx-cale.lua`, contenant :

```lua
for _, nom in ipairs({ "bytes", "string", "ether", "float" }) do
    local origine = ProtoField[nom]
    ProtoField[nom] = function(abbr, name, disp, desc, ...)
        if disp == base.HEX or disp == base.DEC then disp = base.NONE end
        if type(desc) == "table" then desc = nil end
        return origine(abbr, name, disp, desc, ...)
    end
end
```

puis copier `src/lifx.lua` dans le même dossier (ex.
`~/.local/lib/wireshark/plugins/`) et recharger (Ctrl+Maj+L). Cette cale
s'applique à tous les plugins Lua chargés après elle : ne la garder que pour
ce dissecteur.

Filtre d'affichage : utiliser les champs, par exemple `lifx.packetType`
(voir Limites).

## Vérification à l'import

Avec tshark 4.6.4, cale en place, sur des captures synthétiques (text2pcap,
UDP 56700) :

| Trame | Résultat |
|---|---|
| En-tête seul, type `0x0065` | Info « Get light state » |
| Type `0x006B` + contenu de 52 octets | Info « Light status » ; Target address `d0:73:d5:00:00:01`, Hue 21845, Saturation 65535, Brightness 32768, Colour temperature 3500, Power On (`0xffff`), Bulb name « Cuisine » ; `lifx.packetType == 0x6b` sélectionne la trame |

Sans la cale : erreur au chargement, trames affichées en `Data`.

## Limites constatées

- Protocole LIFX v1 (2013) : les ampoules actuelles utilisent le protocole
  LAN v2 (en-tête différent), qui n'est pas décodé correctement.
- L'arbre est ajouté sans référence au protocole (« LIFX packet ») : le filtre
  `lifx` ne sélectionne aucune trame et la colonne Protocole reste `UDP`/`TCP`.
- La cale retire les tables de valeurs passées aux champs `bytes` (ex.
  `securityProtocol`), non prises en charge par Wireshark 4.x.
- Pas de contrôle de longueur ; pas de réassemblage TCP.
- Non testé sur des captures réelles.
