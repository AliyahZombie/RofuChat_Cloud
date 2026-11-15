# RofuChat Flutter frontend: Material Design 3 audit (Hark reviewer)

- Scope: every `.dart` file under `app/lib` (30 files, 7,889 lines). The repo was read only; nothing was modified and git was not run.
- References: `docs/ref/md3/*` (m3.material.io, fetched 2026-11-15). Citations are written `md3/<file> §Section (Lnn)`, and the line numbers refer to that file. M3 defaults were checked against the Flutter 3.50 sources in `/workspace/tools/flutter/packages/flutter/lib/src/material` (cited as `flutter/<file>:line`).
- Contrast figures were computed with the WCAG formula against the M3 baseline tones in the spec token tables. Exact values for the user's seed colours will differ slightly.

## Executive summary

1. **Conflicts with your standing preferences.** Three animations still run linearly: `main.dart:44`, `chat_page.dart:1122` and `motion.dart:135`. Separately, message actions (`chat_page.dart:887`) bypass `showActions`, so a long press on a user bubble opens a popup menu instead of the bottom sheet.
2. **Touch targets (biggest a11y issue).** `Appearance.compact` defaults to `true` and sets the global `VisualDensity.compact`, which caps every M3 button's tap target at 40dp. The chat's mini icon buttons, the context ring, the status icon and the image-remove button go down to 18–32dp. M3 requires 48dp.
3. **Contrast.** The `outline` role is used as a text colour in about 10 places. That gives 4.33:1 in light mode for 11sp text, under 4.5:1. `Colors.orange` on the context ring measures 1.87:1, the white check on the Amber swatch 1.94:1, and the model-initial letters fall as low as 1.32:1.
4. **Semantics.** The app has no `Semantics` widget anywhere. 13 icon buttons and FABs have no tooltip. `MaterialApp` has no `flutter_localizations`, so Material's built-in tooltips and semantics are English-only for zh users.
5. **Theme.** `buildTheme` overrides only 4 component themes. The app bar never shows the M3 scrolled-under tonal change, the divider is 40% `outlineVariant`, and there are no menu, list, snackbar, search, progress or page-transition themes. Radii, durations and spacings are hand-typed literals with no token layer.
6. **Components.**
   - Hand-made search fields are 38–40dp tall (M3 search bar: 56dp).
   - Context menus put a `ListTile` inside a `PopupMenuItem`.
   - The small FAB is no longer recommended.
   - One dialog has 3 actions (M3 allows at most 2).
   - The ink on StepsCard and SummaryCard is invisible: their `InkWell` paints under the `Container` colour.
7. **What is already sound.** The seed-based `ColorScheme`, `useMaterial3`, `primaryContainer`/`onPrimaryContainer` user bubbles, `SegmentedButton`, `Switch`/`CheckboxListTile`, tonal icon buttons, the Drawer surface inside SlideDrawer, and mostly on-scale spacing (`md.sys.measurement`).
8. **Severity counts.** 58 findings: 10 high, 23 medium, 25 low. A shared token and theme foundation (§3) fixes about 60% of them mechanically.

---

## 1. Findings

Severity: **high** means it breaks a standing user preference, an accessibility minimum or visible functionality. **med** means a clear M3 deviation that users can see. **low** means polish or consistency.

