import 'package:shared_preferences/shared_preferences.dart';

import 'auth_identity_mapper.dart';

class AccountEmailRegistry {
  static const _knownEmailsKey = 'sentinel_known_account_emails';

  Future<bool> isKnown(String email) async {
    final knownEmails = await load();
    return knownEmails.contains(AuthIdentityMapper.normalizeEmail(email));
  }

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEmails = prefs.getStringList(_knownEmailsKey) ?? const [];
    return rawEmails
        .map(AuthIdentityMapper.normalizeEmail)
        .where((email) => email.isNotEmpty)
        .toSet();
  }

  Future<void> remember(String email) async {
    final normalizedEmail = AuthIdentityMapper.normalizeEmail(email);
    if (normalizedEmail.isEmpty) {
      return;
    }

    final knownEmails = await load()
      ..add(normalizedEmail);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_knownEmailsKey, knownEmails.toList()..sort());
  }
}
