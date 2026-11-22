import 'package:flutter/material.dart';

import '../ui2/anix_kit.dart';
import '../ui2/page_turn.dart';

/// ANIX design tokens. Legacy gameplay colors remain stable; the app chrome
/// reads [NxThemeColors] from the active theme instead.
class NxColors {
  NxColors._();
  static const navy = Color(0xFF0A0F2C);
  static const navyDeep = Color(0xFF050818);
  static const navySoft = Color(0xFF141B45);
  static const electricBlue = Color(0xFF00C2FF);
  static const violet = Color(0xFF7B3FF2);
  static const iceWhite = Color(0xFFEAF6FF);
  static const turquoise = Color(0xFF2EE6D6);
  static const gold = Color(0xFFFFC857);
  static const pink = Color(0xFFFF4FA3);
  static const danger = Color(0xFFFF5A6E);
  static const success = Color(0xFF3DDC97);
  static const glass = Color(0x22FFFFFF);
  static const glassBorder = Color(0x44FFFFFF);
  static const textDim = Color(0xB3EAF6FF);
}

enum NxAppearanceMode { dark, light }

enum NxVisualTheme { gold, neon }

/// Colors and surface treatment for the two selectable ANIX visual themes.
class NxThemeColors extends ThemeExtension<NxThemeColors> {
  const NxThemeColors({
    required this.accent,
    required this.accentSecondary,
    required this.background,
    required this.backgroundMid,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.muted,
    this.premiumPanels = true,
  });

  final Color accent;
  final Color accentSecondary;
  final Color background;
  final Color backgroundMid;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color text;
  final Color muted;
  final bool premiumPanels;

  /// Station Luxe (black / gold / champagne) — the one app skin. It is identical to [neon] so a user
  /// who picked the old "gold" preset in settings lands on the same home-page palette instead of the
  /// retired navy theme; the preset name is kept for settings compatibility.
  static const gold = NxThemeColors(
    accent: Color(0xFFD9B872),
    accentSecondary: Color(0xFF8A6A2C),
    background: Color(0xFF07080C),
    backgroundMid: Color(0xFF12110D),
    surface: Color(0xE6141310),
    surfaceRaised: Color(0xF01C1A14),
    border: Color(0xFF8A6A2C),
    text: Color(0xFFF4EAD2),
    muted: Color(0xFFB9AE95),
  );

  /// NX2 cosmic neon skin (deep violet, neon cyan/magenta) — the app skin.
  /// App skin: ANIX PRO Station Luxe (black / gold / champagne). Name kept for settings compatibility.
  static const neon = NxThemeColors(
    accent: Color(0xFFD9B872),
    accentSecondary: Color(0xFF8A6A2C),
    background: Color(0xFF07080C),
    backgroundMid: Color(0xFF12110D),
    surface: Color(0xE6141310),
    surfaceRaised: Color(0xF01C1A14),
    border: Color(0xFF8A6A2C),
    text: Color(0xFFF4EAD2),
    muted: Color(0xFFB9AE95),
  );

