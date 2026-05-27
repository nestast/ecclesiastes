#!/usr/bin/env bash
# Quick Start & Verification Script
# Use this to verify all files are in place

echo "🔍 Vérification du Système de Rapports..."
echo "=========================================="
echo ""

# Check Models
echo "📦 Modèles de Données:"
files=(
  "lib/models/report_type.dart"
  "lib/models/audio_segment.dart"
  "lib/models/report_base.dart"
  "lib/models/meeting_report.dart"
  "lib/models/visit_report.dart"
  "lib/models/divine_service_report.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (MANQUANT)"
  fi
done

echo ""

# Check Services
echo "⚙️  Services:"
services=(
  "lib/services/audio_service.dart"
  "lib/services/report_service.dart"
  "lib/services/report_provider.dart"
  "lib/services/validation_service.dart"
  "lib/services/pdf_export_service.dart"
)

for service in "${services[@]}"; do
  if [ -f "$service" ]; then
    echo "  ✅ $service"
  else
    echo "  ❌ $service (MANQUANT)"
  fi
done

echo ""

# Check UI
echo "🎨 Écrans & Widgets:"
ui_files=(
  "lib/screens/report_list_screen.dart"
  "lib/screens/create_report_screen.dart"
  "lib/screens/widgets/audio_recorder_widget.dart"
  "lib/screens/widgets/interactive_report_form.dart"
  "lib/screens/widgets/report_preview_widget.dart"
)

for ui_file in "${ui_files[@]}"; do
  if [ -f "$ui_file" ]; then
    echo "  ✅ $ui_file"
  else
    echo "  ❌ $ui_file (MANQUANT)"
  fi
done

echo ""

# Check Documentation
echo "📚 Documentation:"
docs=(
  "REPORTS_SYSTEM.md"
  "README_REPORTS.md"
  "INTEGRATION_GUIDE.md"
  "COMPLETION_REPORT.md"
  "main_reports_example.dart"
)

for doc in "${docs[@]}"; do
  if [ -f "$doc" ]; then
    echo "  ✅ $doc"
  else
    echo "  ❌ $doc (MANQUANT)"
  fi
done

echo ""
echo "=========================================="
echo "✅ Vérification terminée!"
echo ""
echo "📌 Prochaines étapes:"
echo "  1. flutter pub get"
echo "  2. flutter run"
echo "  3. Voir INTEGRATION_GUIDE.md pour l'intégration"
echo "  4. Consulter REPORTS_SYSTEM.md pour la doc complète"
echo ""
