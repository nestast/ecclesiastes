import 'package:flutter/material.dart';

// Énumérations pour les niveaux d'utilisateurs
enum UserLevel {
  apostle,      // Apôtre
  bishop,       // Évêque
  deacon,       // Diacre
  committeeLead, // Responsable Commission
  minister,     // Ministre
  member        // Membre
}

enum EntityLevel {
  commission,
  district,
  community
}

enum EventType {
  divinService,      // Service Divin
  baptism,           // Baptême
  sealed,            // Scellé
  confirmation,      // Confirmation
  ordination,        // Ordination
  funeral,           // Funérailles
  ecodim,            // ECODIM (École du dimanche)
  youthActivity,     // Activité Jeunesse
  meeting,           // Réunion
  retreat            // Retraite
}

/// Modèle pour un utilisateur
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserLevel level;
  final String? ministry;
  final String apostleField;
  final String district;
  final String community;
  final bool isActive;
  
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    this.ministry,
    required this.apostleField,
    required this.district,
    required this.community,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level.toString(),
      'ministry': ministry,
      'apostleField': apostleField,
      'district': district,
      'community': community,
      'isActive': isActive,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      level: UserLevel.values.firstWhere(
        (e) => e.toString() == map['level'],
        orElse: () => UserLevel.member,
      ),
      ministry: map['ministry'] as String?,
      apostleField: map['apostleField'] as String,
      district: map['district'] as String,
      community: map['community'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// Modèle pour un événement
class ChurchEvent {
  final String id;
  final String title;
  final EventType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String? apostleField;
  final String? district;
  final String? community;
  final String officiator;
  final List<String> assistants;
  final String description;
  final int expectedMembers;
  final int actualMembers;
  final double offering;
  final String offeringCurrency;
  final String status; // planned, ongoing, completed
  final DateTime createdAt;
  final String createdBy;

  ChurchEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.location,
    this.apostleField,
    this.district,
    this.community,
    required this.officiator,
    required this.assistants,
    required this.description,
    this.expectedMembers = 0,
    this.actualMembers = 0,
    this.offering = 0,
    this.offeringCurrency = 'FC',
    this.status = 'planned',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'apostleField': apostleField,
      'district': district,
      'community': community,
      'officiator': officiator,
      'assistants': assistants.join(','),
      'description': description,
      'expectedMembers': expectedMembers,
      'actualMembers': actualMembers,
      'offering': offering,
      'offeringCurrency': offeringCurrency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory ChurchEvent.fromMap(Map<String, dynamic> map) {
    return ChurchEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      type: EventType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => EventType.divinService,
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      location: map['location'] as String,
      apostleField: map['apostleField'] as String?,
      district: map['district'] as String?,
      community: map['community'] as String?,
      officiator: map['officiator'] as String,
      assistants: (map['assistants'] as String).split(',').where((e) => e.isNotEmpty).toList(),
      description: map['description'] as String,
      expectedMembers: map['expectedMembers'] as int? ?? 0,
      actualMembers: map['actualMembers'] as int? ?? 0,
      offering: (map['offering'] as num?)?.toDouble() ?? 0,
      offeringCurrency: map['offeringCurrency'] as String? ?? 'FC',
      status: map['status'] as String? ?? 'planned',
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String,
    );
  }
}