  static const neonLight = NxThemeColors(
    accent: Color(0xFF087EA4),
    accentSecondary: Color(0xFF6D35B5),
    background: Color(0xFFF5F3FF),
    backgroundMid: Color(0xFFEAE4FF),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0ECFF),
    border: Color(0xFF9A7AD8),
    text: Color(0xFF171329),
    muted: Color(0xFF625B78),
  );

  static const goldLight = NxThemeColors(
    accent: Color(0xFF9A6500),
    accentSecondary: Color(0xFF8A4B08),
    background: Color(0xFFFFFBF1),
    backgroundMid: Color(0xFFFFF2D4),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFF7E5),
    border: Color(0xFFC49A48),
    text: Color(0xFF241A08),
    muted: Color(0xFF6C5A38),
  );

  /// Original visual language used inside active game boards and their HUDs.
  static const gameplay = NxThemeColors(
    accent: NxColors.electricBlue,
    accentSecondary: NxColors.violet,
    background: NxColors.navyDeep,
    backgroundMid: NxColors.navy,
    surface: NxColors.glass,
    surfaceRaised: NxColors.navySoft,
    border: NxColors.glassBorder,
    text: NxColors.iceWhite,
    muted: NxColors.textDim,
    premiumPanels: false,
  );

  static NxThemeColors of(BuildContext context) =>
      Theme.of(context).extension<NxThemeColors>() ?? neon;

  @override
  NxThemeColors copyWith({
    Color? accent,
    Color? accentSecondary,
    Color? background,
    Color? backgroundMid,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? text,
    Color? muted,
    bool? premiumPanels,
  }) {
    return NxThemeColors(
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      background: background ?? this.background,
      backgroundMid: backgroundMid ?? this.backgroundMid,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      premiumPanels: premiumPanels ?? this.premiumPanels,
    );
  }

  @override
  NxThemeColors lerp(ThemeExtension<NxThemeColors>? other, double t) {
    if (other is! NxThemeColors) return this;
    return NxThemeColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t) ??
          accentSecondary,
      background: Color.lerp(background, other.background, t) ?? background,
      backgroundMid:
          Color.lerp(backgroundMid, other.backgroundMid, t) ?? backgroundMid,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceRaised:
          Color.lerp(surfaceRaised, other.surfaceRaised, t) ?? surfaceRaised,
      border: Color.lerp(border, other.border, t) ?? border,
      text: Color.lerp(text, other.text, t) ?? text,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      premiumPanels: t < 0.5 ? premiumPanels : other.premiumPanels,
    );
  }
}

/// Per-world accents stay available to gameplay and to the worlds' own content.
class WorldPalette {
  const WorldPalette(this.primary, this.secondary, this.background,
      {this.light = false});
  final Color primary;
  final Color secondary;
  final List<Color> background;
  final bool light;
  static const hub = WorldPalette(NxColors.electricBlue, NxColors.violet,
      [Color(0xFF050818), Color(0xFF0E1640), Color(0xFF1B0F3F)]);
  static const nova = WorldPalette(Color(0xFFFF6FB5), NxColors.gold,
      [Color(0xFF1A0B2E), Color(0xFF3B1450), Color(0xFF5A1E4F)]);
  static const orbit = WorldPalette(NxColors.turquoise, NxColors.electricBlue,
      [Color(0xFF031A26), Color(0xFF06324A), Color(0xFF0A2A3F)]);
  static const arcade = WorldPalette(Color(0xFFFFB020), Color(0xFFFF4F6E),
      [Color(0xFF12051F), Color(0xFF2A0B3A), Color(0xFF3A0F2A)]);
  static const oracle = WorldPalette(Color(0xFF9D7BFF), NxColors.turquoise,
      [Color(0xFF0B0820), Color(0xFF1A1250), Color(0xFF0E2850)]);
  static const personal = WorldPalette(Color(0xFF7CF5D0), Color(0xFFB79CFF),
      [Color(0xFFEFF6FF), Color(0xFFDDE9FF), Color(0xFFEDE3FF)],
      light: true);
  static const social = WorldPalette(Color(0xFF4FD1FF), Color(0xFF7CFF8A),
      [Color(0xFF04141F), Color(0xFF0B2B33), Color(0xFF0E1F3A)]);
  static const exchange = WorldPalette(NxColors.gold, Color(0xFFFFE6A8),
      [Color(0xFF0D0B05), Color(0xFF2A2210), Color(0xFF1A1530)]);
}

class NxSpace {
  NxSpace._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class NxRadius {
  NxRadius._();
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
}

class NxMotion {
  NxMotion._();
  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 520);
  static const curve = Curves.easeOutCubic;
}

/// The NX2 redesign ships one skin: cosmic neon. [style] is kept for API compatibility.
ThemeData buildNxTheme([
  NxVisualTheme style = NxVisualTheme.neon,
  NxAppearanceMode appearance = NxAppearanceMode.dark,
]) => _buildTheme(
      appearance == NxAppearanceMode.light
          ? (style == NxVisualTheme.gold
              ? NxThemeColors.goldLight
              : NxThemeColors.neonLight)
          : (style == NxVisualTheme.gold ? NxThemeColors.gold : NxThemeColors.neon),
      appearance,
    );

/// Preserve the original Finger Soccer field, ball and player-disc palette.
ThemeData buildNxGameplayTheme() =>
    _buildTheme(NxThemeColors.gameplay, NxAppearanceMode.dark);

