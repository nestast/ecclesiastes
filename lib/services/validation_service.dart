class ValidationService {
  static final ValidationService _instance = ValidationService._internal();

  factory ValidationService() {
    return _instance;
  }

  ValidationService._internal();

  List<String> validateEmail(String email) {
    final errors = <String>[];
    if (email.isEmpty) {
      errors.add('L\'adresse email est requise');
    } else if (!_isValidEmail(email)) {
      errors.add('L\'adresse email n\'est pas valide');
    }
    return errors;
  }

  List<String> validatePhone(String phone) {
    final errors = <String>[];
    if (phone.isEmpty) {
      errors.add('Le numéro de téléphone est requis');
    } else if (!_isValidPhone(phone)) {
      errors.add('Le numéro de téléphone n\'est pas valide');
    }
    return errors;
  }

  List<String> validateField(String value, String fieldName, {int minLength = 0, int maxLength = 1000}) {
    final errors = <String>[];
    
    if (value.isEmpty) {
      errors.add('$fieldName est requis');
    } else if (value.length < minLength) {
      errors.add('$fieldName doit contenir au moins $minLength caractères');
    } else if (value.length > maxLength) {
      errors.add('$fieldName ne peut pas dépasser $maxLength caractères');
    }
    
    return errors;
  }

  List<String> validateDate(DateTime? date, String fieldName) {
    final errors = <String>[];
    
    if (date == null) {
      errors.add('$fieldName est requise');
    } else if (date.isAfter(DateTime.now())) {
      errors.add('$fieldName ne peut pas être dans le futur');
    }
    
    return errors;
  }

  List<String> validateNumber(String value, String fieldName, {int? min, int? max}) {
    final errors = <String>[];
    
    if (value.isEmpty) {
      errors.add('$fieldName est requis');
      return errors;
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      errors.add('$fieldName doit être un nombre valide');
    } else {
      if (min != null && number < min) {
        errors.add('$fieldName doit être au moins $min');
      }
      if (max != null && number > max) {
        errors.add('$fieldName ne peut pas dépasser $max');
      }
    }
    
    return errors;
  }

  List<String> validateList(List<dynamic> list, String fieldName, {int minItems = 0}) {
    final errors = <String>[];
    
    if (list.isEmpty && minItems > 0) {
      errors.add('Au moins $minItems $fieldName est/sont requis');
    }
    
    return errors;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$');
    return regex.hasMatch(phone);
  }
}
