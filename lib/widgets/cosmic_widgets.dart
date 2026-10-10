import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/theme.dart';

// ─── Gradient buton (birincil CTA) ───────────────────────────────────────────
class CosmicPrimaryButton extends StatelessWidget {
  const CosmicPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width = double.infinity,
    this.height = 56,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double width;
  final double height;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final isActive = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isActive
              ? tokens.primaryGradient
              : LinearGradient(
                  colors: [tokens.onSurfaceMuted, tokens.onSurfaceMuted],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isActive ? tokens.primaryGlow(radius: 16, opacity: 0.3) : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isActive
                ? () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                : null,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: AppTextStyles.button(tokens),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── İkincil buton (kenarlıklı, şeffaf) ──────────────────────────────────────
class CosmicSecondaryButton extends StatelessWidget {
  const CosmicSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 52,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.accentPrimary,
          side: BorderSide(color: tokens.accentPrimary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.button(tokens)
              .copyWith(color: tokens.accentPrimary),
        ),
        onPressed: onPressed != null
            ? () {
                HapticFeedback.selectionClick();
                onPressed!();
              }
            : null,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}

// ─── Ghost buton (sadece metin) ───────────────────────────────────────────────
class CosmicGhostButton extends StatelessWidget {
  const CosmicGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color ?? tokens.accentPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: AppTextStyles.button(tokens).copyWith(
          color: color ?? tokens.accentPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ─── Destructive buton ────────────────────────────────────────────────────────
class CosmicDestructiveButton extends StatelessWidget {
  const CosmicDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: tokens.errorColor,
        textStyle:
            AppTextStyles.button(tokens).copyWith(color: tokens.errorColor),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// ─── Düz kart ─────────────────────────────────────────────────────────────────
class CosmicCard extends StatelessWidget {
  const CosmicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.isSelected = false,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isSelected;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap != null
            ? () {
                HapticFeedback.selectionClick();
                onTap!();
              }
            : null,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isSelected
                  ? tokens.accentPrimary
                  : (borderColor ?? tokens.glassStroke),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: isSelected
              ? Stack(
                  children: [
                    child,
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: tokens.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 13),
                      ),
                    ),
                  ],
                )
              : child,
        ),
      ),
    );
  }
}

// ─── Cam kart (glassmorphism) ─────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.opacity = 0.08,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: tokens.glassStroke, width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ─── Premium kilitli kart ─────────────────────────────────────────────────────
class LockedPremiumCard extends StatelessWidget {
  const LockedPremiumCard({
    super.key,
    required this.label,
    this.sublabel,
    this.onPreview,
  });

  final String label;
  final String? sublabel;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return CosmicCard(
      borderColor: tokens.premiumBadge.withValues(alpha: 0.5),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: tokens.primaryGradient,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.lock_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleSmall(tokens),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: AppTextStyles.caption(tokens).copyWith(
                      color: tokens.premiumBadge,
                    ),
                  ),
              ],
            ),
          ),
          if (onPreview != null)
            CosmicGhostButton(label: 'Dene', onPressed: onPreview),
        ],
      ),
    );
  }
}

// ─── Chip ────────────────────────────────────────────────────────────────────
class CosmicChip extends StatelessWidget {
  const CosmicChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accentPrimary.withValues(alpha: 0.18)
              : tokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? tokens.accentPrimary : tokens.glassStroke,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label(tokens).copyWith(
                color: isSelected ? tokens.accentPrimary : tokens.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Boş durum ────────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 20),
            ],
            Text(
              title,
              style: AppTextStyles.h2(tokens),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body(tokens).copyWith(
                  color: tokens.onSurfaceSubtle,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              CosmicPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hata durumu ──────────────────────────────────────────────────────────────
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: tokens.errorColor, size: 48),
            const SizedBox(height: 16),
            Text(
              'Bir şeyler ters gitti',
              style: AppTextStyles.h2(tokens),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body(tokens).copyWith(
                color: tokens.onSurfaceSubtle,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CosmicSecondaryButton(
                label: 'Tekrar Dene',
                onPressed: onRetry,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Yükleniyor shimmer ───────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: tokens.onSurfaceMuted.withValues(
              alpha: reduceMotion ? 0.3 : _animation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

// ─── Snackbar helper ─────────────────────────────────────────────────────────
void showCosmicSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final tokens = Theme.of(context).extension<CosmicTokens>()!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: AppTextStyles.body(tokens),
      ),
      backgroundColor: isError
          ? tokens.errorColor.withValues(alpha: 0.95)
          : tokens.surfaceElevated,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

// ─── Premium rozet ────────────────────────────────────────────────────────────
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: tokens.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        compact ? '★' : '✦ Premium',
        style: AppTextStyles.labelSmall(tokens).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 11,
        ),
      ),
    );
  }
}

// ─── Kaynak etiketi (AI / Yerel / Demo) ──────────────────────────────────────
class ContentSourceBadge extends StatelessWidget {
  const ContentSourceBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CosmicTokens>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.glassOverlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.glassStroke),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(tokens),
      ),
    );
  }
}