ThemeData _buildTheme(NxThemeColors visual, NxAppearanceMode appearance) {
  final scheme = (appearance == NxAppearanceMode.light
          ? ColorScheme.light
          : ColorScheme.dark)(
    primary: visual.accent,
    secondary: visual.accentSecondary,
    tertiary:
        visual.premiumPanels ? visual.accentSecondary : NxColors.turquoise,
    surface: visual.surfaceRaised,
    error: NxColors.danger,
    onPrimary: appearance == NxAppearanceMode.light ? Colors.white : const Color(0xFF08101A),
    onSurface: visual.text,
  );
  final bool isDark = appearance == NxAppearanceMode.dark;
  final Color chromePanel = isDark ? const Color(0xF214130F) : visual.surfaceRaised;
  final Color chromeSheet = isDark ? const Color(0xFF0F0E0B) : visual.surfaceRaised;
  final Color chromeChip = isDark ? const Color(0xE61C1912) : visual.surface;
  final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      // Every Material default (FAB labels, chips, buttons with their own text styles) uses the app fonts too.
      fontFamily: kNxFont,
      fontFamilyFallback: kNxFontFallback);
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[visual],
    pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: NxPageTurnTransitionsBuilder(),
      TargetPlatform.iOS: NxPageTurnTransitionsBuilder(),
      TargetPlatform.linux: NxPageTurnTransitionsBuilder(),
      TargetPlatform.macOS: NxPageTurnTransitionsBuilder(),
      TargetPlatform.windows: NxPageTurnTransitionsBuilder(),
    }),
    scaffoldBackgroundColor: visual.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: visual.text,
      titleTextStyle: TextStyle(
          fontFamily: kNxFontHead,
          fontFamilyFallback: kNxFontHeadFallback,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: visual.text),
    ),
    textTheme: nxGameTextTheme(base.textTheme)
        .apply(bodyColor: visual.text, displayColor: visual.text),
    iconTheme: IconThemeData(color: visual.text),
    cardTheme: CardThemeData(
      color: visual.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        side: BorderSide(color: visual.border.withValues(alpha: 0.35)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: visual.surface.withValues(alpha: 0.82),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        borderSide: BorderSide(color: visual.border.withValues(alpha: 0.46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        borderSide: BorderSide(color: visual.border.withValues(alpha: 0.38)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        borderSide: BorderSide(color: visual.accent, width: 1.5),
      ),
      labelStyle: TextStyle(color: visual.muted),
      hintStyle: TextStyle(color: visual.muted.withValues(alpha: 0.82)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: visual.accentSecondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NxRadius.md)),
        textStyle: const TextStyle(
            fontFamily: kNxFont, fontFamilyFallback: kNxFontFallback, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: visual.accent,
        side: BorderSide(color: visual.accent.withValues(alpha: 0.7)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NxRadius.md)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xF21C1A14) : visual.surfaceRaised,
      contentTextStyle: TextStyle(
          fontFamily: kNxFont,
          fontFamilyFallback: kNxFontFallback,
          fontWeight: FontWeight.w700,
          color: visual.text),
      actionTextColor: visual.accent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        side: BorderSide(color: visual.border.withValues(alpha: 0.45)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: chromePanel,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontFamily: kNxFontHead,
          fontFamilyFallback: kNxFontHeadFallback,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: visual.text),
      contentTextStyle: TextStyle(
          fontFamily: kNxFont,
          fontFamilyFallback: kNxFontFallback,
          fontSize: 13.5,
          height: 1.45,
          color: visual.muted),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NxRadius.lg),
        side: BorderSide(color: visual.border.withValues(alpha: 0.5)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: chromeSheet,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: chromeSheet,
      showDragHandle: true,
      dragHandleColor: visual.border.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NxRadius.lg)),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: visual.accent,
      unselectedLabelColor: visual.muted,
      indicatorColor: visual.accent,
      dividerColor: Colors.transparent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: visual.accent),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: chromePanel,
      indicatorColor: visual.accentSecondary.withValues(alpha: 0.35),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, color: visual.text)),
      iconTheme: WidgetStatePropertyAll<IconThemeData>(
          IconThemeData(color: visual.text)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: chromeChip,
      selectedColor: visual.accentSecondary.withValues(alpha: 0.45),
      side: BorderSide(color: visual.border.withValues(alpha: 0.7)),
      labelStyle: TextStyle(color: visual.text, fontWeight: FontWeight.w700),
      shape: const StadiumBorder(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> s) =>
          s.contains(WidgetState.selected) ? Colors.white : visual.muted),
      trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> s) =>
          s.contains(WidgetState.selected)
              ? visual.accentSecondary
              : const Color(0x33FFFFFF)),
    ),
    // ANIX tooltip pack: compact panel with its pointer, opening above the target.
    tooltipTheme: TooltipThemeData(
      decoration: anixTooltipDecoration(),
      preferBelow: false,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: const TextStyle(
          fontFamily: kNxFont,
          fontFamilyFallback: kNxFontFallback,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFEAF6FF)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: visual.accent,
      thumbColor: Colors.white,
      inactiveTrackColor: const Color(0x33FFFFFF),
    ),
    // Everything below exists so legacy pages that still use raw Material widgets (menus, list tiles,
    // spinners, checkboxes, sheets) inherit the same chrome as the pages rebuilt on the Luxe kit.
    dividerTheme: DividerThemeData(
      color: visual.border.withValues(alpha: 0.28),
      thickness: 1,
      space: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: chromePanel,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NxRadius.md),
        side: BorderSide(color: visual.border.withValues(alpha: 0.45)),
      ),
      labelTextStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(
          fontFamily: kNxFont,
          fontFamilyFallback: kNxFontFallback,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: visual.text)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: visual.text, fontFamily: kNxFont),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(chromePanel),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(NxRadius.md)),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: visual.text,
      iconColor: visual.muted,
      selectedColor: visual.accent,
      selectedTileColor: visual.accent.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NxRadius.sm)),
      minVerticalPadding: 10,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: visual.accent,
        textStyle: const TextStyle(
            fontFamily: kNxFont, fontFamilyFallback: kNxFontFallback, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NxRadius.sm)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: visual.text,
        highlightColor: visual.accent.withValues(alpha: 0.16),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> st) =>
          st.contains(WidgetState.selected) ? visual.accent : Colors.transparent),
      checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF07080C)),
      side: BorderSide(color: visual.border.withValues(alpha: 0.7), width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> st) =>
          st.contains(WidgetState.selected) ? visual.accent : visual.muted),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> st) =>
            st.contains(WidgetState.selected)
                ? visual.accent.withValues(alpha: 0.22)
                : chromeChip),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> st) =>
            st.contains(WidgetState.selected) ? visual.accent : visual.muted),
        side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: visual.border.withValues(alpha: 0.4))),
        textStyle: const WidgetStatePropertyAll<TextStyle>(TextStyle(
            fontFamily: kNxFont, fontFamilyFallback: kNxFontFallback, fontWeight: FontWeight.w800)),
      ),
    ),
  );
}


