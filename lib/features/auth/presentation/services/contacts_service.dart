import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import 'auth_identity_mapper.dart';
import 'auth_service.dart';

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String relation;
  final String? alternativePhone;
  final int priority;
  final bool canReceiveAlerts;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.relation,
    this.alternativePhone,
    this.priority = 1,
    this.canReceiveAlerts = true,
  });

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? relation,
    String? alternativePhone,
    int? priority,
    bool? canReceiveAlerts,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relation: relation ?? this.relation,
      alternativePhone: alternativePhone ?? this.alternativePhone,
      priority: priority ?? this.priority,
      canReceiveAlerts: canReceiveAlerts ?? this.canReceiveAlerts,
    );
  }

  Map<String, dynamic> toBackendPayload() => {
    'nombre_completo': name.trim(),
    'parentesco': relation.trim().isEmpty ? null : relation.trim(),
    'telefono': AuthIdentityMapper.normalizePhone(phone),
    'telefono_alternativo': _normalizeNullablePhone(alternativePhone),
    'prioridad': priority,
    'puede_recibir_alertas': canReceiveAlerts,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'relation': relation,
    'telefono_alternativo': alternativePhone,
    'prioridad': priority,
    'puede_recibir_alertas': canReceiveAlerts,
  };

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: _readString(json['id']),
    name: _readString(
      json['nombre_completo'],
      fallback: _readString(json['name']),
    ),
    phone: _readString(json['telefono'], fallback: _readString(json['phone'])),
    email: _readNullableEmail(
      json['correo_electronico'],
      fallback: _readNullableEmail(json['email']),
    ),
    relation: _readString(
      json['parentesco'],
      fallback: _readString(
        json['relation'],
        fallback: 'Contacto de emergencia',
      ),
    ),
    alternativePhone: _readNullableString(json['telefono_alternativo']),
    priority: _readInt(json['prioridad'], fallback: 1),
    canReceiveAlerts: _readBool(json['puede_recibir_alertas'], fallback: true),
  );

  static String? _normalizeNullablePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized = AuthIdentityMapper.normalizePhone(value);
    return normalized.isEmpty ? null : normalized;
  }
}

class ContactsService {
  static const _contactsCachePrefix = 'contacts_cache_';
  static const _contactEmailsPrefix = 'contact_emails_';

  final AuthService _authService;
  final ApiClient _apiClient;

  ContactsService({AuthService? authService, ApiClient? apiClient})
    : _authService = authService ?? AuthService(),
      _apiClient = apiClient ?? ApiClient();

  String _cacheKey(String userId) => '$_contactsCachePrefix$userId';
  String _emailCacheKey(String userId) => '$_contactEmailsPrefix$userId';

