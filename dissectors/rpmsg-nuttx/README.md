# RPMsg (NuttX / openvela) — traces de messagerie interprocesseur

Dissecteur Wireshark en Lua des traces RPMsg (messagerie interprocesseur
d'OpenAMP) produites par NuttX dans openvela : en-tête RPMsg (source,
destination, longueur, drapeaux) et services `PING`, `NS` (annonce de noms),
`SOCKET`, `TEST` et `FS` (système de fichiers distant : open, close, read/write,
fstat…) (issue #385).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/open-vela/nuttx (fichier `tools/rpmsg_protocal.lua`) |
| Commit importé | `9eb6537886a576edf35402e72a410de4ec570b8c` du 27/10/2026 (dernier commit de `dev`, branche par défaut) ; fichier ajouté par `7fc1620c9858a42d1216d93a0e9bac5c4e3a4e75` du 13/08/2025 (mazhuang), inchangé depuis |
| Licence amont | Apache-2.0 (en-tête ASF du fichier ; `LICENSE` du dépôt) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur RPMsg natif (pas de `packet-rpmsg*.c` ni de mention dans `epan/dissectors/CMakeLists.txt` sur `release-4.6`) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (texte
Apache-2.0 de référence, https://www.apache.org/licenses/LICENSE-2.0.txt,
auquel renvoie l'en-tête du fichier ; le `LICENSE` amont, de 417 Ko, y ajoute
les licences de composants tiers de NuttX sans rapport avec ce fichier). Le
fichier `NOTICE` amont, auquel renvoie l'en-tête, est copié tel quel.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/rpmsg_protocal.lua` | Protocole `rpmsg_trace`, enregistré dans `wtap_encap` sous 147 (DLT `USER0`) ; champs `rpmsg.*` |
| `NOTICE` | Avis NOTICE d'Apache NuttX (copie conforme) |

Fichier repris tel quel (nom amont conservé, « protocal » compris), en-tête de
provenance ajouté. Le reste du dépôt (système d'exploitation NuttX) est hors
périmètre.

## Utilisation

1. Copier `src/rpmsg_protocal.lua` dans le dossier des plugins Lua de Wireshark.
2. Ouvrir une trace RPMsg de NuttX enregistrée en DLT 147 (`USER0`). Si elle
   n'est pas reconnue, associer le DLT au protocole dans Préférences ›
   Protocols › DLT_USER (`User 0 (DLT=147)` → `rpmsg_trace`), comme l'indique
   l'en-tête amont.
3. Filtres : `rpmsg_trace`, `rpmsg.src`, `rpmsg.dst`, `rpmsg.fs.header.command`…

## Limites constatées à l'import

- format de trace propre à NuttX/openvela (pas de capture RPMsg « sur le fil ») ;
  services décodés limités à ceux listés par `rpmsg.service_type` ;
- enregistrement sur DLT 147 (`USER0`), partagé avec tout autre usage local de
  ce DLT ;
- noms de champs `rpmsg.*` différents du nom du protocole (`rpmsg_trace`) ;
- pas de capture d'exemple : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée.
