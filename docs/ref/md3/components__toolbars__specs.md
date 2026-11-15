Source: https://m3.material.io/components/toolbars/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T08:14:45.120Z

# Toolbars — Specs

## Variants

*[Image: 2 variants of toolbars.]*

1. Docked toolbar
2. Floating toolbar

### Baseline variant

The baseline bottom app bar is no longer recommended. It should be replaced with the docked toolbar, which is very similar and more flexible.

*[Image: Baseline bottom app bar, which looks like the docked toolbar, but is not recommended.]*

1. Bottom app bar (not recommended)

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Docked toolbar | -- | Available |
| Floating toolbar | -- | Available |
| Bottom app bar | Available | Not recommended.  Use **docked toolbar**. |

star

Note:

Implementation differs per platform. On Jetpack Compose, the floating toolbar is a separate component from the docked toolbar and bottom app bar.

## Configurations

*[Image: Color configuration of toolbars.]*

1. Standard and vibrant toolbars
2. Vertical floating toolbar
3. Floating toolbar with FAB

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Color | Standard (default) | Available as bottom app bar | Available |
| Vibrant | -- | Available |
| Floating toolbar layout | Horizontal (default) | -- | Available |
| Vertical | -- | Available |
| Other elements | With FAB | Available as bottom app bar | Available* |

star

Note:

