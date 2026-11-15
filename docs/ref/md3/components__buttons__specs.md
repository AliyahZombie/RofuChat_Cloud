Source: https://m3.material.io/components/buttons/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-24T06:19:49.216Z

# Buttons — Specs

## Variants

*[Image: Diagram comparing buttons with toggle buttons.]*

1. Default button
2. Toggle button

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Default | Available | Available |
| Toggle (selection) | -- | Available |

## Configurations

*[Image: Diagram showing configurations of buttons.]*

1. Size
2. Shape
3. Color
4. Small button padding

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Size | Small (default) | Available | Available |
| XS, M, L, XL | -- | Available |
| Shape | Round (default) | Available | Available |
| Square | -- | Available |
| Color | Elevated, filled (default), tonal, outlined, text | Available | Available |
| Small button padding | 24dp | Available | Not recommended.  Use 16dp |
| 16dp | -- | Available |

## Tokens & specs

Use the table's menu to select a token set. Button token sets are separated into common tokens, color, and size. [View baseline tokens](https://m3.material.io/components/buttons/specs#c305d304-a6c0-466a-a48c-8d0718a29ae2)

#### Token set: Button - Color - Elevated (`md.comp.button.elevated`)

For elevated buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.elevated.container.color` | Button elevated container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.button.elevated.unselected.container.color` | Button elevated container color - toggle (unselected) | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.button.elevated.selected.container.color` | Button elevated container color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.container.shadow-color` | Button elevated shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.button.elevated.container.elevation` | Button elevated elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.button.elevated.label-text.color` | Button elevated label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.label-text.color` | Button elevated label color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.label-text.color` | Button elevated label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.icon.color` | Button elevated icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.icon.color` | Button elevated icon color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.icon.color` | Button elevated icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.elevated.disabled.container.color` | Button elevated disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.elevated.disabled.container.opacity` | Button elevated disabled container opacity |  | 0.1 |
| `md.comp.button.elevated.disabled.container.elevation` | Button elevated disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.elevated.disabled.label-text.color` | Button elevated disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.elevated.disabled.label-text.opacity` | Button elevated disabled label opacity |  | 0.38 |
| `md.comp.button.elevated.disabled.icon.color` | Button elevated disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.elevated.disabled.icon.opacity` | Button elevated disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.elevated.hovered.state-layer.color` | Button elevated hovered container state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.hovered.state-layer.color` | Button elevated hovered container state layer color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.hovered.state-layer.color` | Button elevated hovered container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.hovered.state-layer.opacity` | Button elevated hovered container state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.button.elevated.hovered.container.elevation` *(deprecated)* | Button elevated hovered container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.button.elevated.hovered.label-text.color` | Button elevated hovered label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.hovered.label-text.color` | Button elevated hovered label color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.hovered.label-text.color` | Button elevated hovered label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.hovered.icon.color` | Button elevated hovered icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.hovered.icon.color` | Button elevated hovered icon color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.hovered.icon.color` | Button elevated hovered icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.elevated.focused.state-layer.color` | Button elevated focused container state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.focused.state-layer.color` | Button elevated focused container state layer color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.focused.state-layer.color` | Button elevated focused container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.focused.state-layer.opacity` | Button elevated focused container state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.button.elevated.focused.container.elevation` | Button elevated focused container state layer elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.button.elevated.focused.label-text.color` | Button elevated focused label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.focused.label-text.color` | Button elevated focused label color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.focused.label-text.color` | Button elevated focused label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.focused.icon.color` | Button elevated focused icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.focused.icon.color` | Button elevated focused icon color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.focused.icon.color` | Button elevated focused icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.elevated.pressed.state-layer.color` | Button elevated pressed container state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.pressed.state-layer.color` | Button elevated pressed container state layer color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.pressed.state-layer.color` | Button elevated pressed container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.pressed.state-layer.opacity` | Button elevated pressed container state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.button.elevated.pressed.container.elevation` | Button elevated pressed container state layer elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.button.elevated.pressed.label-text.color` | Button elevated pressed label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.pressed.label-text.color` | Button elevated pressed label color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.pressed.label-text.color` | Button elevated pressed label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.elevated.pressed.icon.color` | Button elevated pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.unselected.pressed.icon.color` | Button elevated pressed icon color - toggle (unselected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.elevated.selected.pressed.icon.color` | Button elevated pressed icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

#### Token set: Button - Color - Filled (`md.comp.button.filled`)

For filled buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.filled.container.color` | Button filled container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.filled.unselected.container.color` | Button filled container color - toggle (unselected) | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.button.filled.selected.container.color` | Button filled container color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.filled.container.shadow-color` | Button filled shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.button.filled.container.elevation` | Button filled elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.filled.label-text.color` | Button filled label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.label-text.color` | Button filled label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.label-text.color` | Button filled label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.icon.color` | Button filled icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.icon.color` | Button filled icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.icon.color` | Button filled icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.filled.disabled.container.color` | Button filled disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.filled.disabled.container.opacity` | Button filled disabled container opacity |  | 0.1 |
| `md.comp.button.filled.disabled.container.elevation` | Button filled disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.filled.disabled.label-text.color` | Button filled disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.filled.disabled.label-text.opacity` | Button filled disabled label opacity |  | 0.38 |
| `md.comp.button.filled.disabled.icon.color` | Button filled disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.filled.disabled.icon.opacity` | Button filled disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.filled.hovered.state-layer.color` | Button filled hovered container state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.hovered.state-layer.color` | Button filled hovered container state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.hovered.state-layer.color` | Button filled hovered container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.hovered.state-layer.opacity` | Button filled hovered container state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.button.filled.hovered.container.elevation` *(deprecated)* | Button filled hovered container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.button.filled.hovered.label-text.color` | Button filled hovered label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.hovered.label-text.color` | Button filled hovered label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.hovered.label-text.color` | Button filled hovered label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.hovered.icon.color` | Button filled hovered icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.hovered.icon.color` | Button filled hovered icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.hovered.icon.color` | Button filled hovered icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.filled.focused.state-layer.color` | Button filled focused container state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.focused.state-layer.color` | Button filled focused container state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.focused.state-layer.color` | Button filled focused container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.focused.state-layer.opacity` | Button filled focused container state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.button.filled.focused.container.elevation` | Button filled focused container state layer elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.filled.focused.label-text.color` | Button filled focused label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.focused.label-text.color` | Button filled focused label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.focused.label-text.color` | Button filled focused label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.focused.icon.color` | Button filled focused icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.focused.icon.color` | Button filled focused icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.focused.icon.color` | Button filled focused icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.filled.pressed.state-layer.color` | Button filled pressed container state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.pressed.state-layer.color` | Button filled pressed container state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.pressed.state-layer.color` | Button filled pressed container state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.pressed.state-layer.opacity` | Button filled pressed container state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.button.filled.pressed.container.elevation` | Button filled pressed container state layer elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.filled.pressed.label-text.color` | Button filled pressed label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.pressed.label-text.color` | Button filled pressed label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.pressed.label-text.color` | Button filled pressed label color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.pressed.icon.color` | Button filled pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.button.filled.unselected.pressed.icon.color` | Button filled pressed icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.filled.selected.pressed.icon.color` | Button filled pressed icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

#### Token set: Button - Color - Tonal (`md.comp.button.tonal`)

For tonal buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.tonal.container.color` | Button tonal container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.button.tonal.unselected.container.color` | Button tonal container color - toggle (unselected) | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.button.tonal.selected.container.color` | Button tonal container color - toggle (selected) | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.button.tonal.container.shadow-color` | Button tonal shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.button.tonal.container.elevation` | Button tonal elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.tonal.label-text.color` | Button tonal label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.label-text.color` | Button tonal label color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.label-text.color` | Button tonal label color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.icon.color` | Button tonal icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.icon.color` | Button tonal icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.icon.color` | Button tonal icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.tonal.disabled.container.color` | Button tonal disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.tonal.disabled.container.opacity` | Button tonal disabled container opacity |  | 0.1 |
| `md.comp.button.tonal.disabled.container.elevation` | Button tonal disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.tonal.disabled.label-text.color` | Button tonal disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.tonal.disabled.label-text.opacity` | Button tonal disabled label opacity |  | 0.38 |
| `md.comp.button.tonal.disabled.icon.color` | Button tonal disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.tonal.disabled.icon.opacity` | Button tonal disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.tonal.hovered.state-layer.color` | Button tonal hovered container state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.hovered.state-layer.color` | Button tonal hovered container state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.hovered.state-layer.color` | Button tonal hovered container state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.hovered.state-layer.opacity` | Button tonal hovered container state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.button.tonal.hovered.container.elevation` *(deprecated)* | Button tonal hovered container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.button.tonal.hovered.label-text.color` | Button tonal hovered label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.hovered.label-text.color` | Button tonal hovered label color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.hovered.label-text.color` | Button tonal hovered label color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.hovered.icon.color` | Button tonal hovered icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.hovered.icon.color` | Button tonal hovered icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.hovered.icon.color` | Button tonal hovered icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.tonal.focused.state-layer.color` | Button tonal focused container state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.focused.state-layer.color` | Button tonal focused container state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.focused.state-layer.color` | Button tonal focused container state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.focused.state-layer.opacity` | Button tonal focused container state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.button.tonal.focused.container.elevation` | Button tonal focused container state layer elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.tonal.focused.label-text.color` | Button tonal focused label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.focused.label-text.color` | Button tonal focused label color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.focused.label-text.color` | Button tonal focused label color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.focused.icon.color` | Button tonal focused icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.focused.icon.color` | Button tonal focused icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.focused.icon.color` | Button tonal focused icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.tonal.pressed.state-layer.color` | Button tonal pressed container state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.pressed.state-layer.color` | Button tonal pressed container state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.pressed.state-layer.color` | Button tonal pressed container state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.pressed.state-layer.opacity` | Button tonal pressed container state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.button.tonal.pressed.container.elevation` | Button tonal pressed container state layer elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.button.tonal.pressed.label-text.color` | Button tonal pressed label color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.pressed.label-text.color` | Button tonal pressed label color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.pressed.label-text.color` | Button tonal pressed label color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.button.tonal.pressed.icon.color` | Button tonal pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.unselected.pressed.icon.color` | Button tonal pressed icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.button.tonal.selected.pressed.icon.color` | Button tonal pressed icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

#### Token set: Button - Color - Outlined (`md.comp.button.outlined`)

For outlined buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.outlined.outline.color` | Button outlined outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.selected.container.color` | Button outlined container color - toggle (selected) | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |
| `md.comp.button.outlined.label-text.color` | Button outlined label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.label-text.color` | Button outlined label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.label-text.color` | Button outlined label color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.icon.color` | Button outlined icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.icon.color` | Button outlined icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.icon.color` | Button outlined icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.outlined.disabled.outline.color` | Button outlined disabled outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.unselected.disabled.outline.color` | Button outlined disabled outline color (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.selected.disabled.container.color` | Button outlined disabled container color (selected) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.outlined.disabled.container.opacity` | Button outlined disabled container opacity |  | 0.1 |
| `md.comp.button.outlined.disabled.label-text.color` | Button outlined disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.outlined.disabled.label-text.opacity` | Button outlined disabled label opacity |  | 0.38 |
| `md.comp.button.outlined.disabled.icon.color` | Button outlined disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.outlined.disabled.icon.opacity` | Button outlined disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.outlined.hovered.state-layer.color` | Button outlined hovered state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.hovered.state-layer.color` | Button outlined hovered state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.hovered.state-layer.color` | Button outlined hovered state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.hovered.state-layer.opacity` | Button outlined hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.button.outlined.hovered.outline.color` | Button outlined hovered outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.unselected.hovered.outline.color` | Button outlined hovered outline color - toggle (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.hovered.label-text.color` | Button outlined hovered label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.hovered.label-text.color` | Button outlined hovered label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.hovered.label-text.color` | Button outlined hovered label color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.hovered.icon.color` | Button outlined hovered icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.hovered.icon.color` | Button outlined hovered icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.hovered.icon.color` | Button outlined hovered icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.outlined.focused.state-layer.color` | Button outlined focused container state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.focused.state-layer.color` | Button outlined focused container state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.focused.state-layer.color` | Button outlined focused container state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.focused.state-layer.opacity` | Button outlined focused container state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.button.outlined.focused.outline.color` | Button outlined focused outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.unselected.focused.outline.color` | Button outlined focused outline color - toggle (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.focused.label-text.color` | Button outlined focused label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.focused.label-text.color` | Button outlined focused label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.focused.label-text.color` | Button outlined focused label color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.focused.icon.color` | Button outlined focused icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.focused.icon.color` | Button outlined focused icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.focused.icon.color` | Button outlined focused icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.outlined.pressed.state-layer.color` | Button outlined pressed container state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.pressed.state-layer.color` | Button outlined pressed container state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.pressed.state-layer.color` | Button outlined pressed container state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.pressed.state-layer.opacity` | Button outlined pressed container state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.button.outlined.pressed.outline.color` | Button outlined pressed outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.unselected.pressed.outline.color` | Button outlined pressed outline color - toggle (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.button.outlined.pressed.label-text.color` | Button outlined pressed label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.pressed.label-text.color` | Button outlined pressed label color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.pressed.label-text.color` | Button outlined pressed label color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.button.outlined.pressed.icon.color` | Button outlined pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.unselected.pressed.icon.color` | Button outlined pressed icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.button.outlined.selected.pressed.icon.color` | Button outlined pressed icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

#### Token set: Button - Color - Text (`md.comp.button.text`)

For text buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.text.label-text.color` | Button text label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.icon.color` | Button text icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.text.disabled.container.color` | Button text disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.text.disabled.container.opacity` | Button text disabled container opacity |  | 0.1 |
| `md.comp.button.text.disabled.label-text.color` | Button text disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.text.disabled.label-text.opacity` | Button text disabled label opacity |  | 0.38 |
| `md.comp.button.text.disabled.icon.color` | Button text disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.button.text.disabled.icon.opacity` | Button text disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.text.hovered.state-layer.color` | Button text hovered state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.hovered.state-layer.opacity` | Button text hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.button.text.hovered.label-text.color` | Button text hovered label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.hovered.icon.color` | Button text hovered icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.text.focused.state-layer.color` | Button text focused state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.focused.state-layer.opacity` | Button text focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.button.text.focused.label-text.color` | Button text focused label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.focused.icon.color` | Button text focused icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.text.pressed.state-layer.color` | Button text pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.pressed.state-layer.opacity` | Button text pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.button.text.pressed.label-text.color` | Button text pressed label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.button.text.pressed.icon.color` | Button text pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

#### Token set: Button - Size - Xsmall (`md.comp.button.xsmall`)

For XS buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.xsmall.container.height` | Button xsmall container height |  | 32dp |
| `md.comp.button.xsmall.outlined.outline.width` | Button xsmall outline width |  | 1dp |
| `md.comp.button.xsmall.label-text` | Button xsmall label size | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.button.xsmall.icon.size` | Button xsmall icon size |  | 20dp |
| `md.comp.button.xsmall.container.shape.round` | Button xsmall shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button.xsmall.container.shape.square` | Button xsmall shape square | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.button.xsmall.leading-space` | Button xsmall leading space |  | 12dp |
| `md.comp.button.xsmall.icon-label-space` | Button xsmall between icon label space | md.sys.measurement.space50 | 4dp |
| `md.comp.button.xsmall.trailing-space` | Button xsmall trailing space |  | 12dp |
| `md.comp.button.xsmall.pressed.container.shape` | Button xsmall shape pressed morph | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.button.xsmall.pressed.container.corner-size.motion.spring.damping` | Button xsmall shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button.xsmall.pressed.container.corner-size.motion.spring.stiffness` | Button xsmall shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button.xsmall.selected.container.shape.round` | Button xsmall selected container shape round | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.button.xsmall.selected.container.shape.square` | Button xsmall selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Button - Size - Small (`md.comp.button.small`)

For small buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.small.container.height` | Button small container height |  | 40dp |
| `md.comp.button.small.outlined.outline.width` | Button small outline width |  | 1dp |
| `md.comp.button.small.label-text` | Button small label size | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.button.small.icon.size` | Button small icon size |  | 20dp |
| `md.comp.button.small.container.shape.round` | Button small shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button.small.container.shape.square` | Button small shape square | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.button.small.leading-space` | Button small leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.button.small.icon-label-space` | Button small between icon label space | md.sys.measurement.space100 | 8dp |
| `md.comp.button.small.trailing-space` | Button small trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.button.small.pressed.container.shape` | Button small shape pressed morph | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.button.small.pressed.container.corner-size.motion.spring.damping` | Button small shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button.small.pressed.container.corner-size.motion.spring.stiffness` | Button small shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button.small.selected.container.shape.round` | Button small selected container shape round | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.button.small.selected.container.shape.square` | Button small selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Button - Size - Medium (`md.comp.button.medium`)

For medium buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.medium.container.height` | Button medium container height |  | 56dp |
| `md.comp.button.medium.outlined.outline.width` | Button medium outline width |  | 1dp |
| `md.comp.button.medium.label-text` | Button medium label size | md.sys.typescale.title-medium → md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 16pt; line-height 24pt; tracking 0.15pt |
| `md.comp.button.medium.icon.size` | Button medium icon size |  | 24dp |
| `md.comp.button.medium.container.shape.round` | Button medium shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button.medium.container.shape.square` | Button medium shape square | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.button.medium.leading-space` | Button medium leading space | md.sys.measurement.space300 | 24dp |
| `md.comp.button.medium.icon-label-space` | Button medium between icon label space | md.sys.measurement.space100 | 8dp |
| `md.comp.button.medium.trailing-space` | Button medium trailing space | md.sys.measurement.space300 | 24dp |
| `md.comp.button.medium.pressed.container.shape` | Button medium shape pressed morph | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.button.medium.pressed.container.corner-size.motion.spring.damping` | Button medium shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button.medium.pressed.container.corner-size.motion.spring.stiffness` | Button medium shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button.medium.selected.container.shape.round` | Button medium selected container shape round | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.button.medium.selected.container.shape.square` | Button medium selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Button - Size - Large (`md.comp.button.large`)

For large buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.large.container.height` | Button large container height |  | 96dp |
| `md.comp.button.large.outlined.outline.width` | Button large outline width |  | 2dp |
| `md.comp.button.large.label-text` | Button large label size | md.sys.typescale.headline-small → md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto; weight 400; size 24pt; line-height 32pt; tracking 0pt |
| `md.comp.button.large.icon.size` | Button large icon size |  | 32dp |
| `md.comp.button.large.container.shape.round` | Button large shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button.large.container.shape.square` | Button large shape square | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.button.large.leading-space` | Button large leading space | md.sys.measurement.space600 | 48dp |
| `md.comp.button.large.icon-label-space` | Button large between icon label space | md.sys.measurement.space150 | 12dp |
| `md.comp.button.large.trailing-space` | Button large trailing space | md.sys.measurement.space600 | 48dp |
| `md.comp.button.large.pressed.container.shape` | Button large shape pressed morph | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.button.large.pressed.container.corner-size.motion.spring.damping` | Button large shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button.large.pressed.container.corner-size.motion.spring.stiffness` | Button large shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button.large.selected.container.shape.round` | Button large selected container shape round | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.button.large.selected.container.shape.square` | Button large selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Button - Size - Xlarge (`md.comp.button.xlarge`)

For XL buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button.xlarge.container.height` | Button xlarge container height |  | 136dp |
| `md.comp.button.xlarge.outlined.outline.width` | Button xlarge outline width |  | 3dp |
| `md.comp.button.xlarge.label-text` | Button xlarge label size | md.sys.typescale.headline-large → md.sys.typescale.headline-large.font → md.ref.typeface.brand | Roboto; weight 400; size 32pt; line-height 40pt; tracking 0pt |
| `md.comp.button.xlarge.icon.size` | Button xlarge icon size |  | 40dp |
| `md.comp.button.xlarge.container.shape.round` | Button xlarge shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button.xlarge.container.shape.square` | Button xlarge shape square | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.button.xlarge.leading-space` | Button xlarge leading space | md.sys.measurement.space800 | 64dp |
| `md.comp.button.xlarge.icon-label-space` | Button xlarge between icon label space | md.sys.measurement.space200 | 16dp |
| `md.comp.button.xlarge.trailing-space` | Button xlarge trailing space | md.sys.measurement.space800 | 64dp |
| `md.comp.button.xlarge.pressed.container.shape` | Button xlarge shape pressed morph | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.button.xlarge.pressed.container.corner-size.motion.spring.damping` | Button xlarge shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button.xlarge.pressed.container.corner-size.motion.spring.stiffness` | Button xlarge shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button.xlarge.selected.container.shape.round` | Button xlarge selected container shape round | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.button.xlarge.selected.container.shape.square` | Button xlarge selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

## Anatomy

*[Image: Diagram labeling 3 parts of a button.]*

1. Container
2. Label text
3. Icon (optional)

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.

- There are five built-in button color styles: elevated, filled, tonal, outlined, and text
- The default and toggle buttons use different colors
- Toggle buttons don’t use the text style

star

Note:

These color roles were chosen to create design coherence and familiarity. Other color roles can be used as long as the container and text have a 3:1 contrast ratio. For example, tertiary and on tertiary.

*[Image: Diagram shows dark and light color schemes for buttons.]*

A. Elevated, B. Filled, C. Tonal, D. Outlined, E. Text

1. Default
2. Toggle: unselected
3. Toggle: selected

|  | 1. Default | 2. Toggle unselected | 3. Toggle selected |
| --- | --- | --- | --- |
| Elevated container  Elevated icon & label | Surface container low  Primary | Surface container low  Primary | Primary  On primary |
| Filled container  Filled icon & label | Primary On primary | Surface container  On surface variant | Primary  On primary |
| Tonal container  Tonal icon & label | Secondary container  On secondary container | Secondary container  On secondary container | Secondary  On secondary |
| Outlined container  Outlined icon & label | Outline variant (outline)  On surface variant | Outline variant (outline)  On surface variant | Inverse surface  Inverse on surface |
| Text icon & label | Primary | -- | -- |

## States

States are visual representations used to communicate the status of a component or interactive element.

### Elevated button states

The elevated button style has an elevation of 1 by default and 0 when disabled.

#### Default

*[Image: Elevated button states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

#### Toggle

*[Image: Toggle elevated button states.]*

A. Unselected, B. Selected

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Filled button states

#### Default

*[Image: Filled button states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

#### Toggle

*[Image: Toggle filled button states.]*

A. Unselected, B. Selected

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Tonal button states

#### Default

*[Image: Tonal button states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

#### Toggle

*[Image: Toggle tonal button states.]*

A. Unselected, B. Selected

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Outlined button states

The outlined button’s container fill is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed.

#### Default

*[Image: Outlined button states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

#### Toggle

*[Image: Outlined button states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Text button style states

The text button’s container is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed. There is no toggle text button.

*[Image: Default text button style states.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

## Shape morph

### Pressed state

When pressed, buttons can morph to become more square. Both round and square buttons should have the same pressed shape.

The corner radius value differs for each button size. [See full button corner measurements](https://m3.material.io/components/buttons/specs#b1f39738-6f3a-409b-8f08-4cab6d78d756)

*[Image: Shape changes of a button.]*

A. Round button, B. Square button

1. Enabled
2. Hovered
3. Pressed

### When selected

In addition to changing shape when pressed, toggle buttons also change the resting shape from round (unselected) to square (selected).

If the resting unselected shape is square, the selected shape should be round.

*[Image: Shape changes of a toggle button.]*

A. Round button, B. Square button

1. Enabled
2. Hovered
3. Pressed
4. Selected

## Measurements

*[Image: Diagram of measurements of all button sizes.]*

Padding and size measurements of each button size

1. Extra small
2. Small
3. Medium
4. Large
5. Extra large

### Target areas

Extra small and small icon buttons must have a target size of 48x48dp or larger to be accessible.

*[Image: Diagram of small button target areas.]*

A. Extra small  B. Small

1. Round button
2. Button with icon
3. Square button

### Corner sizes

*[Image: Diagram of corner radii of buttons.]*

|  | XS | S | M | L | XL |
| --- | --- | --- | --- | --- | --- |
| A. Round button | Full | Full | Full | Full | Full |
| B. Square button | 12dp | 12dp | 16dp | 28dp | 28dp |
| C. Pressed state | 8dp | 8dp | 12dp | 16dp | 16dp |

## Baseline tokens

Use the table's menu to switch token sets. The baseline button token sets are organized by color.

#### Token set: [Deprecated] Button - Elevated (`md.comp.elevated-button`)

This token set is deprecated. Use `md.comp.button.elevated` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.elevated-button.container.shape` *(deprecated)* | Elevated button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.elevated-button.disabled.container.color` *(deprecated)* | Elevated button disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.elevated-button.focus.container.elevation` *(deprecated)* | Elevated button focus container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.elevated-button.hover.container.elevation` *(deprecated)* | Elevated button hover container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.elevated-button.pressed.container.elevation` *(deprecated)* | Elevated button pressed container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.elevated-button.container.height` *(deprecated)* | Elevated button container height |  | 40dp |
| `md.comp.elevated-button.disabled.container.opacity` *(deprecated)* | Elevated button disabled container opacity |  | 0.12 |
| `md.comp.elevated-button.container.elevation` *(deprecated)* | Elevated button container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.elevated-button.disabled.container.elevation` *(deprecated)* | Elevated button disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.elevated-button.container.shadow-color` *(deprecated)* | Elevated button container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.elevated-button.container.color` *(deprecated)* | Elevated button container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.elevated-button.container.surface-tint-layer.color` *(deprecated)* | Elevated button container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.elevated-button.focus.indicator.color` *(deprecated)* | Elevated button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.elevated-button.focus.indicator.thickness` *(deprecated)* | Elevated button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.elevated-button.focus.indicator.outline.offset` *(deprecated)* | Elevated button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.elevated-button.with-icon.disabled.icon.color` *(deprecated)* | Elevated button with icon disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.elevated-button.with-icon.focus.icon.color` *(deprecated)* | Elevated button with icon focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.with-icon.hover.icon.color` *(deprecated)* | Elevated button with icon hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.with-icon.icon.size` *(deprecated)* | Elevated button with icon icon size |  | 18dp |
| `md.comp.elevated-button.with-icon.pressed.icon.color` *(deprecated)* | Elevated button with icon pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.with-icon.disabled.icon.opacity` *(deprecated)* | Elevated button with icon disabled icon opacity |  | 0.38 |
| `md.comp.elevated-button.with-icon.icon.color` *(deprecated)* | Elevated button with icon icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.elevated-button.disabled.label-text.color` *(deprecated)* | Elevated button disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.elevated-button.focus.label-text.color` *(deprecated)* | Elevated button focus label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.hover.label-text.color` *(deprecated)* | Elevated button hover label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.label-text.font` *(deprecated)* | Elevated button label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.elevated-button.pressed.label-text.color` *(deprecated)* | Elevated button pressed label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.disabled.label-text.opacity` *(deprecated)* | Elevated button disabled label opacity |  | 0.38 |
| `md.comp.elevated-button.label-text.line-height` *(deprecated)* | Elevated button label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.elevated-button.label-text.size` *(deprecated)* | Elevated button label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.elevated-button.label-text.weight` *(deprecated)* | Elevated button label weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.elevated-button.label-text.tracking` *(deprecated)* | Elevated button label tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.elevated-button.label-text.type` *(deprecated)* | Label text type style | md.comp.elevated-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.elevated-button.label-text.color` *(deprecated)* | Elevated button label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.elevated-button.focus.state-layer.color` *(deprecated)* | Elevated button focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.hover.state-layer.color` *(deprecated)* | Elevated button hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.pressed.state-layer.color` *(deprecated)* | Elevated button pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.elevated-button.focus.state-layer.opacity` *(deprecated)* | Elevated button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.elevated-button.hover.state-layer.opacity` *(deprecated)* | Elevated button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.elevated-button.pressed.state-layer.opacity` *(deprecated)* | Elevated button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

#### Token set: [Deprecated] Button - Filled (`md.comp.filled-button`)

This token set is deprecated. Use `md.comp.button.filled` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-button.container.shape` *(deprecated)* | Filled button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.filled-button.disabled.container.elevation` *(deprecated)* | Filled button disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-button.dragged.container.elevation` *(deprecated)* | Filled button dragged container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.filled-button.focus.container.elevation` *(deprecated)* | Filled button focus container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-button.hover.container.elevation` *(deprecated)* | Filled button hover container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.filled-button.pressed.container.elevation` *(deprecated)* | Filled button pressed container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-button.container.height` *(deprecated)* | Filled button container height |  | 40dp |
| `md.comp.filled-button.disabled.container.color` *(deprecated)* | Filled button disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-button.container.elevation` *(deprecated)* | Filled button container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-button.disabled.container.opacity` *(deprecated)* | Filled button disabled container opacity |  | 0.12 |
| `md.comp.filled-button.container.shadow-color` *(deprecated)* | Filled button container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.filled-button.container.color` *(deprecated)* | Filled button container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-button.focus.indicator.color` *(deprecated)* | Filled button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.filled-button.focus.indicator.thickness` *(deprecated)* | Filled button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.filled-button.focus.indicator.outline.offset` *(deprecated)* | Filled button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-button.with-icon.disabled.icon.color` *(deprecated)* | Filled button with icon disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-button.with-icon.dragged.icon.color` *(deprecated)* | Filled button with icon dragged icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.with-icon.focus.icon.color` *(deprecated)* | Filled button with icon focus icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.with-icon.hover.icon.color` *(deprecated)* | Filled button with icon hover icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.with-icon.icon.size` *(deprecated)* | Filled button with icon icon size |  | 18dp |
| `md.comp.filled-button.with-icon.pressed.icon.color` *(deprecated)* | Filled button with icon pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.with-icon.disabled.icon.opacity` *(deprecated)* | Filled button with icon disabled icon opacity |  | 0.38 |
| `md.comp.filled-button.with-icon.icon.color` *(deprecated)* | Filled button with icon icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-button.disabled.label-text.color` *(deprecated)* | Filled button disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-button.dragged.label-text.color` *(deprecated)* | Filled button dragged label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.focus.label-text.color` *(deprecated)* | Filled button focus label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.hover.label-text.color` *(deprecated)* | Filled button hover label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.label-text.font` *(deprecated)* | Filled button label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.filled-button.pressed.label-text.color` *(deprecated)* | Filled button pressed label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.disabled.label-text.opacity` *(deprecated)* | Filled button disabled label opacity |  | 0.38 |
| `md.comp.filled-button.label-text.line-height` *(deprecated)* | Filled button label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.filled-button.label-text.size` *(deprecated)* | Filled button label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.filled-button.label-text.weight` *(deprecated)* | Filled button label weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.filled-button.label-text.tracking` *(deprecated)* | Filled button label tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.filled-button.label-text.type` *(deprecated)* | Label text type style | md.comp.filled-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.filled-button.label-text.color` *(deprecated)* | Filled button label color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-button.dragged.state-layer.color` *(deprecated)* | Filled button dragged state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.focus.state-layer.color` *(deprecated)* | Filled button focus state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.hover.state-layer.color` *(deprecated)* | Filled button hover state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.pressed.state-layer.color` *(deprecated)* | Filled button pressed state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-button.dragged.state-layer.opacity` *(deprecated)* | Filled button dragged state layer opacity | md.sys.state.dragged.state-layer-opacity | 0.16 |
| `md.comp.filled-button.focus.state-layer.opacity` *(deprecated)* | Filled button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.filled-button.hover.state-layer.opacity` *(deprecated)* | Filled button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.filled-button.pressed.state-layer.opacity` *(deprecated)* | Filled button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

#### Token set: [Deprecated] Button - Tonal (`md.comp.filled-tonal-button`)

This token set is deprecated. Use `md.comp.button.tonal` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-button.container.color` *(deprecated)* | Filled tonal button container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.filled-tonal-button.disabled.container.color` *(deprecated)* | Filled tonal button disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-tonal-button.focus.container.elevation` *(deprecated)* | Filled tonal button focus container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-tonal-button.hover.container.elevation` *(deprecated)* | Filled tonal button hover container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.filled-tonal-button.pressed.container.elevation` *(deprecated)* | Filled tonal button pressed container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-tonal-button.container.shadow-color` *(deprecated)* | Filled tonal button container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.filled-tonal-button.disabled.container.elevation` *(deprecated)* | Filled tonal button disabled container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-tonal-button.container.elevation` *(deprecated)* | Filled tonal button container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.filled-tonal-button.disabled.container.opacity` *(deprecated)* | Filled tonal button disabled container opacity |  | 0.12 |
| `md.comp.filled-tonal-button.container.height` *(deprecated)* | Filled tonal button container height |  | 40dp |
| `md.comp.filled-tonal-button.container.shape` *(deprecated)* | Filled tonal button container shape | md.sys.shape.corner.full | fully rounded (circular) |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-button.focus.indicator.color` *(deprecated)* | Filled tonal button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.filled-tonal-button.focus.indicator.thickness` *(deprecated)* | Filled tonal button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.filled-tonal-button.focus.indicator.outline.offset` *(deprecated)* | Filled tonal button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-button.with-icon.disabled.icon.color` *(deprecated)* | Filled tonal button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-tonal-button.with-icon.focus.icon.color` *(deprecated)* | Filled tonal button focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.with-icon.hover.icon.color` *(deprecated)* | Filled tonal button hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.with-icon.icon.color` *(deprecated)* | Filled tonal button icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.with-icon.pressed.icon.color` *(deprecated)* | Filled tonal button pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.with-icon.disabled.icon.opacity` *(deprecated)* | Filled tonal button disabled icon opacity |  | 0.38 |
| `md.comp.filled-tonal-button.with-icon.icon.size` *(deprecated)* | Filled tonal button icon size |  | 18dp |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-button.disabled.label-text.color` *(deprecated)* | Filled tonal button disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-tonal-button.focus.label-text.color` *(deprecated)* | Filled tonal button focus label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.hover.label-text.color` *(deprecated)* | Filled tonal button hover label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.label-text.color` *(deprecated)* | Filled tonal button label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.pressed.label-text.color` *(deprecated)* | Filled tonal button pressed label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.disabled.label-text.opacity` *(deprecated)* | Filled tonal button disabled label text opacity |  | 0.38 |
| `md.comp.filled-tonal-button.label-text.font` *(deprecated)* | Filled tonal button label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.filled-tonal-button.label-text.line-height` *(deprecated)* | Filled tonal button label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.filled-tonal-button.label-text.size` *(deprecated)* | Filled tonal button label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.filled-tonal-button.label-text.tracking` *(deprecated)* | Filled tonal button label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.filled-tonal-button.label-text.weight` *(deprecated)* | Filled tonal button label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.filled-tonal-button.label-text.type` *(deprecated)* | Filled tonal button label text type | md.comp.filled-tonal-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-button.focus.state-layer.color` *(deprecated)* | Filled tonal button focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.hover.state-layer.color` *(deprecated)* | Filled tonal button hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.pressed.state-layer.color` *(deprecated)* | Filled tonal button pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-button.focus.state-layer.opacity` *(deprecated)* | Filled tonal button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.filled-tonal-button.hover.state-layer.opacity` *(deprecated)* | Filled tonal button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.filled-tonal-button.pressed.state-layer.opacity` *(deprecated)* | Filled tonal button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

#### Token set: [Deprecated] Button – Outlined (`md.comp.outlined-button`)

This token set is deprecated. Use `md.comp.button.outlined` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.container.shape` *(deprecated)* | Outlined button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.outlined-button.container.height` *(deprecated)* | Outlined button container height |  | 40dp |
| `md.comp.outlined-button.container.elevation` *(deprecated)* | Outlined button container elevation | md.sys.elevation.level0 | 0dp |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.focus.indicator.color` *(deprecated)* | Outlined button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.outlined-button.focus.indicator.thickness` *(deprecated)* | Outlined button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.outlined-button.focus.indicator.outline.offset` *(deprecated)* | Outlined button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.with-icon.disabled.icon.color` *(deprecated)* | Outlined button with icon disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-button.with-icon.focus.icon.color` *(deprecated)* | Outlined button with icon focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.with-icon.hover.icon.color` *(deprecated)* | Outlined button with icon hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.with-icon.icon.size` *(deprecated)* | Outlined button with icon icon size |  | 18dp |
| `md.comp.outlined-button.with-icon.pressed.icon.color` *(deprecated)* | Outlined button with icon pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.with-icon.disabled.icon.opacity` *(deprecated)* | Outlined button with icon disabled icon opacity |  | 0.38 |
| `md.comp.outlined-button.with-icon.icon.color` *(deprecated)* | Outlined button with icon icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.disabled.label-text.color` *(deprecated)* | Outlined button disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-button.focus.label-text.color` *(deprecated)* | Outlined button focus label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.hover.label-text.color` *(deprecated)* | Outlined button hover label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.label-text.font` *(deprecated)* | Outlined button label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.outlined-button.pressed.label-text.color` *(deprecated)* | Outlined button pressed label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.disabled.label-text.opacity` *(deprecated)* | Outlined button disabled label opacity |  | 0.38 |
| `md.comp.outlined-button.label-text.line-height` *(deprecated)* | Outlined button label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.outlined-button.label-text.size` *(deprecated)* | Outlined button label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.outlined-button.label-text.weight` *(deprecated)* | Outlined button label weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.outlined-button.label-text.tracking` *(deprecated)* | Outlined button label tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.outlined-button.label-text.type` *(deprecated)* | Type style | md.comp.outlined-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.outlined-button.label-text.color` *(deprecated)* | Outlined button label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Outline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.disabled.outline.color` *(deprecated)* | Outlined button disabled outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-button.focus.outline.color` *(deprecated)* | Outlined button focus outline color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.hover.outline.color` *(deprecated)* | Outlined button hover outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.outlined-button.outline.color` *(deprecated)* | Outlined button outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.outlined-button.pressed.outline.color` *(deprecated)* | Outlined button pressed outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.outlined-button.disabled.outline.opacity` *(deprecated)* | Outlined button disabled outline opacity |  | 0.12 |
| `md.comp.outlined-button.outline.width` *(deprecated)* | Outlined button outline width |  | 1dp |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-button.focus.state-layer.color` *(deprecated)* | Outlined button focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.hover.state-layer.color` *(deprecated)* | Outlined button hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.pressed.state-layer.color` *(deprecated)* | Outlined button pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.outlined-button.focus.state-layer.opacity` *(deprecated)* | Outlined button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.outlined-button.hover.state-layer.opacity` *(deprecated)* | Outlined button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.outlined-button.pressed.state-layer.opacity` *(deprecated)* | Outlined button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

#### Token set: [Deprecated] Button - Text (`md.comp.text-button`)

This token set is deprecated. Use `md.comp.button.text` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.text-button.container.shape` *(deprecated)* | Text button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.text-button.container.height` *(deprecated)* | Text button container height |  | 40dp |
| `md.comp.text-button.container.elevation` *(deprecated)* | Text button container elevation | md.sys.elevation.level0 | 0dp |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.text-button.focus.indicator.color` *(deprecated)* | Text button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.text-button.focus.indicator.thickness` *(deprecated)* | Text button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.text-button.focus.indicator.outline.offset` *(deprecated)* | Text button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.text-button.with-icon.disabled.icon.color` *(deprecated)* | Text button with icon disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.text-button.with-icon.focus.icon.color` *(deprecated)* | Text button with icon focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.with-icon.hover.icon.color` *(deprecated)* | Text button with icon hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.with-icon.icon.size` *(deprecated)* | Text button with icon icon size |  | 18dp |
| `md.comp.text-button.with-icon.pressed.icon.color` *(deprecated)* | Text button with icon pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.with-icon.disabled.icon.opacity` *(deprecated)* | Text button with icon disabled icon opacity |  | 0.38 |
| `md.comp.text-button.with-icon.icon.color` *(deprecated)* | Text button with icon icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.text-button.disabled.label-text.color` *(deprecated)* | Text button disabled label color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.text-button.focus.label-text.color` *(deprecated)* | Text button focus label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.hover.label-text.color` *(deprecated)* | Text button hover label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.label-text.font` *(deprecated)* | Text button label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.text-button.pressed.label-text.color` *(deprecated)* | Text button pressed label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.disabled.label-text.opacity` *(deprecated)* | Text button disabled label opacity |  | 0.38 |
| `md.comp.text-button.label-text.line-height` *(deprecated)* | Text button label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.text-button.label-text.size` *(deprecated)* | Text button label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.text-button.label-text.weight` *(deprecated)* | Text button label weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.text-button.label-text.tracking` *(deprecated)* | Text button label tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.text-button.label-text.type` *(deprecated)* | Type style | md.comp.text-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.text-button.label-text.color` *(deprecated)* | Text button label color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.text-button.focus.state-layer.color` *(deprecated)* | Text button focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.hover.state-layer.color` *(deprecated)* | Text button hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.pressed.state-layer.color` *(deprecated)* | Text button pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.text-button.focus.state-layer.opacity` *(deprecated)* | Text button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.text-button.hover.state-layer.opacity` *(deprecated)* | Text button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.text-button.pressed.state-layer.opacity` *(deprecated)* | Text button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
