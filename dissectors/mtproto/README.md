# MTProto (Telegram)

Dissecteur Wireshark Lua pour MTProto 2.0, le protocole de Telegram : transports Abridged / Full / Intermediate / HTTP, dé-obfuscation, réassemblage TCP, déchiffrement avec auth key, et dissection des charges RPC en langage TL.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/tomer8007/mtproto-dissector |
| Commit importé | `8ddd78563f5419864d0c5758ae4ddc4121a574da` du 20/03/2026 (branche `master`) |
| Licence amont | GPLv2 (texte intégral, sans clause « ou toute version ultérieure ») |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur MTProto natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/mtproto.lua` | Dissecteur principal (2 134 lignes) : handshake obfusqué, messages de transport, RPC TL |
| `src/json.lua` | Décodeur JSON de rxi (MIT), utilisé pour lire les schémas TL |
| `src/schema/*.json` | Schémas TL (MTProto + couches API 216/218/220, erreurs) chargés au démarrage — 3,9 Mo au total |

Le dépôt amont contient aussi `auth_key_extraction/` (scripts Frida/Python d'extraction de clés d'authentification, hors périmètre Lua) et `screenshots/` : non importés.

## Utilisation

Copier le dossier `src/` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/mtproto/`) : `mtproto.lua` ouvre les schémas via un chemin relatif à son emplacement (`src/schema/…`). Le déchiffrement optionnel demande [luagcrypt](https://github.com/Lekensteyn/luagcrypt) + Libgcrypt, et les auth keys dans Préférences → Protocoles → MTProto. Pour la dé-obfuscation, la conversation TCP doit être capturée depuis le début.

## Limites constatées à l'import

- `mtproto.lua` construit les chemins de schémas avec un séparateur antislash (`schema\\…`), convention Windows : sous Linux/macOS il faut ajuster le chemin en `schema/…` (fichier amont importé tel quel, non corrigé) ;
- MTProto 2.0 uniquement, pas de WebSocket/Padded intermediate/UDP, TL non couvert à 100 % (limites amont, voir son README) ;
- les schémas JSON (`api_tl_schema_layer_216/218/220.json`) datent de l'import : les couches plus récentes demandent d'ajouter le fichier correspondant.
