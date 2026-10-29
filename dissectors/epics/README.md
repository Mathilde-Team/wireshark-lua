# EPICS — Channel Access (CA) et PV Access (PVA)

Dissecteur Wireshark Lua pour les protocoles EPICS : CA (Channel Access) et
PVA (PV Access), utilisés pour le contrôle-commande d'accélérateurs de
particules et d'instruments scientifiques. Le dissecteur CA fait le
réassemblage TCP des messages volumineux ; le dissecteur PVA décode aussi
PVA sur TLS via ALPN.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/mdavidsaver/cashark |
| Commit importé | `20ffcc19b5576d40ff4c9074b36f1a6031f5982e` du 23/08/2025 (branche `master`) |
| Licence amont | BSD-3-Clause (fichier `LICENSE` amont : Regents of the University of California) — compatible GPL-3.0-or-later |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur EPICS (CA/PVA) natif dans Wireshark |

Texte complet de la licence amont : fichier `LICENSE` de ce dossier (copie
conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/ca.lua` | Dissecteur Channel Access : trafic UDP et TCP sur les ports standard 5064 et 5065, réassemblage TCP des messages volumineux |
| `src/pva.lua` | Dissecteur PV Access : trafic sur les ports standard TCP 5075 et UDP 5076 (et ports non standard), y compris PVA dans TLS via ALPN |

Le dépôt amont contient aussi `test/` (captures de test, dont certaines
compressées), `test-all.sh`, `.github/workflows/test.yml` et `.gitattributes` :
non importés ici (le dépôt ne collecte que les scripts Lua).

## Utilisation

Copier `src/ca.lua` et/ou `src/pva.lua` dans le dossier `plugins` de
Wireshark (ex. `~/.local/lib/wireshark/plugins` sous Linux), ou lancer
`wireshark -X lua_script:/chemin/ca.lua -X lua_script:/chemin/pva.lua`.
Le script chargeur affiche « Loading CA... » / « Loading PVA... » sur stderr.

## Limites constatées à l'import

- CA ne distingue pas client et serveur sans observer le début de la
  connexion : seuls certains messages sont décodés complètement, les autres
  avec des noms de champs génériques (limite du protocole, documentée dans
  le README amont) ;
- les en-têtes des fichiers Lua amont mentionnent « EPICS Open License,
  see the file LICENSE », mais le fichier `LICENSE` amont contient la licence
  BSD-3-Clause des Regents of the University of California : c'est ce texte
  qui fait foi (reproduit dans `LICENSE`) ;
- en-tête amont conservé tel quel, y compris la mention `Revision $Id$`
  (mot-clé CVS non résolu dans l'amont).
