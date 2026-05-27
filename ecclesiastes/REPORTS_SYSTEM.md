# Système de Rapports Interactifs avec Audio - Ecclesiastes

## 📋 Vue d'ensemble

Ce système offre une solution complète pour créer, gérer et exporter des rapports interactifs avec support audio intégré. Conçu spécifiquement pour l'Église Néo-Apostolique RDC Ouest, il supporte plusieurs types de rapports : réunions, visites, services divins, et bien plus.

## 🎯 Fonctionnalités Principales

### 1. **Création de Rapports Interactifs**
- Interface intuitive pour créer plusieurs types de rapports
- Formulaires dynamiques adaptés à chaque type de rapport
- Validation automatique des champs requis
- Support de métadonnées personnalisées

### 2. **Enregistrement Audio Intégré**
- Enregistrement audio en temps réel (AAC-LC, 44.1kHz)
- Lecture et gestion des enregistrements
- Pause/reprise des enregistrements
- Association automatique des enregistrements aux rapports
- Chronomètre visuel pendant l'enregistrement

### 3. **Gestion des Rapports**
- Visualisation de tous les rapports créés
- Recherche par titre ou auteur
- Filtrage par type de rapport
- Prévisualisation détaillée avant exportation
- Édition et suppression de rapports

### 4. **Export en PDF**
- Export structuré et professionnel
- Formatage adapté à chaque type de rapport
- Inclusion des enregistrements audio (métadonnées)
- Sauvegarde locale sécurisée

## 📁 Structure du Projet

```
lib/
├── models/
│   ├── report_type.dart           # Énumération des types de rapport
│   ├── audio_segment.dart         # Modèle pour les enregistrements audio
│   ├── report_base.dart           # Classe de base pour tous les rapports
│   ├── meeting_report.dart        # Modèle pour rapports de réunion
│   ├── visit_report.dart          # Modèle pour rapports de visite
│   └── divine_service_report.dart # Modèle pour services divins
├── services/
│   ├── audio_service.dart         # Service d'enregistrement/lecture audio
│   ├── report_service.dart        # Persistance (base de données SQLite)
│   ├── report_provider.dart       # Gestion d'état (Provider)
│   ├── validation_service.dart    # Validation des champs
│   └── pdf_export_service.dart    # Export en PDF
├── screens/
│   ├── report_list_screen.dart    # Écran de liste des rapports
│   ├── create_report_screen.dart  # Écran de création de rapport
│   └── widgets/
│       ├── audio_recorder_widget.dart       # Widget d'enregistrement
│       ├── interactive_report_form.dart    # Widget de formulaire
│       └── report_preview_widget.dart      # Widget de prévisualisation
```

## 🚀 Utilisation

### Installation des Dépendances
```bash
flutter pub get
```

### Types de Rapports Supportés

#### 1. **Rapport de Réunion** (Meeting Report)
**Champs:**
- Hiérarchie organisationnelle
- Type de réunion
- Objet de la réunion
- Date et heures
- Président et secrétaire
- Liste des participants (présents/absents)
- Points de discussion avec décisions
- Actions à entreprendre
- Finances (si applicable)

**Sections Audio:**
- Discussion principale
- Décisions & actions
- Notes additionnelles

#### 2. **Rapport de Visite** (Visit Report)
**Champs:**
- Lieu de la visite
- Hiérarchie/autorité responsable
- Raison de la visite
- Date de la visite
- Personnes visitées
- Observations
- Constatations
- Recommandations
- Conclusion

#### 3. **Rapport de Service Divin** (Divine Service Report)
**Champs:**
- Date du service
- Type de service
- Nombre de participants
- Orateurs/prédateurs
- Thème
- Résumé du service
- Hymnes chantés
- Collections/offrandes
- Prochain service prévu
- Observations

## 💾 Modèles de Données

### ReportBase (Classe abstraite)
```dart
abstract class ReportBase {
  final String id;                      // UUID unique
  final ReportType type;                // Type de rapport
  final String title;                   // Titre
  final String author;                  // Auteur
  final DateTime createdAt;             // Date de création
  final DateTime? updatedAt;            // Date de modification
  final List<AudioSegment> audioSegments; // Enregistrements
  final Map<String, dynamic> metadata;  // Métadonnées personnalisées
  bool isCompleted;                     // Statut de complétion

  List<String> validate();              // Validation
  Map<String, dynamic> toJson();        // Sérialisation
}
```

### AudioSegment
```dart
class AudioSegment {
  final String id;                // UUID unique
  final String filePath;          // Chemin du fichier audio
  final String? transcription;    // Transcription (futur)
  final Duration duration;        // Durée
  final DateTime createdAt;       // Date de création
  final String section;           // Section du rapport
  bool isProcessed;              // Statut de traitement
}
```

