#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validation des imports de dissecteurs (convention #563, issue #579).

Chaque répertoire ``dissectors/<protocole>/`` doit contenir :

- un ``README.md`` documentant la provenance (« Dépôt amont »,
  « Commit importé ») ;
- au moins un fichier ``.lua``, chacun avec une en-tête
  ``-- SPDX-License-Identifier:`` en première ligne et la mention de
  l'import (« Importé de… ») dans ses dix premières lignes ;
- de préférence le texte de licence amont (``LICENSE``, ``LICENSE.txt``…),
  sinon simple avertissement.

La syntaxe Lua de chaque fichier est vérifiée si un compilateur est
disponible (``luac``, ``luac5.x``, ``luajit -bl``) ; sinon la vérification
est signalée comme ignorée (avertissement, non bloquant).

Sortie : 0 si aucune erreur, 1 sinon. Les avertissements ne bloquent pas.
"""

from __future__ import annotations

import pathlib
import shutil
import subprocess
import sys

RACINE = pathlib.Path(__file__).resolve().parent.parent
DOSSIER_DISSECTORS = "dissectors"
FICHIERS_LICENCE = ("LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "COPYING.txt")
MENTIONS_PROVENANCE = ("Dépôt amont", "Commit importé")


class Rapport:
    """Accumule erreurs (bloquantes) et avertissements (non bloquants)."""

    def __init__(self) -> None:
        self.erreurs: list[str] = []
        self.avertissements: list[str] = []

    def erreur(self, message: str) -> None:
        self.erreurs.append(message)
        print(f"[ERROR] {message}")

    def avert(self, message: str) -> None:
        self.avertissements.append(message)
        print(f"[WARN ] {message}")

    @property
    def ok(self) -> bool:
        return not self.erreurs


def _rel(chemin: pathlib.Path) -> str:
    """Chemin affiché, relatif à la racine du dépôt si possible."""
    try:
        return str(chemin.relative_to(RACINE))
    except ValueError:
        return str(chemin)


def trouver_compilateur_lua() -> list[str] | None:
    """Commande de vérification de syntaxe Lua, ou None si indisponible."""
    for candidat in ("luac", "luac5.4", "luac5.3", "luac5.2", "luac5.1"):
        if shutil.which(candidat):
            return [candidat, "-p"]
    if shutil.which("luajit"):
        return ["luajit", "-bl"]
    return None


def syntaxe_valide(commande: list[str], fichier: pathlib.Path) -> bool:
    """True si le fichier compile (syntaxe Lua valide)."""
    try:
        resultat = subprocess.run(
            commande + [str(fichier)], capture_output=True, text=True
        )
    except OSError:
        return False
    return resultat.returncode == 0


def _en_tete_spdx(lignes: list[str]) -> bool:
    """En-tête SPDX en première ligne, ou en seconde après un shebang
    (SOCLE.md : « après le shebang s'il y en a un »)."""
    if not lignes:
        return False
    if lignes[0].startswith("-- SPDX-License-Identifier:"):
        return True
    return (
        lignes[0].startswith("#!")
        and len(lignes) > 1
        and lignes[1].startswith("-- SPDX-License-Identifier:")
    )


def valider_fichier_lua(
    rapport: Rapport, chemin: pathlib.Path, commande_lua: list[str] | None
) -> None:
    """Vérifie en-tête SPDX, mention d'import et syntaxe d'un fichier .lua."""
    try:
        lignes = chemin.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError as exc:
        rapport.erreur(f"{_rel(chemin)} : illisible ({exc})")
        return
    if not _en_tete_spdx(lignes):
        rapport.erreur(
            f"{_rel(chemin)} : en-tête SPDX absent des premières lignes (convention #563)"
        )
    if not any("mporté" in ligne.lower() for ligne in lignes[:10]):
        rapport.erreur(f"{_rel(chemin)} : mention d'import absente des 10 premières lignes")
    if commande_lua is not None and not syntaxe_valide(commande_lua, chemin):
        rapport.erreur(f"{_rel(chemin)} : syntaxe Lua invalide")


def valider_repertoire(
    rapport: Rapport, repertoire: pathlib.Path, commande_lua: list[str] | None
) -> None:
    """Vérifie un répertoire dissectors/<protocole>/."""
    fichiers_lua = sorted(repertoire.rglob("*.lua"))
    if not fichiers_lua:
        rapport.erreur(f"{repertoire.name} : aucun fichier .lua")

    readme = repertoire / "README.md"
    if not readme.is_file():
        rapport.erreur(f"{repertoire.name} : README.md manquant")
    else:
        texte = readme.read_text(encoding="utf-8", errors="replace")
        for mention in MENTIONS_PROVENANCE:
            if mention not in texte:
                rapport.erreur(f"{repertoire.name} : README.md sans « {mention} »")

    if not any((repertoire / nom).is_file() for nom in FICHIERS_LICENCE):
        rapport.avert(f"{repertoire.name} : pas de texte de licence amont (LICENSE/…)")

    for chemin in fichiers_lua:
        valider_fichier_lua(rapport, chemin, commande_lua)


def main(racine: pathlib.Path | None = None) -> int:
    """Valide tous les répertoires sous <racine>/dissectors/ (dépôt par défaut)."""
    dossier = (racine or RACINE) / DOSSIER_DISSECTORS
    if not dossier.is_dir():
        print(f"[ERROR] {DOSSIER_DISSECTORS}/ introuvable")
        return 1

    rapport = Rapport()
    commande_lua = trouver_compilateur_lua()
    if commande_lua is None:
        rapport.avert("aucun compilateur Lua disponible : syntaxe non vérifiée")

    repertoires = sorted(p for p in dossier.iterdir() if p.is_dir())
    if not repertoires:
        rapport.erreur(f"{DOSSIER_DISSECTORS}/ est vide")

    for repertoire in repertoires:
        valider_repertoire(rapport, repertoire, commande_lua)

    print(
        f"\n{len(repertoires)} répertoire(s) vérifié(s), "
        f"{len(rapport.erreurs)} erreur(s), "
        f"{len(rapport.avertissements)} avertissement(s)"
    )
    return 0 if rapport.ok else 1


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover — garde d'exécution (SOCLE.md)
