import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/entite_types.dart';

class DatabaseHelper {
  static const int _dbVersion = 7;
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eglise_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entites (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id TEXT,
        responsable_nom TEXT DEFAULT 'À définir'
      )
    ''');

    await db.execute('''
      CREATE TABLE districts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE communautes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        district_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE membres (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        postnom TEXT,
        prenom TEXT,
        sexe TEXT,
        date_naissance TEXT,
        lieu_naissance TEXT,
        nationalite TEXT,
        etat_civil TEXT,
        profession TEXT,
        nom_pere TEXT,
        pere_neo_apostolique INTEGER,
        nom_mere TEXT,
        mere_neo_apostolique INTEGER,
        membre_neo_apostolique INTEGER,
        adresse TEXT,
        telephone TEXT,
        email TEXT,
        eglise_territoriale TEXT,
        champ_apostolique TEXT,
        district_id TEXT,
        communaute_id TEXT,
        type_profil TEXT,
        statut_membre TEXT,
        communaute_origine TEXT,
        baptise INTEGER,
        date_bapteme TEXT,
        scelle INTEGER,
        date_scellement TEXT,
        sainte_cene INTEGER,
        fonction TEXT,
        commission TEXT,
        photo_path TEXT,
        statut_validation INTEGER DEFAULT 0,
        date_inscription TEXT,
        type_ordination TEXT,
        date_ordination TEXT,
        ordonne_par TEXT,
        date_retraite TEXT,
        statut_retraite INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE annonces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        date_publication TEXT NOT NULL,
        type_annonce TEXT NOT NULL DEFAULT 'COMMUNIQUE',
        auteur TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rapports (
        id TEXT PRIMARY KEY,
        group_id TEXT,
        entite_id TEXT,
        commission TEXT NOT NULL,
        date_activite TEXT NOT NULL,
        offrande_usd REAL NOT NULL DEFAULT 0,
        offrande_fc REAL NOT NULL DEFAULT 0,
        numero_recu TEXT NOT NULL,
        taches_json TEXT,
        statut INTEGER NOT NULL DEFAULT 0,
        created_by TEXT,
        created_at TEXT,
        updated_at TEXT,
        remote_id TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE rapport_transmissions (
        id TEXT PRIMARY KEY,
        rapport_id TEXT NOT NULL,
        dest_entite_id TEXT NOT NULL,
        dest_commission TEXT,
        statut INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        sent_at TEXT,
        received_at TEXT,
        remote_id TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE rapport_history (
        id TEXT PRIMARY KEY,
        rapport_id TEXT NOT NULL,
        action TEXT NOT NULL,
        actor_id TEXT,
        from_entite_id TEXT,
        to_entite_id TEXT,
        data_json TEXT,
        created_at TEXT,
        remote_id TEXT,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE bibliotheque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        type_document TEXT NOT NULL DEFAULT 'Document',
        commission TEXT,
        entite_id TEXT,
        niveau TEXT DEFAULT 'communaute',
        fichier_path TEXT,
        date_ajout TEXT NOT NULL,
        auteur_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE finances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type_offrande TEXT NOT NULL,
        montant REAL NOT NULL,
        devise TEXT NOT NULL,
        numero_recu TEXT NOT NULL,
        date_saisie TEXT NOT NULL,
        entite_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE evenements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT,
        date_evenement TEXT NOT NULL,
        type TEXT,
        niveau TEXT,
        commission_liee TEXT,
        auteur_id TEXT,
        entite_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE utilisateurs (
        id TEXT PRIMARY KEY,
        identifiant TEXT NOT NULL UNIQUE,
        mot_de_passe_hash TEXT NOT NULL,
        nom_complet TEXT NOT NULL,
        role TEXT NOT NULL,
        entite_id TEXT,
        type_entite TEXT,
        statut_validation INTEGER DEFAULT 0,
        date_inscription TEXT,
        role_label TEXT,
        ministere TEXT
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS entites (
          id TEXT PRIMARY KEY,
          nom TEXT NOT NULL,
          type TEXT NOT NULL,
          parent_id TEXT,
          responsable_nom TEXT DEFAULT 'À définir'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS utilisateurs (
          id TEXT PRIMARY KEY,
          identifiant TEXT NOT NULL UNIQUE,
          mot_de_passe_hash TEXT NOT NULL,
          nom_complet TEXT NOT NULL,
          role TEXT NOT NULL,
          entite_id TEXT,
          type_entite TEXT,
          statut_validation INTEGER DEFAULT 0,
          date_inscription TEXT,
          role_label TEXT,
          ministere TEXT
        )
      ''');

      try {
        await db.execute('ALTER TABLE membres ADD COLUMN date_inscription TEXT');
      } catch (_) {}

      try {
        await db.execute('ALTER TABLE finances ADD COLUMN entite_id TEXT');
      } catch (_) {}

      for (final col in [
        "ALTER TABLE evenements ADD COLUMN type TEXT",
        "ALTER TABLE evenements ADD COLUMN niveau TEXT",
        "ALTER TABLE evenements ADD COLUMN commission_liee TEXT",
        "ALTER TABLE evenements ADD COLUMN auteur_id TEXT",
        "ALTER TABLE evenements ADD COLUMN entite_id TEXT",
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }

      await _migrateLegacyHierarchy(db);
      await _seedInitialData(db, onlyIfEmpty: true);
    }
    if (oldVersion < 3) {
      await _normalizeEntiteTypeCodes(db);
      await _insertDefaultHierarchy(db);
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE utilisateurs ADD COLUMN statut_validation INTEGER DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE utilisateurs ADD COLUMN date_inscription TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE utilisateurs ADD COLUMN role_label TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE utilisateurs ADD COLUMN ministere TEXT');
      } catch (_) {}
      // Update existing admin account to be pre-validated
      try {
        await db.update('utilisateurs', {
          'statut_validation': 1,
          'date_inscription': DateTime.now().toIso8601String(),
          'role_label': 'Apôtre',
          'ministere': 'Commission de la Jeunesse'
        }, where: "identifiant = 'admin'");
      } catch (_) {}
    }
    if (oldVersion < 5) {
      for (final col in [
        "ALTER TABLE membres ADD COLUMN type_ordination TEXT",
        "ALTER TABLE membres ADD COLUMN date_ordination TEXT",
        "ALTER TABLE membres ADD COLUMN ordonne_par TEXT",
        "ALTER TABLE membres ADD COLUMN date_retraite TEXT",
        "ALTER TABLE membres ADD COLUMN statut_retraite INTEGER DEFAULT 0",
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bibliotheque (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titre TEXT NOT NULL,
            type_document TEXT NOT NULL DEFAULT 'Document',
            commission TEXT,
            entite_id TEXT,
            niveau TEXT DEFAULT 'communaute',
            fichier_path TEXT,
            date_ajout TEXT NOT NULL,
            auteur_id TEXT
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 6) {
      for (final col in [
        "ALTER TABLE annonces ADD COLUMN type_annonce TEXT NOT NULL DEFAULT 'COMMUNIQUE'",
        "ALTER TABLE annonces ADD COLUMN auteur TEXT",
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS annonces (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titre TEXT NOT NULL,
            contenu TEXT NOT NULL,
            date_publication TEXT NOT NULL,
            type_annonce TEXT NOT NULL DEFAULT 'COMMUNIQUE',
            auteur TEXT
          )
        ''');
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rapports (
            id TEXT PRIMARY KEY,
            group_id TEXT,
            entite_id TEXT,
            commission TEXT NOT NULL,
            date_activite TEXT NOT NULL,
            offrande_usd REAL NOT NULL DEFAULT 0,
            offrande_fc REAL NOT NULL DEFAULT 0,
            numero_recu TEXT NOT NULL,
            taches_json TEXT,
            statut INTEGER NOT NULL DEFAULT 0,
            created_by TEXT,
            created_at TEXT,
            updated_at TEXT,
            remote_id TEXT,
            version INTEGER NOT NULL DEFAULT 1
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 7) {
      for (final col in [
        "ALTER TABLE rapports ADD COLUMN group_id TEXT",
        "ALTER TABLE rapports ADD COLUMN created_by TEXT",
        "ALTER TABLE rapports ADD COLUMN created_at TEXT",
        "ALTER TABLE rapports ADD COLUMN updated_at TEXT",
        "ALTER TABLE rapports ADD COLUMN remote_id TEXT",
        "ALTER TABLE rapports ADD COLUMN version INTEGER NOT NULL DEFAULT 1",
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rapport_transmissions (
            id TEXT PRIMARY KEY,
            rapport_id TEXT NOT NULL,
            dest_entite_id TEXT NOT NULL,
            dest_commission TEXT,
            statut INTEGER NOT NULL DEFAULT 0,
            created_at TEXT,
            sent_at TEXT,
            received_at TEXT,
            remote_id TEXT,
            version INTEGER NOT NULL DEFAULT 1
          )
        ''');
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rapport_history (
            id TEXT PRIMARY KEY,
            rapport_id TEXT NOT NULL,
            action TEXT NOT NULL,
            actor_id TEXT,
            from_entite_id TEXT,
            to_entite_id TEXT,
            data_json TEXT,
            created_at TEXT,
            remote_id TEXT,
            version INTEGER NOT NULL DEFAULT 1
          )
        ''');
      } catch (_) {}
    }
  }

  Future<void> _normalizeEntiteTypeCodes(Database db) async {
    final rows = await db.query('entites');
    for (final row in rows) {
      final id = row['id']?.toString();
      final oldType = row['type']?.toString();
      if (id == null || oldType == null) continue;
      final newType = EntiteTypes.normalize(oldType);
      if (newType != oldType) {
        await db.update('entites', {'type': newType}, where: 'id = ?', whereArgs: [id]);
      }
    }
    final champ = await db.query('entites', where: 'id = ?', whereArgs: ['CHAMP_01'], limit: 1);
    if (champ.isNotEmpty && champ.first['parent_id'] == null) {
      await db.update(
        'entites',
        {'parent_id': 'ET_01'},
        where: 'id = ?',
        whereArgs: ['CHAMP_01'],
      );
    }
  }

  Future<void> _migrateLegacyHierarchy(Database db) async {
    final existing = await db.query('entites', limit: 1);
    if (existing.isNotEmpty) return;

    await db.insert('entites', {
      'id': 'ET_01',
      'nom': 'ENA RDC Ouest',
      'type': EntiteTypes.egliseTerritoriale,
      'parent_id': null,
      'responsable_nom': 'APD Élie Tatien Mukinda Mudinganyi',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('entites', {
      'id': 'CHAMP_01',
      'nom': 'Kinshasa Sud-Ouest',
      'type': EntiteTypes.champApostolique,
      'parent_id': 'ET_01',
      'responsable_nom': 'Apôtre Emmanuel Ngolo Woto',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    final districts = await db.query('districts');
    for (final d in districts) {
      final distId = d['id'].toString();
      await db.insert('entites', {
        'id': distId,
        'nom': d['nom'],
        'type': EntiteTypes.district,
        'parent_id': 'CHAMP_01',
        'responsable_nom': 'À définir',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final communautes = await db.query('communautes');
    for (final c in communautes) {
      final commId = c['id'].toString();
      await db.insert('entites', {
        'id': commId,
        'nom': c['nom'],
        'type': EntiteTypes.communaute,
        'parent_id': c['district_id']?.toString(),
        'responsable_nom': 'À définir',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedInitialData(Database db, {bool onlyIfEmpty = false}) async {
    if (onlyIfEmpty) {
      await _ensureDefaultUser(db);
      await _insertDefaultHierarchy(db);
      return;
    }

    await _insertDefaultHierarchy(db);

    await db.insert('districts', {'nom': 'Ngomba-Kinkusa'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('communautes', {
      'nom': 'Communauté Modèle',
      'district_id': 'DIST_01',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _ensureDefaultUser(db);
  }

  Future<void> _insertDefaultHierarchy(Database db) async {
    await db.insert('entites', {
      'id': 'ET_01',
      'nom': 'ENA RDC Ouest',
      'type': EntiteTypes.egliseTerritoriale,
      'parent_id': null,
      'responsable_nom': 'APD Élie Tatien Mukinda Mudinganyi',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('entites', {
      'id': 'CHAMP_01',
      'nom': 'Kinshasa Sud-Ouest',
      'type': EntiteTypes.champApostolique,
      'parent_id': 'ET_01',
      'responsable_nom': 'Apôtre Emmanuel Ngolo Woto',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('entites', {
      'id': 'CHAMP_02',
      'nom': 'Kinshasa Sud-Est',
      'type': EntiteTypes.champApostolique,
      'parent_id': 'ET_01',
      'responsable_nom': 'Apôtre Mpaka Gilbert Nzakimuena',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('entites', {
      'id': 'DIST_01',
      'nom': 'Ngomba-Kinkusa',
      'type': EntiteTypes.district,
      'parent_id': 'CHAMP_01',
      'responsable_nom': 'Ancien Théophile Buweka',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('entites', {
      'id': 'COMM_01',
      'nom': 'Communauté Modèle',
      'type': EntiteTypes.communaute,
      'parent_id': 'DIST_01',
      'responsable_nom': 'À définir',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _ensureDefaultUser(Database db) async {
    final users = await db.query('utilisateurs', where: 'identifiant = ?', whereArgs: ['admin']);
    if (users.isNotEmpty) return;

    await db.insert('utilisateurs', {
      'id': 'USR_ADMIN',
      'identifiant': 'admin',
      'mot_de_passe_hash': hashPassword('Admin@1234'),
      'nom_complet': 'Nestor Mbuyi Kankolongo',
      'role': 'SUPER_ADMIN',
      'entite_id': null,
      'type_entite': EntiteTypes.champApostolique,
      'statut_validation': 1,
      'date_inscription': DateTime.now().toIso8601String(),
      'role_label': 'Apôtre',
      'ministere': 'Commission de la Jeunesse',
    });
  }

  // --- HIÉRARCHIE (4 niveaux) ---
  Future<List<Map<String, dynamic>>> getEglisesTerritoriales() async {
    final db = await database;
    return db.query(
      'entites',
      where: 'type = ?',
      whereArgs: [EntiteTypes.egliseTerritoriale],
      orderBy: 'nom ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getChampsApostoliques(String egliseId) async {
    return getSubEntites(egliseId, EntiteTypes.champApostolique);
  }

  Future<List<Map<String, dynamic>>> getDistricts({String? champId}) async {
    final db = await database;
    if (champId != null && champId.isNotEmpty) {
      return getSubEntites(champId, EntiteTypes.district);
    }
    return db.query(
      'entites',
      where: 'type = ?',
      whereArgs: [EntiteTypes.district],
      orderBy: 'nom ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getCommunautesByDistrict(String districtId) async {
    return getSubEntites(districtId, EntiteTypes.communaute);
  }

  /// Enfants d'un parent, ou églises territoriales si [parentId] est null et [childType] est EGLISE_TERRITORIALE.
  Future<List<Map<String, dynamic>>> getSubEntites(String? parentId, String childType) async {
    final db = await database;
    final type = EntiteTypes.normalize(childType);
    if (parentId == null || parentId.isEmpty) {
      return db.query(
        'entites',
        where: 'parent_id IS NULL AND type = ?',
        whereArgs: [type],
        orderBy: 'nom ASC',
      );
    }
    return db.query(
      'entites',
      where: 'parent_id = ? AND type = ?',
      whereArgs: [parentId, type],
      orderBy: 'nom ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllEntites() async {
    final db = await database;
    return db.query('entites', orderBy: 'type, nom');
  }

  Future<List<Map<String, dynamic>>> getEntitesByType(String type) async {
    final db = await database;
    return db.query(
      'entites',
      where: 'type = ?',
      whereArgs: [EntiteTypes.normalize(type)],
      orderBy: 'nom ASC',
    );
  }

  Future<Map<String, dynamic>?> getEntiteById(String id) async {
    final db = await database;
    final rows = await db.query('entites', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Remonte la chaîne parentale jusqu'à la racine.
  Future<List<Map<String, dynamic>>> getChaineAncestres(String entiteId) async {
    final chain = <Map<String, dynamic>>[];
    Map<String, dynamic>? current = await getEntiteById(entiteId);
    while (current != null) {
      chain.insert(0, current);
      final parentId = current['parent_id']?.toString();
      if (parentId == null || parentId.isEmpty) break;
      current = await getEntiteById(parentId);
    }
    return chain;
  }

  /// Comptages districts / communautés (optionnellement sous un champ).
  Future<Map<String, int>> getEntiteCounts({String? champId}) async {
    final db = await database;
    if (champId != null && champId.isNotEmpty) {
      final districts = await getSubEntites(champId, EntiteTypes.district);
      var commCount = 0;
      for (final d in districts) {
        final comms = await getSubEntites(d['id'].toString(), EntiteTypes.communaute);
        commCount += comms.length;
      }
      return {'districts': districts.length, 'communautes': commCount, 'champs': 1};
    }
    final d = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM entites WHERE type = ?',
          [EntiteTypes.district],
        )) ??
        0;
    final c = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM entites WHERE type = ?',
          [EntiteTypes.communaute],
        )) ??
        0;
    final ch = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM entites WHERE type = ?',
          [EntiteTypes.champApostolique],
        )) ??
        0;
    return {'districts': d, 'communautes': c, 'champs': ch};
  }

  Future<int> insertEntite({
    required String id,
    required String nom,
    required String type,
    String? parentId,
    String responsableNom = 'À définir',
  }) async {
    final db = await database;
    return db.insert('entites', {
      'id': id,
      'nom': nom,
      'type': type,
      'parent_id': parentId,
      'responsable_nom': responsableNom,
    });
  }

  Future<int> insertCommunaute(Map<String, dynamic> row) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final nom = row['nom'] as String;
    final districtId = row['district_id']?.toString();
    await insertEntite(id: id, nom: nom, type: EntiteTypes.communaute, parentId: districtId);
    final db = await database;
    return db.insert('communautes', {
      'nom': nom,
      'district_id': districtId ?? '',
    });
  }

  // --- UTILISATEURS ---
  Future<Map<String, dynamic>?> getUtilisateurByIdentifiant(String identifiant) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT * FROM utilisateurs WHERE LOWER(identifiant) = ? LIMIT 1',
      [identifiant.toLowerCase()],
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<bool> identifiantExiste(String identifiant) async {
    final user = await getUtilisateurByIdentifiant(identifiant);
    return user != null;
  }

  Future<int> creerUtilisateur({
    required String identifiant,
    required String motDePasseHash,
    required String nomComplet,
    required String role,
    String? entiteId,
    String? typeEntite,
    String? roleLabel,
    String? ministere,
  }) async {
    final db = await database;
    return db.insert('utilisateurs', {
      'id': 'USR_${DateTime.now().millisecondsSinceEpoch}',
      'identifiant': identifiant.toLowerCase(),
      'mot_de_passe_hash': motDePasseHash,
      'nom_complet': nomComplet,
      'role': role,
      'entite_id': entiteId,
      'type_entite': typeEntite ?? EntiteTypes.communaute,
      'statut_validation': 0, // En attente
      'date_inscription': DateTime.now().toIso8601String(),
      'role_label': roleLabel,
      'ministere': ministere,
    });
  }

  Future<int> validerUtilisateur(String id) async {
    final db = await database;
    return db.update('utilisateurs', {'statut_validation': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> supprimerUtilisateur(String id) async {
    final db = await database;
    return db.delete('utilisateurs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUtilisateursEnAttente({String? entiteId}) async {
    final db = await database;
    // Auto-nettoyage des inscriptions de plus de 3 jours expirées
    final now = DateTime.now();
    final users = await db.query('utilisateurs', where: 'statut_validation = ?', whereArgs: [0]);
    for (final u in users) {
      final dateStr = u['date_inscription']?.toString();
      if (dateStr != null && dateStr.isNotEmpty) {
        final d = DateTime.tryParse(dateStr);
        if (d != null && now.difference(d).inDays >= 3) {
          await supprimerUtilisateur(u['id'] as String);
        }
      }
    }

    if (entiteId == null || entiteId == 'TOUS') {
      return db.query('utilisateurs', where: 'statut_validation = ? AND role != ?', whereArgs: [0, 'SUPER_ADMIN'], orderBy: 'nom_complet ASC');
    }
    return db.query(
      'utilisateurs',
      where: 'statut_validation = ? AND entite_id = ? AND role != ?',
      whereArgs: [0, entiteId, 'SUPER_ADMIN'],
      orderBy: 'nom_complet ASC',
    );
  }

  Future<int> mettreAJourMotDePasse(String identifiant, String motDePasseHash) async {
    final db = await database;
    return db.update(
      'utilisateurs',
      {'mot_de_passe_hash': motDePasseHash},
      where: 'LOWER(identifiant) = ?',
      whereArgs: [identifiant.toLowerCase()],
    );
  }

  Future<List<Map<String, dynamic>>> getCommunautesAvecChemin() async {
    final db = await database;
    final all = await db.query('entites');
    final byId = {for (final e in all) e['id'].toString(): e};
    final comms = all.where((e) => EntiteTypes.normalize(e['type']?.toString()) == EntiteTypes.communaute);

    String chemin(String id) {
      final parts = <String>[];
      Map<String, dynamic>? current = byId[id];
      while (current != null) {
        parts.insert(0, current['nom']?.toString() ?? '');
        final pid = current['parent_id']?.toString();
        current = pid != null ? byId[pid] : null;
      }
      return parts.join(' › ');
    }

    return comms
        .map((c) => {
              'id': c['id'].toString(),
              'nom': c['nom']?.toString() ?? '',
              'chemin': chemin(c['id'].toString()),
            })
        .toList()
      ..sort((a, b) => (a['chemin'] as String).compareTo(b['chemin'] as String));
  }

  // --- MEMBRES ---
  Future<int> insertMembre(Map<String, dynamic> row) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data.putIfAbsent('date_inscription', () => DateTime.now().toIso8601String());
    data.putIfAbsent('statut_validation', () => 0);
    return db.insert('membres', data);
  }

  Future<int> updateMembre(String id, Map<String, dynamic> row) async {
    final db = await database;
    return db.update('membres', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> validerMembre(String id) async {
    final db = await database;
    return db.update('membres', {'statut_validation': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> supprimerMembre(String id) async {
    final db = await database;
    return db.delete('membres', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMembresEnAttente({String? communauteId}) async {
    final db = await database;
    if (communauteId == null || communauteId == 'TOUS') {
      return db.query('membres', where: 'statut_validation = ?', whereArgs: [0], orderBy: 'nom ASC');
    }
    return db.query(
      'membres',
      where: 'statut_validation = ? AND communaute_id = ?',
      whereArgs: [0, communauteId],
      orderBy: 'nom ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getMembresValides({
    String? communauteId,
    String? commission,
  }) async {
    final db = await database;
    String where = 'statut_validation = ?';
    final args = <dynamic>[1];
    if (communauteId != null && communauteId.isNotEmpty) {
      where += ' AND communaute_id = ?';
      args.add(communauteId);
    }
    if (commission != null && commission.isNotEmpty) {
      where += ' AND commission = ?';
      args.add(commission);
    }
    return db.query('membres', where: where, whereArgs: args, orderBy: 'nom ASC');
  }

  Future<int> getTotalMembres({String? communauteId}) async {
    final db = await database;
    if (communauteId != null && communauteId.isNotEmpty) {
      return Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM membres WHERE statut_validation = 1 AND communaute_id = ?',
            [communauteId],
          )) ??
          0;
    }
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM membres WHERE statut_validation = 1'),
        ) ??
        0;
  }

  Future<int> getUnvalidatedCount({String? communauteId}) async {
    final db = await database;
    if (communauteId != null && communauteId.isNotEmpty) {
      return Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM membres WHERE statut_validation = 0 AND communaute_id = ?',
            [communauteId],
          )) ??
          0;
    }
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM membres WHERE statut_validation = 0'),
        ) ??
        0;
  }

  // --- STATISTIQUES ---
  Future<Map<String, int>> getStatsCommissions({String? districtId}) async {
    final db = await database;
    String where = 'statut_validation = 1';
    final args = <dynamic>[];
    if (districtId != null && districtId.isNotEmpty) {
      where += ' AND district_id = ?';
      args.add(districtId);
    }
    final res = await db.rawQuery(
      'SELECT commission, COUNT(*) as count FROM membres WHERE $where GROUP BY commission',
      args,
    );
    return {for (var item in res) (item['commission'] ?? 'Autre').toString(): item['count'] as int};
  }

  Future<Map<String, int>> getStatsSacrements({String? districtId}) async {
    final db = await database;
    String filter = '';
    final args = <dynamic>[];
    if (districtId != null && districtId.isNotEmpty) {
      filter = ' AND district_id = ?';
      args.add(districtId);
    }
    final b = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM membres WHERE baptise = 1$filter',
          args,
        )) ??
        0;
    final s = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM membres WHERE scelle = 1$filter',
          args,
        )) ??
        0;
    return {'Baptisés': b, 'Scellés': s};
  }

  // --- ÉVÉNEMENTS ---
  Future<List<Map<String, dynamic>>> getEvenements({String? entiteId}) async {
    final db = await database;
    if (entiteId != null && entiteId.isNotEmpty) {
      return db.query(
        'evenements',
        where: 'entite_id = ? OR entite_id IS NULL',
        whereArgs: [entiteId],
        orderBy: 'date_evenement ASC',
      );
    }
    return db.query('evenements', orderBy: 'date_evenement ASC');
  }

  Future<int> insertEvenement(Map<String, dynamic> row) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data.remove('id');
    if (data.containsKey('date_debut')) {
      data['date_evenement'] = data.remove('date_debut');
    }
    return db.insert('evenements', data);
  }

  // --- ANNONCES & FINANCES ---
  Future<List<Map<String, dynamic>>> getAnnoncesRecent() async {
    final db = await database;
    return db.query('annonces', orderBy: 'date_publication DESC', limit: 10);
  }

  Future<int> insertAnnonce(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('annonces', row);
  }

  Future<List<Map<String, dynamic>>> getAnniversairesDuJour() async {
    final db = await database;
    final dateDuJour = DateTime.now().toIso8601String().substring(5, 10);
    return db.rawQuery(
      "SELECT nom, prenom, telephone, date_naissance FROM membres WHERE strftime('%m-%d', date_naissance) = ?",
      [dateDuJour],
    );
  }

  Future<List<Map<String, dynamic>>> getJournalFinancier({String? entiteId}) async {
    final db = await database;
    if (entiteId != null && entiteId.isNotEmpty) {
      return db.query(
        'finances',
        where: 'entite_id = ?',
        whereArgs: [entiteId],
        orderBy: 'date_saisie DESC',
      );
    }
    return db.query('finances', orderBy: 'date_saisie DESC');
  }

  Future<int> insertFinances(Map<String, dynamic> row) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data.remove('id');
    if (data.containsKey('date_paiement')) {
      data['date_saisie'] = data.remove('date_paiement');
    }
    data.putIfAbsent('date_saisie', () => DateTime.now().toIso8601String().split('T').first);
    return db.insert('finances', data);
  }

  Future<int> transfererMembre(
    String membreId,
    String nuevoDistrictId,
    String nouvelleCommunauteId,
    String commOrigine,
  ) async {
    final db = await database;
    return db.update(
      'membres',
      {
        'district_id': nuevoDistrictId,
        'communaute_id': nouvelleCommunauteId,
        'communaute_origine': commOrigine,
        'statut_membre': 'Transfert',
      },
      where: 'id = ?',
      whereArgs: [membreId],
    );
  }

  Future<Map<String, int>> getStatsRetraite({String? entiteId}) async {
    final db = await database;
    final now = DateTime.now();
    final retraiteLimit = DateTime(now.year - 65, now.month, now.day);
    final dateStr = retraiteLimit.toIso8601String().split('T').first;

    String where = 'statut_validation = 1 AND date_naissance IS NOT NULL AND date_naissance != \'\'';
    final args = <dynamic>[];
    if (entiteId != null && entiteId.isNotEmpty) {
      where += ' AND communaute_id = ?';
      args.add(entiteId);
    }

    final proches = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM membres WHERE $where AND date_naissance >= ?',
      [...args, dateStr],
    );
    final retraites = await db.query('membres',
      where: 'statut_retraite = ?', whereArgs: [1]);

    final total = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM membres WHERE $where', args)) ?? 0;

    return {
      'total': total,
      'proches_retraite': Sqflite.firstIntValue(proches) ?? 0,
      'deja_retraites': retraites.length,
    };
  }

  Future<List<Map<String, dynamic>>> getMembresProchesRetraite({String? entiteId}) async {
    final db = await database;
    final now = DateTime.now();
    final retraiteLimit = DateTime(now.year - 65, now.month, now.day);
    final dateStr = retraiteLimit.toIso8601String().split('T').first;

    String where = 'statut_validation = 1 AND date_naissance IS NOT NULL AND date_naissance != \'\' AND date_naissance >= ?';
    final args = <dynamic>[dateStr];
    if (entiteId != null && entiteId.isNotEmpty) {
      where += ' AND communaute_id = ?';
      args.add(entiteId);
    }
    return db.query('membres', where: where, whereArgs: args, orderBy: 'date_naissance ASC');
  }

  Future<List<Map<String, dynamic>>> getBibliotheque({
    String? entiteId,
    String? commission,
    String? niveau,
  }) async {
    final db = await database;
    String where = '1=1';
    final args = <dynamic>[];
    if (entiteId != null && entiteId.isNotEmpty) {
      where += ' AND entite_id = ?';
      args.add(entiteId);
    }
    if (commission != null && commission.isNotEmpty) {
      where += ' AND commission = ?';
      args.add(commission);
    }
    if (niveau != null && niveau.isNotEmpty) {
      where += ' AND niveau = ?';
      args.add(niveau);
    }
    return db.query('bibliotheque', where: where, whereArgs: args, orderBy: 'date_ajout DESC');
  }

  Future<int> insertDocument(Map<String, dynamic> row) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data.putIfAbsent('date_ajout', () => DateTime.now().toIso8601String());
    data.putIfAbsent('type_document', () => 'Document');
    data.putIfAbsent('niveau', () => 'communaute');
    return db.insert('bibliotheque', data);
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return db.delete('bibliotheque', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertRapport(Map<String, dynamic> row) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data.putIfAbsent('id', () => DateTime.now().millisecondsSinceEpoch.toString());
    data.putIfAbsent('group_id', () => data['id']);
    data.putIfAbsent('created_at', () => DateTime.now().toIso8601String());
    data.putIfAbsent('updated_at', () => DateTime.now().toIso8601String());
    data.putIfAbsent('version', () => 1);
    return db.insert('rapports', data);
  }

  Future<List<Map<String, dynamic>>> getRapportsEmis({
    String? entiteId,
    String? commission,
  }) async {
    final db = await database;
    String where = '1=1';
    final args = <dynamic>[];
    if (entiteId != null && entiteId.isNotEmpty) {
      where += ' AND entite_id = ?';
      args.add(entiteId);
    }
    if (commission != null && commission.isNotEmpty) {
      where += ' AND commission = ?';
      args.add(commission);
    }
    return db.query('rapports', where: where, whereArgs: args, orderBy: 'date_activite DESC');
  }

  Future<List<Map<String, dynamic>>> getRapportsRecus({
    required String destEntiteId,
    String? destCommission,
  }) async {
    final db = await database;
    final where = destCommission == null || destCommission.isEmpty
        ? 't.dest_entite_id = ?'
        : 't.dest_entite_id = ? AND (t.dest_commission = ? OR t.dest_commission IS NULL OR t.dest_commission = \'\')';
    final args = destCommission == null || destCommission.isEmpty
        ? [destEntiteId]
        : [destEntiteId, destCommission];
    return db.rawQuery('''
      SELECT r.*,
             t.id AS transmission_id,
             t.dest_entite_id AS dest_entite_id,
             t.dest_commission AS dest_commission,
             t.statut AS transmission_statut,
             t.sent_at AS sent_at,
             t.received_at AS received_at
      FROM rapport_transmissions t
      JOIN rapports r ON r.id = t.rapport_id
      WHERE $where
      ORDER BY t.sent_at DESC, r.date_activite DESC
    ''', args);
  }

  Future<String?> getParentEntiteId(String entiteId) async {
    final ent = await getEntiteById(entiteId);
    return ent?['parent_id']?.toString();
  }

  Future<void> transmettreRapport({
    required String rapportId,
    required String actorId,
  }) async {
    final db = await database;
    final rows = await db.query('rapports', where: 'id = ?', whereArgs: [rapportId], limit: 1);
    if (rows.isEmpty) return;
    final r = rows.first;
    final fromEntiteId = r['entite_id']?.toString() ?? '';
    if (fromEntiteId.isEmpty) return;
    await transmettreRapportDepuis(
      rapportId: rapportId,
      fromEntiteId: fromEntiteId,
      actorId: actorId,
    );
  }

  Future<void> transmettreRapportDepuis({
    required String rapportId,
    required String fromEntiteId,
    required String actorId,
  }) async {
    final db = await database;
    final rows = await db.query('rapports', where: 'id = ?', whereArgs: [rapportId], limit: 1);
    if (rows.isEmpty) return;
    final r = rows.first;
    final commission = r['commission']?.toString() ?? '';
    if (commission.isEmpty) return;

    final parentId = await getParentEntiteId(fromEntiteId);
    if (parentId == null || parentId.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    final transmissions = [
      {
        'id': 'TX_${DateTime.now().microsecondsSinceEpoch}_E',
        'rapport_id': rapportId,
        'dest_entite_id': parentId,
        'dest_commission': null,
        'statut': 1,
        'created_at': now,
        'sent_at': now,
        'version': 1,
      },
      {
        'id': 'TX_${DateTime.now().microsecondsSinceEpoch}_C',
        'rapport_id': rapportId,
        'dest_entite_id': parentId,
        'dest_commission': commission,
        'statut': 1,
        'created_at': now,
        'sent_at': now,
        'version': 1,
      },
    ];
    for (final t in transmissions) {
      await db.insert('rapport_transmissions', t, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await db.insert('rapport_history', {
      'id': 'H_${DateTime.now().microsecondsSinceEpoch}',
      'rapport_id': rapportId,
      'action': 'TRANSMIS',
      'actor_id': actorId,
      'from_entite_id': fromEntiteId,
      'to_entite_id': parentId,
      'data_json': jsonEncode({
        'destinations': [
          {'dest_entite_id': parentId, 'dest_commission': null},
          {'dest_entite_id': parentId, 'dest_commission': commission},
        ]
      }),
      'created_at': now,
      'version': 1,
    });

    final currentStatut = int.tryParse(r['statut']?.toString() ?? '') ?? 0;
    await db.update(
      'rapports',
      {
        'statut': currentStatut < 2 ? 2 : currentStatut,
        'updated_at': now,
        'version': (r['version'] as int? ?? 1) + 1,
      },
      where: 'id = ?',
      whereArgs: [rapportId],
    );
  }
}