## 🎵 Service Audio

### Fonctionnalités
- **Enregistrement:**
  ```dart
  final filePath = await audioService.startRecording('section');
  // ... enregistrement ...
  await audioService.stopRecording();
  ```

- **Lecture:**
  ```dart
  await audioService.playAudio(filePath);
  await audioService.pausePlayback();
  await audioService.resumePlayback();
  ```

### Flux d'Enregistrement
1. Demander les permissions
2. Initialiser l'enregistrement
3. Afficher le chronomètre
4. Pause/reprise optionnelles
5. Arrêt et sauvegarde
6. Association au rapport

## 📊 Services de Persistance

### ReportService (SQLite)
- CRUD complet pour les rapports
- Requêtes filtrées par type
- Sérialisation JSON
- Gestion des transactions

### ReportProvider (État globale)
- Gestion centralisée des rapports
- Recherche et filtrage
- Sélection de rapport actif
- Gestion d'erreurs et chargement

## ✅ Validation

Le `ValidationService` valide:
- **Emails:** Format standard RFC 5322
- **Téléphones:** Formats internationaux
- **Champs texte:** Longueur min/max
- **Dates:** Non futures par défaut
- **Nombres:** Plages valides
- **Listes:** Nombre minimum d'éléments

## 📄 Export PDF

### Format
- Format A4 avec marges appropriées
- En-têtes avec type et titre du rapport
- Métadonnées (auteur, dates, statut)
- Contenu formaté par section
- Liste des enregistrements audio
- Sauvegarde dans `/reports_pdf/`

### Utilisation
```dart
final pdfPath = await PDFExportService.exportReportToPDF(report);
// Partager ou enregistrer le fichier
```

## 🔒 Sécurité

- Enregistrements audio stockés dans Documents App
- Base de données SQLite chiffrée (à implémenter)
- Validation côté client et serveur (futur)
- UUID pour tous les identifiants
- Pas de données sensibles en logs

## 🎨 Interface Utilisateur

### Écran de Liste
- Cartes de rapport avec aperçu
- Icônes de statut (complété/en cours)
- Nombre d'enregistrements audio
- Recherche en temps réel
- Filtrage par type
- Actions rapides (voir, éditer, supprimer)

### Écran de Création
- Sélection du type avec descriptions
- Onglets: Informations | Audio
- Formulaires dynamiques
- Enregistrement audio en direct
- Prévisualisation avant sauvegarde

### Widget d'Enregistrement Audio
- Boutons: Enregistrer | Pause | Arrêter
- Chronomètre en temps réel
- Indicateur d'enregistrement (point rouge)
- Support pause/reprise

## 📱 Permissions Requises

### Android
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
```
NSMicrophoneUsageDescription: "L'application a besoin d'accès au microphone pour enregistrer les rapports"
NSLocalNetworkUsageDescription: "L'application a besoin d'accéder au réseau local"
```

## 🔄 Flux de Travail Complet

### Créer un Rapport
1. Appuyer sur "Nouveau Rapport"
2. Sélectionner le type
3. Remplir les informations de base
4. Enregistrer audio (optionnel)
5. Ajouter points de discussion
6. Valider et sauvegarder

### Gérer les Rapports
1. Voir la liste des rapports
2. Chercher par titre/auteur
3. Filtrer par type
4. Ouvrir un rapport pour voir les détails
5. Éditer, exporter ou supprimer

### Exporter en PDF
1. Ouvrir un rapport
2. Appuyer sur "Exporter"
3. Sauvegarder le PDF localement
4. Partager si nécessaire

## 🛠️ Configuration Recommandée

### Dépendances Clés
- `provider: ^6.0.0` - Gestion d'état
- `record: ^4.4.4` - Enregistrement audio
- `audioplayers: ^5.2.0` - Lecture audio
- `sqflite: ^2.3.0` - Base de données
- `pdf: ^3.10.0` - Génération PDF
- `uuid: ^4.0.0` - Identifiants uniques

## 📝 Prochaines Améliorations

- [ ] Transcription audio automatique (Speech-to-Text)
- [ ] Support du chiffrement de base de données
- [ ] Synchronisation cloud
- [ ] Signatures numériques
- [ ] Modèles de rapport personnalisés
- [ ] Export en Word/Excel
- [ ] Notifications de suivi des actions
- [ ] Historique des modifications
- [ ] Partage sécurisé des rapports

## 🤝 Support

Pour toute question ou problème, veuillez consulter la documentation ou contacter l'administrateur de l'application.

---

**Dernière mise à jour:** 27 Mai 2026
**Version:** 1.0.0
