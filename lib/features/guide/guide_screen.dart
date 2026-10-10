import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/theme.dart';
import '../../core/limits.dart';
import '../../core/entitlement/entitlement.dart';
import '../../widgets/cosmic_widgets.dart';

// --- State Models ---

class ChatMessageModel {
  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class GuideState {
  const GuideState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.messagesUsed = 0,
    this.cooldownRemaining = 0,
  });

  final List<ChatMessageModel> messages;
  final bool isLoading;
  final String? error;
  final int messagesUsed;
  final int cooldownRemaining;

  GuideState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
    String? error,
    int? messagesUsed,
    int? cooldownRemaining,
    bool clearError = false,
  }) {
    return GuideState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      messagesUsed: messagesUsed ?? this.messagesUsed,
      cooldownRemaining: cooldownRemaining ?? this.cooldownRemaining,
    );
  }
}

// --- Controller ---

class GuideController extends StateNotifier<GuideState> {
  GuideController(this.ref) : super(const GuideState()) {
    _startCooldownTimer();
  }

  final Ref ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.cooldownRemaining > 0) {
        state = state.copyWith(cooldownRemaining: state.cooldownRemaining - 1);
      }
    });
  }

  void clearHistory() {
    state = state.copyWith(messages: []);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final isPremium = ref.read(isPremiumProvider);
    final maxMessages =
        ref.read(entitlementServiceProvider).limitFor(AppFeature.dailyMessages);

    if (!isPremium && state.messagesUsed >= maxMessages) {
      state = state.copyWith(
          error: 'Günlük mesaj limitine ulaştınız. Premium\'a geçin.');
      return;
    }

    if (state.cooldownRemaining > 0) return;

    final userMsg = ChatMessageModel(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
      messagesUsed: state.messagesUsed + 1,
    );

    final lowerText = text.toLowerCase();
    if (lowerText.contains('intihar') ||
        lowerText.contains('kendime zarar') ||
        lowerText.contains('öldürmek')) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final crisisMsg = ChatMessageModel(
        text:
            'Lütfen yalnız olmadığını bil. Sana yardım etmek için buradayız. Lütfen hemen 112 Acil Çağrı Merkezi\'ni veya 182 (ALO Psikiyatri) hattını ara.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, crisisMsg],
        isLoading: false,
        cooldownRemaining: isPremium
            ? AppLimits.premiumCooldownSeconds
            : AppLimits.freeCooldownSeconds,
      );
      return;
    }

    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      String reply =
          'Evrenin bu anında, sorduğun soruya odaklanıyorum... İçindeki ışığı koru.';
      if (lowerText.contains('olumlama')) {
        reply = 'Ben değerliyim ve evrenin sonsuz bolluğuna açığım.';
      } else if (lowerText.contains('niyet')) {
        reply =
            'Bugünkü niyetin: "Karşılaştığım her zorlukta içsel gücümü fark etmeyi seçiyorum."';
      } else if (lowerText.contains('nefes')) {
        reply =
            'Hadi beraber derin bir nefes alalım... 4 saniye al, 4 saniye tut, 4 saniye ver.';
      } else if (lowerText.contains('bugünkü mesajım')) {
        reply =
            'Bugün yaratıcılığının zirvesinde olduğun bir gün. Kendine güven ve sezgilerini dinle.';
      }

      final aiMsg = ChatMessageModel(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        cooldownRemaining: isPremium
            ? AppLimits.premiumCooldownSeconds
            : AppLimits.freeCooldownSeconds,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Bir sorun oluştu. Lütfen tekrar dene.',
      );
    }
  }
}

final guideControllerProvider =
    StateNotifierProvider<GuideController, GuideState>((ref) {
  return GuideController(ref);
});

// --- Screen ---

