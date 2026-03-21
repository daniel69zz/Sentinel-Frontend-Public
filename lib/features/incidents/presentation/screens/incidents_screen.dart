import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../evidence/presentation/widgets/evidence_components.dart';
import '../../domain/models/incident_record.dart';
import '../services/incident_service.dart';
import 'incident_detail_screen.dart';

class IncidentsScreen extends StatefulWidget {
  final bool isEmbedded;

  const IncidentsScreen({super.key, this.isEmbedded = false});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final IncidentService _service = IncidentService();

  List<IncidentRecord> _incidents = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _statusMessage;
  bool _isShowingCache = false;

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

  int get _openCount => _incidents.where((incident) {
    final status = incident.status.toLowerCase();
    return status.contains('abierto') ||
        status.contains('open') ||
        status.contains('registrado') ||
        status.contains('registered');
  }).length;

  int get _withContextCount => _incidents
      .where((incident) => incident.description.trim().isNotEmpty)
      .length;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents({bool refreshing = false}) async {
    if (refreshing) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _service.loadIncidents();
    if (!mounted) return;

    setState(() {
      _incidents = result.incidents;
      _statusMessage = result.message;
      _isShowingCache = result.fromCache;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _openIncidentDetail(IncidentRecord incident) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentDetailScreen(initialIncident: incident),
      ),
    );
    if (!mounted) return;
    await _loadIncidents(refreshing: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: widget.isEmbedded
          ? AppBar(
              title: Text(
                _t(
                  es: 'Incidentes',
                  en: 'Incidents',
                  ay: 'Incidentes',
                  qu: 'Incidentes',
                ),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _loadIncidents(refreshing: true),
                color: AppTheme.primary,
                backgroundColor: AppTheme.cardBg,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    if (!widget.isEmbedded) ...[
                      Text(
                        _t(
                          es: 'Incidentes',
                          en: 'Incidents',
                          ay: 'Incidentes',
                          qu: 'Incidentes',
                        ),
                        style: AppTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _t(
                          es:
                              'Aqui se concentra el contexto de cada caso, las evidencias asociadas y la preparacion para una futura denuncia.',
                          en:
                              'Here you can find the context of each case, the linked evidence, and preparation for a future report.',
                          ay:
                              'Akan sapa cason contexto, mayachata evidencianaka ukat jutir denuncia wakicht\'awix tantachatawa.',
                          qu:
                              'Kaypi sapa kasopa contexto, tinkisqa evidenciakuna hinaspa hamuq denuncia wakichiy tantachisqa kashan.',
                        ),
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: SummaryMetricCard(
                            label: _t(
                              es: 'Total',
                              en: 'Total',
                              ay: 'Total',
                              qu: 'Total',
                            ),
                            value: _incidents.length.toString(),
                            color: AppTheme.primaryLight,
                            icon: Icons.report_gmailerrorred_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryMetricCard(
                            label: _t(
                              es: 'Abiertos',
                              en: 'Open',
                              ay: 'Jist\'arata',
                              qu: 'Kicharisqa',
                            ),
                            value: _openCount.toString(),
                            color: AppTheme.warning,
                            icon: Icons.flag_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryMetricCard(
                            label: _t(
                              es: 'Con contexto',
                              en: 'With context',
                              ay: 'Contextoni',
                              qu: 'Contextoyuq',
                            ),
                            value: _withContextCount.toString(),
                            color: AppTheme.success,
                            icon: Icons.notes_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 16),
                      StatusBanner(
                        message: _statusMessage!,
                        isWarning: _isShowingCache,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _t(
                              es: 'Casos registrados',
                              en: 'Registered cases',
                              ay: 'Qillqt\'ata casos',
                              qu: 'Qillqasqa casos',
                            ),
                            style: AppTheme.titleLarge,
                          ),
                        ),
                        if (_isRefreshing)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t(
                        es:
                            'Cada incidente conserva su contexto completo y una seccion propia para evidencias y preparacion legal.',
                        en:
                            'Each incident keeps its full context and a dedicated section for evidence and legal preparation.',
                        ay:
                            'Sapa incidentex phuqhata contextop imaski ukat evidencia ukhamarak legal wakicht\'awitaki chiqa utji.',
                        qu:
                            'Sapa incidenteqa hunt\'asqa contextonta waqaychan, evidenciapaq hinaspa legal wakichinapaq rakisqa t\'uqta kan.',
                      ),
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    if (_incidents.isEmpty)
                      EmptyStateCard(
                        icon: Icons.assignment_late_outlined,
                        title: _t(
                          es: 'Aun no hay incidentes',
                          en: 'There are no incidents yet',
                          ay: 'Janiw incidentenakax utjkiti',
                          qu: 'Manaraq incidentekuna kanchu',
                        ),
                        subtitle: _t(
                          es:
                              'Las evidencias pueden existir por separado. Cuando registres o recibas incidentes en tu flujo actual, apareceran aqui.',
                          en:
                              'Evidence can exist separately. When you register or receive incidents in your current flow, they will appear here.',
                          ay:
                              'Evidencianakax sapa maynjamaw utjaspa. Jichha thakhiman incidentenak qillqantasax jan ukax katuqkasax akan uñstaniwa.',
                          qu:
                              'Evidenciakunaqa sapallan kanman. Kunan puriyniykipi incidentekunata qillqaspayki utaq chaskispayki, kaypi rikurinqa.',
                        ),
                      )
                    else
                      ..._incidents.map(
                        (incident) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _IncidentCard(
                            incident: incident,
                            onTap: () => _openIncidentDetail(incident),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IncidentRecord incident;
  final VoidCallback onTap;

  const _IncidentCard({required this.incident, required this.onTap});

  Color get _riskColor {
    final normalized = incident.riskLevel.toLowerCase();
    if (normalized.contains('crit')) {
      return AppTheme.error;
    }
    if (normalized.contains('alto')) {
      return AppTheme.warning;
    }
    return AppTheme.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.description_rounded, color: _riskColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.title, style: AppTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        formatEvidenceDate(incident.occurredAt),
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _IncidentTag(
                  label: incident.status,
                  color: AppTheme.primaryLight,
                ),
                _IncidentTag(label: incident.riskLevel, color: _riskColor),
                _IncidentTag(
                  label: incident.type,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.description.trim().isEmpty
                  ? AppLanguageService.instance.pick(
                      es: 'Sin contexto adicional registrado.',
                      en: 'No additional context recorded.',
                      ay: 'Janiw yaqha contexto qillqt\'atakti.',
                      qu: 'Mana yapasqa contexto qillqasqachu.',
                    )
                  : incident.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentTag extends StatelessWidget {
  final String label;
  final Color color;

  const _IncidentTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.trim().isEmpty
            ? AppLanguageService.instance.pick(
                es: 'sin dato',
                en: 'no data',
                ay: 'janiw dato utjkiti',
                qu: 'mana dato kanchu',
              )
            : label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