*Implementation differs per platform. On Jetpack Compose, floating toolbar with FAB is [fully supported](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#HorizontalFloatingToolbar(kotlin.Boolean,androidx.compose.ui.Modifier,androidx.compose.material3.FloatingToolbarColors,androidx.compose.foundation.layout.PaddingValues,androidx.compose.material3.FloatingToolbarScrollBehavior,androidx.compose.ui.graphics.Shape,kotlin.Function1,kotlin.Function1,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp,kotlin.Function1)). On other platforms, each component needs to be added separately.

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Jump to baseline bottom app bar specs](https://m3.material.io/components/toolbars/specs#ad142675-3e3b-43b8-ba53-12c1f0b7138d)

#### Token set: Toolbar - Color - Standard (`md.comp.toolbar.standard`)

For standard docked and floating toolbars.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.container.color` | Toolbar standard container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.standard.button.container.color` | Toolbar standard button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.standard.selected.button.container.color` |  Toolbar standard selected button container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.toolbar.standard.icon.color` | Toolbar standard icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.icon.color` | Toolbar standard selected icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.label-text.color` | Toolbar standard label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.label-text.color` | Toolbar standard selected label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.container.shape` | Toolbar standard container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.disabled.icon.color` | Toolbar standard disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.standard.disabled.icon.opacity` | Toolbar standard disabled icon opacity |  | 0.38 |
| `md.comp.toolbar.standard.disabled.label-text.color` | Toolbar standard disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.standard.disabled.label-text.opacity` | Toolbar standard disabled label opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.hovered.state-layer.color` | Toolbar standard hovered state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.state-layer.color` | Toolbar standard selected hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.hovered.state-layer.opacity` | Toolbar standard hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.toolbar.standard.hovered.icon.color` | Toolbar standard hovered icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.icon.color` | Toolbar standard selected hovered icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.hovered.label-text.color` | Toolbar standard hovered label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.label-text.color` | Toolbar standard selected hovered label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.focused.state-layer.color` | Toolbar standard focused state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.state-layer.color` | Toolbar standard selected focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.focused.state-layer.opacity` | Toolbar standard focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.toolbar.standard.focused.icon.color` | Toolbar standard focused icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.icon.color` | Toolbar standard selected focused icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.focused.label-text.color` | Toolbar standard focused label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.label-text.color` | Toolbar standard selected focused label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.pressed.state-layer.color` | Toolbar standard pressed state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.state-layer.color` | Toolbar standard selected pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.pressed.state-layer.opacity` | Toolbar standard pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.toolbar.standard.pressed.icon.color` | Toolbar standard pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.icon.color` | Toolbar standard selected pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.pressed.label-text.color` | Toolbar standard pressed label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.label-text.color` | Toolbar standard selected pressed label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: Toolbar - Color - Vibrant (`md.comp.toolbar.vibrant`)

For vibrant docked and floating toolbars.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.container.color` | Toolbar standard container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.vibrant.button.container.color` | Toolbar vibrant button container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.vibrant.selected.button.container.color` |  Toolbar vibrant selected button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.vibrant.icon.color` | Toolbar vibrant icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.icon.color` | Toolbar vibrant selected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.label-text.color` | Toolbar vibrant label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.label-text.color` | Toolbar vibrant selected label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.container.shape` | Toolbar vibrant container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.disabled.icon.color` | Toolbar vibrant disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.disabled.icon.opacity` | Toolbar vibrant disabled icon opacity |  | 0.38 |
| `md.comp.toolbar.vibrant.disabled.label-text.color` | Toolbar vibrant disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.disabled.label-text.opacity` | Toolbar vibrant disabled label opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.hovered.state-layer.color` | Toolbar vibrant hovered state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.state-layer.color` | Toolbar vibrant selected hovered state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.hovered.state-layer.opacity` | Toolbar vibrant hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.toolbar.vibrant.hovered.icon.color` | Toolbar vibrant hovered icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.icon.color` | Toolbar vibrant selected hovered icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.hovered.label-text.color` | Toolbar vibrant hovered label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.label-text.color` | Toolbar vibrant selected hovered label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.focused.state-layer.color` | Toolbar vibrant focused state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.state-layer.color` | Toolbar vibrant selected focused state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.focused.state-layer.opacity` | Toolbar vibrant focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.toolbar.vibrant.focused.icon.color` | Toolbar vibrant focused icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.icon.color` | Toolbar vibrant selected focused icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.focused.label-text.color` | Toolbar vibrant focused label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.label-text.color` | Toolbar vibrant selected focused label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.pressed.state-layer.color` | Toolbar vibrant pressed state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.state-layer.color` | Toolbar vibrant selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.pressed.state-layer.opacity` | Toolbar vibrant pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.toolbar.vibrant.pressed.icon.color` | Toolbar vibrant pressed icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.icon.color` | Toolbar vibrant selected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.pressed.label-text.color` | Toolbar vibrant pressed label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.label-text.color` | Toolbar vibrant selected pressed label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

#### Token set: Toolbar - Docked (`md.comp.toolbar.docked`)

For docked toolbars.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.color` *(deprecated)* | Docked toolbar container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.height` | Docked toolbar container height |  | 64dp |
| `md.comp.toolbar.docked.container.leading-space` | Docked toolbar leading padding | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.docked.container.trailing-space` | Docked toolbar trailing padding | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.docked.container.max-spacing` | Docked toolbar max space between actions |  | 32dp |
| `md.comp.toolbar.docked.container.min-spacing` | Docked toolbar min space between actions |  | 4dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.shape` | Docked toolbar container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

#### Token set: Toolbar - Floating (`md.comp.toolbar.floating`)

For floating toolbars.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.standard.container.color` *(deprecated)* | Floating toolbar standard color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.floating.vibrant.container.color` *(deprecated)* | Floating toolbar vibrant color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.floating.vibrant.button.unselected.icon.color` *(deprecated)* | Floating toolbar vibrant unselected button icon color  | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.floating.vibrant.button.unselected.text.color` *(deprecated)* | Floating toolbar vibrant unselected button text color  | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.floating.vibrant.button.selected.icon.color` *(deprecated)* | Floating toolbar vibrant selected button icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.floating.vibrant.button.selected.text.color` *(deprecated)* | Floating toolbar vibrant selected button text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.floating.vibrant.button.selected.container.color` *(deprecated)* | Floating toolbar vibrant selected button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.height` *(deprecated)* | Floating toolbar container height |  | 64dp |
| `md.comp.toolbar.floating.horizontal.container.height` | Floating toolbar container height - horizontal |  | 64dp |
| `md.comp.toolbar.floating.vertical.container.width` | Floating toolbar container height - vertical |  | 64dp |
| `md.comp.toolbar.floating.container.leading-space` | Floating toolbar leading space | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.container.trailing-space` | Floating toolbar trailing space | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.container.external-padding` *(deprecated)* | Floating toolbar margin from screen edge |  | 16dp |
| `md.comp.toolbar.floating.horizontal.container.external-space` | Floating toolbar margin from screen edge - horizontal | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.floating.vertical.container.external-space` | Floating toolbar margin from screen edge - vertical | md.sys.measurement.space300 | 24dp |
| `md.comp.toolbar.floating.container.between-space` | Floating toolbar space between actions | md.sys.measurement.space50 | 4dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.shape` | Floating toolbar container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Elevation**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.elevation` | Floating toolbar container elevation | md.sys.elevation.level3 | 6dp |

#### Token set: Toolbar - Floating - FAB (`md.comp.toolbar.floating.fab`)

For floating toolbars with a FAB in them.

**Expanded**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.container.height` | Toolbar floating FAB container height |  | 56dp |
| `md.comp.toolbar.floating.fab.container.width` | Toolbar floating FAB container width |  | 56dp |
| `md.comp.toolbar.floating.fab.icon.size` | Toolbar floating FAB icon size |  | 24dp |
| `md.comp.toolbar.floating.fab.container.shape` | Toolbar floating FAB container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.toolbar.floating.fab.container.elevation` | Toolbar floating FAB container elevation | md.sys.elevation.level1 | 1dp |

**Collapsed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.medium.container.height` | Toolbar floating FAB medium container height |  | 80dp |
| `md.comp.toolbar.floating.fab.medium.container.width` | Toolbar floating FAB medium container width |  | 80dp |
| `md.comp.toolbar.floating.fab.medium.icon.size` | Toolbar floating FAB medium icon size |  | 28dp |
| `md.comp.toolbar.floating.fab.medium.container.shape` | Toolbar floating FAB medium container shape | md.sys.shape.corner.large-increased | rounded corners: 20dp all corners |
| `md.comp.toolbar.floating.fab.medium.container.elevation` | Toolbar floating FAB medium container elevation | md.sys.elevation.level2 | 3dp |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.between-space` | Toolbar floating FAB space between toolbar and FAB | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.fab.standard.container.color` | Toolbar floating FAB standard container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.toolbar.floating.fab.standard.icon.color` | Toolbar floating FAB standard icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.floating.fab.vibrant.container.color` | Toolbar floating FAB vibrant container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.toolbar.floating.fab.vibrant.icon.color` | Toolbar floating FAB vibrant icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

## Anatomy

*[Image: 2 elements of a toolbar.]*

1. Container
2. Placed components

### Flexibility & slots

When configuring a toolbar, think of it as a container with several slots.

Each slot can be a different element. The most common elements are icon buttons, buttons, and text fields.

*[Image: A toolbar with 5 slots, conceptual spaces for UI elements, next to each other.]*

A toolbar is essentially a container with configurable slots

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

### Standard

*[Image: 4 color roles in the standard color scheme  of the floating toolbar in light and dark scheme.]*

Standard color schemes and icon button types:

1. Surface container
2. Filled button (Primary, On primary)
3. Toggle tonal button (Secondary container, On secondary container)
4. Standard button (Primary)

### Vibrant

*[Image: 4 color roles in the vibrant color scheme of the floating toolbar in light and dark scheme.]*

Vibrant color scheme and icon button types:

1. Primary container
2. Filled button (Primary, On primary)
3. Toggle tonal button: (Surface container, On surface)
4. Standard button (On primary container)

## Measurements

By default all toolbars are 64dp high, center-aligned, have equal padding between items, and have a minimum outside padding of 16dp.

### Docked toolbar

*[Image: Default internal padding of a docked toolbar.]*

1. Default margins and padding
2. Margins and padding with leading, middle, and trailing content

*[Image: 2 docked toolbars with different margins and alignment.]*

Alignment and padding can be configured to create unique layouts:

1. Left and right alignment
2. Center-aligned, 8dp padding between items

### Floating toolbar

*[Image: Diagram noting margin around edge of floating toolbar.]*

Default padding of floating toolbar

*[Image: Diagram noting layout measurements.]*

Floating toolbar size and padding measurements

*[Image: Diagram noting layout margins.]*

Floating toolbar margins

---

## Bottom app bar (baseline)

*[Image: Diagram of bottom app bar indicating the container.]*

1. Container

### Tokens & specs

Bottom app bar tokens are in one token set.

#### Token set: Bottom app bar (baseline) (`md.comp.bottom-app-bar`)

Baseline bottom app bar container tokens. For expressive, use `md.comp.toolbar.docked` and `md.comp.toolbar.standard` instead.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.bottom-app-bar.container.color` | Bottom app bar container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.bottom-app-bar.container.shape` | Bottom app bar container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.bottom-app-bar.container.elevation` | Bottom app bar container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.bottom-app-bar.container.surface-tint-layer.color` *(deprecated)* | Bottom app bar container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.bottom-app-bar.container.height` | Bottom app bar container height |  | 80dp |
| `md.comp.bottom-app-bar.with-fab.container.height` *(deprecated)* | Bottom app bar with FAB container height |  | 72dp |

#### Token set: Toolbar - Docked (`md.comp.toolbar.docked`)

For docked toolbars.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.color` *(deprecated)* | Docked toolbar container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.height` | Docked toolbar container height |  | 64dp |
| `md.comp.toolbar.docked.container.leading-space` | Docked toolbar leading padding | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.docked.container.trailing-space` | Docked toolbar trailing padding | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.docked.container.max-spacing` | Docked toolbar max space between actions |  | 32dp |
| `md.comp.toolbar.docked.container.min-spacing` | Docked toolbar min space between actions |  | 4dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.docked.container.shape` | Docked toolbar container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

#### Token set: Toolbar - Floating (`md.comp.toolbar.floating`)

For floating toolbars.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.standard.container.color` *(deprecated)* | Floating toolbar standard color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.floating.vibrant.container.color` *(deprecated)* | Floating toolbar vibrant color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.floating.vibrant.button.unselected.icon.color` *(deprecated)* | Floating toolbar vibrant unselected button icon color  | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.floating.vibrant.button.unselected.text.color` *(deprecated)* | Floating toolbar vibrant unselected button text color  | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.floating.vibrant.button.selected.icon.color` *(deprecated)* | Floating toolbar vibrant selected button icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.floating.vibrant.button.selected.text.color` *(deprecated)* | Floating toolbar vibrant selected button text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.floating.vibrant.button.selected.container.color` *(deprecated)* | Floating toolbar vibrant selected button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.height` *(deprecated)* | Floating toolbar container height |  | 64dp |
| `md.comp.toolbar.floating.horizontal.container.height` | Floating toolbar container height - horizontal |  | 64dp |
| `md.comp.toolbar.floating.vertical.container.width` | Floating toolbar container height - vertical |  | 64dp |
| `md.comp.toolbar.floating.container.leading-space` | Floating toolbar leading space | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.container.trailing-space` | Floating toolbar trailing space | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.container.external-padding` *(deprecated)* | Floating toolbar margin from screen edge |  | 16dp |
| `md.comp.toolbar.floating.horizontal.container.external-space` | Floating toolbar margin from screen edge - horizontal | md.sys.measurement.space200 | 16dp |
| `md.comp.toolbar.floating.vertical.container.external-space` | Floating toolbar margin from screen edge - vertical | md.sys.measurement.space300 | 24dp |
| `md.comp.toolbar.floating.container.between-space` | Floating toolbar space between actions | md.sys.measurement.space50 | 4dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.shape` | Floating toolbar container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Elevation**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.container.elevation` | Floating toolbar container elevation | md.sys.elevation.level3 | 6dp |

#### Token set: Toolbar - Color - Standard (`md.comp.toolbar.standard`)

For standard docked and floating toolbars.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.container.color` | Toolbar standard container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.standard.button.container.color` | Toolbar standard button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.standard.selected.button.container.color` |  Toolbar standard selected button container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.toolbar.standard.icon.color` | Toolbar standard icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.icon.color` | Toolbar standard selected icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.label-text.color` | Toolbar standard label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.label-text.color` | Toolbar standard selected label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.container.shape` | Toolbar standard container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.disabled.icon.color` | Toolbar standard disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.standard.disabled.icon.opacity` | Toolbar standard disabled icon opacity |  | 0.38 |
| `md.comp.toolbar.standard.disabled.label-text.color` | Toolbar standard disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.standard.disabled.label-text.opacity` | Toolbar standard disabled label opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.hovered.state-layer.color` | Toolbar standard hovered state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.state-layer.color` | Toolbar standard selected hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.hovered.state-layer.opacity` | Toolbar standard hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.toolbar.standard.hovered.icon.color` | Toolbar standard hovered icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.icon.color` | Toolbar standard selected hovered icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.hovered.label-text.color` | Toolbar standard hovered label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.hovered.label-text.color` | Toolbar standard selected hovered label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.focused.state-layer.color` | Toolbar standard focused state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.state-layer.color` | Toolbar standard selected focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.focused.state-layer.opacity` | Toolbar standard focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.toolbar.standard.focused.icon.color` | Toolbar standard focused icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.icon.color` | Toolbar standard selected focused icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.focused.label-text.color` | Toolbar standard focused label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.focused.label-text.color` | Toolbar standard selected focused label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.standard.pressed.state-layer.color` | Toolbar standard pressed state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.state-layer.color` | Toolbar standard selected pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.pressed.state-layer.opacity` | Toolbar standard pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.toolbar.standard.pressed.icon.color` | Toolbar standard pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.icon.color` | Toolbar standard selected pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.standard.pressed.label-text.color` | Toolbar standard pressed label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.toolbar.standard.selected.pressed.label-text.color` | Toolbar standard selected pressed label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: Toolbar - Color - Vibrant (`md.comp.toolbar.vibrant`)

For vibrant docked and floating toolbars.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.container.color` | Toolbar standard container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.vibrant.button.container.color` | Toolbar vibrant button container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.toolbar.vibrant.selected.button.container.color` |  Toolbar vibrant selected button container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.toolbar.vibrant.icon.color` | Toolbar vibrant icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.icon.color` | Toolbar vibrant selected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.label-text.color` | Toolbar vibrant label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.label-text.color` | Toolbar vibrant selected label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.container.shape` | Toolbar vibrant container shape | md.sys.shape.corner.full | fully rounded (circular) |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.disabled.icon.color` | Toolbar vibrant disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.disabled.icon.opacity` | Toolbar vibrant disabled icon opacity |  | 0.38 |
| `md.comp.toolbar.vibrant.disabled.label-text.color` | Toolbar vibrant disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.disabled.label-text.opacity` | Toolbar vibrant disabled label opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.hovered.state-layer.color` | Toolbar vibrant hovered state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.state-layer.color` | Toolbar vibrant selected hovered state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.hovered.state-layer.opacity` | Toolbar vibrant hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.toolbar.vibrant.hovered.icon.color` | Toolbar vibrant hovered icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.icon.color` | Toolbar vibrant selected hovered icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.hovered.label-text.color` | Toolbar vibrant hovered label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.hovered.label-text.color` | Toolbar vibrant selected hovered label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.focused.state-layer.color` | Toolbar vibrant focused state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.state-layer.color` | Toolbar vibrant selected focused state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.focused.state-layer.opacity` | Toolbar vibrant focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.toolbar.vibrant.focused.icon.color` | Toolbar vibrant focused icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.icon.color` | Toolbar vibrant selected focused icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.focused.label-text.color` | Toolbar vibrant focused label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.focused.label-text.color` | Toolbar vibrant selected focused label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.vibrant.pressed.state-layer.color` | Toolbar vibrant pressed state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.state-layer.color` | Toolbar vibrant selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.pressed.state-layer.opacity` | Toolbar vibrant pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.toolbar.vibrant.pressed.icon.color` | Toolbar vibrant pressed icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.icon.color` | Toolbar vibrant selected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.toolbar.vibrant.pressed.label-text.color` | Toolbar vibrant pressed label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.toolbar.vibrant.selected.pressed.label-text.color` | Toolbar vibrant selected pressed label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

#### Token set: Toolbar - Floating - FAB (`md.comp.toolbar.floating.fab`)

For floating toolbars with a FAB in them.

**Expanded**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.container.height` | Toolbar floating FAB container height |  | 56dp |
| `md.comp.toolbar.floating.fab.container.width` | Toolbar floating FAB container width |  | 56dp |
| `md.comp.toolbar.floating.fab.icon.size` | Toolbar floating FAB icon size |  | 24dp |
| `md.comp.toolbar.floating.fab.container.shape` | Toolbar floating FAB container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.toolbar.floating.fab.container.elevation` | Toolbar floating FAB container elevation | md.sys.elevation.level1 | 1dp |

**Collapsed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.medium.container.height` | Toolbar floating FAB medium container height |  | 80dp |
| `md.comp.toolbar.floating.fab.medium.container.width` | Toolbar floating FAB medium container width |  | 80dp |
| `md.comp.toolbar.floating.fab.medium.icon.size` | Toolbar floating FAB medium icon size |  | 28dp |
| `md.comp.toolbar.floating.fab.medium.container.shape` | Toolbar floating FAB medium container shape | md.sys.shape.corner.large-increased | rounded corners: 20dp all corners |
| `md.comp.toolbar.floating.fab.medium.container.elevation` | Toolbar floating FAB medium container elevation | md.sys.elevation.level2 | 3dp |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.toolbar.floating.fab.between-space` | Toolbar floating FAB space between toolbar and FAB | md.sys.measurement.space100 | 8dp |
| `md.comp.toolbar.floating.fab.standard.container.color` | Toolbar floating FAB standard container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.toolbar.floating.fab.standard.icon.color` | Toolbar floating FAB standard icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.toolbar.floating.fab.vibrant.container.color` | Toolbar floating FAB vibrant container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.toolbar.floating.fab.vibrant.icon.color` | Toolbar floating FAB vibrant icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Diagram of bottom app bar indicating its color mappings.]*

Bottom app bar color role used for light and dark themes:

1. Surface container

### Measurements

*[Image: Diagram showing layout values and paddings for bottom app bar.]*

Bottom app bar padding and size measurements

### Common layouts

*[Image: Side by side view of bottom app bars in different configurations.]*

1. Icon buttons and FAB
2. Icon buttons and no FAB
