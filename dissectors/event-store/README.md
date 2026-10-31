# Event Store

Dissecteur Wireshark Lua pour [Event Store](https://www.eventstore.com/)
(base de données événementielle, protocole TCP binaire + protobuf) (issue
#459).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/x-cubed/event-store-dissector |
| Commit importé | `fb3dcff34e86f20c8852809587ec774045cea0c8` du 25/04/2018 |
| Licence amont | Unlicense (`LICENSE` amont, domaine public) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Event Store natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/event-store.lua` | Dissecteur du protocole TCP d'Event Store (port 1113 par défaut) : en-tête, commandes, messages protobuf |
| `src/files/ClientMessageDtos.proto` | Schéma protobuf des messages clients Event Store (référence) |

Le dissecteur s'appuie sur le plugin protobuf de Wireshark (`dex/protobuf`
dissector) pour décoder les charges : le schéma doit être enregistré côté
Wireshark (voir Utilisation).

## Utilisation

Copier `src/event-store.lua` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Pour décoder les messages protobuf, enregistrer
`ClientMessageDtos.proto` dans les préférences du dissecteur protobuf de
Wireshark (Protobuf → Protobuf search paths) et charger le fichier dans le
dossier de recherche.

## Limites constatées à l'import

- dépend du plugin protobuf de Wireshark (message d'expert amont si absent) ;
- le dissecteur amont date de 2018 : les versions récentes du protocole Event
  Store (TCP v3, gRPC en 23.x+) ne sont pas couvertes.
