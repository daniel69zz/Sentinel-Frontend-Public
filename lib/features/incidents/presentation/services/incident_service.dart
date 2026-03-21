import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/services/auth_service.dart';
import '../../domain/models/incident_record.dart';

class IncidentListResult {
  final List<IncidentRecord> incidents;
  final bool fromCache;
  final String? message;

  const IncidentListResult({
    required this.incidents,
    required this.fromCache,
    this.message,
  });
}

class IncidentMutationResult {
  final bool success;
  final IncidentRecord? incident;
  final String message;

  const IncidentMutationResult({
    required this.success,
    required this.message,
    this.incident,
  });
}

class IncidentService {
  static const _cacheKeyPrefix = 'incident_records_cache_';

  final AuthService _authService;
  final ApiClient _apiClient;

  IncidentService({AuthService? authService, ApiClient? apiClient})
    : _authService = authService ?? AuthService(),
      _apiClient = apiClient ?? ApiClient();

  String _t({
    required String es,
    required String en,
    required String ay,
    required String qu,
  }) {
    return AppLanguageService.instance.pick(
      es: es,
      en: en,
      ay: ay,
      qu: qu,
    );
  }

  Future<IncidentListResult> loadIncidents() async {
    final user = await _authService.getSession();
    if (user == null) {
      return IncidentListResult(
        incidents: [],
        fromCache: true,
        message: _t(
          es: 'Inicia sesion para ver tus incidentes.',
          en: 'Sign in to see your incidents.',
          ay: 'Incidentenakama uñjañatakix sesion qalltaya.',
          qu: 'Incidenteykikunata rikunaykipaq sesionta qallarichiy.',
        ),
      );
    }

    final cached = await _loadCachedIncidents(user.id);

    try {
      final response = await _apiClient.getJson(
        '/incidents',
        accessToken: user.accessToken,
      );
      final incidents = _extractIncidentList(response);
      await _saveCachedIncidents(user.id, incidents);

      return IncidentListResult(
        incidents: incidents,
        fromCache: false,
        message: incidents.isEmpty
            ? _t(
                es: 'Todavia no tienes incidentes registrados.',
                en: 'You do not have any registered incidents yet.',
                ay: 'Jichhakamax janiw qillqt\'ata incidentenakam utjkiti.',
                qu: 'Manaraq incidenteykikuna qillqasqachu kashan.',
              )
            : null,
      );
    } on ApiException catch (error) {
      return IncidentListResult(
        incidents: cached,
        fromCache: true,
        message: cached.isEmpty
            ? _mapLoadError(error)
            : _t(
                es: 'Mostrando incidentes guardados en este dispositivo.',
                en: 'Showing incidents saved on this device.',
                ay: 'Aka dispositivon imata incidentenakwa uñstaski.',
                qu: 'Kay dispositivopi waqaychasqa incidentekuna rikuchisqa kashan.',
              ),
      );
    } catch (_) {
      return IncidentListResult(
        incidents: cached,
        fromCache: true,
        message: cached.isEmpty
            ? _t(
                es: 'No se pudo cargar tu historial de incidentes.',
                en: 'Your incident history could not be loaded.',
                ay: 'Janiw incidentenakan historialamax cargañjamakiti.',
                qu: 'Incidente historiaykiqa mana cargayta atikurqanchu.',
              )
            : _t(
                es: 'Mostrando incidentes guardados en este dispositivo.',
                en: 'Showing incidents saved on this device.',
                ay: 'Aka dispositivon imata incidentenakwa uñstaski.',
                qu: 'Kay dispositivopi waqaychasqa incidentekuna rikuchisqa kashan.',
              ),
      );
    }
  }

