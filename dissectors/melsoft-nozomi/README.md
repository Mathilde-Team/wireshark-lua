# MELSOFT — automates de sécurité iQ-R (Nozomi Networks)

Dissecteur Wireshark Lua du protocole **MELSOFT** de Mitsubishi Electric
(dialogue entre l'atelier logiciel, ex. GX Works3, et les automates MELSEC),
centré sur les phases d'authentification et d'autorisation des automates de
sécurité iQ-R Safety. Une section « Expert » signale les échanges liés à
CVE-2021-20594, CVE-2021-20597, CVE-2021-20598, CVE-2021-20599 et
NN-2021-0019 (issue #67). Publié avec la conférence Black Hat MEA 2023
« Safety is not Security » de Nozomi Networks.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/NozomiNetworks/blackhat23-melsoft |
| Commit importé | `b981e723471cb740713d8acdc83462a315ee333c` du 11/11/2023 (dernier commit de la branche par défaut `main`) |
| Licence amont | BSD-3-Clause (`LICENSE` amont, © 2023 Nozomi Networks) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur natif équivalent (`tshark -G protocols`) |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont). Il couvre aussi les captures.

Le script est repris tel quel (fins de ligne CRLF de l'amont conservées),
avec l'en-tête de provenance ajouté (convention du dépôt, issue #563). Le
`README.md` amont et ses captures d'écran ne sont pas importés.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/melsoft_bhmea2023.lua` | Protocole `melsoft` (« Mitsubishi Electric MELSOFT Protocol ») sur TCP 5007 : octets magiques `0x5701` (requête) et `0xd700` (réponse), découpage en en-tête Ethernet MELSOFT, en-tête de commande, données de commande et pied ; détail des commandes `0x0131` Username Login, `0x0132` Password Login, `0x0134` Read User Information from PLC B et `0x1133` User Information Registration ; autres codes de commande nommés sans détail ; alertes « Expert » par CVE |
| `captures/legitimate_user_addition_plc_stop_test.pcapng` | Capture amont : enregistrement d'un utilisateur, arrêt à distance, passage du mode sécurité en test (actions légitimes) |
| `captures/cve_2021_20594_username_bruteforce.pcapng` | Capture amont : force brute sur le nom d'utilisateur (CVE-2021-20594) |
| `captures/cve_2021_20598_20599_nn_2021_0019_attack_demo_1.pcapng` | Capture amont : démonstration n° 1 de la conférence (rejeu du jeton, désactivation des routines de sécurité, verrouillage de l'automate) |

## Utilisation

Copier `src/melsoft_bhmea2023.lua` dans le dossier des plugins Lua
personnels de Wireshark (ex. `~/.config/wireshark/plugins/`), puis
Ctrl+Maj+L. Filtre d'affichage : `melsoft`, champs `melsoft.*` ; alertes
dans « Analyse › Informations expertes ».

## Vérification à l'import

Avec tshark 4.6.4 (`tshark -X lua_script:src/melsoft_bhmea2023.lua -r <capture>`),
le script se charge sans erreur et décode les trois captures amont :

| Capture | Trames MELSOFT / total | Alertes CVE relevées |
|---|---|---|
| `cve_2021_20594_username_bruteforce` | 18 / 36 | 9 requêtes Username Login ; 8 réponses « wrong username », 1 « correct username » (CVE-2021-20594) |
| `cve_2021_20598_20599_nn_2021_0019_attack_demo_1` | 160 / 456 | 10 Password Login (6 « wrong password », 1 « wrong password and PLC locked », 3 « correct password ») (CVE-2021-20598) ; 3 requêtes avec jeton d'autorisation (CVE-2021-20599) ; Read User Information from PLC B (NN-2021-0019) ; 4 Username Login |
| `legitimate_user_addition_plc_stop_test` | 1494 / 1905 | 2 User Information Registration (CVE-2021-20597) ; 9 requêtes avec jeton (CVE-2021-20599) ; 2 Username/Password Login ; 2 Read User Information from PLC B |

Les alertes sont des signalements « peut être légitime ou une tentative
d'exploitation » : elles marquent les échanges sensibles, pas une attaque
avérée (cf. la capture légitime).

## Limites constatées

- Incompatible avec l'autre import MELSOFT du dépôt,
  [`dissectors/melsoft/`](../melsoft/README.md) (issue #82, louislau86) : les
  deux scripts déclarent un protocole nommé `melsoft` / `MELSOFT`, et
  Wireshark refuse de charger le second (« Proto_new: there cannot be two
  protocols with the same name »). N'en installer qu'un à la fois : celui-ci
  pour l'authentification et les alertes de sécurité, l'autre pour la
  lecture/écriture de périphériques.
- Port TCP 5007 codé en dur ; MELSOFT sur UDP 5006 n'est pas enregistré.
- Seules quatre commandes sont détaillées ; les autres sont seulement
  nommées (ex. `0x0410` Modify Value) ou affichées par leur seul code
  (ex. `0x0411`, `0x0162`).
- Les condensats de mot de passe (`SHA256(Password)` de `0x1133`,
  `SHA256(Username Token + SHA256(Password))` de `0x0132`) sont affichés en
  octets bruts ; les captures fournies en contiennent (laboratoire de
  l'amont, publiées par lui).
- Variables et fonctions globales (`setDefault`, `proto_melsoft`,
  tables de champs) : risque de collision avec d'autres scripts Lua.
- Protocole issu de rétro-ingénierie (précision de l'amont) ; pas testé
  sur d'autres automates que la gamme iQ-R Safety des captures.
