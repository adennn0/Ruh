import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/streak_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/time_moment/special_times.dart';
import '../../widgets/cosmic_widgets.dart';

class TimeMomentScreen extends ConsumerStatefulWidget {
  const TimeMomentScreen({super.key, this.initialDate, this.initialTime});

  final String? initialDate;
  final String? initialTime;

  @override
  ConsumerState<TimeMomentScreen> createState() => _TimeMomentScreenState();
}

class _TimeMomentScreenState extends ConsumerState<TimeMomentScreen> {
  String _currentTime = '';
  Timer? _timer;
  final TextEditingController _intentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateTime();
    if (!_hasFixedInitialTime) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    }
  }

  bool get _hasFixedInitialTime {
    final value = widget.initialTime;
    if (value == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
      return false;
    }
    final parts = value.split(':').map(int.parse).toList();
    return parts[0] >= 0 && parts[0] < 24 && parts[1] >= 0 && parts[1] < 60;
  }

  void _updateTime() {
    if (_hasFixedInitialTime) {
      if (_currentTime != widget.initialTime) {
        setState(() => _currentTime = widget.initialTime!);
      }
      return;
    }
    final now = DateTime.now();
    final newTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    if (newTime != _currentTime) {
      setState(() {
        _currentTime = newTime;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intentionController.dispose();
    super.dispose();
  }

  bool _isMirrorTime(String time) => SpecialTimes.isSpecial(time);

  Future<void> _saveMoment() async {
    final text = _intentionController.text.trim();
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final dateStr = widget.initialDate ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await db.into(db.timeMomentTable).insert(
          TimeMomentTableCompanion.insert(
            date: dateStr,
            timeLabel: _currentTime,
            intentionText: drift.Value(text.isEmpty ? null : text),
          ),
        );

    final streakRepo = ref.read(streakRepositoryProvider);
    await streakRepo.recordActivity(StreakBit.saveTimeMoment);
    if (!await streakRepo.hasBadge(BadgeId.firstTimeMoment.name)) {
      await streakRepo.awardBadge(BadgeId.firstTimeMoment.name);
    }

    if (mounted) {
      context.push('/time-moment/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final isMirror = _isMirrorTime(_currentTime);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Saat Anı geçmişi',
            onPressed: () => context.push('/time-moment/history'),
            icon: Icon(Icons.history, color: tokens.onBackground),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isMirror ? tokens.accentPrimary : tokens.glassStroke,
                    width: isMirror ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  _currentTime,
                  style: AppTextStyles.heroTitle(tokens),
                ),
              ),
              const SizedBox(height: 12),
              if (isMirror)
                Text(
                  'Özel bir saat yakaladın!',
                  style: AppTextStyles.titleSmall(tokens).copyWith(
                    color: tokens.premiumBadge,
                  ),
                ),
              const SizedBox(height: 28),
              Text(
                'Bu ana ne niyetin?',
                style: AppTextStyles.h2(tokens),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _intentionController,
                maxLength: 120,
                maxLines: 3,
                style: AppTextStyles.bodyLarge(tokens),
                decoration: InputDecoration(
                  hintText: 'Niyetini buraya yaz...',
                  hintStyle: AppTextStyles.bodyLarge(tokens)
                      .copyWith(color: tokens.onSurfaceMuted),
                  filled: true,
                  fillColor: tokens.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.glassStroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.glassStroke),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: tokens.accentPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CosmicPrimaryButton(
                label: 'Kayıt Et',
                onPressed: _saveMoment,
              ),
              const SizedBox(height: 16),
              CosmicGhostButton(
                label: 'Sadece Fark Et',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                color: tokens.onSurfaceSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
