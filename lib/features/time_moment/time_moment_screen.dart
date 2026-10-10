import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/streak_repository.dart';
import '../../domain/models/enums.dart';
import '../../widgets/cosmic_widgets.dart';

class TimeMomentScreen extends ConsumerStatefulWidget {
  const TimeMomentScreen({super.key});

  @override
  ConsumerState<TimeMomentScreen> createState() => _TimeMomentScreenState();
}

class _TimeMomentScreenState extends ConsumerState<TimeMomentScreen>
    with SingleTickerProviderStateMixin {
  late String _currentTime;
  Timer? _timer;
  final TextEditingController _intentionController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateTime() {
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
    _pulseController.dispose();
    super.dispose();
  }

  bool _isMirrorTime(String time) {
    const mirrors = {
      '00:00', '01:01', '02:02', '03:03', '04:04', '05:05', '06:06', '07:07',
      '08:08', '09:09', '10:10', '11:01', '11:11', '12:12', '13:13', '14:14',
      '15:15', '16:16', '17:17', '18:18', '19:19', '20:20', '21:21', '22:22', '23:23'
    };
    return mirrors.contains(time);
  }

  Future<void> _saveMoment() async {
    final text = _intentionController.text.trim();
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final dateStr =
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
      showCosmicSnackbar(context, 'Saat anı kaydedildi.', isError: false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final isMirror = _isMirrorTime(_currentTime);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = reduceMotion ? 1.0 : _pulseAnimation.value;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 24),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(32),
                        border: isMirror
                            ? Border.all(color: tokens.premiumBadge, width: 2)
                            : Border.all(color: tokens.glassStroke),
                        boxShadow: isMirror
                            ? tokens.primaryGlow(
                                radius: 24, opacity: 0.5)
                            : null,
                      ),
                      child: Text(
                        _currentTime,
                        style: AppTextStyles.heroTitle(tokens),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (isMirror)
                Text(
                  'Özel bir saat yakaladın!',
                  style: AppTextStyles.titleSmall(tokens).copyWith(
                    color: tokens.premiumBadge,
                  ),
                ),
              const SizedBox(height: 48),
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
              const SizedBox(height: 32),
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
