import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/network/api_client.dart';
import '../models/contact_model.dart';
import 'auth_identity_mapper.dart';
import 'auth_service.dart';

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
      // Load cached contacts BEFORE overwriting — used as email fallback below.
      final previousCache = await _loadCachedContacts(userId);

      final response = await _apiClient.getJson(
        '/contacts',
        accessToken: session.accessToken,
      );
      final data = response['data'];
      if (data is! List) {
        return [];
      }

      var contacts =
          data
              .map(
                (item) =>
                    ContactModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      // Restore emails for contacts where the backend returned null.
      contacts = await _mergeLocalEmailFallback(userId, contacts, previousCache);

      await _saveCachedContacts(userId, contacts);
      return contacts;
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
    if (contacts.length >= 1) {
      return false;
    }
    final exists = contacts.any(
      (contact) =>
          AuthIdentityMapper.normalizePhone(contact.phone) == normalizedPhone,
    );
    if (exists) {
      return false;
    }

    final localContact = ContactModel(
      id: _buildLocalContactId(),
      name: name.trim(),
      phone: normalizedPhone,
      email: email,
      relation: relation.trim().isEmpty
          ? 'Contacto de emergencia'
          : relation.trim(),
      priority: contacts.length + 1,
    );

    try {
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
      if (email != null) {
        await _upsertLocalEmail(userId, normalizedPhone, email);
      }
      await _refreshCache(userId);
      return true;
    } catch (error) {
      if (!_shouldSaveLocally(error)) {
        return false;
      }

      await _saveContactLocally(userId, localContact);
      await OfflineSyncService.instance.enqueueCreateContact(
        userId: userId,
        contact: localContact,
      );
      return true;
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

    final previousContact = contacts.cast<ContactModel?>().firstWhere(
      (contact) => contact?.id == updated.id,
      orElse: () => null,
    );
    final normalizedContact = updated.copyWith(phone: normalizedPhone);
    await _upsertCachedContact(userId, normalizedContact);

    if (_isLocalId(normalizedContact.id)) {
      await OfflineSyncService.instance.enqueueUpdateContact(
        userId: userId,
        contact: normalizedContact,
      );
      return true;
    }

    try {
      await _apiClient.putJson(
        '/contacts/${updated.id}',
        accessToken: session.accessToken,
        body: normalizedContact.toBackendPayload(),
      );
      if (normalizedContact.email != null) {
        await _upsertLocalEmail(userId, normalizedPhone, normalizedContact.email!);
      }
      await _refreshCache(userId);
      return true;
    } catch (error) {
      if (!_shouldSaveLocally(error)) {
        if (previousContact != null) {
          await _upsertCachedContact(userId, previousContact);
        }
        return false;
      }

      await OfflineSyncService.instance.enqueueUpdateContact(
        userId: userId,
        contact: normalizedContact,
      );
      return true;
    }
  }

  Future<bool> deleteContact(String userId, String contactId) async {
    final session = await _authService.getSession();
    if (session == null) {
      return false;
    }

    final cachedContacts = await _loadCachedContacts(userId);
    final removedContact = cachedContacts.cast<ContactModel?>().firstWhere(
      (contact) => contact?.id == contactId,
      orElse: () => null,
    );
    cachedContacts.removeWhere((contact) => contact.id == contactId);
    await _saveCachedContacts(userId, cachedContacts);

    if (_isLocalId(contactId)) {
      await OfflineSyncService.instance.enqueueDeleteContact(
        userId: userId,
        contactId: contactId,
      );
      return true;
    }

    try {
      await _apiClient.deleteJson(
        '/contacts/$contactId',
        accessToken: session.accessToken,
      );
      return true;
    } catch (error) {
      if (!_shouldSaveLocally(error)) {
        if (removedContact != null) {
          cachedContacts.insert(0, removedContact);
          await _saveCachedContacts(userId, cachedContacts);
        }
        return false;
      }

      await OfflineSyncService.instance.enqueueDeleteContact(
        userId: userId,
        contactId: contactId,
      );
      return true;
    }
  }

  Future<void> _refreshCache(String userId) async {
    final session = await _authService.getSession();
    if (session == null) {
      return;
    }

    try {
      final previousCache = await _loadCachedContacts(userId);

      final response = await _apiClient.getJson(
        '/contacts',
        accessToken: session.accessToken,
      );
      final data = response['data'];
      if (data is! List) {
        return;
      }

      var contacts =
          data
              .map(
                (item) =>
                    ContactModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      contacts = await _mergeLocalEmailFallback(userId, contacts, previousCache);

      await _saveCachedContacts(userId, contacts);
    } catch (_) {
      // Keep the previous cache if refresh fails.
    }
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

  Future<void> _saveContactLocally(String userId, ContactModel contact) async {
    await _upsertCachedContact(userId, contact);
  }

  Future<void> _upsertCachedContact(String userId, ContactModel contact) async {
    final contacts = await _loadCachedContacts(userId);
    final index = contacts.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      contacts.add(contact);
    } else {
      contacts[index] = contact;
    }
    contacts.sort((a, b) => a.priority.compareTo(b.priority));
    await _saveCachedContacts(userId, contacts);
  }

  bool _shouldSaveLocally(Object error) {
    if (error is! Exception) {
      return true;
    }

    final normalized = error.toString().toLowerCase();
    return normalized.contains('no se pudo conectar con el servidor') ||
        normalized.contains('schema cache') ||
        normalized.contains('schema_cache') ||
        normalized.contains('pgrst204') ||
        normalized.contains('pgrst205');
  }

  bool _isLocalId(String id) {
    return id.trim().startsWith('local-');
  }

  String _buildLocalContactId() {
    return 'local-contact-${DateTime.now().microsecondsSinceEpoch}';
  }

  // ---------------------------------------------------------------------------
  // Local email fallback — keeps emails available even when the backend returns
  // null for correo_electronico (e.g. for contacts created before the column
  // existed, or when RLS doesn't expose it yet).
  // ---------------------------------------------------------------------------

  Future<List<ContactModel>> _mergeLocalEmailFallback(
    String userId,
    List<ContactModel> contacts,
    List<ContactModel> previousCache,
  ) async {
    if (contacts.every((c) => c.email != null)) return contacts;

    // Build lookup maps from the previous cache (already has emails stored).
    final emailById = <String, String>{};
    final emailByPhone = <String, String>{};
    for (final c in previousCache) {
      final email = c.email;
      if (email == null || email.trim().isEmpty) continue;
      if (c.id.trim().isNotEmpty) emailById[c.id.trim()] = email;
      final phone = AuthIdentityMapper.normalizePhone(c.phone);
      if (phone.isNotEmpty) emailByPhone[phone] = email;
    }

    // Also pull from the dedicated contact_emails_ key (older local storage).
    final legacyEmails = await _loadLocalEmails(userId);

    return contacts.map((contact) {
      if (contact.email != null) return contact;

      // Try previous cache by id then phone.
      final cachedEmail =
          emailById[contact.id.trim()] ??
          emailByPhone[AuthIdentityMapper.normalizePhone(contact.phone)];
      if (cachedEmail != null) return contact.copyWith(email: cachedEmail);

      // Try legacy contact_emails_ map.
      for (final key in _emailAliasesForContact(contact)) {
        final legacyEmail = legacyEmails[key];
        if (legacyEmail != null && legacyEmail.trim().isNotEmpty) {
          return contact.copyWith(email: legacyEmail);
        }
      }

      return contact;
    }).toList();
  }

  Future<Map<String, String>> _loadLocalEmails(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_emailCacheKey(userId));
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded
          .map((k, v) => MapEntry(k, v?.toString() ?? ''))
        ..removeWhere((_, v) => v.trim().isEmpty);
    } catch (_) {
      return {};
    }
  }

  Future<void> _upsertLocalEmail(
    String userId,
    String normalizedPhone,
    String email,
  ) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = await _loadLocalEmails(userId);

    if (normalizedPhone.isNotEmpty) {
      existing['phone:$normalizedPhone'] = trimmed;
    }

    await prefs.setString(_emailCacheKey(userId), jsonEncode(existing));
  }

  List<String> _emailAliasesForContact(ContactModel contact) {
    final aliases = <String>[];
    if (contact.id.trim().isNotEmpty) aliases.add('id:${contact.id.trim()}');
    final phone = AuthIdentityMapper.normalizePhone(contact.phone);
    if (phone.isNotEmpty) aliases.add('phone:$phone');
    return aliases;
  }
}
