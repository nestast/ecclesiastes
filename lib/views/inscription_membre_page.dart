import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:uuid/uuid.dart';

class InscriptionMembrePage extends StatefulWidget {
  const InscriptionMembrePage({super.key});

  @override
  State<InscriptionMembrePage> createState() => _InscriptionMembrePageState();
}

class _InscriptionMembrePageState extends State<InscriptionMembrePage> {
  final _formKey = GlobalKey<FormState>();
  
  // I. IDENTITÉ
  final _nomController = TextEditingController();
  final _postnomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _lieuNaisController = TextEditingController();
  final _nationaliteController = TextEditingController(text: "Congolaise");
  final _professionController = TextEditingController();
  String _sexe = 'M';
  String _etatCivil = 'Célibataire';
  DateTime _dateNaissance = DateTime(2000, 1, 1);

  // II. FILIATION
  final _nomPereController = TextEditingController();
  final _nomMereController = TextEditingController();
  int _pereNeo = 0; 
  int _mereNeo = 0;
  int _membreNeo = 0;

  // III. COORDONNÉES
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();

  // IV. FILTRE PAR ENTITÉ (4 niveaux)
  String? _selectedEgliseId;
  String? _selectedChampId;
  String? _selectedDistrict;
  String? _selectedCommunaute;
  
  final _newCommunauteController = TextEditingController();
  String _statutMembre = 'Nouveau'; 
  final _communauteOrigineController = TextEditingController();

  // TYPE PROFIL
  String _typeProfil = 'Membre'; 
  final _fonctionController = TextEditingController();

  // V. VIE SACRAMENTELLE
  bool _isBaptise = false;
  DateTime? _dateBapteme;
  bool _isScelle = false;
  DateTime? _dateScellement;
  bool _sainteCene = false;

  // VI. COMMISSIONS
  String? _selectedCommission;

  // VII. ORDINATION (Réforme : Ordination / Mandatement / Nomination)
  String? _typeOrdination;
  DateTime? _dateOrdination;
  final _ordonneParController = TextEditingController();

  File? _image;

  List<Map<String, dynamic>> _eglises = [];
  List<Map<String, dynamic>> _champs = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _communautes = [];

  final List<String> _commissions = [
    'Chorale', 'Jeunesse', 'Femmes', 'Hommes', 'Diaconie', 'Ecole du Dimanche', 'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _chargerEglises();
  }

  Future<void> _chargerEglises() async {
    final data = await DatabaseHelper.instance.getEglisesTerritoriales();
    if (mounted) setState(() => _eglises = data);
  }

  Future<void> _onEgliseChanged(String? egliseId) async {
    setState(() {
      _selectedEgliseId = egliseId;
      _selectedChampId = null;
      _selectedDistrict = null;
      _selectedCommunaute = null;
      _champs = [];
      _districts = [];
      _communautes = [];
    });
    if (egliseId != null) {
      final data = await DatabaseHelper.instance.getChampsApostoliques(egliseId);
      if (mounted) setState(() => _champs = data);
    }
  }

  Future<void> _onChampChanged(String? champId) async {
    setState(() {
      _selectedChampId = champId;
      _selectedDistrict = null;
      _selectedCommunaute = null;
      _districts = [];
      _communautes = [];
    });
    if (champId != null) {
      final data = await DatabaseHelper.instance.getDistricts(champId: champId);
      if (mounted) setState(() => _districts = data);
    }
  }

  void _onDistrictChanged(String? val) async {
    setState(() {
      _selectedDistrict = val;
      _selectedCommunaute = null;
      _communautes = [];
    });
    if (val != null) {
      final data = await DatabaseHelper.instance.getCommunautesByDistrict(val);
      if (mounted) setState(() => _communautes = data);
    }
  }

  String? _nomEntite(List<Map<String, dynamic>> list, String? id) {
    if (id == null) return null;
    for (final e in list) {
      if (e['id'].toString() == id) return e['nom']?.toString();
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => onSelected(picked));
  }

