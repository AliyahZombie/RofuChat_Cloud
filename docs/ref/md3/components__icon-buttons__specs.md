Source: https://m3.material.io/components/icon-buttons/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:05:22.141Z

# Icon buttons — Specs

## Variants

*[Image: Side by side view of default and toggle icon buttons.]*

1. Default icon button
2. Toggle icon button

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Default | Available | Available |
| Toggle (selection) | Available | Available |

## Configurations

*[Image: Side by side view of size, shape, color, and width variations.]*

1. Five sizes
2. Two shapes
3. Four color styles
4. Three widths

| Category | Options | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Size | Small (default) | Available | Available |
| XS, M, L, XL | -- | Available |
| Shape | Round (default) | Available | Available |
| Square | -- | Available |
| Color | Filled (default), tonal, outlined, standard | Available | Available |
| Width | Default | Available | Available |
| Narrow, wide | -- | Available |

## Tokens & specs

Icon button token sets are organized by common tokens, color, and size. Select the token set from the table’s menu. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: Icon button - Color - Filled (`md.comp.icon-button.filled`)

For filled icon buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.filled.container.color` | Icon button filled container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.icon-button.filled.unselected.container.color` | Icon button filled container color - toggle (unselected) | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.icon-button.filled.selected.container.color` | Icon button filled container color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.icon-button.filled.icon.color` | Icon button filled icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.icon.color` | Icon button filled icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.icon.color` | Icon button filled icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.filled.disabled.container.color` | Icon button filled disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.filled.disabled.container.opacity` | Icon button filled disabled container opacity |  | 0.1 |
| `md.comp.icon-button.filled.disabled.icon.color` | Icon button filled disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.filled.disabled.icon.opacity` | Icon button filled disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.filled.hovered.state-layer.color` | Icon button filled hovered state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.hovered.state-layer.color` | Icon button filled hovered state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.hovered.state-layer.color` | Icon button filled hovered state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.hovered.state-layer.opacity` | Icon button filled hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.icon-button.filled.hovered.icon.color` | Icon button filled hovered icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.hovered.icon.color` | Icon button filled hovered icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.hovered.icon.color` | Icon button filled hovered icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.filled.focused.state-layer.color` | Icon button filled focused state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.focused.state-layer.color` | Icon button filled focused state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.focused.state-layer.color` | Icon button filled focused state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.focused.state-layer.opacity` | Icon button filled focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.icon-button.filled.focused.icon.color` | Icon button filled focused icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.focused.icon.color` | Icon button filled focused icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.focused.icon.color` | Icon button filled focused icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.filled.pressed.state-layer.color` | Icon button filled pressed state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.pressed.state-layer.color` | Icon button filled pressed state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.pressed.state-layer.color` | Icon button filled pressed state layer color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.pressed.state-layer.opacity` | Icon button filled pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.icon-button.filled.pressed.icon.color` | Icon button filled pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.icon-button.filled.unselected.pressed.icon.color` | Icon button filled pressed icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.filled.selected.pressed.icon.color` | Icon button filled pressed icon color - toggle (selected) | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

#### Token set: Icon button - Color - Tonal (`md.comp.icon-button.tonal`)

For tonal icon buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.tonal.container.color` | Icon button tonal container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.icon-button.tonal.unselected.container.color` | Icon button tonal container color - toggle (unselected) | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.icon-button.tonal.selected.container.color` | Icon button tonal container color - toggle (selected) | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.icon-button.tonal.icon.color` | Icon button tonal icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.icon.color` | Icon button tonal icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.icon.color` | Icon button tonal icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.tonal.disabled.container.color` | Icon button tonal disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.tonal.disabled.container.opacity` | Icon button tonal disabled container opacity |  | 0.1 |
| `md.comp.icon-button.tonal.disabled.icon.color` | Icon button tonal disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.tonal.disabled.icon.opacity` | Icon button tonal disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.tonal.hovered.state-layer.color` | Icon button tonal hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.hovered.state-layer.color` | Icon button tonal hovered state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.hovered.state-layer.color` | Icon button tonal hovered state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.icon-button.tonal.hovered.state-layer.opacity` | Icon button tonal hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.icon-button.tonal.hovered.icon.color` | Icon button tonal hovered icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.hovered.icon.color` | Icon button tonal hovered icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.hovered.icon.color` | Icon button tonal hovered icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.tonal.focused.state-layer.color` | Icon button tonal focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.focused.state-layer.color` | Icon button tonal focused state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.focused.state-layer.color` | Icon button tonal focused state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.icon-button.tonal.focused.state-layer.opacity` | Icon button tonal focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.icon-button.tonal.focused.icon.color` | Icon button tonal focused icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.focused.icon.color` | Icon button tonal focused icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.focused.icon.color` | Icon button tonal focused icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.tonal.pressed.state-layer.color` | Icon button tonal pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.pressed.state-layer.color` | Icon button tonal pressed state layer color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.pressed.state-layer.color` | Icon button tonal pressed state layer color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.icon-button.tonal.pressed.state-layer.opacity` | Icon button tonal pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.icon-button.tonal.pressed.icon.color` | Icon button tonal pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.unselected.pressed.icon.color` | Icon button tonal pressed icon color - toggle (unselected) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.icon-button.tonal.selected.pressed.icon.color` | Icon button tonal pressed icon color - toggle (selected) | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