// ------------------------------------------------------------------ fonts (bundled, OFL)
/// Latin + digits: Chakra Petch (HUD/game look). Persian uses Estedad for a
/// consistent, readable shape across body text, buttons and headings.
const String kNxFont = 'ChakraPetch';
const List<String> kNxFontFallback = <String>['Estedad'];
const String kNxFontHead = 'ChakraPetch';
const List<String> kNxFontHeadFallback = <String>['Estedad'];

TextTheme nxGameTextTheme(TextTheme t) {
  TextStyle? body(TextStyle? s) => s?.copyWith(fontFamily: kNxFont, fontFamilyFallback: kNxFontFallback);
  TextStyle? head(TextStyle? s) => s?.copyWith(fontFamily: kNxFontHead, fontFamilyFallback: kNxFontHeadFallback);
  return t.copyWith(
    displayLarge: head(t.displayLarge),
    displayMedium: head(t.displayMedium),
    displaySmall: head(t.displaySmall),
    headlineLarge: head(t.headlineLarge),
    headlineMedium: head(t.headlineMedium),
    headlineSmall: head(t.headlineSmall),
    titleLarge: head(t.titleLarge),
    titleMedium: body(t.titleMedium),
    titleSmall: body(t.titleSmall),
    bodyLarge: body(t.bodyLarge),
    bodyMedium: body(t.bodyMedium),
    bodySmall: body(t.bodySmall),
    labelLarge: body(t.labelLarge),
    labelMedium: body(t.labelMedium),
    labelSmall: body(t.labelSmall),
  );
}