/// Modèle pour un responsable d'entité avec suppléant
class EntityResponsible {
  final String id;
  final String entityId;
  final String entityName;
  final EntityLevel entityLevel; // commission, district, community
  final String principalName;
  final String? principalEmail;
  final String? deputyName;
  final String? deputyEmail;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  EntityResponsible({
    required this.id,
    required this.entityId,
    required this.entityName,
    required this.entityLevel,
    required this.principalName,
    this.principalEmail,
    this.deputyName,
    this.deputyEmail,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityId': entityId,
      'entityName': entityName,
      'entityLevel': entityLevel.toString(),
      'principalName': principalName,
      'principalEmail': principalEmail,
      'deputyName': deputyName,
      'deputyEmail': deputyEmail,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory EntityResponsible.fromMap(Map<String, dynamic> map) {
    return EntityResponsible(
      id: map['id'] as String,
      entityId: map['entityId'] as String,
      entityName: map['entityName'] as String,
      entityLevel: EntityLevel.values.firstWhere(
        (e) => e.toString() == map['entityLevel'],
        orElse: () => EntityLevel.community,
      ),
      principalName: map['principalName'] as String,
      principalEmail: map['principalEmail'] as String?,
      deputyName: map['deputyName'] as String?,
      deputyEmail: map['deputyEmail'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// Modèle pour une commission
class Commission {
  final String id;
  final String name;
  final String? description;
  final String communityId;
  final String communityName;
  final String responsibleName;
  final String? responsibleEmail;
  final String? deputyName;
  final String? deputyEmail;
  final List<String> memberIds;
  final int expectedMembers;
  final int activeMembers;
  final String status; // active, inactive
  final DateTime createdAt;

  Commission({
    required this.id,
    required this.name,
    this.description,
    required this.communityId,
    required this.communityName,
    required this.responsibleName,
    this.responsibleEmail,
    this.deputyName,
    this.deputyEmail,
    this.memberIds = const [],
    this.expectedMembers = 0,
    this.activeMembers = 0,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'communityId': communityId,
      'communityName': communityName,
      'responsibleName': responsibleName,
      'responsibleEmail': responsibleEmail,
      'deputyName': deputyName,
      'deputyEmail': deputyEmail,
      'memberIds': memberIds.join(','),
      'expectedMembers': expectedMembers,
      'activeMembers': activeMembers,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Commission.fromMap(Map<String, dynamic> map) {
    return Commission(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      communityId: map['communityId'] as String,
      communityName: map['communityName'] as String,
      responsibleName: map['responsibleName'] as String,
      responsibleEmail: map['responsibleEmail'] as String?,
      deputyName: map['deputyName'] as String?,
      deputyEmail: map['deputyEmail'] as String?,
      memberIds: (map['memberIds'] as String).split(',').where((e) => e.isNotEmpty).toList(),
      expectedMembers: map['expectedMembers'] as int? ?? 0,
      activeMembers: map['activeMembers'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

/// Modèle pour un rapport de sacristie
class SacristyReport {
  final String id;
  final String eventId;
  final DateTime date;
  final int memberCount;
  final int visitorCount;
  final List<String> presentMembers;
  final List<String> saintSealed;
  final String churchOrder;
  final double offeringAmount;
  final List<String> chaliceOpeners; // Ouverture des calices
  final List<String> chaliceClosers; // Couverture des calices
  final List<String> holySceneDistributors; // Distribution de la Sainte Scène
  final List<String> sickList;
  final String observations;
  final String reporterName;
  final DateTime createdAt;

  SacristyReport({
    required this.id,
    required this.eventId,
    required this.date,
    required this.memberCount,
    required this.visitorCount,
    required this.presentMembers,
    required this.saintSealed,
    required this.churchOrder,
    required this.offeringAmount,
    required this.chaliceOpeners,
    required this.chaliceClosers,
    required this.holySceneDistributors,
    required this.sickList,
    required this.observations,
    required this.reporterName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'date': date.toIso8601String(),
      'memberCount': memberCount,
      'visitorCount': visitorCount,
      'presentMembers': presentMembers.join('|'),
      'saintSealed': saintSealed.join('|'),
      'churchOrder': churchOrder,
      'offeringAmount': offeringAmount,
      'chaliceOpeners': chaliceOpeners.join('|'),
      'chaliceClosers': chaliceClosers.join('|'),
      'holySceneDistributors': holySceneDistributors.join('|'),
      'sickList': sickList.join('|'),
      'observations': observations,
      'reporterName': reporterName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SacristyReport.fromMap(Map<String, dynamic> map) {
    return SacristyReport(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      date: DateTime.parse(map['date'] as String),
      memberCount: map['memberCount'] as int,
      visitorCount: map['visitorCount'] as int,
      presentMembers: (map['presentMembers'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      saintSealed: (map['saintSealed'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      churchOrder: map['churchOrder'] as String,
      offeringAmount: (map['offeringAmount'] as num).toDouble(),
      chaliceOpeners: (map['chaliceOpeners'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      chaliceClosers: (map['chaliceClosers'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      holySceneDistributors: (map['holySceneDistributors'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      sickList: (map['sickList'] as String).split('|').where((e) => e.isNotEmpty).toList(),
      observations: map['observations'] as String,
      reporterName: map['reporterName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