#### Token set: Icon button - Color - Outlined (`md.comp.icon-button.outlined`)

For outlined icon buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.outlined.outline.color` | Icon button outlined color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.icon-button.outlined.unselected.outline.color` | Icon button outlined color - toggle (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.icon-button.outlined.selected.container.color` | Icon button outlined container color - toggle (selected) | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |
| `md.comp.icon-button.outlined.icon.color` | Icon button outlined icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.icon.color` | Icon button outlined icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.icon.color` | Icon button outlined icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.outlined.disabled.outline.color` | Icon button outlined disabled outline color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.icon-button.outlined.unselected.disabled.outline.color` | Icon button outlined disabled outline color (unselected) | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |
| `md.comp.icon-button.outlined.selected.disabled.container.color` | Icon button outlined disabled container color (selected) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.outlined.selected.disabled.container.opacity` | Icon button outlined disabled container opacity (selected) |  | 0.1 |
| `md.comp.icon-button.outlined.disabled.icon.color` | Icon button outlined disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.outlined.disabled.icon.opacity` | Icon button outlined disabled icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.outlined.hovered.state-layer.color` | Icon button outlined hovered state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.hovered.state-layer.color` | Icon button outlined hovered state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.hovered.state-layer.color` | Icon button outlined hovered state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.icon-button.outlined.hovered.state-layer.opacity` | Icon button outlined hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.icon-button.outlined.hovered.icon.color` | Icon button outlined hovered icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.hovered.icon.color` | Icon button outlined hovered icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.hovered.icon.color` | Icon button outlined hovered icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.outlined.focused.state-layer.color` | Icon button outlined focused state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.focused.state-layer.color` | Icon button outlined focused state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.focused.state-layer.color` | Icon button outlined focused state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.icon-button.outlined.focused.state-layer.opacity` | Icon button outlined focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.icon-button.outlined.focused.icon.color` | Icon button outlined focused icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.focused.icon.color` | Icon button outlined focused icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.focused.icon.color` | Icon button outlined focused icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.outlined.pressed.state-layer.color` | Icon button outlined pressed state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.pressed.state-layer.color` | Icon button outlined pressed state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.pressed.state-layer.color` | Icon button outlined pressed state layer color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.icon-button.outlined.pressed.state-layer.opacity` | Icon button outlined pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.icon-button.outlined.pressed.icon.color` | Icon button outlined pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.unselected.pressed.icon.color` | Icon button outlined pressed icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.outlined.selected.pressed.icon.color` | Icon button outlined pressed icon color - toggle (selected) | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

#### Token set: Icon button - Color - Standard (`md.comp.icon-button.standard`)

For standard icon buttons.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.standard.icon.color` | Icon button icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.icon.color` | Icon button icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.icon.color` | Icon button icon color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.standard.disabled.icon.color` | Icon button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.icon-button.standard.disabled.icon.opacity` | Icon button disabled opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.standard.hovered.state-layer.color` | Icon button hovered state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.hovered.state-layer.color` | Icon button hovered state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.hovered.state-layer.color` | Icon button hovered state layer color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.icon-button.standard.hovered.state-layer.opacity` | Icon button hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.icon-button.standard.hovered.icon.color` | Icon button hovered icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.hovered.icon.color` | Icon button hovered icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.hovered.icon.color` | Icon button hovered icon color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.standard.focused.state-layer.color` | Icon button focused state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.focused.state-layer.color` | Icon button focused state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.focused.state-layer.color` | Icon button focused state layer color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.icon-button.standard.focused.state-layer.opacity` | Icon button focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.icon-button.standard.focused.icon.color` | Icon button focused icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.focused.icon.color` | Icon button focused icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.focused.icon.color` | Icon button focused icon color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.standard.pressed.state-layer.color` | Icon button pressed state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.pressed.state-layer.color` | Icon button pressed state layer color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.pressed.state-layer.color` | Icon button pressed state layer color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.icon-button.standard.pressed.state-layer.opacity` | Icon button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.icon-button.standard.pressed.icon.color` | Icon button pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.unselected.pressed.icon.color` | Icon button pressed icon color - toggle (unselected) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.icon-button.standard.selected.pressed.icon.color` | Icon button pressed icon color - toggle (selected) | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

#### Token set: Icon button - Size - Xsmall (`md.comp.icon-button.xsmall`)

For XS icon buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.xsmall.container.height` | Icon button xsmall container height |  | 32dp |
| `md.comp.icon-button.xsmall.icon.size` | Icon button xsmall icon size |  | 20dp |
| `md.comp.icon-button.xsmall.narrow.leading-space` | Icon button xsmall narrow leading space | md.sys.measurement.space50 | 4dp |
| `md.comp.icon-button.xsmall.narrow.trailing-space` | Icon button xsmall narrow trailing space | md.sys.measurement.space50 | 4dp |
| `md.comp.icon-button.xsmall.default.leading-space` | Icon button xsmall default leading space | md.sys.measurement.space75 | 6dp |
| `md.comp.icon-button.xsmall.default.trailing-space` | Icon button xsmall default trailing space | md.sys.measurement.space75 | 6dp |
| `md.comp.icon-button.xsmall.wide.leading-space` | Icon button xsmall wide leading space | md.sys.measurement.space125 | 10dp |
| `md.comp.icon-button.xsmall.wide.trailing-space` | Icon button xsmall wide trailing space | md.sys.measurement.space125 | 10dp |
| `md.comp.icon-button.xsmall.container.shape.round` | Icon button xsmall container shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.icon-button.xsmall.container.shape.square` | Icon button xsmall container shape square | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.icon-button.xsmall.outlined.outline.width` | Icon button xsmall outline width |  | 1dp |
| `md.comp.icon-button.xsmall.pressed.container.shape` | Icon button xsmall shape pressed morph | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.icon-button.xsmall.pressed.container.corner-size.motion.spring.damping` | Icon button xsmall shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.icon-button.xsmall.pressed.container.corner-size.motion.spring.stiffness` | Icon button xsmall shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.icon-button.xsmall.selected.container.shape.round` | Icon button xsmall selected container shape round | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.icon-button.xsmall.selected.container.shape.square` | Icon button xsmall selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Icon button - Size - Small (`md.comp.icon-button.small`)

For small icon buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.small.container.height` | Icon button small container height |  | 40dp |
| `md.comp.icon-button.small.icon.size` | Icon button small icon size |  | 24dp |
| `md.comp.icon-button.small.narrow.leading-space` | Icon button small narrow leading space | md.sys.measurement.space50 | 4dp |
| `md.comp.icon-button.small.narrow.trailing-space` | Icon button small narrow trailing space | md.sys.measurement.space50 | 4dp |
| `md.comp.icon-button.small.default.leading-space` | Icon button small default leading space | md.sys.measurement.space100 | 8dp |
| `md.comp.icon-button.small.default.trailing-space` | Icon button small default trailing space | md.sys.measurement.space100 | 8dp |
| `md.comp.icon-button.small.wide.leading-space` | Icon button small wide leading space | md.sys.measurement.space175 | 14dp |
| `md.comp.icon-button.small.wide.trailing-space` | Icon button small wide trailing space | md.sys.measurement.space175 | 14dp |
| `md.comp.icon-button.small.container.shape.round` | Icon button small container shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.icon-button.small.container.shape.square` | Icon button small container shape square | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.icon-button.small.outlined.outline.width` | Icon button small outline width |  | 1dp |
| `md.comp.icon-button.small.pressed.container.shape` | Icon button small shape pressed morph | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.icon-button.small.pressed.container.corner-size.motion.spring.damping` | Icon button small shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.icon-button.small.pressed.container.corner-size.motion.spring.stiffness` | Icon button small shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.icon-button.small.selected.container.shape.round` | Icon button small selected container shape round | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.icon-button.small.selected.container.shape.square` | Icon button small selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Icon button - Size - Medium (`md.comp.icon-button.medium`)

For medium icon buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.medium.container.height` | Icon button medium container height |  | 56dp |
| `md.comp.icon-button.medium.icon.size` | Icon button medium icon size |  | 24dp |
| `md.comp.icon-button.medium.narrow.leading-space` | Icon button medium narrow leading space | md.sys.measurement.space150 | 12dp |
| `md.comp.icon-button.medium.narrow.trailing-space` | Icon button medium narrow trailing space | md.sys.measurement.space150 | 12dp |
| `md.comp.icon-button.medium.default.leading-space` | Icon button medium default leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.icon-button.medium.default.trailing-space` | Icon button medium default trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.icon-button.medium.wide.leading-space` | Icon button medium wide leading space | md.sys.measurement.space300 | 24dp |
| `md.comp.icon-button.medium.wide.trailing-space` | Icon button medium wide trailing space | md.sys.measurement.space300 | 24dp |
| `md.comp.icon-button.medium.container.shape.round` | Icon button medium container shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.icon-button.medium.container.shape.square` | Icon button medium container shape square | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.icon-button.medium.outlined.outline.width` | Icon button medium outline width |  | 1dp |
| `md.comp.icon-button.medium.pressed.container.shape` | Icon button medium shape pressed morph | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.icon-button.medium.pressed.container.corner-size.motion.spring.damping` | Icon button medium shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.icon-button.medium.pressed.container.corner-size.motion.spring.stiffness` | Icon button medium shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.icon-button.medium.selected.container.shape.round` | Icon button medium selected container shape round | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.icon-button.medium.selected.container.shape.square` | Icon button medium selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Icon button - Size - Large (`md.comp.icon-button.large`)

For large icon buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.large.container.height` | Icon button large container height |  | 96dp |
| `md.comp.icon-button.large.icon.size` | Icon button large icon size |  | 32dp |
| `md.comp.icon-button.large.narrow.leading-space` | Icon button large narrow leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.icon-button.large.narrow.trailing-space` | Icon button large narrow trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.icon-button.large.default.leading-space` | Icon button large default leading space | md.sys.measurement.space400 | 32dp |
| `md.comp.icon-button.large.default.trailing-space` | Icon button large default trailing space | md.sys.measurement.space400 | 32dp |
| `md.comp.icon-button.large.wide.leading-space` | Icon button large wide leading space | md.sys.measurement.space600 | 48dp |
| `md.comp.icon-button.large.wide.trailing-space` | Icon button large wide trailing space | md.sys.measurement.space600 | 48dp |
| `md.comp.icon-button.large.container.shape.round` | Icon button large container shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.icon-button.large.container.shape.square` | Icon button large container shape square | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.icon-button.large.outlined.outline.width` | Icon button large outline width |  | 2dp |
| `md.comp.icon-button.large.pressed.container.shape` | Icon button large shape pressed morph | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.icon-button.large.pressed.container.corner-size.motion.spring.damping` | Icon button large shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.icon-button.large.pressed.container.corner-size.motion.spring.stiffness` | Icon button large shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.icon-button.large.selected.container.shape.round` | Icon button large selected container shape round | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.icon-button.large.selected.container.shape.square` | Icon button large selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Icon button - Size - Xlarge (`md.comp.icon-button.xlarge`)

For XL icon buttons.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.icon-button.xlarge.container.height` | Icon button xlarge container height |  | 136dp |
| `md.comp.icon-button.xlarge.icon.size` | Icon button xlarge icon size |  | 40dp |
| `md.comp.icon-button.xlarge.narrow.leading-space` | Icon button xlarge narrow leading space | md.sys.measurement.space400 | 32dp |
| `md.comp.icon-button.xlarge.narrow.trailing-space` | Icon button xlarge narrow trailing space | md.sys.measurement.space400 | 32dp |
| `md.comp.icon-button.xlarge.default.leading-space` | Icon button xlarge default leading space | md.sys.measurement.space600 | 48dp |
| `md.comp.icon-button.xlarge.default.trailing-space` | Icon button xlarge default trailing space | md.sys.measurement.space600 | 48dp |
| `md.comp.icon-button.xlarge.wide.leading-space` | Icon button xlarge wide leading space | md.sys.measurement.space900 | 72dp |
| `md.comp.icon-button.xlarge.wide.trailing-space` | Icon button xlarge wide trailing space | md.sys.measurement.space900 | 72dp |
| `md.comp.icon-button.xlarge.container.shape.round` | Icon button xlarge container shape round | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.icon-button.xlarge.container.shape.square` | Icon button xlarge container shape square | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.icon-button.xlarge.outlined.outline.width` | Icon button xlarge outline width |  | 3dp |
| `md.comp.icon-button.xlarge.pressed.container.shape` | Icon button xlarge shape pressed morph | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.icon-button.xlarge.pressed.container.corner-size.motion.spring.damping` | Icon button xlarge shape spring animation damping | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.icon-button.xlarge.pressed.container.corner-size.motion.spring.stiffness` | Icon button xlarge shape spring animation stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.icon-button.xlarge.selected.container.shape.round` | Icon button xlarge selected container shape round | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.icon-button.xlarge.selected.container.shape.square` | Icon button xlarge selected container shape square | md.sys.shape.corner.full | fully rounded (circular) |

## Anatomy

*[Image: Diagram indicating anatomy of filled icon button.]*

1. Icon
2. Container

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value.

There are four built-in color styles: filled, tonal, outlined, and standard. Default and toggle buttons use different color roles per style.

star

Note:

These color roles were chosen to create design coherence and familiarity. Other color roles can be used as long as the container and text have a 3:1 contrast ratio. For example, tertiary and on tertiary.

*[Image: Color roles of default and toggle buttons in 4 visual styles.]*

A: Filled, B: Tonal, C: Outlined, D: Standard

1. Default
2. Toggle, unselected
3. Toggle, selected

|  | 1. Default | 2. Toggle, unselected | 3. Toggle, selected |
| --- | --- | --- | --- |
| Filled container  Filled icon | Primary  On primary | Surface container  On surface variant | Primary  On primary |
| Tonal container  Tonal icon | Secondary container  On secondary container | Secondary container  On secondary container | Secondary  On secondary |
| Outlined container  Outlined icon | Outline variant (outline)  On surface variant | Outline variant (outline)  On surface variant | Inverse surface  Inverse on surface |
| Standard icon | On surface variant | On surface variant | Primary |

## States

States are visual representations used to communicate the status of a component or interactive element. State layers slightly change button color. Disabled states have different base colors. [View tokens for details](https://m3.material.io/foundations/design-tokens/overview)

### Filled button states

#### Default

*[Image: 5 states of filled icon button.]*

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

#### Toggle

*[Image: 5 states of filled toggle icon button.]*

A: Unselected. B: Selected

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

### Tonal button states

#### Default

*[Image: 5 states of tonal icon button.]*

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

#### Toggle

*[Image: 5 states of tonal toggle icon button.]*

A: Unselected. B: Selected

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

### Outlined button states

#### Default

*[Image: 5 states of outlined icon button.]*

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

#### Toggle

*[Image: 5 states of outlined toggle icon button.]*

A: Unselected. B: Selected

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

### Standard icon button states

The standard icon button’s container is invisible at rest, but visible when the state layer is applied.

#### Default

*[Image: 5 states of standard icon button.]*

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

#### Toggle

*[Image: 5 states of standard toggle icon button.]*

A: Unselected. B: Selected

1. Enabled
2. Disabled (10% state layer)
3. Hovered (8% state layer)
4. Focused (10% state layer)
5. Pressed (10% state layer)

## Shape morph

### Pressed state

While pressed, icon buttons can morph to become more square.

Both round and square icon buttons should have the same pressed shape radius.  
  
The corner radius value differs for each button size. [See full icon button corner measurements](https://m3.material.io/components/icon-buttons/specs#b3df1f02-d313-44e9-9542-37f7e0e24dc7)

*[Image: Shape changes for round and square icon buttons in 3 states.]*

A. Round, B. Square

1. Enabled
2. Hovered
3. Pressed

### When selected

In addition to changing shape when pressed, toggle icon buttons also change the resting shape from round (unselected) to square (selected) by default.  
  
If the resting shape is square, the selected shape should be round.

*[Image: Shape changes for round and square toggle icon buttons in 3 states.]*

A. Round, B. Square

1. Enabled
2. Hovered
3. Pressed
4. Selected

## Measurements

*[Image: Diagram of 5 sizes of icon buttons in 4 widths.]*

A. Extra small  B. Small  C. Medium  D. Large  E. Extra large

1. Icon size
2. Default width size
3. Narrow width size
4. Wide width size

### Target sizes

Extra small and small icon buttons must have a target size of 48x48dp or larger to be accessible.

*[Image: Diagram of target sizes.]*

A. Extra small icon button size  B. Small icon button size

1. Narrow width
2. Default width
3. Wide width

### Button corner radius

*[Image: Diagram of icon button corner radius.]*

|  | XS | S | M | L | XL |
| --- | --- | --- | --- | --- | --- |
| A. Round button | Full | Full | Full | Full | Full |
| B. Square button | 12dp | 12dp | 16dp | 28dp | 28dp |
| C. Pressed state | 8dp | 8dp | 12dp | 16dp | 16dp |

## Baseline tokens

Use the table's menu to select a token set. Filled, tonal, and outlined icon button tokens are now deprecated in favor of the new token sets. All other tokens are still available in the module at the top of the page.

#### Token set: [Deprecated] Icon button - Filled (`md.comp.filled-icon-button`)

This token set is deprecated. Use `md.comp.icon-button.filled` instead.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-icon-button.container.size` *(deprecated)* | Filled icon button container size |  | 40dp |
| `md.comp.filled-icon-button.disabled.container.color` *(deprecated)* | Filled icon button disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-icon-button.container.width` *(deprecated)* | Filled icon button container width |  | 40dp |
| `md.comp.filled-icon-button.disabled.container.opacity` *(deprecated)* | Filled icon button disabled container opacity |  | 0.12 |
| `md.comp.filled-icon-button.container.height` *(deprecated)* | Filled icon button container height |  | 40dp |
| `md.comp.filled-icon-button.container.shape` *(deprecated)* | Filled icon button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.filled-icon-button.container.color` *(deprecated)* | Filled icon button container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.unselected.container.color` *(deprecated)* | Filled icon button unselected container color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.filled-icon-button.selected.container.color` *(deprecated)* | Filled icon button selected container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-icon-button.focus.indicator.color` *(deprecated)* | Filled icon button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.filled-icon-button.focus.indicator.thickness` *(deprecated)* | Filled icon button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.filled-icon-button.focus.indicator.outline.offset` *(deprecated)* | Filled icon button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-icon-button.disabled.icon.color` *(deprecated)* | Filled icon button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-icon-button.focus.icon.color` *(deprecated)* | Filled icon button focus icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.hover.icon.color` *(deprecated)* | Filled icon button hover icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.icon.size` *(deprecated)* | Filled icon button icon size |  | 24dp |
| `md.comp.filled-icon-button.pressed.icon.color` *(deprecated)* | Filled icon button pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.disabled.icon.opacity` *(deprecated)* | Filled icon button disabled icon color |  | 0.38 |
| `md.comp.filled-icon-button.icon.color` *(deprecated)* | Filled icon button icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.unselected.focus.icon.color` *(deprecated)* | Filled icon button toggle unselected focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.unselected.hover.icon.color` *(deprecated)* | Filled icon button toggle unselected hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.unselected.pressed.icon.color` *(deprecated)* | Filled icon button toggle unselected pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.selected.focus.icon.color` *(deprecated)* | Filled icon button toggle selected focus icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.selected.hover.icon.color` *(deprecated)* | Filled icon button toggle selected hover icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.selected.pressed.icon.color` *(deprecated)* | Filled icon button toggle selected pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.unselected.icon.color` *(deprecated)* | Filled icon button toggle unselected icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.selected.icon.color` *(deprecated)* | Filled icon button toggle selected icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-icon-button.focus.state-layer.opacity` *(deprecated)* | Filled icon button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.filled-icon-button.hover.state-layer.opacity` *(deprecated)* | Filled icon button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.filled-icon-button.pressed.state-layer.opacity` *(deprecated)* | Filled icon button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.filled-icon-button.focus.state-layer.color` *(deprecated)* | Filled icon button focus state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.hover.state-layer.color` *(deprecated)* | Filled icon button hover state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.pressed.state-layer.color` *(deprecated)* | Filled icon button pressed state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.unselected.focus.state-layer.color` *(deprecated)* | Filled icon button toggle unselected focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.unselected.hover.state-layer.color` *(deprecated)* | Filled icon button hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.unselected.pressed.state-layer.color` *(deprecated)* | Filled icon button toggle unselected pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.filled-icon-button.toggle.selected.focus.state-layer.color` *(deprecated)* | Filled icon button toggle selected focus state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.selected.hover.state-layer.color` *(deprecated)* | Filled icon button hover state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.filled-icon-button.toggle.selected.pressed.state-layer.color` *(deprecated)* | Filled icon button toggle selected pressed state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

#### Token set: [Deprecated] Icon button - Tonal (`md.comp.filled-tonal-icon-button`)

This token set is deprecated. Use `md.comp.icon-button.tonal` instead.

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-icon-button.pressed.icon.color` *(deprecated)* | Filled tonal icon button pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.unselected.pressed.icon.color` *(deprecated)* | Filled tonal icon button toggle unselected pressed icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.selected.pressed.icon.color` *(deprecated)* | Filled tonal icon button toggle selected pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-icon-button.container.size` *(deprecated)* | Filled tonal icon button container size |  | 40dp |
| `md.comp.filled-tonal-icon-button.disabled.container.color` *(deprecated)* | Filled tonal icon button disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-tonal-icon-button.container.width` *(deprecated)* | Filled tonal icon button container width |  | 40dp |
| `md.comp.filled-tonal-icon-button.disabled.container.opacity` *(deprecated)* | Filled tonal icon button disabled container opacity |  | 0.12 |
| `md.comp.filled-tonal-icon-button.container.height` *(deprecated)* | Filled tonal icon button container height |  | 40dp |
| `md.comp.filled-tonal-icon-button.container.shape` *(deprecated)* | Filled tonal icon button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.filled-tonal-icon-button.container.color` *(deprecated)* | Filled tonal icon button container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.filled-tonal-icon-button.unselected.container.color` *(deprecated)* | Filled tonal icon button unselected container color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.filled-tonal-icon-button.selected.container.color` *(deprecated)* | Filled tonal icon button selected container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-icon-button.focus.indicator.color` *(deprecated)* | Filled tonal icon button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.filled-tonal-icon-button.focus.indicator.thickness` *(deprecated)* | Filled tonal icon button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.filled-tonal-icon-button.focus.indicator.outline.offset` *(deprecated)* | Filled tonal icon button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-icon-button.disabled.icon.color` *(deprecated)* | Filled tonal icon button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.filled-tonal-icon-button.focus.icon.color` *(deprecated)* | Filled tonal icon button focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.hover.icon.color` *(deprecated)* | Filled tonal icon button hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.icon.size` *(deprecated)* | Filled tonal icon button icon size |  | 24dp |
| `md.comp.filled-tonal-icon-button.disabled.icon.opacity` *(deprecated)* | Filled tonal icon button disabled icon opacity |  | 0.38 |
| `md.comp.filled-tonal-icon-button.icon.color` *(deprecated)* | Filled tonal icon button icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.unselected.focus.icon.color` *(deprecated)* | Filled tonal icon button toggle unselected focus icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.unselected.hover.icon.color` *(deprecated)* | Filled tonal icon button toggle unselected hover icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.selected.focus.icon.color` *(deprecated)* | Filled tonal icon button toggle selected focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.selected.hover.icon.color` *(deprecated)* | Filled tonal icon button toggle selected hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.unselected.icon.color` *(deprecated)* | Filled tonal icon button toggle unselected icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.selected.icon.color` *(deprecated)* | Filled tonal icon button toggle selected icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.filled-tonal-icon-button.focus.state-layer.opacity` *(deprecated)* | Filled tonal icon button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.filled-tonal-icon-button.hover.state-layer.color` *(deprecated)* | Filled tonal icon button hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.pressed.state-layer.opacity` *(deprecated)* | Filled tonal icon button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.filled-tonal-icon-button.focus.state-layer.color` *(deprecated)* | Filled tonal icon button focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.pressed.state-layer.color` *(deprecated)* | Filled tonal icon button pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.unselected.hover.state-layer.color` *(deprecated)* | Filled tonal icon button toggle unselected hover state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.selected.hover.state-layer.color` *(deprecated)* | Filled tonal icon button toggle selected hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.unselected.focus.state-layer.color` *(deprecated)* | Filled tonal icon button toggle unselected focus state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.toggle.unselected.pressed.state-layer.color` *(deprecated)* | Filled tonal icon button toggle unselected pressed state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.filled-tonal-icon-button.hover.state-layer.opacity` *(deprecated)* | Filled tonal icon button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.filled-tonal-icon-button.toggle.selected.focus.state-layer.color` *(deprecated)* | Filled tonal icon button toggle selected focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.filled-tonal-icon-button.toggle.selected.pressed.state-layer.color` *(deprecated)* | Filled tonal icon button toggle selected pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: [Deprecated] Icon button - Outlined (`md.outlined-icon-button`)

This token set is deprecated. Use `md.comp.icon-button.outlined` instead.

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.unselected.pressed.icon.color` *(deprecated)* | Outlined icon button unselected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.selected.pressed.icon.color` *(deprecated)* | Outlined icon button selected pressed icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.container.size` *(deprecated)* | Outlined icon button container size |  | 40dp |
| `md.outlined-icon-button.disabled.selected.container.color` *(deprecated)* | Outlined icon button disabled selected container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.container.width` *(deprecated)* | Outlined icon button container width |  | 40dp |
| `md.outlined-icon-button.disabled.selected.container.opacity` *(deprecated)* | Outlined icon button disabled selected container opacity |  | 0.12 |
| `md.outlined-icon-button.container.height` *(deprecated)* | Outlined icon button container height |  | 40dp |
| `md.outlined-icon-button.container.shape` *(deprecated)* | Outlined icon button container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.outlined-icon-button.selected.container.color` *(deprecated)* | Outlined icon button selected container color | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.focus.indicator.color` *(deprecated)* | Outlined icon button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.outlined-icon-button.focus.indicator.thickness` *(deprecated)* | Outlined icon button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.outlined-icon-button.focus.indicator.outline.offset` *(deprecated)* | Outlined icon button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.disabled.icon.color` *(deprecated)* | Outlined icon button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.icon.size` *(deprecated)* | Outlined icon button icon size |  | 24dp |
| `md.outlined-icon-button.unselected.focus.icon.color` *(deprecated)* | Outlined icon button focus icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.outlined-icon-button.unselected.hover.icon.color` *(deprecated)* | Outlined icon button unselected hover icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.outlined-icon-button.disabled.icon.opacity` *(deprecated)* | Outlined icon button disabled icon opacity |  | 0.38 |
| `md.outlined-icon-button.selected.focus.icon.color` *(deprecated)* | Outlined icon button focus icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.outlined-icon-button.selected.hover.icon.color` *(deprecated)* | Outlined icon button selected hover icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.outlined-icon-button.unselected.icon.color` *(deprecated)* | Outlined icon button unselected icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.outlined-icon-button.selected.icon.color` *(deprecated)* | Outlined icon button selected icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

**[Deprecated] Outline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.disabled.unselected.outline.color` *(deprecated)* | Outlined icon button disabled unselected outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.unselected.outline.color` *(deprecated)* | Outlined icon button unselected outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.outlined-icon-button.disabled.unselected.outline.opacity` *(deprecated)* | Outlined icon button disabled unselected outline opacity |  | 0.12 |
| `md.outlined-icon-button.unselected.outline.width` *(deprecated)* | Outlined icon button unselected outline width |  | 1dp |
| `md.outlined-icon-button.disabled.outline.color` *(deprecated)* | Outlined icon button disabled outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.disabled.outline.opacity` *(deprecated)* | Outlined icon button disabled outline opacity |  | 0.12 |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.outlined-icon-button.focus.state-layer.opacity` *(deprecated)* | Outlined icon button focus state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.outlined-icon-button.hover.state-layer.opacity` *(deprecated)* | Outlined icon button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.outlined-icon-button.pressed.state-layer.opacity` *(deprecated)* | Outlined icon button pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.outlined-icon-button.unselected.focus.state-layer.color` *(deprecated)* | Outlined icon button unselected focus state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.outlined-icon-button.unselected.hover.state-layer.color` *(deprecated)* | Outlined icon button unselected hover state layer color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.outlined-icon-button.unselected.pressed.state-layer.color` *(deprecated)* | Outlined icon button unselected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.outlined-icon-button.selected.focus.state-layer.color` *(deprecated)* | Outlined icon button selected focus state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.outlined-icon-button.selected.hover.state-layer.color` *(deprecated)* | Outlined icon button selected hover state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.outlined-icon-button.selected.pressed.state-layer.color` *(deprecated)* | Outlined icon button selected pressed state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
