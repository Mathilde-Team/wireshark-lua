# SPDX-License-Identifier: GPL-3.0-or-later
"""Tests unitaires du validateur d'imports (scripts/valider_imports.py).

Chaque test construit un répertoire de dissecteur temporaire (fixtures)
et vérifie les erreurs/avertissements produits par valider_repertoire.
"""

from __future__ import annotations

import importlib.util
import pathlib
import tempfile
import unittest
import unittest.mock

CHEMIN_SCRIPT = (
    pathlib.Path(__file__).resolve().parent.parent / "scripts" / "valider_imports.py"
)
_spec = importlib.util.spec_from_file_location("valider_imports", CHEMIN_SCRIPT)
valider = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(valider)


class ValiderImportsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.racine_tmp = pathlib.Path(self.tmp.name)
        self.rapport = valider.Rapport()
        # Aucune vérification de syntaxe (pas de dépendance à un compilateur Lua).
        self.commande_lua = None

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def _creer(self, nom: str) -> pathlib.Path:
        rep = self.racine_tmp / nom
        rep.mkdir()
        return rep

    def _lua_valide(self, rep: pathlib.Path, nom: str = "proto.lua") -> pathlib.Path:
        chemin = rep / nom
        chemin.write_text(
            "-- SPDX-License-Identifier: MIT\n"
            "-- Importé de https://example.com/upstream,\n"
            "-- commit abc123 du 01/01/2020.\n"
            "local p = Proto.new('demo', 'Demo')\n",
            encoding="utf-8",
        )
        return chemin

    def _readme(self, rep: pathlib.Path, provenance: bool = True) -> None:
        corps = "# Demo\n"
        if provenance:
            corps += (
                "| Dépôt amont | https://example.com/upstream |\n"
                "| Commit importé | abc123 |\n"
            )
        (rep / "README.md").write_text(corps, encoding="utf-8")

    def test_repertoire_valide_sans_erreur(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        self._lua_valide(rep)
        (rep / "LICENSE").write_text("MIT…", encoding="utf-8")
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(self.rapport.ok)
        self.assertEqual(self.rapport.avertissements, [])

    def test_licence_absente_avertissement_seulement(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        self._lua_valide(rep)
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(self.rapport.ok)
        self.assertEqual(len(self.rapport.avertissements), 1)

    def test_sans_readme_ni_lua(self) -> None:
        rep = self._creer("vide")
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        # pas de .lua + README manquant = 2 erreurs ; licence absente = avertissement
        self.assertEqual(len(self.rapport.erreurs), 2)
        self.assertEqual(len(self.rapport.avertissements), 1)
        self.assertFalse(self.rapport.ok)

    def test_readme_sans_provenance(self) -> None:
        rep = self._creer("demo")
        self._readme(rep, provenance=False)
        self._lua_valide(rep)
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        messages = " ".join(self.rapport.erreurs)
        self.assertIn("Dépôt amont", messages)
        self.assertIn("Commit importé", messages)

    def test_lua_sans_spdx(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        (rep / "proto.lua").write_text(
            "-- Importé de https://example.com/upstream.\nlocal x = 1\n",
            encoding="utf-8",
        )
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(any("SPDX" in e for e in self.rapport.erreurs))

    def test_lua_sans_mention_import(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        (rep / "proto.lua").write_text(
            "-- SPDX-License-Identifier: MIT\nlocal x = 1\n", encoding="utf-8"
        )
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(any("import" in e for e in self.rapport.erreurs))

    def test_lua_spdx_apres_shebang(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        (rep / "proto.lua").write_text(
            "#!/usr/bin/env tarantool\n"
            "-- SPDX-License-Identifier: BSD-2-Clause\n"
            "-- Importé de https://example.com/upstream.\n"
            "local z = 3\n",
            encoding="utf-8",
        )
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(self.rapport.ok)

    def test_lua_spdx_absent_sous_shebang(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        (rep / "proto.lua").write_text(
            "#!/usr/bin/env lua\n-- Importé de https://example.com/upstream.\nlocal z = 3\n",
            encoding="utf-8",
        )
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(any("SPDX" in e for e in self.rapport.erreurs))

    def test_lua_sous_repertoires_verifies(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        sous = rep / "src" / "lib"
        sous.mkdir(parents=True)
        (sous / "lib.lua").write_text(
            "-- SPDX-License-Identifier: MIT\n-- importé via example.com\nlocal y = 2\n",
            encoding="utf-8",
        )
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(self.rapport.ok)

    def test_rapport_ok_avec_avertissement(self) -> None:
        rapport = valider.Rapport()
        rapport.avert("mineur")
        self.assertTrue(rapport.ok)
        rapport.erreur("majeur")
        self.assertFalse(rapport.ok)


    def test_compilateur_lua_54(self) -> None:
        def faux_which(nom: str) -> str | None:
            return "/usr/bin/luac5.4" if nom == "luac5.4" else None

        with unittest.mock.patch("shutil.which", side_effect=faux_which):
            with unittest.mock.patch.object(
                valider, "_version_lua", return_value="Lua 5.4.7  Copyright"
            ):
                self.assertEqual(
                    valider.trouver_compilateur_lua(), ["luac5.4", "-p"]
                )

    def test_compilateur_lua_53_accepte(self) -> None:
        def faux_which(nom: str) -> str | None:
            return "/usr/bin/luac" if nom == "luac" else None

        with unittest.mock.patch("shutil.which", side_effect=faux_which):
            with unittest.mock.patch.object(
                valider, "_version_lua", return_value="Lua 5.3.6  Copyright"
            ):
                self.assertEqual(valider.trouver_compilateur_lua(), ["luac", "-p"])

    def test_compilateur_lua_51_refuse(self) -> None:
        def faux_which(nom: str) -> str | None:
            return "/usr/bin/luac" if nom == "luac" else None

        with unittest.mock.patch("shutil.which", side_effect=faux_which):
            with unittest.mock.patch.object(
                valider, "_version_lua", return_value="Lua 5.1.5  Copyright"
            ):
                self.assertIsNone(valider.trouver_compilateur_lua())

    def test_compilateur_lua_absent(self) -> None:
        with unittest.mock.patch("shutil.which", return_value=None):
            self.assertIsNone(valider.trouver_compilateur_lua())

    def test_version_lua_commande_inexistante(self) -> None:
        self.assertEqual(
            valider._version_lua("/bin/commande-inexistante-xyz"), ""
        )

    def test_syntaxe_valide(self) -> None:
        fichier = self.racine_tmp / "x.lua"
        fichier.write_text("local a = 1\n", encoding="utf-8")
        self.assertTrue(valider.syntaxe_valide(["true"], fichier))
        self.assertFalse(valider.syntaxe_valide(["false"], fichier))

    def test_main_sans_compilateur_lua(self) -> None:
        racine = self.racine_tmp / "sansluac"
        rep = racine / "dissectors" / "demo"
        rep.mkdir(parents=True)
        self._readme(rep)
        self._lua_valide(rep)
        (rep / "LICENSE").write_text("MIT…", encoding="utf-8")
        with unittest.mock.patch.object(
            valider, "trouver_compilateur_lua", return_value=None
        ):
            self.assertEqual(valider.main(racine), 0)

    def test_main_ok(self) -> None:
        racine = self.racine_tmp / "ok"
        rep = racine / "dissectors" / "demo"
        rep.mkdir(parents=True)
        self._readme(rep)
        self._lua_valide(rep)
        (rep / "LICENSE").write_text("MIT…", encoding="utf-8")
        self.assertEqual(valider.main(racine), 0)

    def test_main_avec_erreurs(self) -> None:
        racine = self.racine_tmp / "ko"
        (racine / "dissectors" / "vide").mkdir(parents=True)
        self.assertEqual(valider.main(racine), 1)

    def test_main_sans_dossier_dissectors(self) -> None:
        racine = self.racine_tmp / "rien"
        racine.mkdir()
        self.assertEqual(valider.main(racine), 1)

    def test_main_dissectors_vide(self) -> None:
        racine = self.racine_tmp / "vide"
        (racine / "dissectors").mkdir(parents=True)
        self.assertEqual(valider.main(racine), 1)

    def test_syntaxe_valide_commande_inexistante(self) -> None:
        fichier = self.racine_tmp / "y.lua"
        fichier.write_text("local b = 2\n", encoding="utf-8")
        self.assertFalse(
            valider.syntaxe_valide(["/bin/commande-inexistante-xyz"], fichier)
        )

    def test_lua_fichier_vide(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        (rep / "vide.lua").write_text("", encoding="utf-8")
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(any("SPDX" in e for e in self.rapport.erreurs))

    def test_lua_illisible(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        # Un répertoire nommé *.lua est trouvé par rglob mais illisible.
        (rep / "bizarre.lua").mkdir()
        valider.valider_repertoire(self.rapport, rep, self.commande_lua)
        self.assertTrue(any("illisible" in e for e in self.rapport.erreurs))

    def test_syntaxe_invalide_signalee(self) -> None:
        rep = self._creer("demo")
        self._readme(rep)
        self._lua_valide(rep)
        # « false » échoue toujours : simule un compilateur signalant une erreur.
        valider.valider_repertoire(self.rapport, rep, ["false"])
        self.assertTrue(any("syntaxe Lua invalide" in e for e in self.rapport.erreurs))


if __name__ == "__main__":
    unittest.main()