  Future<IncidentMutationResult> updateIncidentDetails({
    required IncidentRecord incident,
    required String title,
    required String description,
  }) async {
    final normalizedTitle = title.trim().isEmpty
        ? incident.title
        : title.trim();
    final updatedIncident = incident.copyWith(
      title: normalizedTitle,
      description: description.trim(),
    );

    final user = await _authService.getSession();
    if (user != null) {
      await upsertCachedIncident(userId: user.id, incident: updatedIncident);
    }

    if (user == null) {
      return IncidentMutationResult(
        success: true,
        message: _t(
          es: 'Los cambios se guardaron solo en este dispositivo.',
          en: 'The changes were saved only on this device.',
          ay: 'Mayjt\'awinakax aka dispositivon sapaki imatawa.',
          qu: 'Tukuy tikraykunaqa kay dispositivollapim waqaychasqa karqan.',
        ),
        incident: updatedIncident,
      );
    }

    try {
      await _apiClient.putJson(
        '/incidents/${incident.id}',
        accessToken: user.accessToken,
        body: {
          'titulo': updatedIncident.title,
          'descripcion': updatedIncident.description,
        },
      );

      return IncidentMutationResult(
        success: true,
        message: _t(
          es: 'Incidente actualizado correctamente.',
          en: 'Incident updated successfully.',
          ay: 'Incidentex wali sum machaqtayatawa.',
          qu: 'Incidenteqa allinta musuqyachisqa karqan.',
        ),
        incident: updatedIncident,
      );
    } on ApiException catch (error) {
      return IncidentMutationResult(
        success: true,
        message:
            '${_t(
              es: 'Se guardo localmente.',
              en: 'It was saved locally.',
              ay: 'Localan imatawa.',
              qu: 'Localpim waqaychasqa karqan.',
            )} ${_t(
              es: 'No se pudo sincronizar el incidente:',
              en: 'The incident could not be synced:',
              ay: 'Janiw incidentex sincronizañjamakiti:',
              qu: 'Incidenteqa mana sincronizayta atikurqanchu:',
            )} ${error.message}',
        incident: updatedIncident,
      );
    } catch (_) {
      return IncidentMutationResult(
        success: true,
        message: '${_t(
          es: 'Se guardo localmente.',
          en: 'It was saved locally.',
          ay: 'Localan imatawa.',
          qu: 'Localpim waqaychasqa karqan.',
        )} ${_t(
          es: 'No se pudo sincronizar el incidente.',
          en: 'The incident could not be synced.',
          ay: 'Janiw incidentex sincronizañjamakiti.',
          qu: 'Incidenteqa mana sincronizayta atikurqanchu.',
        )}',
        incident: updatedIncident,
      );
    }
  }

  Future<void> upsertCachedIncident({
    required String userId,
    required IncidentRecord incident,
  }) async {
    final incidents = await _loadCachedIncidents(userId);
    final index = incidents.indexWhere((item) => item.id == incident.id);
    if (index == -1) {
      incidents.insert(0, incident);
    } else {
      incidents[index] = incident;
    }
    await _saveCachedIncidents(userId, incidents);
  }

  Future<List<IncidentRecord>> _loadCachedIncidents(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cacheKeyPrefix$userId');
    if (raw == null || raw.trim().isEmpty) {
      return <IncidentRecord>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <IncidentRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => IncidentRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return <IncidentRecord>[];
    }
  }

  Future<void> _saveCachedIncidents(
    String userId,
    List<IncidentRecord> incidents,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_cacheKeyPrefix$userId',
      jsonEncode(incidents.map((item) => item.toJson()).toList()),
    );
  }

  List<IncidentRecord> _extractIncidentList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
                IncidentRecord.fromBackendJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (data is Map) {
      for (final key in const ['incidents', 'items', 'rows']) {
        final nested = data[key];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map(
                (item) => IncidentRecord.fromBackendJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }
    }

    return const <IncidentRecord>[];
  }

  String _mapLoadError(ApiException error) {
    final normalized = error.message.toLowerCase();
    if (normalized.contains('no se pudo conectar con el servidor')) {
      return _t(
        es: 'No se pudo actualizar el historial de incidentes. Revisa tu conexion.',
        en: 'The incident history could not be updated. Check your connection.',
        ay: 'Janiw incidenten historialapax machaqtayañjamakiti. Conexion uñakipam.',
        qu:
            'Incidente historiaykiqa mana musuqyachiyta atikurqanchu. Conexionniykita qhawariy.',
      );
    }
    return error.message;
  }
}
