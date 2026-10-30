# OpenAPI 5G Core (SBI)

Dissecteur Wireshark Lua pour les interfaces SBI (Service Based Interfaces) du 5G Core : décodage des charges JSON des appels REST (NRF, AMF, SMF…) sur HTTP/2, avec validation OpenAPI et filtres par champs.

## Import

| | |
|---|---|
| Dépôt amont | https://github.com/telekom/OpenAPI-Dissector |
| Commit importé | `ed9bcb57622e62bddf4553215786945e9ac38e69` du 21/10/2025 (branche `master`) |
| Licence amont | GPLv2 ou toute version ultérieure (README) |
| Natif Wireshark 4.6.4 | Non — pas d'équivalent natif (JSON générique seulement) |

Texte complet de la licence amont : fichier `LICENSE.txt` de ce dossier (copie conforme de l'amont).

## Fichiers

| Fichier | Rôle |
|---|---|
| `src/openapi.lua` | Dissecteur principal (982 lignes) : dissection des charges JSON selon les spécifications OpenAPI 3GPP |
| `src/json_validator.lua` | Validateur JSON (747 lignes), requis par `openapi.lua` |
| `filters/openapi_fields.lua.example` | Exemple de configuration des champs filtrables |

Non importés : `generator/` (outil Python qui produit `openapi_spec.lua` à partir des YAML 3GPP — voir ci-dessous), `automation/`, `tests/`, `doc/`.

## Utilisation

1. `openapi.lua` requiert un module `openapi_spec` non fourni : le générer avec l'outil Python amont (`generator/`) à partir des spécifications 3GPP (Rel-15 à Rel-17) — ex. `openapi_spec.lua` ;
2. copier `src/` (et le `openapi_spec` généré) dans le dossier `plugins` de Wireshark ;
3. optionnel : renommer `filters/openapi_fields.lua.example` en `openapi_fields.lua` et l'ajuster.

## Limites constatées à l'import

- le module `openapi_spec` (généré, volumineux) n'est pas importé : il dépend de la version 3GPP visée et se régénère avec l'outil amont ;
- la génération dépend de Python ≥ 3.10 (outil non importé) ;
- documentation d'utilisation complète : `doc/` de l'amont.
