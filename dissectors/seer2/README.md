# Seer 2 (赛尔号2)

Dissecteur Wireshark Lua des messages du jeu Seer 2 sur TCP : messages en clair
du serveur de connexion (port 1863) et messages chiffrés des serveurs de jeu
(ports 1201 à 1276), déchiffrés à la volée (issue #332).

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/arcadia-star/seer2-wireshark-dissector |
| Commit importé | `f20d1e24e84a1f459739b3ec402ee00330c752b9` du 25/12/2023 (dernier commit de `main`) |
| Licence amont | Apache-2.0 (fichier `LICENSE` amont, texte de la licence Apache 2.0 ; pas de fichier `NOTICE`, détenteur des droits non précisé) |
| Natif Wireshark 4.6.4 | Non — aucun dissecteur Seer 2 natif |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie
du `LICENSE` amont). La licence Apache-2.0 est conservée (en-tête SPDX
`Apache-2.0`), compatible avec la GPL-3.0-or-later du dépôt.

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/wireshark_seer2msg_cleartext.lua` | Protocole `seer2msg_cleartext` sur TCP 1863 : réassemblage, en-tête (longueur, commande, utilisateur, séquence, statut ou somme de contrôle), corps des commandes 103, 105, 106 et 111 ; sous-protocoles `seer2msg_cleartext_105`, `seer2msg_cleartext_106` et `seer2msg_cleartext_serverInfo` (liste des serveurs en ligne) |
| `src/wireshark_seer2msg_ciphertext.lua` | Protocole `seer2msg_ciphertext` sur TCP 1201-1276, limité aux deux adresses de serveur de jeu codées en dur : réassemblage, longueur et commande, corps déchiffré (rotation de bits et XOR à clé fixe) affiché comme champ généré, en-têtes client et serveur |

Les fichiers sont repris tels quels, en-tête de provenance ajouté. Le README et
le `.gitignore` amont ne sont pas importés.

## Utilisation

Copier les deux fichiers de `src/` dans le dossier `plugins` de Wireshark (ex.
`~/.config/wireshark/plugins/`). Filtres : `seer2msg_cleartext`,
`seer2msg_cleartext_105`, `seer2msg_cleartext_106`,
`seer2msg_cleartext_serverInfo`, `seer2msg_ciphertext`.

## Limites constatées à l'import

- testé par l'auteur avec Wireshark 4.0.3 seulement ;
- adresses IPv4 des serveurs de jeu (`118.89.150.183`, `118.89.149.189`) et
  ports codés en dur : tout changement d'infrastructure du jeu rend le
  dissecteur chiffré inopérant ;
- seules quelques commandes ont un corps décodé (103, 105, 106, 111 et les
  informations de serveur) ;
- objets `Proto` et `tcp_table` en variables globales ; un champ
  (`seer2_clientmsg_cleartext.statusCode`) ne suit pas le préfixe du
  protocole ;
- pas de capture d'exemple amont : syntaxe vérifiée avec `luac5.4 -p`, pas de
  dissection testée sur trafic réel.
