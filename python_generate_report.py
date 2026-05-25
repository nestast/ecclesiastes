import os
import re
import json
from pathlib import Path

# Configuration
PROJECT_ROOT = Path.cwd()  # Dossier courant (le projet Flutter)
OUTPUT_FILE = "project_structure_report.txt"
IGNORE_DIRS = {".dart_tool", "build", ".git", "android", "ios", "web", "linux", "macos", "windows", "test"}
DART_EXT = ".dart"
SQLITE_FILE = "app_database.db"  # À adapter si votre fichier DB a un autre nom

def main():
    with open(OUTPUT_FILE, "w", encoding="utf-8") as report:
        report.write("=== RAPPORT DE STRUCTURE DU PROJET FLUTTER ===\n\n")
        report.write(f"Racine du projet : {PROJECT_ROOT}\n\n")
        
        # 1. Arborescence des dossiers
        report.write("=== ARBORESCENCE ===\n")
        for root, dirs, files in os.walk(PROJECT_ROOT):
            # Ignorer les dossiers inutiles
            dirs[:] = [d for d in dirs if d not in IGNORE_DIRS and not d.startswith('.')]
            level = Path(root).relative_to(PROJECT_ROOT).as_posix()
            indent = "  " * (level.count("/") if level != "." else 0)
            report.write(f"{indent}{os.path.basename(root)}/\n")
            sub_indent = "  " * (level.count("/") + 1 if level != "." else 1)
            for file in files:
                if file.endswith(DART_EXT):
                    report.write(f"{sub_indent}{file}\n")
        report.write("\n")
        
        # 2. Contenu des fichiers Dart les plus importants (vous pouvez adapter la liste)
        important_files = [
            "lib/main.dart",
            "lib/services/database_helper.dart",
            "lib/services/auth_service.dart",
            "lib/services/admin_service.dart",
            "lib/models/",
            "lib/views/",
        ]
        report.write("=== EXTRAITS DES FICHIERS CLÉS ===\n")
        for pattern in important_files:
            if pattern.endswith("/"):  # dossier
                for root, _, files in os.walk(PROJECT_ROOT / pattern):
                    for f in files:
                        if f.endswith(DART_EXT):
                            filepath = Path(root) / f
                            report.write(f"\n--- {filepath.relative_to(PROJECT_ROOT)} ---\n")
                            try:
                                with open(filepath, "r", encoding="utf-8") as code:
                                    # Limiter à 200 lignes pour ne pas exploser
                                    lines = code.readlines()[:200]
                                    report.write("".join(lines))
                                    if len(lines) == 200:
                                        report.write("... (limité à 200 lignes)\n")
                            except Exception as e:
                                report.write(f"Erreur de lecture : {e}\n")
            else:
                filepath = PROJECT_ROOT / pattern
                if filepath.exists():
                    report.write(f"\n--- {pattern} ---\n")
                    with open(filepath, "r", encoding="utf-8") as code:
                        report.write(code.read()[:5000])
                        if len(code.read()) > 5000:
                            report.write("\n... (tronqué à 5000 caractères)\n")
                else:
                    report.write(f"\n--- {pattern} non trouvé ---\n")
        
        # 3. Schéma de la base de données SQLite (si fichier .db présent)
        db_path = PROJECT_ROOT / SQLITE_FILE
        if db_path.exists():
            report.write("\n=== SCHEMA DE LA BASE DE DONNÉES ===\n")
            try:
                import sqlite3
                conn = sqlite3.connect(db_path)
                cursor = conn.cursor()
                cursor.execute("SELECT name, sql FROM sqlite_master WHERE type='table';")
                tables = cursor.fetchall()
                for table_name, create_sql in tables:
                    report.write(f"\nTable : {table_name}\n")
                    report.write(f"{create_sql}\n")
                conn.close()
            except ImportError:
                report.write("Module sqlite3 non disponible, impossible d'extraire le schéma.\n")
            except Exception as e:
                report.write(f"Erreur d'extraction : {e}\n")
        else:
            report.write("\n=== BASE DE DONNÉES ===\nAucun fichier .db trouvé. Si vous utilisez SQLite, précisez le chemin.\n")
        
        # 4. Liste des dépendances (pubspec.yaml)
        pubspec = PROJECT_ROOT / "pubspec.yaml"
        if pubspec.exists():
            report.write("\n=== DEPENDANCES (pubspec.yaml) ===\n")
            with open(pubspec, "r", encoding="utf-8") as f:
                content = f.read()
                # Extraire la section dependencies
                dep_match = re.search(r"dependencies:\s*\n(.*?)(?=^\w|\Z)", content, re.DOTALL | re.MULTILINE)
                if dep_match:
                    report.write(dep_match.group(0))
                dev_match = re.search(r"dev_dependencies:\s*\n(.*?)(?=^\w|\Z)", content, re.DOTALL | re.MULTILINE)
                if dev_match:
                    report.write("\n" + dev_match.group(0))
        
        # 5. Conclusion
        report.write("\n=== FIN DU RAPPORT ===\n")
    
    print(f"Rapport généré : {OUTPUT_FILE}")

if __name__ == "__main__":
    main()