class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final state = ref.watch(guideControllerProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final maxMessages = ref
        .watch(entitlementServiceProvider)
        .limitFor(AppFeature.dailyMessages);

    ref.listen<GuideState>(guideControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surface,
        title: Text('Rehber', style: AppTextStyles.h2(tokens)),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.light),
                color: tokens.onBackground),
            onPressed: () => context.push(
                '/profile/notifications'), // Will navigate to notification settings based on standard setup
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: tokens.onBackground),
            color: tokens.surfaceElevated,
            onSelected: (val) {
              if (val == 'clear') {
                ref.read(guideControllerProvider.notifier).clearHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Text('Sohbet geçmişini sil',
                    style: AppTextStyles.body(tokens)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Mock Banner
          Container(
            width: double.infinity,
            color: tokens.accentSecondary.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.info(PhosphorIconsStyle.fill),
                    color: tokens.accentSecondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Geliştirme modu: örnek yanıtlar',
                  style: AppTextStyles.labelSmall(tokens)
                      .copyWith(color: tokens.accentSecondary),
                ),
              ],
            ),
          ),

          // Header / Daily Message Card
          if (state.messages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                            color: tokens.accentPrimary, size: 20),
                        const SizedBox(width: 8),
                        Text('Bugünkü mesajım',
                            style: AppTextStyles.titleSmall(tokens)),
                        const Spacer(),
                        if (isPremium) const PremiumBadge(compact: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'İçindeki yıldızların sana fısıldadığı bir şeyler var. Sorularını sor, beraber keşfedelim.',
                      style: AppTextStyles.body(tokens),
                    ),
                  ],
                ),
              ),
            ),

          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          // Error State
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ErrorStateWidget(
                message: state.error!,
                onRetry: () {
                  ref
                      .read(guideControllerProvider.notifier)
                      .sendMessage(_textController.text);
                },
              ),
            ),

          // Loading State
          if (state.isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: tokens.accentPrimary),
                  ),
                  const SizedBox(width: 12),
                  Text('Rehber yanıtlıyor...',
                      style: AppTextStyles.caption(tokens)),
                ],
              ),
            ),

          // Quick Suggestions
          if (!state.isLoading && state.messages.isEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  'Bugünkü mesajım',
                  'Bana bir olumlama yaz',
                  'Niyetimi netleştir',
                  '1 dakikalık nefes',
                  'Burcuma göre bugün'
                ]
                    .map((text) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CosmicChip(
                            label: text,
                            onTap: () {
                              _textController.text = text;
                              ref
                                  .read(guideControllerProvider.notifier)
                                  .sendMessage(text);
                              _textController.clear();
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Input Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Quota & Cooldown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPremium
                            ? 'Sınırsız mesaj (Premium)'
                            : 'Bugün kalan: ${maxMessages - state.messagesUsed}/$maxMessages',
                        style: AppTextStyles.caption(tokens),
                      ),
                      if (state.cooldownRemaining > 0)
                        Text(
                          'Bekleme süresi: ${state.cooldownRemaining}sn',
                          style: AppTextStyles.caption(tokens)
                              .copyWith(color: tokens.errorColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: AppTextStyles.body(tokens),
                          enabled:
                              !state.isLoading && state.cooldownRemaining == 0,
                          decoration: InputDecoration(
                            hintText: 'Bir şeyler sor...',
                            hintStyle: AppTextStyles.body(tokens)
                                .copyWith(color: tokens.onSurfaceMuted),
                            filled: true,
                            fillColor: tokens.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: tokens.glassStroke),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: tokens.glassStroke),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide:
                                  BorderSide(color: tokens.accentPrimary),
                            ),
                          ),
                          onSubmitted: (val) {
                            ref
                                .read(guideControllerProvider.notifier)
                                .sendMessage(val);
                            _textController.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient:
                              (state.isLoading || state.cooldownRemaining > 0)
                                  ? null
                                  : tokens.primaryGradient,
                          color:
                              (state.isLoading || state.cooldownRemaining > 0)
                                  ? tokens.onSurfaceMuted
                                  : null,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: (state.isLoading ||
                                  state.cooldownRemaining > 0)
                              ? null
                              : () {
                                  ref
                                      .read(guideControllerProvider.notifier)
                                      .sendMessage(_textController.text);
                                  _textController.clear();
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? tokens.accentPrimary.withValues(alpha: 0.15)
              : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomLeft: !message.isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: message.isUser
                ? tokens.accentPrimary.withValues(alpha: 0.3)
                : tokens.glassStroke,
          ),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body(tokens).copyWith(
            color: tokens.onBackground,
          ),
        ),
      ),
    );
  }
}
