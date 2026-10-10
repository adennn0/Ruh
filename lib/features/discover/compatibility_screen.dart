import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../data/repositories/saved_person_repository.dart';
import '../../domain/astrology/astrology_engine.dart';
import '../../domain/compatibility/compatibility_engine.dart';
import '../../widgets/cosmic_widgets.dart';

class CompatibilityScreen extends ConsumerStatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  ConsumerState<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends ConsumerState<CompatibilityScreen> {
  ZodiacSign? _sign1;
  ZodiacSign _sign2 = ZodiacSign.taurus; // default
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile?.birthDate != null) {
        final engine = ref.read(astrologyEngineProvider);
        final sunSign = engine.sunSign(userProfile!.birthDate).sunSign;
        setState(() {
          _sign1 = sunSign;
        });
      } else {
        setState(() {
          _sign1 = ZodiacSign.aries;
        });
      }
    });
  }

  Color _getScoreColor(int score, CosmicTokens tokens) {
    if (score >= 85) return tokens.premiumBadge;
    if (score >= 70) return tokens.accentPrimary;
    if (score >= 55) return tokens.accentSecondary;
    return tokens.accentTertiary;
  }

  void _showAddPersonSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const AddPersonSheet(),
    );
  }

  void _selectSavedPerson(SavedPerson person) {
    final engine = ref.read(astrologyEngineProvider);
    final sunSign = engine.sunSign(person.birthDate).sunSign;
    setState(() {
      _sign2 = sunSign;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final engine = ref.watch(compatibilityEngineProvider);
    final savedPersonsAsync = ref.watch(savedPersonsStreamProvider);
    final isPremium = ref.watch(isPremiumProvider);

    if (_sign1 == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final result = engine.calculate(_sign1!, _sign2);
    final scoreColor = _getScoreColor(result.score, tokens);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Uyumluluk', style: AppTextStyles.h2(tokens).copyWith(color: tokens.onBackground)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: tokens.onBackground),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPersonSheet,
        backgroundColor: tokens.surfaceElevated,
        icon: Icon(Icons.add, color: tokens.onSurface),
        label: Text('Kişi Ekle', style: AppTextStyles.button(tokens).copyWith(color: tokens.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sign Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSignSelector(_sign1!, (s) => setState(() => _sign1 = s), tokens, 'Sen'),
                Icon(Icons.favorite, color: scoreColor, size: 32),
                _buildSignSelector(_sign2, (s) => setState(() => _sign2 = s), tokens, 'Partner'),
              ],
            ),
            const SizedBox(height: 32),

            // Score Display
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scoreColor, width: 8),
                boxShadow: tokens.primaryGlow(radius: 20, opacity: 0.2),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${result.score}',
                    style: AppTextStyles.display(tokens).copyWith(color: scoreColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: scoreColor),
              ),
              child: Text(
                result.label,
                style: AppTextStyles.labelLarge(tokens).copyWith(color: scoreColor),
              ),
            ),
            const SizedBox(height: 24),

            // Commentary
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                result.shortText,
                style: AppTextStyles.bodyLarge(tokens).copyWith(color: tokens.onSurface),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Disclaimer
            Text(
              'Bu puan sembolik ve eğlence amaçlıdır, kaderinizi belirlemez.',
              style: AppTextStyles.caption(tokens).copyWith(color: tokens.onSurfaceSubtle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Saved Persons
            savedPersonsAsync.when(
              data: (persons) {
                if (persons.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kayıtlı Kişiler', style: AppTextStyles.title(tokens).copyWith(color: tokens.onBackground)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: persons.length,
                        itemBuilder: (ctx, i) {
                          final p = persons[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () => _selectSavedPerson(p),
                              borderRadius: BorderRadius.circular(16),
                              child: CosmicCard(
                                borderColor: tokens.glassStroke,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(p.nickname, style: AppTextStyles.bodyLarge(tokens).copyWith(color: tokens.onSurface)),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(p.birthDate),
                                      style: AppTextStyles.caption(tokens).copyWith(color: tokens.onSurfaceSubtle),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, st) => Text('Hata', style: AppTextStyles.body(tokens).copyWith(color: tokens.errorColor)),
            ),
            const SizedBox(height: 24),

            // Premium Section
            Opacity(
              opacity: isPremium ? 1.0 : 0.5,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Detaylı Analiz', style: AppTextStyles.title(tokens).copyWith(color: tokens.onBackground)),
                        const Spacer(),
                        if (!isPremium) const PremiumBadge(compact: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLockedTab(Icons.favorite, 'Aşk', tokens),
                        _buildLockedTab(Icons.group, 'Arkadaşlık', tokens),
                        _buildLockedTab(Icons.chat, 'İletişim', tokens),
                        _buildLockedTab(Icons.handshake, 'İş birliği', tokens),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSignSelector(ZodiacSign current, ValueChanged<ZodiacSign> onChanged, CosmicTokens tokens, String label) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.label(tokens).copyWith(color: tokens.onSurfaceSubtle)),
        const SizedBox(height: 8),
        DropdownButton<ZodiacSign>(
          value: current,
          dropdownColor: tokens.surfaceElevated,
          underline: const SizedBox(),
          icon: Icon(Icons.arrow_drop_down, color: tokens.onSurface),
          items: ZodiacSign.values.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text('${s.symbol} ${s.displayName}', style: AppTextStyles.bodyLarge(tokens).copyWith(color: tokens.onSurface)),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildLockedTab(IconData icon, String label, CosmicTokens tokens) {
    return Column(
      children: [
        Icon(icon, color: tokens.onSurfaceSubtle, size: 28),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption(tokens).copyWith(color: tokens.onSurfaceSubtle)),
      ],
    );
  }
}

class AddPersonSheet extends ConsumerStatefulWidget {
  const AddPersonSheet({super.key});

  @override
  ConsumerState<AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<AddPersonSheet> {
  final _nameCtrl = TextEditingController();
  DateTime? _date;
  String? _error;

  void _save() async {
    if (_nameCtrl.text.trim().isEmpty || _date == null) {
      setState(() => _error = 'Lütfen ad ve doğum tarihi girin.');
      return;
    }
    final repo = ref.read(savedPersonRepositoryProvider);
    final res = await repo.addPerson(_nameCtrl.text.trim(), _date!);
    if (res.success) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _error = res.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kişi Ekle', style: AppTextStyles.h2(tokens).copyWith(color: tokens.onBackground), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyLarge(tokens).copyWith(color: tokens.onSurface),
              decoration: InputDecoration(
                hintText: 'İsim / Lakap',
                hintStyle: AppTextStyles.body(tokens).copyWith(color: tokens.onSurfaceSubtle),
                filled: true,
                fillColor: tokens.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: tokens.onSurfaceSubtle),
                    const SizedBox(width: 12),
                    Text(
                      _date == null ? 'Doğum Tarihi Seç' : DateFormat('dd.MM.yyyy').format(_date!),
                      style: AppTextStyles.bodyLarge(tokens).copyWith(color: tokens.onSurface),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: AppTextStyles.body(tokens).copyWith(color: tokens.errorColor)),
              const SizedBox(height: 16),
            ],
            CosmicPrimaryButton(
              label: 'Kaydet',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

final savedPersonsStreamProvider = StreamProvider<List<SavedPerson>>((ref) {
  return ref.watch(savedPersonRepositoryProvider).watchAll();
});