  void _afficherDialogueAjoutCommunaute() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter une Communauté"),
        content: TextField(
          controller: _newCommunauteController,
          decoration: const InputDecoration(labelText: "Nom de la communauté"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (_newCommunauteController.text.isNotEmpty && _selectedDistrict != null) {
                await DatabaseHelper.instance.insertCommunaute({
                  'nom': _newCommunauteController.text,
                  'district_id': _selectedDistrict,
                });
                _newCommunauteController.clear();
                if (context.mounted) Navigator.pop(context);
                _onDistrictChanged(_selectedDistrict);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _sauvegarder() async {
    if (_formKey.currentState!.validate()) {
      final nouveauMembre = {
        'id': const Uuid().v4(),
        'nom': _nomController.text,
        'postnom': _postnomController.text,
        'prenom': _prenomController.text,
        'sexe': _sexe,
        'date_naissance': _dateNaissance.toIso8601String(),
        'lieu_naissance': _lieuNaisController.text,
        'nationalite': _nationaliteController.text,
        'etat_civil': _etatCivil,
        'profession': _professionController.text,
        'nom_pere': _nomPereController.text,
        'pere_neo_apostolique': _pereNeo,
        'nom_mere': _nomMereController.text,
        'mere_neo_apostolique': _mereNeo,
        'membre_neo_apostolique': _membreNeo,
        'adresse': _adresseController.text,
        'telephone': _telephoneController.text,
        'email': _emailController.text,
        'eglise_territoriale': _nomEntite(_eglises, _selectedEgliseId),
        'champ_apostolique': _nomEntite(_champs, _selectedChampId),
        'district_id': _selectedDistrict,
        'communaute_id': _selectedCommunaute,
        'type_profil': _typeProfil,
        'statut_membre': _statutMembre,
        'communaute_origine': _communauteOrigineController.text,
        'baptise': _isBaptise ? 1 : 0,
        'date_bapteme': _dateBapteme?.toIso8601String(),
        'scelle': _isScelle ? 1 : 0,
        'date_scellement': _dateScellement?.toIso8601String(),
        'sainte_cene': _sainteCene ? 1 : 0,
        'fonction': _typeProfil == 'Ministre' ? _fonctionController.text : 'Aucune',
        'commission': _selectedCommission,
        'photo_path': _image?.path,
        'statut_validation': 0,
        'type_ordination': _typeOrdination,
        'date_ordination': _dateOrdination?.toIso8601String(),
        'ordonne_par': _ordonneParController.text,
        'date_retraite': DateTime(_dateNaissance.year + AppConstants.ageRetraite, _dateNaissance.month, _dateNaissance.day).toIso8601String(),
      };

      await DatabaseHelper.instance.insertMembre(nouveauMembre);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enregistrement effectué et en attente de validation.")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fiche d'Inscription")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de Profil
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (p != null) setState(() => _image = File(p.path));
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? const Icon(Icons.camera_alt, size: 35) : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // I. IDENTITÉ
              const Text("I. IDENTITÉ DU MEMBRE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              TextFormField(controller: _nomController, decoration: const InputDecoration(labelText: "Nom")),
              TextFormField(controller: _postnomController, decoration: const InputDecoration(labelText: "Post-nom")),
              TextFormField(controller: _prenomController, decoration: const InputDecoration(labelText: "Prénom")),
              
              DropdownButtonFormField<String>(
                initialValue: _sexe,
                items: const [DropdownMenuItem(value: 'M', child: Text("Masculin")), DropdownMenuItem(value: 'F', child: Text("Féminin"))],
                onChanged: (v) => setState(() => _sexe = v!),
                decoration: const InputDecoration(labelText: "Sexe"),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, (d) => _dateNaissance = d),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Date de naissance"),
                  child: Text("${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}"),
                ),
              ),
              TextFormField(controller: _lieuNaisController, decoration: const InputDecoration(labelText: "Lieu de naissance")),
              TextFormField(controller: _nationaliteController, decoration: const InputDecoration(labelText: "Nationalité")),
              DropdownButtonFormField<String>(
                initialValue: _etatCivil,
                items: ['Célibataire', 'Marié(e)', 'Veuf(ve)', 'Divorcé(e)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _etatCivil = v!),
                decoration: const InputDecoration(labelText: "État Civil"),
              ),
              TextFormField(controller: _professionController, decoration: const InputDecoration(labelText: "Profession")),

              const SizedBox(height: 20),
              // PROFIL
              DropdownButtonFormField<String>(
                initialValue: _typeProfil,
                decoration: const InputDecoration(labelText: "Type de Profil / Statut d'activité"),
                items: const [
                  DropdownMenuItem(value: 'Membre', child: Text("Membre")),
                  DropdownMenuItem(value: 'Ministre', child: Text("Ministre de l'Église")),
                ],
                onChanged: (v) => setState(() => _typeProfil = v!),
              ),
              if (_typeProfil == 'Ministre')
                TextFormField(
                  controller: _fonctionController,
                  decoration: const InputDecoration(labelText: "Ministère actuel (ex: Diacre, Prêtre...)"),
                ),

              const SizedBox(height: 25),
              // II. FILIATION
              const Text("II. FILIATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              TextFormField(controller: _nomPereController, decoration: const InputDecoration(labelText: "Nom du Père")),
              const SizedBox(height: 8),
              const Text("Le père est-il néo-apostolique ?"),
              RadioGroup<int>(
                groupValue: _pereNeo,
                onChanged: (v) => setState(() => _pereNeo = v!),
                child: const Column(
                  children: [
                    RadioListTile<int>(
                      title: Text("Oui"),
                      value: 1,
                    ),
                    RadioListTile<int>(
                      title: Text("Non"),
                      value: 0,
                    ),
                    RadioListTile<int>(
                      title: Text("Inconnu"),
                      value: 2,
                    ),
                  ],
                ),
              ),
              TextFormField(controller: _nomMereController, decoration: const InputDecoration(labelText: "Nom de la Mère")),
              const SizedBox(height: 8),
              const Text("La mère est-elle néo-apostolique ?"),
              RadioGroup<int>(
                groupValue: _mereNeo,
                onChanged: (v) => setState(() => _mereNeo = v!),
                child: const Column(
                  children: [
                    RadioListTile<int>(
                      title: Text("Oui"),
                      value: 1,
                    ),
                    RadioListTile<int>(
                      title: Text("Non"),
                      value: 0,
                    ),
                    RadioListTile<int>(
                      title: Text("Inconnu"),
                      value: 2,
                    ),
                  ],
                ),
              ),
              const Text("Le membre est-il néo-apostolique de naissance ?"),
              RadioGroup<int>(
                groupValue: _membreNeo,
                onChanged: (v) => setState(() => _membreNeo = v!),
                child: const Row(
                  children: [
                    RadioListTile<int>(
                      title: Text("Oui"),
                      value: 1,
                    ),
                    RadioListTile<int>(
                      title: Text("Non"),
                      value: 0,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              // III. COORDONNÉES
              const Text("III. COORDONNÉES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              TextFormField(controller: _adresseController, decoration: const InputDecoration(labelText: "Adresse Complète")),
              TextFormField(controller: _telephoneController, decoration: const InputDecoration(labelText: "Téléphone")),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Adresse E-mail")),

              const SizedBox(height: 25),
              // IV. HIÉRARCHIE
              const Text("IV. HIÉRARCHIE ECCLÉSIASTIQUE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              DropdownButtonFormField<String>(
                initialValue: _selectedEgliseId,
                decoration: const InputDecoration(labelText: "Église territoriale"),
                items: _eglises
                    .map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['nom']?.toString() ?? '')))
                    .toList(),
                onChanged: _onEgliseChanged,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedChampId,
                hint: const Text("Champ apostolique"),
                items: _champs
                    .map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['nom']?.toString() ?? '')))
                    .toList(),
                onChanged: _selectedEgliseId == null ? null : _onChampChanged,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedDistrict,
                hint: const Text("District"),
                items: _districts
                    .map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['nom']?.toString() ?? '')))
                    .toList(),
                onChanged: _selectedChampId == null ? null : _onDistrictChanged,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCommunaute,
                      hint: const Text("Sélectionner la Communauté"),
                      items: _communautes.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['nom']))).toList(),
                      onChanged: (v) => setState(() => _selectedCommunaute = v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
                    onPressed: _selectedDistrict == null ? null : _afficherDialogueAjoutCommunaute,
                  )
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _statutMembre,
                decoration: const InputDecoration(labelText: "Statut d'intégration"),
                items: ['Nouveau', 'Ancien', 'Transfert'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _statutMembre = v!),
              ),
              if (_statutMembre == 'Transfert')
                TextFormField(controller: _communauteOrigineController, decoration: const InputDecoration(labelText: "Communauté d'origine")),

              const SizedBox(height: 25),
              // V. VIE SACRAMENTELLE
              const Text("V. VIE SACRAMENTELLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              SwitchListTile(
                title: const Text("Baptisé(e)"),
                value: _isBaptise,
                onChanged: (v) => setState(() => _isBaptise = v),
              ),
              if (_isBaptise)
                InkWell(
                  onTap: () => _selectDate(context, (d) => _dateBapteme = d),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Date de Baptême"),
                    child: Text(_dateBapteme == null ? "Choisir la date" : "${_dateBapteme!.day}/${_dateBapteme!.month}/${_dateBapteme!.year}"),
                  ),
                ),
              SwitchListTile(
                title: const Text("Scellé(e)"),
                value: _isScelle,
                onChanged: (v) => setState(() => _isScelle = v),
              ),
              if (_isScelle)
                InkWell(
                  onTap: () => _selectDate(context, (d) => _dateScellement = d),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Date de Scellement"),
                    child: Text(_dateScellement == null ? "Choisir la date" : "${_dateScellement!.day}/${_dateScellement!.month}/${_dateScellement!.year}"),
                  ),
                ),
              SwitchListTile(
                title: const Text("Admis à la Sainte-Cène"),
                value: _sainteCene,
                onChanged: (v) => setState(() => _sainteCene = v),
              ),

              const SizedBox(height: 25),
              // VI. COMMISSIONS
              const Text("VI. ENGAGEMENT ET COMMISSIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              DropdownButtonFormField<String>(
                initialValue: _selectedCommission,
                hint: const Text("Sélectionner une Commission / Activité"),
                items: _commissions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCommission = v),
              ),

              const SizedBox(height: 25),
              const Text("VII. ORDINATION (Réforme)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              DropdownButtonFormField<String>(
                initialValue: _typeOrdination,
                hint: const Text("Type d'ordination"),
                items: AppConstants.typesOrdination.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _typeOrdination = v),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, (d) => setState(() => _dateOrdination = d)),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Date d'ordination / Mandatement / Nomination"),
                  child: Text(_dateOrdination == null ? "Choisir la date" : "${_dateOrdination!.day}/${_dateOrdination!.month}/${_dateOrdination!.year}"),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ordonneParController,
                decoration: const InputDecoration(labelText: "Ordonné par (nom de l'Apôtre)"),
              ),

              const SizedBox(height: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55), backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: _sauvegarder,
                child: const Text("ENREGISTRER LE MEMBRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _lieuNaisController.dispose();
    _nationaliteController.dispose();
    _professionController.dispose();
    _nomPereController.dispose();
    _nomMereController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _fonctionController.dispose();
    _newCommunauteController.dispose();
    _communauteOrigineController.dispose();
    super.dispose();
  }
}