  Future<List<ContactModel>> getContacts(String userId) async {
    final session = await _authService.getSession();
    if (session == null) {
      return _loadCachedContacts(userId);
    }

    try {
      final response = await _apiClient.getJson(
        '/contacts',
        accessToken: session.accessToken,
      );
      final data = response['data'];
      if (data is! List) {
        return [];
      }

      final contacts =
          data
              .map(
                (item) => ContactModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      final mergedContacts = await _mergeLocalContactEmails(userId, contacts);
      await _saveCachedContacts(userId, mergedContacts);
      return mergedContacts;
    } catch (_) {
      return _loadCachedContacts(userId);
    }
  }

  Future<bool> hasContacts(String userId) async {
    final contacts = await getContacts(userId);
    return contacts.isNotEmpty;
  }

  Future<bool> addContact(
    String userId,
    String name,
    String phone,
    String relation,
    String? email,
  ) async {
    final session = await _authService.getSession();
    if (session == null) {
      return false;
    }

    final normalizedPhone = AuthIdentityMapper.normalizePhone(phone);
    if (normalizedPhone.isEmpty) {
      return false;
    }

    final contacts = await getContacts(userId);
    final exists = contacts.any(
      (contact) =>
          AuthIdentityMapper.normalizePhone(contact.phone) == normalizedPhone,
    );
    if (exists) {
      return false;
    }

    try {
      await _upsertLocalEmail(
        userId,
        phone: normalizedPhone,
        email: email,
      );
      await _apiClient.postJson(
        '/contacts',
        accessToken: session.accessToken,
        body: ContactModel(
          id: '',
          name: name.trim(),
          phone: normalizedPhone,
          email: email,
          relation: relation.trim().isEmpty
              ? 'Contacto de emergencia'
              : relation.trim(),
          priority: contacts.length + 1,
        ).toBackendPayload(),
      );
      await _refreshCache(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateContact(String userId, ContactModel updated) async {
    final session = await _authService.getSession();
    if (session == null) {
      return false;
    }

    final normalizedPhone = AuthIdentityMapper.normalizePhone(updated.phone);
    if (normalizedPhone.isEmpty) {
      return false;
    }

    final contacts = await getContacts(userId);
    final duplicates = contacts.any(
      (contact) =>
          contact.id != updated.id &&
          AuthIdentityMapper.normalizePhone(contact.phone) == normalizedPhone,
    );
    if (duplicates) {
      return false;
    }

    try {
      final previousContact = contacts.cast<ContactModel?>().firstWhere(
        (contact) => contact?.id == updated.id,
        orElse: () => null,
      );
      if (previousContact != null) {
        await _removeLocalEmailEntries(userId, previousContact);
      }
      await _upsertLocalEmail(
        userId,
        contact: updated.copyWith(phone: normalizedPhone),
      );
      await _apiClient.putJson(
        '/contacts/${updated.id}',
        accessToken: session.accessToken,
        body: updated.copyWith(phone: normalizedPhone).toBackendPayload(),
      );
      await _refreshCache(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteContact(String userId, String contactId) async {
    final session = await _authService.getSession();
    if (session == null) {
      return false;
    }

    try {
      await _apiClient.deleteJson(
        '/contacts/$contactId',
        accessToken: session.accessToken,
      );
      final cachedContacts = await _loadCachedContacts(userId);
      final removedContact = cachedContacts.cast<ContactModel?>().firstWhere(
        (contact) => contact?.id == contactId,
        orElse: () => null,
      );
      if (removedContact != null) {
        await _removeLocalEmailEntries(userId, removedContact);
      }
      cachedContacts.removeWhere((contact) => contact.id == contactId);
      await _saveCachedContacts(userId, cachedContacts);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _refreshCache(String userId) async {
    final session = await _authService.getSession();
    if (session == null) {
      return;
    }

    try {
      final response = await _apiClient.getJson(
        '/contacts',
        accessToken: session.accessToken,
      );
      final data = response['data'];
      if (data is! List) {
        return;
      }

      final contacts =
          data
              .map(
                (item) =>
                    ContactModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      final mergedContacts = await _mergeLocalContactEmails(userId, contacts);
      await _saveCachedContacts(userId, mergedContacts);
    } catch (_) {
      // Keep the previous cache if refresh fails.
    }
  }

  Future<List<ContactModel>> _mergeLocalContactEmails(
    String userId,
    List<ContactModel> contacts,
  ) async {
    final localEmails = await _loadLocalEmails(userId);
    if (localEmails.isEmpty) {
      return contacts;
    }

    return contacts.map((contact) {
      final email = _resolveLocalEmail(localEmails, contact);
      if (email == null) {
        return contact;
      }

      return contact.copyWith(email: email);
    }).toList();
  }

  Future<Map<String, String>> _loadLocalEmails(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_emailCacheKey(userId));
    if (raw == null || raw.trim().isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map(
        (key, value) => MapEntry(key, _readString(value)),
      )..removeWhere((key, value) => value.trim().isEmpty);
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _saveLocalEmails(
    String userId,
    Map<String, String> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailCacheKey(userId), jsonEncode(values));
  }

  Future<void> _upsertLocalEmail(
    String userId, {
    ContactModel? contact,
    String? phone,
    String? email,
  }) async {
    final prefs = await _loadLocalEmails(userId);
    final normalizedEmail = _normalizeNullableEmail(email ?? contact?.email);
    final keys = contact != null
        ? _emailAliasesForContact(contact)
        : _emailAliasesForPhone(phone);

    if (keys.isEmpty) {
      return;
    }

    for (final key in keys) {
      if (normalizedEmail == null) {
        prefs.remove(key);
      } else {
        prefs[key] = normalizedEmail;
      }
    }

    await _saveLocalEmails(userId, prefs);
  }

  Future<void> _removeLocalEmailEntries(
    String userId,
    ContactModel contact,
  ) async {
    final emails = await _loadLocalEmails(userId);
    final keys = _emailAliasesForContact(contact);
    if (keys.isEmpty) {
      return;
    }

    for (final key in keys) {
      emails.remove(key);
    }

    await _saveLocalEmails(userId, emails);
  }

  String? _resolveLocalEmail(
    Map<String, String> localEmails,
    ContactModel contact,
  ) {
    for (final key in _emailAliasesForContact(contact)) {
      final value = localEmails[key];
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  List<String> _emailAliasesForContact(ContactModel contact) {
    final aliases = <String>[];
    final trimmedId = contact.id.trim();
    if (trimmedId.isNotEmpty) {
      aliases.add('id:$trimmedId');
    }

    final normalizedPhone = AuthIdentityMapper.normalizePhone(contact.phone);
    if (normalizedPhone.isNotEmpty) {
      aliases.add('phone:$normalizedPhone');
    }

    return aliases;
  }

  List<String> _emailAliasesForPhone(String? phone) {
    final normalizedPhone = AuthIdentityMapper.normalizePhone(phone ?? '');
    if (normalizedPhone.isEmpty) {
      return const <String>[];
    }

    return <String>['phone:$normalizedPhone'];
  }

  Future<List<ContactModel>> _loadCachedContacts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(userId));
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
      return decoded.map(ContactModel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveCachedContacts(
    String userId,
    List<ContactModel> contacts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(userId),
      jsonEncode(contacts.map((contact) => contact.toJson()).toList()),
    );
  }
}

String _readString(dynamic value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

String? _readNullableString(dynamic value) {
  final stringValue = _readString(value);
  return stringValue.trim().isEmpty ? null : stringValue;
}

String? _readNullableEmail(dynamic value, {String? fallback}) {
  final normalized = _normalizeNullableEmail(_readString(value));
  if (normalized != null) {
    return normalized;
  }

  return _normalizeNullableEmail(fallback);
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(_readString(value)) ?? fallback;
}

bool _readBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  final normalized = _readString(value).toLowerCase();
  if (normalized == 'true') {
    return true;
  }
  if (normalized == 'false') {
    return false;
  }
  return fallback;
}

String? _normalizeNullableEmail(String? value) {
  final trimmed = (value ?? '').trim().toLowerCase();
  if (trimmed.isEmpty) {
    return null;
  }

  final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
  return isValid ? trimmed : null;
}
