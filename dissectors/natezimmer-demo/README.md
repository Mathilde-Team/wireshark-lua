# Tutoriel : dissecteur chaîné et générateur PCAP (NateZimmer)

Exemple pédagogique de bout en bout, issue #57 : un dissecteur Lua chaîné
(`my_proto`, protocole requête/réponse fictif sur le type de lien utilisateur
DLT 148) et un script Node.js qui produit un flux pcap à envoyer dans
Wireshark. Il ne s'agit pas d'un protocole réel : à utiliser comme modèle.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/NateZimmer/wireshark-dissector |
| Commit importé | `9e2fea5480cd37c4e8be9379d603a9d996f8f7f1` du 25/05/2020 |
| Licence amont | MIT (« @license MIT » et « @author NZ » dans l'en-tête de `demo.lua` et de `simulate_devices.js` ; pas de fichier de licence ni de ligne de copyright amont) — compatible avec la licence du dépôt (GPL-3.0-or-later) |
| Natif Wireshark 4.6.4 | sans objet (protocole d'exemple) |

Fichiers importés tels quels (aucune modification de code) ; seule une en-tête
`SPDX-License-Identifier: MIT` avec la provenance est ajoutée (convention du
dépôt, issue #563). L'amont ne fournit pas de texte de licence : aucun fichier
`LICENSE` n'est ajouté, faute de ligne de copyright à reproduire ; l'auteur
déclaré est « NZ » (NateZimmer).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/demo.lua` | Protocole `my_proto` enregistré sur `wtap_encap` `wtap.USER1` (DLT 148) : octet d'en-tête (bit requête/réponse et adresse sur 7 bits), numéro de séquence ; pour les réponses, valeur sur 16 bits, longueur et données, puis appel chaîné du dissecteur `data` |
| `outils/simulate_devices.js` | Script Node.js : écrit sur la sortie standard un en-tête pcap (DLT 148) puis, toutes les 2,5 s, une requête et une réponse aléatoires |

Non importée : la capture d'écran `image/ref.png`.

## Utilisation

Copier `src/demo.lua` dans le dossier des plugins Lua personnels de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`), puis Ctrl+Maj+L. Pour un
flux de démonstration :

```
node outils/simulate_devices.js | wireshark -k -i -
```

Filtre d'affichage : `my_proto`.

## Vérification à l'import

Avec tshark 4.6.4, `demo.lua` se charge sans erreur. Sur des captures
synthétiques (text2pcap `-l 148`) :

| Trame | Résultat |
|---|---|
| `95 07` (requête, adresse `0x15`, séquence 7) | Protocole `My Proto`, Info « Req, ADR:21, Seq[7] » |
| `15 07 01 2c 03 aa bb cc` (réponse) | Info « Res, ADR:21, Seq[7], Data: 300 », longueur 3, données `aabbcc` passées au dissecteur `data` |

`outils/simulate_devices.js` n'a pas été exécuté (contrôle de syntaxe
`node --check` seulement).

## Limites constatées

- Le champ « Req/Res » affiche l'inverse du sens réel : la table de valeurs
  donne `0 = Request`, `1 = Response`, alors que le code (et le générateur)
  traite le bit `0x80` à 1 comme une requête.
- Les champs « Req/Res » et « Address » partagent l'abréviation
  `my_proto.req` : le filtre `my_proto.req` porte sur les deux.
- Le dissecteur occupe `wtap.USER1` (DLT 148) : il entre en conflit avec toute
  autre utilisation de ce type de lien (table « DLT_USER » des préférences).
- Code d'exemple non maintenu depuis 2020.
