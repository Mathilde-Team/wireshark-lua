# Wirdigen — générateur de dissecteurs Lua depuis une description JSON

**Wir**eshark **Di**ssector **Gen**erator : petite bibliothèque Rust qui génère un
dissecteur Wireshark en Lua à partir d'une description JSON du paquet (nom,
endianness, protocole/ports, champs avec format, base, décalage et taille).
L'outil amont est en Rust ; le présent dépôt ne collectant que des scripts Lua,
l'import retient la description JSON d'exemple (copie conforme) et le dissecteur
Lua que l'outil génère à partir d'elle. L'outil lui-même n'est pas importé.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/Cerclique/wirdigen |
| Commit importé | `fdbfb70444c1a88df285b7b5b1c2ef8037b23e28` du 26/10/2026 (branche `main`, dernier commit du dépôt) |
| Licence amont | MIT (texte complet dans `LICENSE` de ce dossier, copie conforme de l'amont) |
| Natif Wireshark 4.6.4 | sans objet (générateur, pas un dissecteur d'un protocole réel) |

## Génération du Lua

`example/dissector_test.lua` n'est pas un fichier de l'amont : il est produit
par wirdigen lui-même depuis la description JSON d'exemple de l'amont
(`example/example_dissector.json`, copie conforme, non modifiable par
convention d'import). Génération :

- wirdigen 0.3.0 compilé depuis le commit `fdbfb7044` (Rust 1.88.0 épinglé ; la
  compilation dans l'environnement de génération a exigé d'ajouter la
  dépendance `openssl` en mode « vendored » — sans effet sur la génération) ;
- appel de la bibliothèque par le programme minimal suivant (reproduit ici car
  l'amont n'a pas de binaire en ligne de commande) :

```rust
use std::fs::File;
use std::io::BufReader;
use wirdigen::generator::Generator;

fn main() {
    let rdr = BufReader::new(File::open("./example/example_dissector.json").expect("JSON introuvable"));
    let mut gen = Generator::default();
    gen.set_output_directory("./gen-out");
    println!("Generated: {}", gen.from_reader(rdr).expect("échec de génération"));
}
```

- fichier produit : `gen-out/dissector_test.lua` (194 lignes), recopié dans
  `example/` avec une en-tête de provenance ; le contenu généré est inchangé.

L'exemple démontre toutes les combinaisons format/base (bool, char, uint8-64,
int8-64, float, double, temps, bytes, ipv4/ipv6, ether, guid, oid, `valstr`) :
le dissecteur s'enregistre sur les ports UDP 60001/60002.

## Fichiers

| Fichier | Rôle |
|---|---|
| `example/example_dissector.json` | description d'exemple de l'amont, copie conforme (entrée du générateur) |
| `example/dissector_test.lua` | dissecteur Lua généré par wirdigen depuis cette description |
| `LICENSE` | licence MIT de l'amont, copie conforme |

Non importés : les sources Rust (`src/*.rs`, `Cargo.toml`) — le dépôt ne collecte
que du Lua —, `docs/`, `AGENTS.md`, `CLAUDE.md`, `GLOSSARY.md`, les workflows
CI amont et le README amont (remplacé par ce README).

## Utilisation

Le dissecteur d'exemple se copie tel quel dans le dossier `plugins` de
Wireshark (ex. `~/.local/lib/wireshark/plugins/`) : il s'enregistre sur les
ports UDP 60001/60002 et affiche les champs de la description. Pour générer un
dissecteur pour un autre protocole, décrire le paquet en JSON (structure dans
le README amont) et lancer wirdigen.
