import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/education_topics_catalog.dart';
import '../../domain/models/education_topic.dart';
import '../widgets/education_empty_state.dart';
import '../widgets/education_library_intro_card.dart';
import '../widgets/education_topic_card.dart';
import 'education_topic_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  final bool isEmbedded;

  const EducationScreen({super.key, this.isEmbedded = false});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _query = '';

  List<EducationTopic> get _visibleTopics {
    return EducationTopicsCatalog.topics
        .where((topic) => topic.matchesQuery(_query))
        .toList();
  }

  void _openTopic(EducationTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EducationTopicDetailScreen(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTopics = _visibleTopics;
    final isFiltering = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: widget.isEmbedded
          ? AppBar(title: const Text('Educacion DSDR'))
          : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isEmbedded) ...[
                      Text('Educacion', style: AppTheme.headlineLarge),
                      const SizedBox(height: 6),
                      Text(
                        'Derechos Sexuales y Reproductivos',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ],
                    EducationLibraryIntroCard(
                      totalTopics: EducationTopicsCatalog.topics.length,
                      visibleTopics: visibleTopics.length,
                      isFiltering: isFiltering,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: TextField(
                        style: AppTheme.bodyLarge,
                        onChanged: (value) {
                          setState(() => _query = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar tema...',
                          hintStyle: AppTheme.bodyMedium,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isFiltering ? 'Resultados' : 'Temas disponibles',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isFiltering
                          ? 'Selecciona el tema que quieras abrir.'
                          : 'Cada tarjeta abre otra pantalla con video, comic y texto.',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: visibleTopics.isEmpty
                  ? const SliverToBoxAdapter(child: EducationEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final topic = visibleTopics[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EducationTopicCard(
                            topic: topic,
                            onTap: () => _openTopic(topic),
                          ),
                        );
                      }, childCount: visibleTopics.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
