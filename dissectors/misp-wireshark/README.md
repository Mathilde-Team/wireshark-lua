# MISP — export de données Wireshark vers le format MISP

Plugin Wireshark en Lua qui extrait des données de la capture et les convertit
au format MISP Core (JSON) : `network-connection` (TCP), `http-request`
(TCP/HTTP, charges utiles incluses) et `dns-record` (UDP/DNS). Ce n'est pas un
dissecteur : il ne décode pas de protocole, il exporte vers MISP. Dans
Wireshark, menu `Tools → MISP: Export to MISP format` ; en ligne de commande
avec tshark (`-X lua_script…`). `community-id` nécessite Wireshark ≥ 3.3.1
(protocole CommunityID activé dans `Analyze/Enabled Protocols`).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/MISP/misp-wireshark |
| Commit importé | `be6d89df62503465d9b92e6839612111ea8fc068` du 23/10/2023 (branche `main`, dernier commit du dépôt, inactif depuis) |
| Sous-module `lib/LuaMISP` | https://github.com/MISP/LuaMISP, commit `bd80c85bf22c5117b3946fd1b29ceb51fa26677e` du 21/02/2022 (épinglé par l'amont) |
| Licence amont | plugin : Affero GPL v2, déclarée dans les métadonnées du plugin (`license = "AGPLv2"`), sans fichier LICENSE amont ; LuaMISP : MIT ; détails par fichier ci-dessous |
| Natif Wireshark 4.6.4 | sans objet (exporteur, pas un dissecteur) |

Fichiers importés tels quels (aucune modification de code), structure amont
conservée : le plugin fait `require 'lib.LuaMISP.LuaMISP'`, l'arborescence
`lib/LuaMISP/` doit donc rester à côté de `misp-wireshark.lua`. Seule une
en-tête `SPDX-License-Identifier` avec la provenance est ajoutée à chaque
fichier (convention du dépôt, issue #563).

Note de licence : l'Affero GPL v2 (2007, publiée par AFFERO) est une licence
copyleft libre, mais non compatible GPL-3.0. Les fichiers concernés sont
importés tels quels et gardent leur licence d'origine (SOCLE.md §1 : un code
dérivé garde la licence de son projet d'origine) ; aucun code de l'équipe n'est
combiné avec eux. L'amont ne fournit pas de texte de licence pour le plugin :
le texte officiel n'est plus distribué par affero.org (`oagpl.html`, page
disparue). Le fichier `LICENSE` de ce dossier est celui de LuaMISP (MIT, copie
conforme de l'amont).

## Fichiers

| Fichier | Licence | Rôle |
|---|---|---|
| `misp-wireshark.lua` | AGPL v2 | point d'entrée : menus Wireshark, options (filtre, charges HTTP, chemin d'export, tags), export JSON |
| `mispHelper.lua` | AGPL v2 | construction des objets MISP (`network-connection`, `http-request`, `dns-record`) |
| `mispWiresharkUtils.lua` | AGPL v2 | utilitaires : copie profonde, sauvegarde de fichier |
| `lib/LuaMISP/LuaMISP.lua` | MIT | bibliothèque de création d'entités MISP (Event, Object, Attribute, Tag, ObjectReference) |
| `lib/LuaMISP/utils.lua` | MIT | agrégation des utilitaires (JSON, UUID, base64) |
| `lib/LuaMISP/test.lua` | MIT | test amont de la bibliothèque |
| `lib/LuaMISP/utils/base64.lua` | domaine public | encodage/décodage base64 (v1.5.3) |
| `lib/LuaMISP/utils/uuid.lua` | Apache-2.0 | génération d'UUID |
| `lib/LuaMISP/utils/lunajson.lua`, `utils/lunajson/*.lua` (4 fichiers) | MIT | encodeur/décodeur JSON de la bibliothèque lunajson (projet rxi/grafi-tt) |

Non importés : `doc/pictures/` (captures d'écran du README amont), le
`README.md` amont (documentation remplacée par ce README), `.gitmodules` (le
sous-module est importé directement à son commit épinglé) et `lib/empty/`
(dossier vide de l'amont).

## Utilisation

Copier ce dossier dans le dossier `plugins` de Wireshark (ex.
`~/.local/lib/wireshark/plugins/misp-wireshark/`), puis menu `Tools → MISP:
Export to MISP format`. En ligne de commande (tshark) :

```bash
tshark -r capture.pcap \
    -X lua_script:misp-wireshark.lua \
    -X lua_script1:filters="ip.addr == 127.0.0.1" \
    -X lua_script1:include_payload=n \
    -X lua_script1:tags="tlp1,tlp2" \
    frame.number == 0
```

Sans chemin d'export, le JSON MISP est imprimé sur la sortie standard ; le
filtre `frame.number == 0` donné à tshark ne sert qu'à silencer la sortie de
tshark (le plugin n'utilise que le filtre passé par `-X lua_script1:filters`).
