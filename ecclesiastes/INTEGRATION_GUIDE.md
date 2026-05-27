# Guide d'Intégration - Système de Rapports

## 🔗 Comment Intégrer le Système dans Votre App Existante

### Étape 1: Mettre à jour main.dart

Ajouter le `ReportProvider` à votre MultiProvider:

```dart
import 'package:provider/provider.dart';
import 'services/report_provider.dart';
import 'screens/report_list_screen.dart';
import 'screens/create_report_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
        // Vos autres providers...
      ],
      child: const MyApp(),
    ),
  );
}
```

### Étape 2: Ajouter les Routes

```dart
MaterialApp(
  routes: {
    '/reports': (context) => const ReportListScreen(),
    '/create-report': (context) => const CreateReportScreen(),
    '/view-report': (context) => ReportViewScreen(),
    // Autres routes...
  },
)
```

### Étape 3: Ajouter Navigation au Menu

```dart
ListTile(
  leading: Icon(Icons.description),
  title: Text('Rapports'),
  onTap: () => Navigator.pushNamed(context, '/reports'),
),
```

### Étape 4: Utiliser le Provider dans vos Écrans

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        // Accéder aux rapports
        final reports = reportProvider.filteredReports;
        
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return ReportCard(report: reports[index]);
          },
        );
      },
    );
  }
}
```

## 📦 Fichiers à Copier

Assurez-vous que tous ces fichiers sont présents dans votre projet:

### Modèles (`lib/models/`)
```
✓ report_type.dart
✓ audio_segment.dart
✓ report_base.dart
✓ meeting_report.dart
✓ visit_report.dart
✓ divine_service_report.dart
```

### Services (`lib/services/`)
```
✓ audio_service.dart
✓ report_service.dart
✓ report_provider.dart
✓ validation_service.dart
✓ pdf_export_service.dart
```

### Écrans (`lib/screens/`)
```
✓ report_list_screen.dart
✓ create_report_screen.dart
```

### Widgets (`lib/screens/widgets/`)
```
✓ audio_recorder_widget.dart
✓ interactive_report_form.dart
✓ report_preview_widget.dart
```

## 🔧 Configuration Android

Ajouter à `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        targetSdkVersion 34
        minSdkVersion 21
    }
}
```

Ajouter à `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 🍎 Configuration iOS

Ajouter à `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>L'application a besoin d'accès au microphone pour enregistrer les rapports</string>
<key>NSLocalNetworkUsageDescription</key>
<string>L'application utilise le réseau local</string>
</xml>
```

## 🎯 Cas d'Utilisation Courants

### Créer un Rapport Programmatiquement

```dart
final reportProvider = context.read<ReportProvider>();

final meeting = MeetingReport(
  title: 'Réunion Mensuelle',
  author: 'Admin',
  hierarchy: 'Direction',
  meetingType: 'Administrative',
  meetingDate: DateTime.now(),
);

meeting.addDiscussionPoint('Point 1', 'Décision 1');
meeting.addDiscussionPoint('Point 2', 'Décision 2');

await reportProvider.createReport(meeting);
```

### Rechercher des Rapports

```dart
final reportProvider = context.read<ReportProvider>();
reportProvider.searchReports('réunion');
```

### Filtrer par Type

```dart
reportProvider.filterByType(ReportType.meeting.name);
```

### Exporter en PDF

```dart
import 'services/pdf_export_service.dart';

final pdfPath = await PDFExportService.exportReportToPDF(report);
// Partager le fichier
```

### Écouter les Changements

```dart
Consumer<ReportProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Erreur: ${provider.error}');
    }
    
    return ReportList(reports: provider.filteredReports);
  },
)
```

## 🧪 Tests

### Test Unitaire pour ValidationService

```dart
void main() {
  group('ValidationService', () {
    final validator = ValidationService();
    
    test('should validate email', () {
      expect(
        validator.validateEmail('test@example.com'),
        isEmpty,
      );
    });
    
    test('should reject invalid email', () {
      final errors = validator.validateEmail('invalid');
      expect(errors, isNotEmpty);
    });
  });
}
```

### Test Widget pour AudioRecorderWidget

```dart
void main() {
  testWidgets('AudioRecorderWidget shows record button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioRecorderWidget(
            section: 'Test',
            onRecordingComplete: (_, __) {},
          ),
        ),
      ),
    );
    
    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
```

## 🐛 Dépannage Courant

### Problème: "Parent directory does not exist"
**Solution:** Créer les répertoires manuellement
```bash
mkdir -p lib/models lib/services lib/screens/widgets
```

### Problème: Erreur de permission audio
**Solution:** Vérifier AndroidManifest.xml et Info.plist

### Problème: Base de données non accessible
**Solution:** Vérifier les permissions d'écriture et le chemin de l'app

### Problème: Provider non disponible
**Solution:** Assurez-vous que le Provider est enveloppé dans MultiProvider au root

## 📊 Points d'Extension

### Ajouter un Nouveau Type de Rapport

1. Créer une nouvelle classe héritant de `ReportBase`
2. Implémenter `validate()` et `toJson()`
3. Ajouter à l'enum `ReportType`
4. Créer un widget de formulaire spécifique
5. Ajouter à `_parseReport()` dans `ReportService`

### Personnaliser la Validation

```dart
class CustomValidationService extends ValidationService {
  List<String> validateCustomField(String value) {
    final errors = <String>[];
    // Logique personnalisée
    return errors;
  }
}
```

### Implémenter la Synchronisation Cloud

```dart
class CloudReportService extends ReportService {
  Future<void> syncReports() async {
    // Implémentation de synchronisation
  }
}
```

## 📱 Performance

### Optimisations Recommandées

```dart
// Utiliser const où possible
const Widget widget = ReportListScreen();

// Limiter les rebuilds avec ValueListenableBuilder
ValueListenableBuilder<ReportProvider>(...)

// Lazy loading pour grandes listes
ListView.builder(
  lazy: true,
  itemCount: reports.length,
)
```

## 🔄 Workflow de Développement

```
1. Feature Branch
   └─ Créer branche: git checkout -b feature/new-report-type

2. Développement
   ├─ Créer modèle
   ├─ Implémenter service
   ├─ Créer écran/widget
   └─ Ajouter tests

3. Tests
   ├─ Tests unitaires
   ├─ Tests widgets
   └─ Tests d'intégration

4. Pull Request
   └─ Documentation + code review

5. Merge & Deploy
```

## 📞 Support

Pour des questions:
1. Consulter `REPORTS_SYSTEM.md` - Documentation complète
2. Voir `main_reports_example.dart` - Exemple complet
3. Vérifier les tests - Patterns d'utilisation
4. Ouvrir une issue GitHub - Support community

---

**Dernière mise à jour:** 27 Mai 2026
