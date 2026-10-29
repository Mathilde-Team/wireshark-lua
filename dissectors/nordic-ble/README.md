# Nordic BLE sniffer (nRF)

Dissecteur Wireshark Lua pour le protocole méta du sniffer BLE Nordic nRF : encapsulation des paquets sniffés (sync word, compteur UART, identifiants de paquets).

> **Obsolète** : Wireshark ≥ 2.4 dissèque nativement `nordic_ble` (configurer l'entrée User 10, DLT=157, de la table d'encapsulation DLT_USER). Ce Lua n'est utile que pour les versions 1.12.x à 2.3.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/tewarid/wireshark-nordic-ble-lua |
| Commit importé | `71116a48d947c55373fcbbf42198a9ee7992eacd` du 21/07/2017 (branche `master`) |
| Licence amont | GPLv2 (fichier `LICENSE`, sans clause « or later ») |
| Natif Wireshark 4.6.4 | Oui — `nordic_ble` natif depuis Wireshark 2.4 |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/nordic_ble.lua` | Dissecteur (12 Ko) : en-tête du sniffer, version du protocole, compteur de paquets |

Non importés : `README.md` (documentation, reprise ici), `.gitignore`.

## Utilisation

Copier `src/nordic_ble.lua` dans le dossier `plugins` de Wireshark (ex. `~/.config/wireshark/plugins/`) — ou l'appeler depuis `init.lua` via `dofile`. Requiert le dissecteur natif `btle` (Wireshark ≥ 1.12).

## Limites constatées à l'import

- portage Lua du dissecteur natif de Nordic : l'en-tête héritage (version 0.9.7) et le dissecteur `nordic_debug` ne sont pas portés (limites amont) ;
- fichier en fins de ligne CRLF côté amont (préservées).
