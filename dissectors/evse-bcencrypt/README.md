# OCPP 1.6J sur WebSocket, déchiffrement « bcencrypt » (bornes de recharge)

Dissecteur Wireshark en Lua du trafic OCPP 1.6J (Open Charge Point Protocol)
échangé en WebSocket par certaines bornes de recharge de véhicules
électriques, dont les messages sont masqués par un XOR à clé répétée
(« bcencrypt »). Le dissecteur affiche les données brutes (ASCII et
hexadécimal) et, si une clé est fournie, le message JSON OCPP déchiffré,
issue #156.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/aardbeiplantje/evse |
| Commit importé | `6e49e31326dc7efbe4320b1b0afd3cec0288a45f` du 08/10/2026 |
| Licence amont | Unlicense (fichier `LICENSE` amont, domaine public) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | non (WebSocket natif, sans OCPP ni déchiffrement bcencrypt) |

Fichier importé tel quel (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: Unlicense` avec la provenance est ajoutée
(convention du dépôt, issue #563).

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ws.lua` | Protocole `bcencrypt` : heuristique sur le dissecteur `ws` (accepte toutes les données WebSocket) et remplacement du dissecteur du port WebSocket 80 ; champs `bcencrypt.data` (ASCII), `bcencrypt.hex` et `bcencrypt.command` (JSON déchiffré avec la clé, ou données brutes sans clé) |

Non importés : les scripts Perl et shell du dépôt (extraction de la clé
`getkey.pl`, rapport `evse-report.pl`, `evse-ws-decrypt.sh`, etc.), hors
périmètre d'un dissecteur.

## Utilisation

Le script lit la clé XOR dans son premier argument : il doit être chargé en
ligne de commande, pas depuis le dossier des plugins (voir Limites).

```
tshark -r capture.pcap -X lua_script:src/ws.lua -X lua_script1:<clé> \
       -T fields -e bcencrypt.command
```

Même syntaxe `-X` pour `wireshark`. Sans `-X lua_script1:`, les messages sont
affichés tels quels (trafic non chiffré). La clé peut être retrouvée avec
`getkey.pl` du dépôt amont (non importé).

## Vérification à l'import

Avec tshark 4.6.4, sur une capture synthétique (text2pcap, TCP port 80 :
négociation HTTP Upgrade `ocpp1.6`, puis une trame WebSocket texte contenant
`[2,"1","Heartbeat",{}]` chiffré par XOR avec la clé `K1`), chargé par
`-X lua_script:` avec `-X lua_script1:K1` : trame `BCENCRYPT`,
`bcencrypt.command` = `[2,"1","Heartbeat",{}]`, `bcencrypt.hex` = données
chiffrées.

## Limites constatées

- Copié dans le dossier des plugins, le script reçoit de Wireshark 4.x son nom
  (`ws`) comme premier argument et l'utilise comme clé XOR :
  `bcencrypt.command` est alors illisible. Le charger uniquement avec
  `-X lua_script:` (et `-X lua_script1:<clé>`).
- L'heuristique accepte toutes les données WebSocket et masque les autres
  sous-dissecteurs WebSocket ; le port 80 est fixé dans le code.
- Le JSON OCPP n'est pas décodé champ par champ (chaîne unique).
- Non testé sur des captures réelles.