| ID | Sev | Cat | file:line | Current state | M3 requirement (citation) | Flutter fix |
|---|---|---|---|---|---|---|
| H-001 | high | 5 Motion · **pref conflict** | main.dart:44 | `AnimatedSwitcher(duration: 200ms)` with no curves. Flutter defaults `switchInCurve`/`switchOutCurve` to `Curves.linear` (flutter/../widgets/animated_switcher.dart:121-122). The connect→login→chat swap is linear, which violates "animations are non-linear". | Use the emphasized/standard easing sets, not linear, for UI transitions (md3/styles__motion-easing-and-duration__tokens-specs §Tokens L27-36; §Easing L93-140). | `switchInCurve: Easing.emphasizedDecelerate, switchOutCurve: Easing.emphasizedAccelerate, duration: Durations.medium2` |
| H-002 | high | 5 Motion · **pref conflict** | chat_page.dart:1122-1123 | The `AnimatedSize` for the "Thinking…/Calling tool…" status has no `curve`, so it defaults to `Curves.linear` (flutter/../widgets/animated_size.dart:33). | Same as H-001. | `curve: Easing.standard, duration: Durations.short4` |
| H-003 | high | 5 Motion · **pref conflict** | widgets/motion.dart:135 | `Collapsible` fade `reverseCurve: Interval(0, 0.6)`. `Interval` defaults to `curve: Curves.linear` (flutter/../animation/curves.dart:160), so every collapse fades out linearly (steps, summaries, sidebar character picker). | Same as H-001. Exits use the accelerate variants (tokens-specs §Emphasized easing set L95-118). | `reverseCurve: const Interval(0, 0.6, curve: Easing.standardAccelerate)` |
| H-004 | high | 6 Components · **pref conflict** | chat_page.dart:887-976; message_rows.dart:192 | The message menu builds its own `showMenu` and never calls `showActions`. A long press on a user bubble (`onLongPressStart → onMore(globalPosition)`) opens a popup menu at the finger instead of the bottom sheet, and the per-item `MenuAction` list is duplicated. | Your rule is right-click → menu at the cursor and long press → bottom sheet. M3 agrees: compact = bottom sheet, medium+ = menu (md3/foundations__layout-breakpoints__overview §Designing across breakpoints L74-80); a secondary click opens a context menu (md3/components__menus__guidelines §Context menus L63-69). | Build a `List<MenuAction>` and call `showActions(context, actions, at: isSecondaryClick ? pos : null)`. Long press passes `at: null`. The "More" button can keep a menu anchored to the button (pass its centre). Give `onMore` a `bool secondary` flag. |
| H-005 | med | 6 Components · pref gap | chat_page.dart:769, 843-856 | Assistant text blocks sit in a `SelectionArea`. A right-click there opens the text-selection toolbar, not the message actions, and a long press starts selection. Message actions can only be reached through the footer "more" button. | Context menus on secondary click (menus guidelines §Context menus L63-69). | Pass `SelectionArea(contextMenuBuilder: ...)` that appends "Copy message / Edit / Branch / Delete" buttons to `AdaptiveTextSelectionToolbar.buttonItems(...)`. This keeps selection and adds the message actions. |
| H-006 | high | 7 Layout / 9 A11y | core/theme.dart:30, 126 | `compact` defaults to `true`, which sets `ThemeData.visualDensity = VisualDensity.compact` on every platform. `ButtonStyleButton` computes the padded tap target as `48 + density(-8) = 40dp` (flutter/button_style_button.dart:580-584). Every M3 button, icon button and chip on phones gets a 40dp target, and dense `ListTile`s shrink to about 40dp. | Interactive target ≥ 48×48dp (md3/components__icon-buttons__specs L586; md3/foundations__interaction-states__state-layers L27). | Keep the user's "Compact" toggle, but on touch platforms apply it to the spacing tokens only and keep `VisualDensity.standard` + `MaterialTapTargetSize.padded`. Allow `VisualDensity.compact` only on pointer/desktop (see §3 `densityFor`). Needs your sign-off because it changes how the toggle behaves. |
| H-007 | high | 9 A11y | message_rows.dart:265-273 (`_MiniIcon`/`MiniIconButton`), 534-543 (`SwipeNav`) | `constraints: min 32×32` (arrows 28×32), `padding: zero` and compact density. These are the most-used controls in the app (copy, edit, regenerate, more, version arrows). | 48dp target (icon-buttons specs L586). The visual container can stay small (extra-small icon button). | `IconButton(style: IconButton.styleFrom(minimumSize: Size(32,32), padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.padded, visualDensity: VisualDensity.standard))`. This keeps the 32dp look with a 48dp hit area. On desktop (pointer) a 32dp target is acceptable if you want to keep it. |
| H-008 | high | 9 A11y | widgets/common.dart:154-158 (`ContextRing`); message_rows.dart:503-510 (`ActualStatusIcon`) | `InkResponse` hit area of `size+8` = 30dp; the status icon is about 24×16 and has no tooltip or label. | 48dp target; icon buttons show a tooltip naming the action (md3/components__icon-buttons__guidelines L166-170). | Wrap both in `IconButton` (or `SizedBox.square(48)` + `InkResponse(radius: 24)`), add `tooltip:` to `ActualStatusIcon` ("Compression failed — tap to fix"), and add `Semantics(button: true, value: '65%')` to the ring. |
| H-009 | high | 9 A11y | chat_page.dart:1617-1627 | The remove-attachment control is `InkWell` → `CircleAvatar(radius: 9)`: an 18dp target with no tooltip or semantics. | 48dp target; label (icon-buttons guidelines L166). | `IconButton.filledTonal(iconSize: 14, style: …minimumSize 24, tapTargetSize padded, tooltip: t('移除图片','Remove image'))` positioned at the thumb corner. |
| H-010 | high | 1 Color / 9 Contrast | sidebar.dart:126; chat_page.dart:743, 1211, 1247; message_rows.dart:233, 385, 396, 399; common.dart:209; character_editor.dart:413 | Text in `scheme.outline`, mostly on `labelSmall` (11sp). Baseline light outline #79747E on surface #FEF7FF is **4.33:1**, under 4.5:1. | Outline is for boundaries; text on surfaces uses `onSurface`/`onSurfaceVariant` (md3/styles__color__roles §Surface L149-150, §Outline L226-228; accessible pairings L16, L36-38). | Replace with `scheme.onSurfaceVariant` (#49454F, about 9:1). Keep `outline` only for strokes and the pending spinner. |
| H-011 | high | 9 A11y | (whole lib) e.g. character_editor.dart:203-207; sidebar.dart:441-470; settings_page.dart:150-157; message_rows.dart:251-254; chat_page.dart:1758-1782 | `rg Semantics` returns 0 hits. Custom tappables (avatar picker, character chips, seed swatches, image thumbnails, watch mic/stop button) have no label, role or selected state. Screen readers announce nothing or "button". | Interactive elements must be operable and labelled for assistive tech (md3/foundations__overview__assistive-technology L11-15); icon-only controls need a text alternative (icon-buttons guidelines L166). | Add `Semantics(button: true, selected: selected, label: …)` or `Tooltip`. Better, use real components: seed swatches → `ChoiceChip`/`IconButton(isSelected:)`; watch mic → `IconButton.filled(tooltip:)`. |
| H-012 | med | 9 A11y | admin_page.dart:75; character_editor.dart:300; chat_page.dart:585, 1822, 1826; connect_page.dart:69, 104; memory_page.dart:113; providers_page.dart:209, 238, 286; tools_page.dart:25, 143 | Icon buttons and FABs with no `tooltip` (no semantics label, no hover hint). | Icon buttons display a tooltip describing the action (icon-buttons guidelines L166-170); FABs on hover show a tooltip (md3/components__floating-action-button__guidelines L112). | Add `tooltip:` to each. Use `BackButton()` for connect_page.dart:104. |
| H-013 | med | 9 A11y / i18n | main.dart:31-45 | No `localizationsDelegates`/`supportedLocales` and no `flutter_localizations` in pubspec. `locale: Locale('zh')` falls back to en_US, so Material's own strings (PopupMenuButton "Show menu", BackButton "Back", bottom-sheet drag handle, license page, text-selection toolbar) are English only. | Assistive-tech labels must be meaningful to the user (assistive-technology L11). | Add `flutter_localizations`, `localizationsDelegates: GlobalMaterialLocalizations.delegates`, `supportedLocales: [Locale('zh'), Locale('en')]`. |
| H-014 | med | 9 Text scaling | sidebar.dart:56, 165, 240; chat_page.dart:317, 342; main.dart:41-42 | Fixed heights around text: the character strip (84/64 with a label), search fields at 38/40dp, and a 60dp app bar with a two-line title. These clip at 1.3×+ text scale. The watch multiplies the system scale by 0.85. | Text fields 56dp, app bar 64dp (md3/components__app-bars__specs L105; md3/components__search__specs L137). Components must reflow with user text size (assistive-technology). | Remove the fixed `SizedBox(height:)` around text and use `constraints: BoxConstraints(minHeight: …)`. App bar → default 64. **Watch:** keep the smaller base (your watch layout) but apply it as `mq.textScaler.clamp(minScaleFactor: 0.85)` on top of the user's scale rather than a blind multiply. |
| H-015 | med | 1 Color | widgets/common.dart:151; settings_page.dart:156; widgets/slide_drawer.dart:85 | `Colors.orange` for the 60–85% ring (1.87:1 on light `surfaceContainer`), `Colors.white` check on seed swatches (1.94:1 on Amber, 2.9:1 on Sakura), and `Colors.black@0.4` scrim. | Use roles only, in their pairs (color roles §Pairing L34-44). Graphics need ≥3:1 (L16). The scrim is the `scrim` role (color roles L20). | Ring warning → `scheme.tertiary`, or a `StatusColors` ThemeExtension generated with `ColorScheme.fromSeed(seedColor: Colors.orange, brightness: b).primary`. Check mark → `ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : Colors.black`. Scrim → `scheme.scrim.withValues(alpha: 0.32 * v)`. Keep the drawer behaviour exactly as it is. |
| H-016 | med | 1 Color / 9 Contrast | widgets/common.dart:96-98, 114-120 | Fallback initials use `HSLColor(hue, .55, .55)` letters on `surfaceContainerHighest`: **1.32:1** (light, yellow hues) up to 4.99:1. Character avatars in dark mode fall to 3.15:1 for an ~11sp letter. | Accessible role pairs (color roles L16, L36-44). | Derive per-hue pairs: `final s = ColorScheme.fromSeed(seedColor: HSLColor.fromAHSL(1,hue,.5,.5).toColor(), brightness: b); bg = s.primaryContainer; fg = s.onPrimaryContainer;` (cache by hue). |
| H-017 | med | 4 Elevation / 1 Color | core/theme.dart:127-131 | `AppBarTheme(backgroundColor: surface, surfaceTintColor: transparent, scrolledUnderElevation: 0)`. A plain `backgroundColor` in the theme also wins in the scrolled-under state (flutter/app_bar.dart:934-943), so the app bar never changes tone when content scrolls under it. | App bar (scrolled) = elevation level 2 (md3/styles__elevation__tokens §Component elevation). Tonal difference shows the app bar is separate from scrolling content (md3/styles__elevation__applying-elevation §Tonal difference L33). | Delete the three overrides; Flutter's M3 defaults already use surface → `surfaceContainer` on scroll with transparent shadow/tint (flutter/app_bar.dart:2520-2545). |
| H-018 | low | 1 Color | core/theme.dart:132-135; chat_page.dart:1550; common.dart:166 | Divider `outlineVariant @40%`, composer border @60%, ring track @50%. | `md.comp.divider.color` = outline-variant at full opacity (md3/components__divider__specs L24). | `DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1)`. Remove the alpha values. |
| H-019 | med | 1 Color / 4 | core/theme.dart:109-118 | "Black" mode replaces 6 surface roles with hand-picked hexes. `surfaceContainerLow #0B0B0D` vs black is about 1.07:1, so the desktop sidebar and drawer sheet read as the same plane as the chat. `surfaceDim/Bright`, `inverseSurface` and `outlineVariant` are untouched. | Surface container roles exist to create hierarchy (color roles §Surface L155-166). Separation needs a visible tonal difference (applying-elevation L33-46). | Keep the Black option and derive the steps instead: `surfaceContainerLow: Color.lerp(Colors.black, scheme.surfaceContainerLow, .5)` etc., or keep pure black body + `surfaceContainer` for nav. Add `DrawerThemeData(shape: …side: BorderSide(color: outlineVariant))` in black mode only. |
| H-020 | med | 1 Color / 6 | sidebar.dart:132-136 | Selected chat uses `secondaryContainer @60%` + `ListTile` default `selectedColor` = primary text, 12dp corners, dense + compact (~40dp). | Active indicator: `secondary-container`, `corner.full`, label `on-secondary-container` (md3/components__navigation-drawer__specs L35-37, L101). Item height 56 (flutter `_NavigationDrawerDefaultsM3` tileHeight 56). | `ListTileThemeData(selectedTileColor: scheme.secondaryContainer, selectedColor: scheme.onSecondaryContainer, shape: StadiumBorder())`, `minTileHeight: 48` (touch) / 40 (desktop pointer). |
| H-021 | med | 1 Color / 6 | message_rows.dart:452-461 | SummaryCard: `tertiaryContainer @35%` fill, `tertiary @40%` border; body text inherits `onSurface`. The alpha-blended roles have no defined "on" pair. | Pair and layer roles as intended (color roles §Pairing L34-44); tertiary marks contrasting accents (L105). | `Card.filled(color: scheme.tertiaryContainer)` + text/icons `onTertiaryContainer`, or `Card.outlined` (outlineVariant) + `tertiary` icon only. |
| H-022 | med | 1 Color / 6 | chat_page.dart:1176-1204 vs chat_page.dart:1030-1041, character_editor.dart:397-401, tools_page.dart:198-204 | Three error-surface styles: outlined `error` border + `fontSize: 12.5`; filled `errorContainer` r8. | Error roles: `errorContainer`/`onErrorContainer` for containers (color roles §Error L125-140). | One `ErrorBanner` widget: `Material(color: errorContainer, shape: Corners.medium)`, `bodyMedium` in `onErrorContainer`, optional trailing `TextButton`. |
| H-023 | med | 2 Type | chat_page.dart:685-688 | Chat body `bodyLarge.copyWith(fontSize: (watch ? 13 : 15.5) * fontScale, height: 1.55)`. 15.5 and 13 are off-scale. | Body large 16/24, body medium 14/20 (md3/styles__typography__type-scale-tokens §Baseline type style tokens). | `final role = watch ? text.bodyMedium! : text.bodyLarge!; base = role.copyWith(fontSize: role.fontSize! * fontScale, height: role.height)`. Keeps your font-size slider. |
| H-024 | low | 2 Type | chat_page.dart:180, 1192, 1812; message_rows.dart:434; tools_page.dart:137 | Ad-hoc `TextStyle(fontSize: 11 / 12.5 / 13 / 12 / 13)`, including two monospace styles. | Use type-scale roles (type-scale-tokens §Type scale; md3/styles__typography__applying-type §Roles). | 11 → `labelSmall`; 12.5 → `bodySmall`; 13 → `bodyMedium`; monospace → `text.bodySmall!.copyWith(fontFamily: 'monospace', fontFamilyFallback: ['Menlo','Consolas','Noto Sans Mono CJK SC'])` held in a `MonoText` token. |
| H-025 | low | 2 Type / 6 | chat_page.dart:341-378 | Chat app bar title `titleMedium`, subtitle `labelSmall`, `toolbarHeight: 60`. | Small app bar: height 64, title `title-large`, subtitle `label-medium` (app-bars specs L105-107). | `toolbarHeight` default (64); title `titleLarge` (or keep `titleMedium` deliberately for long chat titles), subtitle `labelMedium` + `onSurfaceVariant`. |
| H-026 | med | 3 Shape | chat_page.dart:1548 (24); message_rows.dart:327 (18), 253 (10), 232 (6) | Radii that are not on the scale. | Scale: 0/4/8/12/16/20/28/32/48/full (md3/styles__shape__corner-radius-scale §Shape tokens L27-50). | Composer 24 → `Corners.xl` 28 (or `StadiumBorder` while single-line). StepsCard 18 → 16 (`large`). Thumb 10 → 12 (`medium`). Tag 6 → 8 (`small`). (User bubble 20 = `large-increased`: already compliant.) |
| H-027 | low | 3 Shape | 19 `BorderRadius.circular(n)` literals (see `rg "circular("`) | Corner values are typed per widget, so a scale change means editing 19 sites. | Customise a shape style once and every component mapped to it follows (corner-radius-scale §Customizing shapes L93-110). | `Corners` token class (§3). Feed it into `cardTheme`, `dialogTheme`, `listTileTheme`, `chipTheme` etc. |
| H-028 | low | 3 Shape / 6 | widgets/common.dart:300-314; chat_page.dart:972-976 | `showMenu` uses Flutter's baseline 4dp menu corner (flutter/popup_menu.dart:1867). | Current menus spec: container `corner.large` 16dp; 4dp is the deprecated baseline (md3/components__menus__specs L124 vs L611). | Optional: `popupMenuTheme`/`menuTheme` shape `Corners.large`. Decide together with the other reviewer, because Flutter's M3 defaults still ship the baseline. |
| H-029 | low | 4 Elevation / 1 | chat_page.dart:213-247; sidebar.dart:201-203 | The desktop standard sidebar is `surfaceContainerLow` + `VerticalDivider`. | Standard drawer container = `surface` (nav-drawer specs L46). Navigation areas commonly use `surfaceContainer` (color roles L170-176). Either is defensible, but the divider is redundant with tonal separation. | Choose `surfaceContainer` (consistent with the color-roles guidance across breakpoints) and drop the `VerticalDivider`, or keep the divider and use `surface`. |
| H-030 | med | 5 Motion | chat_page.dart:220 (360), 518 (320); motion.dart:18 (320), 45 (160), 126 (260), 172 (220); slide_drawer.dart:29-30 (380/300); message_rows.dart:474 (260); settings_page.dart:286 (260) | Durations that are not tokens; `Curves.easeOutCubic` used everywhere as a stand-in for M3 easing. All are non-linear (OK with your preference). | Duration tokens 50…1000 in 50/100ms steps; emphasized/standard easing sets (tokens-specs L42-57, L93-140). | Map: 360 → `Durations.medium3` 350; 320 → `medium2` 300; 380 → `medium4` 400; 260 → `medium1` 250; 220 → `short4` 200; 160 → `short3` 150. `easeOutCubic` → `Easing.emphasizedDecelerate` (enter) / `Easing.standard` (in-place). **SlideDrawer:** only swap the constants; keep the follow-finger drag and fling-scaled settle. |
| H-031 | low | 5 Motion | (theme) core/theme.dart:119-140 | No `pageTransitionsTheme`. Defaults: Android `PredictiveBackPageTransitionsBuilder` (good), Windows/Linux `ZoomPageTransitionsBuilder`, Apple Cupertino (flutter/page_transitions_theme.dart:762-769). | Forward/backward and top-level transition patterns (md3/styles__motion-transitions__transition-patterns §Forward and backward, §Top level). | `PageTransitionsTheme(builders: {android: PredictiveBackPageTransitionsBuilder(), windows/linux: FadeForwardsPageTransitionsBuilder(), iOS/macOS: Cupertino…})`. BackGuard is unaffected (it guards the root route only). |
| H-032 | med | 6 Components | widgets/common.dart:303-312; chat_page.dart:895-970 | Context-menu items are a `ListTile(dense)` inside a `PopupMenuItem`. That doubles horizontal padding, gives an uneven row height and 24dp icons, and the label uses body style. | Menu item 48dp, leading icon 20dp (current) / 24dp (baseline), label `label-large` (menus specs L142, L596, L632, L638). | Use `MenuAnchor` + `MenuItemButton(leadingIcon: Icon(a.icon), child: Text(a.label))` and open it with `controller.open(position: localOffset)`. This keeps "menu at the cursor" exactly. Alternatively `PopupMenuItem(height: 48, child: Row([Icon(size: 20), Gap(12), Text]))`. Danger items: `MenuItemButton(style: MenuItemButton.styleFrom(foregroundColor: scheme.error, iconColor: scheme.error))`. |
| H-033 | med | 6 Components | chat_page.dart:582-590 | Scroll-to-bottom uses `FloatingActionButton.small`, with no tooltip and the `heroTag` string 'bottom'. | "The small FAB is no longer recommended" (fab guidelines L29; fab specs L17-28). A FAB is the screen's primary action, not a scroll helper (fab guidelines §Usage). | `IconButton.filledTonal(tooltip: t('回到底部','Jump to latest'), icon: Icon(Icons.keyboard_double_arrow_down_rounded))` in a `Material(elevation: 3 (level2), shape: CircleBorder())`. Animate in/out with `AnimatedScale` + `Easing.emphasizedDecelerate`. |
| H-034 | med | 6 Components | chat_page.dart:1052-1071 | The compressed-content dialog has 3 actions: Regenerate, Cancel, Save. | Dialogs contain a maximum of two actions: confirm + dismiss (md3/components__dialogs__guidelines L125-128, L136-141). | Move "Regenerate" into the content (a `TextButton.icon` above the field, or an `IconButton` in the title row). Actions: Cancel (`TextButton`) + Save. |
| H-035 | low | 6 Components | widgets/common.dart:244-257 (+ callers sidebar.dart:391, 408; chat_page.dart:474, 1003; memory_page.dart:182; admin_page.dart:537; providers_page.dart:212; tools_page.dart:146) | Destructive confirms use the generic "OK" `FilledButton` in primary colour. | Avoid unclear choices; the confirming action states the action (dialogs guidelines L117-128). | Callers pass `ok: t('删除','Delete')`. Add `destructive: true` → `FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)`. |
| H-036 | low | 6 Components | chat_page.dart:988-993 | Token-usage `AlertDialog` with content only and no actions (watch). | A single action must be an acknowledgement; dialogs require an action to close (dialogs guidelines L117-120, §Basic dialog L143-147). | Add `actions: [TextButton(onPressed: pop, child: Text(t('关闭','Close')))]`. |
| H-037 | med | 6 Components / 7 | sidebar.dart:164-170, 239-245; model_picker.dart:48-51; providers_page.dart:321; memory_page.dart:120-126 | Search is a plain `TextField` with a global `OutlineInputBorder` + `isDense`, squeezed to 38/40dp in the sidebar. | Search bar: 56dp container, full corner, surface-container-high (md3/components__search__specs L137; md3/components__search__guidelines §Usage). | `SearchBar(leading: const Icon(Icons.search_rounded), hintText: …, onChanged: …, elevation: WidgetStatePropertyAll(0))` with `searchBarTheme`. On desktop pointer use `constraints: BoxConstraints(minHeight: 48)`. |
| H-038 | low | 6 Components | settings_page.dart:173-184; memory_page.dart:129-140 | `DropdownButton` (M2 pattern). | Select menus / text-field dropdown menus (menus guidelines L42-43, L284; text-fields guidelines L262). | `DropdownMenu<String>(initialSelection:, dropdownMenuEntries: …)`. For settings, a `ListTile` + `MenuAnchor` trailing is also fine. |
| H-039 | low | 6 Components | chat_page.dart:172-192 | The watch title is an `ActionChip` with `TextStyle(fontSize: 11)` and zero padding, used as a navigation trigger. | Chips aren't buttons; they are for selections and contextual actions (md3/components__chips__guidelines §Chips aren't buttons L19-25). | Keep the watch layout. Use `FilledButton.tonalIcon` (or `TextButton.icon`) with `labelSmall`, `minimumSize: Size(48, 32)` + padded target. |
| H-040 | med | 8 States | chat_page.dart:1273-1280, 1670-1677; character_editor.dart:413; tools_page.dart:42 | Regenerate stays visually enabled while generating (`onPressed: () {}`); Add image looks greyed (`outline` colour) but is enabled and shows an error snackbar; disabled tools are tinted `outline`. | Disabled = content `on-surface` @38% (`md.sys.state.disabled` 0.38, state-layers token table); disabled controls are not interactive (md3/foundations__interaction-states__overview). | Regenerate: `onPressed: ctl.generating ? null : …`. Add image: `onPressed: vision ? … : null` + `tooltip: t('当前模型不支持图片','Model has no vision')`. Disabled labels: `scheme.onSurface.withValues(alpha: .38)`. |
| H-041 | med | 8 States | message_rows.dart:325-346, 367-389 (StepsCard); 452-461 (SummaryCard) | `InkWell` sits inside a `Container(decoration: color…)` with no `Material` in between. Ink paints on the ancestor Material, under the container's fill, so hover/pressed/focus state layers are invisible. Also unclipped to the 18/16dp radius. | State layers sit between container and content (8/10/10/16%) (state-layers L33-40, L47-66). | `Material(color: scheme.surfaceContainerHigh, shape: Corners.shapeLarge, clipBehavior: Clip.antiAlias, child: InkWell(…))`, or `Card.filled(clipBehavior: antiAlias)` + `InkWell`, or `Ink(decoration:)`. |
| H-042 | low | 8 States | chat_page.dart:846-847, 1171-1172; message_rows.dart:168-169 | Out-of-context messages use `Opacity(0.5/0.6)` on the whole subtree, which fades their buttons too and costs a saveLayer per row. | Lower emphasis via roles (`onSurfaceVariant`), not alpha on interactive content (color roles §Surface L149-150; disabled 0.38 is only for disabled). | Keep the "Not in context" tag. Render text with `onSurfaceVariant` and keep the action buttons at full emphasis. Drop `Opacity`. |
| H-043 | low | 6 Components | message_rows.dart:225-235 vs chat_page.dart:1241-1249 | "Not in context" is drawn two ways (bordered r6 tag vs plain `outline` text). | Similarity: same elements, same styling (md3/foundations__layout-grids-spacing__spacing §Similarity). | One `ContextTag` widget: `outlineVariant` border, `Corners.small`, `labelSmall` in `onSurfaceVariant`. |
| H-044 | low | 6 Components | chat_page.dart:386-419 | The chat app bar has an overflow `PopupMenuButton` with 6 items (rename, compress, scan memory, memory, character settings, delete). | "Avoid placing an overflow menu in the app bar when possible"; app bars carry 1–2 essential actions (md3/components__app-bars__guidelines L13-25). | Acceptable for now. Longer term, move chat-scoped actions into a side sheet / bottom sheet "Chat details" (desktop: standard side sheet). Keep "New chat" as the one action. |
| H-045 | low | 6 Components | connect_page.dart:104 | `IconButton(Icons.arrow_back)` without a tooltip. | Navigation icon with label (app-bars guidelines L9). | `leading: BackButton(onPressed: () => …showConnect())` (adaptive icon, localized tooltip). |
| H-046 | low | 6 Components | sidebar.dart:94-95, 138; chat_page.dart:663, 752-755; message_rows.dart:373, 499; (all `CircularProgressIndicator`/`LinearProgressIndicator`) | `year2023` defaults to `true` (flutter/progress_indicator.dart:595), giving the 2023 look with no track gap and no stop indicator. | Current progress indicators have an active indicator, a track gap and a stop indicator (md3/components__progress-indicators__guidelines §Anatomy, §Stop indicator). | `progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false)`. Check the 10–12dp mini spinners still read well. Keep `LoadingBlob` (your expressive loading indicator; its linear spin is the expected loop). |
| H-047 | low | 6 Components | widgets/back_guard.dart:59-64 vs common.dart:278-284, message_rows.dart:518 | BackGuard's snackbar is `floating`, all others `fixed`. "Copied" lasts 1s. Errors show raw `'$e'`. | Snackbars without actions auto-dismiss after 4–10s (md3/components__snackbar__guidelines L209); keep them clear of FABs (L155-157). | `snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating)`. Remove the 1s duration (Flutter default is 4s). Map exceptions to a friendly message + "Details" action. BackGuard keeps its own 2s window (your Back behaviour; flag only). |
| H-048 | low | 6 Components | character_editor.dart:477-481 | A `Switch` as the `leading` of an `ExpansionTile` header nests two interactive targets in one row. | List items have one primary action; controls go in the trailing slot (md3/components__lists__guidelines §Anatomy). | Title row: name + subtitle; trailing: `Switch`; expansion chevron via `ExpansionTile(controlAffinity: ListTileControlAffinity.leading)`, or move "Enabled" into the expanded body as a `SwitchListTile`. |
| H-049 | med | 7 Layout | core/form_factor.dart:7-10 | Three form factors: watch (<300 shortest side), desktop (≥1000 width), and phone for everything else. There are no M3 window size classes, so 600–999dp (tablets, half-screen desktop windows) gets the phone layout with full-width chat and no reading-width cap. | Compact <600, medium 600–839, expanded 840–1199, large 1200–1599, XL 1600+ (md3/foundations__layout-breakpoints__overview L48-54). Medium/expanded can use a modal drawer (nav-drawer guidelines L211-221). | **Preserve** the watch rule (<300) and the RikkaHub sidebar on non-desktop. Add a `WindowSizeClass` helper (§3) for sizing decisions only: a reading width ~840 on medium+ and the composer max width. Whether "desktop" should start at 840 instead of 1000 is your call, because it would move 840–999dp devices off the RikkaHub layout. |
| H-050 | med | 7 Layout | message_rows.dart:167, 195 | User-bubble max width = `MediaQuery.sizeOf(context).width * 0.85`, the **window** width. On desktop with the 300dp sidebar or the 900dp reading cap, the bubble can be wider than its pane. | Panes resize independently (breakpoints §What should be resized L138-155). | Use `LayoutBuilder` → `constraints.maxWidth * maxWidthFactor` (or `FractionallySizedBox`/`ConstrainedBox` from the list's constraints). |
| H-051 | low | 7 Layout | chat_page.dart:259 | Modal drawer width `min(320, 85%)`. | Drawer container width 360dp (nav-drawer specs L53, L198). | Optional: `min(360, width - 56)`. SlideDrawer, its open zone and BackGuard stay as they are. |
| H-052 | low | 7 Layout | chat_page.dart:849, 1442; message_rows.dart:231, 393; providers_page.dart:292; sidebar.dart:224 | Spacing is mostly on the `md.sys.measurement` scale (2/4/6/8/10/12/14/16/24/32/40/48/64/72). The exceptions are 1, 3, 5, 20, 44 and 60. | Rhythm/similarity via consistent spacing (spacing §Rhythm, §Similarity). Scale values from `md.sys.measurement.space*` (e.g. md3/components__lists__specs, icon-buttons specs). | 1 → 0 or 2; 3/5 → 4/6; 20 → 16 or 24; 44 → 48 (aligns the step body with the 18dp icon + 12 gap + 14 inset); 60 → 64 (FAB clearance: use `kFloatingActionButtonMargin + 56`). |
| H-053 | med | 7 Layout / 6 | sidebar.dart:131-133, 248-250, 272-274, 286-288, 302-305, 425; model_picker.dart:67-74; providers_page.dart:336-343 | `ListTile(dense: true)` + compact density → ~40dp rows on touch devices. | One-line list item 56dp, two-line 72dp (lists specs L221-223); targets ≥48dp. | `ListTileThemeData(minTileHeight: 48)` on touch and drop the per-tile `dense/visualDensity`. Keep dense on desktop pointer through `densityFor` (§3). |
| H-054 | low | 10 Icons | e.g. chat_page.dart:1260-1286; sidebar.dart:187-189, 320-324; message_rows.dart:206-209 | 83 distinct icons: 22 `_rounded`, 29 `_outlined`, ~32 default filled. Footers mix `copy_rounded` + `edit_outlined` + `more_vert`. | "Use and maintain a consistent visual style… Avoid mixing styles" (md3/styles__icons__designing-icons L25-29). | Choose one family (Rounded fits the RikkaHub look). Add `abstract final class AppIcons { static const copy = Icons.copy_rounded; … }`. Use the filled glyph only for selected/active states (pin, lightbulb). |
| H-055 | low | 10 Icons | `rg "size: 1[4-8]|size: 2[26]"` (Icon sizes 12/14/16/18/22/26) | Icon glyph sizes are ad hoc. | Supported sizes 20/24/40/48dp; 20 for dense/desktop (designing-icons L45-51). | 18 → 20 (dense) or 24; 14/16 → 20 in buttons. Reserve <20 only inside badges/chips. Set `IconThemeData(size: 24)` and an `IconButton` style per density. |
| H-056 | low | 10 Icons | chat_page.dart:345 vs 176; character_editor.dart:108; sidebar.dart:195, 322 | Drawer toggle is `notes_rounded` (phone/desktop) but `menu` (watch). Export uses iOS `ios_share` on every platform. "Connection" uses `swap_horiz`. | App bar navigation is the Menu icon (app-bars guidelines L9). Consistent, meaningful glyphs (designing-icons §Design principles). | `Icons.menu_rounded` everywhere; `Icons.adaptive.share` or `Icons.file_download_rounded` for export; `Icons.dns_rounded`/`cloud_rounded` for connection. |
| H-057 | low | 9 A11y | widgets/common.dart:203-230 | TokenIndicator text "↑1.2k ↓350 ⚡800 · 5.3s": screen readers read arrows/emoji. Its tooltip is long-press only. | Meaningful alternatives for assistive tech (assistive-technology L11). | `Semantics(label: t('输入 1.2k，输出 350…','Input 1.2k, output 350…'), excludeSemantics: true)`. |
| H-058 | low | 1 Color | sidebar.dart:229; chat_page.dart:1758-1760 | Rikka sidebar `Material(color: Colors.transparent)` (inherits the Drawer surface: fine). The watch mic uses `Material(color: busy ? errorContainer : primary)`; the busy pairing (errorContainer/onErrorContainer) and the idle pairing (primary/onPrimary) are both correct, but they are hand-rolled. | Use component roles (color roles §Pairing). | Replace with `IconButton.filled` / `IconButton.filledTonal(style: …backgroundColor: errorContainer)` so roles, state layers and tooltip come for free (also closes H-011 for this control). |

**Severity totals:** high 10 (H-001 to H-004, H-006 to H-011; H-005 is graded med); med 23; low 25.

---

## 2. Top 10 findings (priority order)

1. **H-004**: Message menus bypass `showActions`, so a long press on a user bubble opens a popup menu instead of the bottom sheet. This conflicts with your standing preference.
2. **H-001 / H-002 / H-003**: Three linear animations remain (root `AnimatedSwitcher`, status `AnimatedSize`, `Collapsible` reverse fade). This conflicts with "non-linear only".
3. **H-006**: Global `VisualDensity.compact`, on by default, caps every M3 control at a 40dp tap target on phones.
4. **H-007**: The chat's mini icon buttons and version arrows are 28–32dp targets. They are the app's most-used controls.
5. **H-010**: The `outline` role is used for text, about 4.33:1 at 11sp (fails 4.5:1).
6. **H-011 + H-012**: There is no `Semantics` anywhere, and 13 icon buttons and FABs have no tooltip.
7. **H-008 / H-009**: The context ring (30dp), the compression-status icon and the attachment remove button (18dp) are tiny and unlabelled.
8. **H-017**: The app bar never shows the scrolled-under tonal elevation, because a theme override defeats Flutter's M3 default.
9. **H-041**: StepsCard and SummaryCard have invisible ripples and state layers (`InkWell` under the `Container` fill).
10. **H-037 + H-032**: Hand-made 38–40dp search fields and `ListTile`-inside-`PopupMenuItem` context menus. The fix is `SearchBar` and `MenuAnchor` positioned at the cursor, which keeps your context-menu behaviour.

---

## 3. Proposed shared theme foundation

Goals:

- **One token layer:** spacing, shape, motion, icon sizes and the window size class.
- **One `buildTheme`** that sets every component theme the app uses, so widgets stop hand-styling.
- **Your preferences are encoded, not fought:**
  - Non-linear easing is the only easing exported.
  - `showActions` remains the single entry for item actions.
  - SlideDrawer and BackGuard are untouched.
  - The RikkaHub sidebar stays on non-desktop.
  - The watch layout keeps its <300 rule.

Suggested files: `app/lib/core/tokens.dart` (new), `app/lib/core/theme.dart` (replace `buildTheme`), `app/lib/core/form_factor.dart` (add `WindowSizeClass`; keep `FormFactor`).

```dart
// app/lib/core/tokens.dart
import 'package:flutter/material.dart';

/// md.sys.measurement.space* (only the steps M3 defines).
abstract final class Space {
  static const double s0 = 0, s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,
      s14 = 14, s16 = 16, s24 = 24, s32 = 32, s40 = 40, s48 = 48, s64 = 64, s72 = 72;
  static const double minTarget = kMinInteractiveDimension; // 48
  /// Gaps that change with the user's "Compact" toggle (spacing only — never tap targets).
  static double gap(bool compact) => compact ? s8 : s12;
  static double pageInset(bool compact) => compact ? s12 : s16;
}

/// md.sys.shape.corner.* — 0/4/8/12/16/20/28/32/48/full.
abstract final class Corners {
  static const double none = 0, xs = 4, sm = 8, md = 12, lg = 16, lgInc = 20, xl = 28, xlInc = 32, xxl = 48;
  static const BorderRadius extraSmall = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius largeIncreased = BorderRadius.all(Radius.circular(lgInc));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(xl));
  static const RoundedRectangleBorder shapeExtraSmall = RoundedRectangleBorder(borderRadius: extraSmall);
  static const RoundedRectangleBorder shapeSmall = RoundedRectangleBorder(borderRadius: small);
  static const RoundedRectangleBorder shapeMedium = RoundedRectangleBorder(borderRadius: medium);
  static const RoundedRectangleBorder shapeLarge = RoundedRectangleBorder(borderRadius: large);
  static const RoundedRectangleBorder shapeExtraLarge = RoundedRectangleBorder(borderRadius: extraLarge);
  static const StadiumBorder full = StadiumBorder();
}

/// md.sys.motion.* — durations from Flutter's generated [Durations], easing from [Easing].
/// Standing preference: animations are non-linear, so no linear curve is exported.
abstract final class MotionDur {
  static const Duration micro = Durations.short3;     // 150  size nudges, chevrons
  static const Duration fast = Durations.short4;      // 200  icon/state swaps, exits
  static const Duration standard = Durations.medium2; // 300  collapsible, scroll-to
  static const Duration enter = Durations.medium3;    // 350  sidebar (desktop) open
  static const Duration emphasized = Durations.medium4; // 400 drawer open
}

abstract final class MotionEase {
  static const Curve emphasized = Curves.easeInOutCubicEmphasized; // md.sys.motion.easing.emphasized
  static const Curve emphasizedIn = Easing.emphasizedDecelerate;   // entering
  static const Curve emphasizedOut = Easing.emphasizedAccelerate;  // exiting
  static const Curve standard = Easing.standard;
  static const Curve standardIn = Easing.standardDecelerate;
  static const Curve standardOut = Easing.standardAccelerate;
}

/// md.sys icon sizes: 20 (dense/desktop), 24 (default), 40/48 (display).
abstract final class IconSizes {
  static const double dense = 20, standard = 24, large = 40, xl = 48;
}

/// Semantic status colours generated from seeds so they stay in the tonal system.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color warning, onWarning, warningContainer, onWarningContainer;
  const StatusColors({required this.warning, required this.onWarning,
      required this.warningContainer, required this.onWarningContainer});
  factory StatusColors.from(Brightness b) {
    final s = ColorScheme.fromSeed(seedColor: const Color(0xFFFFA000), brightness: b);
    return StatusColors(warning: s.primary, onWarning: s.onPrimary,
        warningContainer: s.primaryContainer, onWarningContainer: s.onPrimaryContainer);
  }
  @override
  StatusColors copyWith({Color? warning, Color? onWarning, Color? warningContainer, Color? onWarningContainer}) =>
      StatusColors(warning: warning ?? this.warning, onWarning: onWarning ?? this.onWarning,
          warningContainer: warningContainer ?? this.warningContainer,
          onWarningContainer: onWarningContainer ?? this.onWarningContainer);
  @override
  StatusColors lerp(StatusColors? o, double t) => o == null ? this : StatusColors(
      warning: Color.lerp(warning, o.warning, t)!, onWarning: Color.lerp(onWarning, o.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, o.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, o.onWarningContainer, t)!);
}
```

```dart
// app/lib/core/form_factor.dart (additions; FormFactor and its thresholds stay as they are)
enum WindowSizeClass { compact, medium, expanded, large, extraLarge }

WindowSizeClass windowSizeClassOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 600) return WindowSizeClass.compact;
  if (w < 840) return WindowSizeClass.medium;
  if (w < 1200) return WindowSizeClass.expanded;
  if (w < 1600) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}

/// Reading width for chat content on medium+ windows (layout only; navigation unchanged).
double readingWidth(WindowSizeClass c) => c.index >= WindowSizeClass.medium.index ? 840 : double.infinity;
```

```dart
// app/lib/core/theme.dart — buildTheme replacement (Appearance class unchanged)
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'tokens.dart';

bool get _isPointerPlatform => switch (defaultTargetPlatform) {
  TargetPlatform.windows || TargetPlatform.linux || TargetPlatform.macOS => true,
  _ => false,
};

/// The user's "Compact" toggle tightens density only where a pointer is used; on touch it is
/// applied through Space.gap/pageInset so tap targets stay 48dp (M3 icon-buttons specs L586).
VisualDensity densityFor(bool compact) =>
    compact && _isPointerPlatform ? VisualDensity.compact : VisualDensity.standard;

ColorScheme _scheme(Appearance a, Brightness b) {
  var s = ColorScheme.fromSeed(seedColor: Color(a.seed), brightness: b);
  if (b == Brightness.dark && a.themeMode == 'black') {
    // Keep pure-black body, but derive container steps from the scheme so they stay distinguishable.
    Color step(Color c, double t) => Color.lerp(Colors.black, c, t)!;
    s = s.copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: step(s.surfaceContainerLow, .55),
      surfaceContainer: step(s.surfaceContainer, .65),
      surfaceContainerHigh: step(s.surfaceContainerHigh, .75),
      surfaceContainerHighest: step(s.surfaceContainerHighest, .85),
    );
  }
  return s;
}

ThemeData buildTheme(Appearance a, Brightness b) {
  final scheme = _scheme(a, b);
  final density = densityFor(a.compact);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: b, visualDensity: density);
  final text = base.textTheme;

  return base.copyWith(
    materialTapTargetSize: MaterialTapTargetSize.padded,
    extensions: [StatusColors.from(b)],
    // H-017: no backgroundColor/scrolledUnderElevation overrides — M3 defaults give surface → surfaceContainer.
    appBarTheme: const AppBarThemeData(),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    }),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1), // H-018
    listTileTheme: ListTileThemeData( // H-020, H-053
      iconColor: scheme.onSurfaceVariant,
      selectedColor: scheme.onSecondaryContainer,
      selectedTileColor: scheme.secondaryContainer,
      shape: Corners.full,
      minTileHeight: _isPointerPlatform && a.compact ? 40 : 48,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.s16),
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom( // H-007
      tapTargetSize: MaterialTapTargetSize.padded,
    )),
    menuTheme: MenuThemeData(style: MenuStyle( // H-032 (MenuAnchor context menus)
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
      shape: const WidgetStatePropertyAll(Corners.shapeExtraSmall), // or shapeLarge — see H-028
    )),
    popupMenuTheme: PopupMenuThemeData(color: scheme.surfaceContainer, labelTextStyle: WidgetStatePropertyAll(text.labelLarge)),
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true), // showActions + model picker
    dialogTheme: const DialogThemeData(), // M3 default: corner.extra-large 28, surfaceContainerHigh
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating), // H-047
    searchBarTheme: SearchBarThemeData( // H-037
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      constraints: BoxConstraints(minHeight: _isPointerPlatform && a.compact ? 40 : 56),
      hintStyle: WidgetStatePropertyAll(text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(year2023: false), // H-046
    cardTheme: const CardThemeData(shape: Corners.shapeMedium, clipBehavior: Clip.antiAlias), // H-041
    chipTheme: ChipThemeData(shape: Corners.shapeSmall, labelStyle: text.labelLarge),
    tooltipTheme: const TooltipThemeData(waitDuration: Durations.long2),
    inputDecorationTheme: const InputDecorationThemeData(border: OutlineInputBorder()), // drop isDense on touch
    drawerTheme: const DrawerThemeData(), // SlideDrawer passes its own width — unchanged
  );
}

```

Component helpers that sit on top of the theme. Each closes several findings at once:

- `ErrorBanner({message, action})` (H-022).
- `ContextTag()` (H-043).
- `MonoText` style (H-024).
- `AppIcons` (H-054, H-056).
- `showActions` rewritten to use `MenuAnchor`/`MenuItemButton` for `at != null` and keep the bottom sheet for `at == null` (H-004, H-032). Every item-action entry point (sidebar, message rows, characters) goes through it.

---

## 4. Migration order and risks

**Phase 0: tokens, no visual change (½ day).** Add `tokens.dart`, `WindowSizeClass` and `AppIcons`. Nothing else changes yet.

**Phase 1: preference conflicts and a11y quick wins (1 day).**
- Fix the linear curves (H-001 to H-003).
- Route message menus through `showActions`; add the SelectionArea context builder (H-004, H-005).
- Add tooltips and Semantics (H-011, H-012, H-057).
- Replace `outline` text with `onSurfaceVariant` (H-010).
- Add `flutter_localizations` (H-013).
- Fix the disabled states (H-040).

All are low-risk, local edits.

**Phase 2: theme foundation (1 day).** Switch to the new `buildTheme`:
- App bar defaults (H-017), divider (H-018), list tile and selection (H-020), snackbar (H-047), progress (H-046), page transitions (H-031).
- Black-mode derivation (H-019).
- Remove the per-widget overrides these make redundant.

**Phase 3: component swaps (2–3 days).**
- `SearchBar` (H-037).
- `MenuAnchor` context menus (H-032, H-028).
- `ErrorBanner`/`ContextTag` (H-022, H-043).
- Steps/Summary cards on `Material`/`Card` (H-021, H-041).
- Scroll-to-bottom button (H-033).
- Dialog actions (H-034 to H-036).
- `DropdownMenu` (H-038), MCP tile (H-048), watch chip (H-039), back button (H-045).

**Phase 4: density, touch targets, layout (1–2 days, needs your decisions).**
- `densityFor` scoping of the Compact toggle (H-006, H-053).
- Mini-button targets (H-007 to H-009).
- Fixed heights and text scaling (H-014).
- Bubble width from `LayoutBuilder` (H-050).
- Reading width by window size class (H-049).

**Phase 5: tokens sweep (1 day).** Radii (H-026, H-027), durations (H-030), type roles (H-023 to H-025), spacing (H-052), icon family and sizes (H-054 to H-056), drawer width (H-051).

**Risks and decisions:**
- **Compact toggle semantics (H-006).** Scoping density to pointer platforms changes what "紧凑布局" does on phones, and phones will look slightly looser. Confirm with the user. An alternative is to keep compact visuals and add `tapTargetSize: padded` + `VisualDensity.standard` only on buttons.
- **Context menus (H-004/H-005/H-032).** `MenuAnchor` positions in the anchor's local coordinates (convert `globalPosition`). SelectionArea already claims right-click on assistant text; test on Windows/macOS/Linux/web that right-click on a bubble opens the actions and not the browser or text menu.
- **Window size classes (H-049).** Moving "desktop" from 1000 to 840 would take 840–999dp devices (landscape tablets) off the RikkaHub sidebar. That is a standing-preference boundary and needs an explicit decision. This audit recommends **not** changing `FormFactor` without one.
- **Watch.** H-014's clamp keeps the smaller watch base. Check round-screen insets after removing fixed heights.
- **Black theme (H-019).** Derived container tones will look slightly lighter than today's hand-picked values. Verify OLED users accept it.
- **Progress `year2023: false` (H-046).** It changes the look of every spinner. The 10–12dp inline spinners may need `strokeWidth` tweaks.
- **Page transitions (H-031).** `FadeForwards` changes the desktop feel. Android predictive back works with BackGuard because BackGuard only blocks pop on the root route, but test the "press Back twice to exit" flow on Android 14+.
- **Performance.** Replacing `Opacity` (H-042) helps. Wrapping every StepsCard in `Material` adds a layer per row; profile long chats.
- **Two-reviewer reconciliation.** H-028 (menu corner 16 vs Flutter's 4) and H-029 (sidebar surface role) are judgement calls where the spec and Flutter's shipped defaults differ. Settle them jointly.

---

## 5. Coverage: every `app/lib` file reviewed

UI files were read in full, line by line:
- main.dart
- core/theme.dart
- core/form_factor.dart
- widgets/common.dart
- widgets/motion.dart
- widgets/slide_drawer.dart
- widgets/back_guard.dart
- features/chat/chat_page.dart (1–1848)
- features/chat/message_rows.dart
- features/chat/model_picker.dart
- features/sidebar/sidebar.dart
- features/settings/settings_page.dart
- features/connect/connect_page.dart
- features/admin/admin_page.dart
- features/characters/character_editor.dart
- features/providers/providers_page.dart
- features/memory/memory_page.dart
- features/tools/tools_page.dart

Non-visual files were reviewed for UI, theme, colour, motion and text APIs (grep plus a skim). They have no M3-relevant code beyond what is noted:
- core/api.dart
- core/backend_ffi.dart
- core/backend_ffi_native.dart
- core/backend_ffi_stub.dart
- core/builtin_tools.dart
- core/format.dart (only `fmtDuration`/`fmtTokens` strings)
- core/i18n.dart: language comes from `PlatformDispatcher`, not `Localizations`; see H-013.
- core/model_catalog.dart
- core/storage.dart
- models/models.dart
- state/app_state.dart: `AppearanceCtl` syncs the theme settings.
- features/chat/chat_controller.dart

Total: 30 files.

Also checked:
- `app/pubspec.yaml`: no `flutter_localizations`, no custom fonts.
- Flutter 3.50 defaults: `app_bar.dart`, `button_style_button.dart`, `drawer.dart`, `navigation_drawer.dart`, `popup_menu.dart`, `bottom_sheet.dart`, `card.dart`, `page_transitions_theme.dart`, `progress_indicator.dart`, `motion.dart`; `widgets/animated_switcher.dart`, `widgets/animated_size.dart`, `animation/curves.dart`, `widgets/raw_menu_anchor.dart`.
