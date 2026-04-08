import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_language_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_design_theme.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../directory/presentation/screens/directory_screen.dart';
import '../../../education/presentation/screens/education_screen.dart';
import '../../../emergency/presentation/screens/emergency_screen.dart';
import '../../../evidence/presentation/screens/evidence_library_screen.dart';
import '../../../incidents/presentation/screens/incidents_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _sectionCount = 6;

  late int _currentIndex;
  final Set<int> _visitedIndices = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = _normalizeIndex(widget.initialIndex);
    _visitedIndices.add(_currentIndex);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = _normalizeIndex(widget.initialIndex);
      _visitedIndices.add(_currentIndex);
    }
  }

  int _normalizeIndex(int index) {
    if (index < 0 || index >= _sectionCount) {
      return 0;
    }

    return index;
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = _normalizeIndex(index);
      _visitedIndices.add(_currentIndex);
    });
  }

  Widget _buildScreen(int index) {
    const builders = <int, Widget>{
      0: EmergencyScreen(isEmbedded: true),
      1: EvidenceLibraryScreen(isEmbedded: true),
      2: IncidentsScreen(isEmbedded: true),
      3: EducationScreen(isEmbedded: true),
      4: DirectoryScreen(isEmbedded: true),
      5: ProfileScreen(isEmbedded: true),
    };
    return builders[index] ?? const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_sectionCount, (index) {
          if (_visitedIndices.contains(index)) {
            return _buildScreen(index);
          }
          return const SizedBox.shrink();
        }),
      ),
      floatingActionButton: AppFloatMotion(
        amplitude: 3.1,
        phase: math.pi / 4,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.chatbot),
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: Text(context.tr('navigation.chat')),
        ),
      ),
      floatingActionButtonLocation: const _LowerEndFloatLocation(offsetY: 12),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
      ),
    );
  }
}

class _LowerEndFloatLocation extends FloatingActionButtonLocation {
  final double offsetY;

  const _LowerEndFloatLocation({this.offsetY = 0});

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final base = FloatingActionButtonLocation.endFloat.getOffset(
      scaffoldGeometry,
    );
    final minY = scaffoldGeometry.minInsets.top;
    final maxY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.minInsets.bottom -
        scaffoldGeometry.floatingActionButtonSize.height;

    return Offset(base.dx, (base.dy + offsetY).clamp(minY, maxY));
  }
}
