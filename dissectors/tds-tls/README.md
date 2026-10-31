# TDS TLS (SQL Server)

Dissecteur Wireshark Lua qui met en évidence les informations TLS du
protocole TDS ([SQL Server](https://learn.microsoft.com/sql/relational-databases/azure-data-studio/?view=sql-server-ver17)),
notamment le premier octet du flux (packet type TDS) et la présence d'une
charge TLS (handshake Pre-Login) (issue #464).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/sharzas/Wireshark-TDS_TLS_Dissector |
| Commit importé | `ebf78c5fe1c0988207ccb57e3617b6fb46c1103e` du 26/09/2022 |
| Licence amont | GPLv3 (`LICENSE` amont, sans clause « ou toute version ultérieure ») |
| Natif Wireshark 4.6.4 | Partiellement — le dissecteur TDS natif (packet-tds.c) existe et décode TCP 1433, mais n'expose pas ces champs TLS spécifiques |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont). La licence GPLv3 est conservée telle quelle (en-tête
SPDX `GPL-3.0-only`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/TDS_TLS_Dissector.lua` | Dissecteur TDS TLS : s'enregistre sur TCP 1433 en remplacement du dissecteur TDS natif et affiche le statut TLS (premier octet, charge TLS) |

## Utilisation

Copier `src/TDS_TLS_Dissector.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Le dissecteur remplace le dissecteur natif
sur le port TCP 1433 et affiche les informations TLS du flux TDS.

## Limites constatées à l'import

- remplace le dissecteur TDS natif sur le port 1433 (le décodage TDS complet
  du natif n'est plus disponible pour ces paquets) ;
- ne décode pas le contenu du TLS (chiffrement de bout en bout).
