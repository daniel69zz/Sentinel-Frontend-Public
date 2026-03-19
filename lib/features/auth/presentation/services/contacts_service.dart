import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation; // Ej: Mamá, Hermana, Amiga

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relation': relation,
  };

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    relation: json['relation'],
  );
}

// ----------------------------------------------------------------
// ContactsService — CRUD completo con SharedPreferences
// Cuando tengas backend: solo cambia cada método
// ----------------------------------------------------------------
class ContactsService {
  // La key incluye el userId para que cada usuaria tenga sus propios contactos
  String _key(String userId) => 'contacts_$userId';

  // READ — obtener todos los contactos
  Future<List<ContactModel>> getContacts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final List decoded = json.decode(raw);
    return decoded.map((c) => ContactModel.fromJson(c)).toList();
  }

  // Guarda la lista completa (uso interno)
  Future<void> _saveContacts(String userId, List<ContactModel> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_key(userId), encoded);
  }

  // CREATE — agregar contacto
  Future<bool> addContact(
    String userId,
    String name,
    String phone,
    String relation,
  ) async {
    try {
      final contacts = await getContacts(userId);

      // Evitar duplicados por número
      final exists = contacts.any((c) => c.phone == phone);
      if (exists) return false;

      final newContact = ContactModel(
        id: 'c${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        relation: relation,
      );

      contacts.add(newContact);
      await _saveContacts(userId, contacts);
      return true;
    } catch (e) {
      return false;
    }
  }

  // UPDATE — editar contacto existente
  Future<bool> updateContact(String userId, ContactModel updated) async {
    try {
      final contacts = await getContacts(userId);
      final index = contacts.indexWhere((c) => c.id == updated.id);
      if (index == -1) return false;

      contacts[index] = updated;
      await _saveContacts(userId, contacts);
      return true;
    } catch (e) {
      return false;
    }
  }

  // DELETE — eliminar contacto por id
  Future<bool> deleteContact(String userId, String contactId) async {
    try {
      final contacts = await getContacts(userId);
      contacts.removeWhere((c) => c.id == contactId);
      await _saveContacts(userId, contacts);
      return true;
    } catch (e) {
      return false;
    }
  }
}
