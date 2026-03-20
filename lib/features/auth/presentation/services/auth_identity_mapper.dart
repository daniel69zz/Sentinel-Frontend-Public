class NameParts {
  final String firstName;
  final String lastName;
  final String? middleLastName;

  const NameParts({
    required this.firstName,
    required this.lastName,
    this.middleLastName,
  });
}

class AuthIdentityMapper {
  static String normalizeEmail(String input) {
    return input.trim().toLowerCase();
  }

  static bool isValidEmail(String input) {
    final normalizedEmail = normalizeEmail(input);
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    ).hasMatch(normalizedEmail);
  }

  static String normalizePhone(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final hasLeadingPlus = trimmed.startsWith('+');
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
      return digits.isEmpty ? '' : '+$digits';
    }

    if (hasLeadingPlus) {
      return digits.isEmpty ? '' : '+$digits';
    }

    if (digits.startsWith('591')) {
      return '+$digits';
    }

    if (digits.length == 8) {
      return '+591$digits';
    }

    return digits.isEmpty ? '' : '+$digits';
  }

  static String buildEmailFromPhone(String phone) {
    final normalizedPhone = normalizePhone(phone);
    final digits = normalizedPhone.replaceAll(RegExp(r'\D'), '');
    final localPart = digits.isEmpty ? 'phone_user' : 'phone$digits';
    return '$localPart@sentinel.app';
  }

  static NameParts buildNameParts({
    required String firstNames,
    required String lastNames,
  }) {
    final normalizedFirstNames = firstNames
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');
    final lastNameParts = lastNames
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (lastNameParts.isEmpty) {
      return NameParts(
        firstName: normalizedFirstNames.isEmpty
            ? 'Usuaria'
            : normalizedFirstNames,
        lastName: 'Sin apellido',
      );
    }

    return NameParts(
      firstName: normalizedFirstNames.isEmpty
          ? 'Usuaria'
          : normalizedFirstNames,
      lastName: lastNameParts.first,
      middleLastName: lastNameParts.length > 1
          ? lastNameParts.sublist(1).join(' ')
          : null,
    );
  }

  static NameParts splitFullName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return const NameParts(firstName: 'Usuaria', lastName: 'Sentinel');
    }

    if (parts.length == 1) {
      return NameParts(firstName: parts.first, lastName: 'Sin apellido');
    }

    if (parts.length == 2) {
      return NameParts(firstName: parts.first, lastName: parts.last);
    }

    return NameParts(
      firstName: parts.first,
      lastName: parts[1],
      middleLastName: parts.sublist(2).join(' '),
    );
  }

  static String buildAddressFromCity(String city) {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      return '';
    }

    return 'Ciudad: $trimmedCity';
  }

  static String extractCity(String? address) {
    final trimmedAddress = address?.trim() ?? '';
    if (trimmedAddress.isEmpty) {
      return 'Bolivia';
    }

    const prefix = 'Ciudad: ';
    if (trimmedAddress.startsWith(prefix)) {
      return trimmedAddress.substring(prefix.length).trim();
    }

    return trimmedAddress;
  }

  static String formatBirthDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
