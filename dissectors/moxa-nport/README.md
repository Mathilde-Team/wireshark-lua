# Moxa NPort (CONF et CTRL)

Dissecteur Wireshark Lua de deux protocoles des serveurs série Ethernet
**Moxa NPort** (issue #97) :

- `moxa_conf` — protocole de configuration et de découverte sur UDP 4800
  (identification, nom d'hôte, version, réseau, DNS, SNMP, courriel,
  réglages des ports, filtrage IP, événements) ;
- `moxa_ctrl` — canal de contrôle d'un port série (mode « Real COM »,
  ASPP) sur TCP 966 à 981 : débit, contrôle de flux, état de ligne,
  BREAK, initialisation de port.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/BobHollywood/MoxaNPort (`nport.lua`) |
| Commit importé | `70df6619edf02983b3b952e1aa5c6811825de4f4` du 14/02/2025 (dernier commit de la branche par défaut `main`, qui est aussi la dernière modification de `nport.lua`) |
| Licence amont | Apache-2.0 (`LICENSE` du dépôt, sans fichier `NOTICE`) — compatible avec la licence de ce dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Moxa (`tshark -G protocols`), rien d'enregistré sur UDP 4800 ni TCP 966 à 981 |

Texte complet de la licence : fichier `LICENSE` de ce dossier (copie
conforme du `LICENSE` amont). Le script est repris tel quel (aucune
modification de code) ; seule l'en-tête de provenance est ajoutée en tête
(convention du dépôt, issue #563). Le dépôt amont ne fournit aucune
capture.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/nport.lua` | Protocoles `moxa_conf` (champs `mconf.*` : commande et bit requête/réponse, longueur, ligne de produit, modèle, MAC, IP, masque, passerelle, DNS, version logicielle, numéro de série, nom d'hôte, SNMP, courriel, ports de contrôle et de données, 16 entrées d'IP autorisées, événements) et `moxa_ctrl` (`mctrl.cmd`, `mctrl.len`, `mctrl.unknown`) |

## Utilisation

Copier `src/nport.lua` dans le dossier des plugins Lua de Wireshark
(« Aide › À propos de Wireshark › Dossiers »), puis Ctrl+Maj+L. Filtres :
`moxa_conf`, `moxa_ctrl`, `mconf.cmd`, `mconf.mac`, `mconf.hostname`,
`mctrl.cmd`…

## Vérification à l'import

Avec tshark 4.6.4, le script se charge sans erreur (43 champs `mconf.*`
et `mctrl.*`). Capture synthétique :

| Trame | Résultat |
|---|---|
| UDP 4800 requête `0x01` puis `0x10` | `[REQ 01], Ident` ; `[REQ 10], Identify`, ligne de produit, modèle, MAC |
| réponse `0x90` (renvoyée vers un port client quelconque) | `Hostname: NP5210_lab` (la conversation est reconnue) |
| réponse `0x96` | `Get Product Details, SW: 03.10`, numéro de série 4242 |
| réponse `0xA6` | IP `192.168.1.10`, masque, passerelle |
| réponse `0xD1` | 16 entrées d'IP autorisées (activée / désactivée, IP, masque) |
| réponse `0xD2` | bits d'événements courriel et trap décodés |
| réponse `0x90` tronquée | erreur Lua « Range is out of bounds » (ligne 263 de `src/nport.lua`, 258 en amont) |
| TCP 966 `Set Baud` (`0x17`, longueur 4) puis réponse `OK` | `[C->S]` ; `[S->C], OK` |
| TCP 966 réponse `Line Status` (`0x13`) | longueur et octets bruts |
| TCP 12345 « hello world » (11 octets, sans le script : TCP brut) | capté à tort : `MOXA_CTRL [S->C]`, commande `0x68` inconnue |
| HTTP 80 (18 octets), UDP 5353 | non touchés (dissecteurs de port prioritaires) |

## Limites constatées

- Heuristique TCP très large : tout segment TCP de 20 octets ou moins sur
  un port sans dissecteur est décodé comme `MOXA_CTRL`, et la
  conversation est ensuite rattachée à `moxa_ctrl`. Désactiver
  l'heuristique « moxa_ctrl » (« Analyse › Protocoles activés ») si
  besoin.
- `moxa_ctrl` : seules les charges de 20 octets au plus sont décodées ;
  le sens est déduit du port de destination (966 à 981).
- `moxa_conf` : l'heuristique UDP exige le port de destination 4800 ; le
  port 1029 des anciens modèles, la mise à jour de micrologiciel (4900)
  et les ports de données (950 à 965) ne sont pas pris en charge (TODO
  amont). La longueur annoncée n'est pas vérifiée : une trame tronquée
  provoque une erreur Lua.
- Réponse `0x9D` : seuls 20 octets sont affichés alors que le décalage
  avance de 208 (faute de frappe probable en amont, sans effet visible
  car rien ne suit).
- `mc_dnsgateway_f`, référencé dans la liste des champs, n'est pas
  défini (valeur `nil` sans conséquence au chargement).
- Variables globales : `moxa_conf`, `moxa_ctrl`, `append_pinfo`,
  `heur_dissect_moxa_conf`, `heur_dissect_moxa_ctrl`.
- Enregistrement superflu sur le port UDP 0.
- Non testé sur des captures réelles.
