Source: https://m3.material.io/components/navigation-bar/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T07:36:27.700Z

# Navigation bar — Specs

## Variants

*[Image: The recommended flexible navigation bar.]*

1. Flexible navigation bar

### Baseline variants

The baseline nav bar is no longer recommended, and should be replaced by the flexible nav bar, which is shorter and supports horizontal navigation items in medium windows. [View baseline nav bar specs](https://m3.material.io/components/navigation-bar/specs#46dc2521-acf0-44e3-bbc0-78dc225b9749)

*[Image: 1 baseline navigation bar.]*

1. Navigation bar (not recommended)

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Flexible navigation bar | -- | Available |
| Navigation bar | Available | Not recommended.  Use **flexible navigation bar**. |

## Configurations

In compact windows, navigation bars use vertical items. In medium windows, navigation bars should use horizontal items.

*[Image: Two size configurations for navigation bar and items.]*

1. Vertical navigation items
2. Horizontal navigation items

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Navigation item layout | Vertical (default) | Available | Available |
| Horizontal | -- | Available |

## Tokens & specs

Use the table's menu to switch between token sets for the navigation bar and the nav items. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: Nav bar - Common (`md.comp.nav-bar`)

Common tokens for navigation bars.

**Nav item**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.between-space` | Nav bar space between items | md.sys.measurement.space0 | 0dp |
| `md.comp.nav-bar.item.active-indicator.shape` | Nav bar item shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.nav-bar.item.active-indicator.icon-label-space` | Nav bar item space between icon label space |  | 4dp |
| `md.comp.nav-bar.item.icon.size` | Nav bar item icon size |  | 24dp |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.container.height` | Nav bar height |  | 64dp |
| `md.comp.nav-bar.container.shape` | Nav bar shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.hovered.state-layer.color` | Nav bar item active hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.hovered.state-layer.opacity` | Nav bar item active hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.nav-bar.item.inactive.hovered.state-layer.color` | Nav bar item inactive hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.pressed.state-layer.color` | Nav bar item active pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.pressed.state-layer.opacity` | Nav bar item active pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.nav-bar.item.inactive.pressed.state-layer.color` | Nav bar item inactive pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.focused.state-layer.color` | Nav bar item active focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.focused.state-layer.opacity` | Nav bar item active focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.nav-bar.item.inactive.focused.state-layer.color` | Nav bar item inactive focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.container.elevation` | Nav bar container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.nav-bar.container.shadow-color` | Nav bar container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.nav-bar.container.color` | Nav bar container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.nav-bar.item.active.indicator.color` | Nav bar item indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.nav-bar.item.active.label-text.color` | Nav bar item active label text color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.nav-bar.item.inactive.label-text.color` | Nav bar item inactive label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.nav-bar.item.active.icon.color` | Nav bar item active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.inactive.icon.color` | Nav bar item inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: Nav bar - Item - Vertical (`md.comp.nav-bar.item.vertical`)

For vertical nav items, where elements are stacked.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.vertical.label-text.font` | Nav bar item vertical label text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-bar.item.vertical.active-indicator.height` | Nav bar item vertical active indicator height |  | 32dp |
| `md.comp.nav-bar.item.vertical.active-indicator.width` | Nav bar item vertical active indicator width |  | 56dp |
| `md.comp.nav-bar.item.vertical.container.between-space` | Nav bar item vertical container between space | md.sys.measurement.space75 | 6dp |
| `md.comp.nav-bar.item.vertical.active-indicator.icon-label-space` | Nav bar item vertical active indicator icon label space | md.sys.measurement.space50 | 4dp |

#### Token set: Nav bar - Item - Horizontal (`md.comp.nav-bar.item.horizontal`)

For horizontal nav items, where elements are side-by-side.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.horizontal.label-text.font` | Nav bar item horizontal label text text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-bar.item.horizontal.active-indicator.height` | Nav bar item horizontal active indicator height |  | 40dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.leading-space` | Nav bar item horizontal active indicator leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.trailing-space` | Nav bar item horizontal active indicator trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.icon-label-space` | Nav bar item horizontal active indicator icon label space | md.sys.measurement.space50 | 4dp |

## Anatomy

*[Image: Seven elements of the navigation bar.]*

1. Container
2. Icon
3. Label text
4. Active indicator
5. Small badge (optional)
6. Large badge (optional)
7. Large badge label

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Six color roles of the navigation bar.]*

Navigation bar color roles used for light and dark schemes:

1. Surface container
2. On-secondary container
3. Secondary
4. Secondary container
5. On-surface variant
6. On-surface variant

For badge color roles, go to [badge specs](https://m3.material.io/components/badges/specs).

## States

States are visual representations used to communicate the status of a component or an interactive element.

*[Image: Four states of the navigation bar items.]*

1. Enabled
2. Hovered (8% state layer)
3. Focused (10% state layer)
4. Pressed (10% state layer)

## Measurements

The navigation bar stretches the full window width.

*[Image: Navigation bar padding and size measurements.]*

Navigation bar padding and size measurements

Vertical navigation items dynamically change width to equally fit the container. Horizontal navigation items have a fixed width, so extra space is added to the ends of the navigation bar instead.

*[Image: Navigation bar and item widths.]*

Navigation bar width and margins for compact and medium windows.

1. Vertical navigation item
2. Margin from window edge
3. Horizontal navigation item

---

## Baseline navigation bar

*[Image: 7 elements of baseline navigation bar.]*

1. Container
2. Icon
3. Label text
4. Active indicator
5. Small badge
6. Large badge
7. Large badge label

### Tokens & specs

These tokens are for the baseline navigation bar.

#### Token set: Navigation bar (baseline) (`md.comp.navigation-bar`)

For baseline navigation bar. For expressive, use `md.comp.nav-bar` and corresponding `.item` token sets instead.

**Active indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.active-indicator.color` | Color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.navigation-bar.active-indicator.height` | Height |  | 32dp |
| `md.comp.navigation-bar.active-indicator.width` | Width |  | 64dp |
| `md.comp.navigation-bar.active-indicator.shape` | Shape | md.sys.shape.corner.full | fully rounded (circular) |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.container.color` | Color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.navigation-bar.container.shape` | Shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.navigation-bar.container.height` | Height |  | 80dp |
| `md.comp.navigation-bar.container.elevation` | Elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.navigation-bar.container.surface-tint-layer.color` *(deprecated)* | Surface tint color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.navigation-bar.container.shadow-color` *(deprecated)* | Navigation bar container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.focus.indicator.color` | Navigation bar focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.navigation-bar.focus.indicator.thickness` | Navigation bar focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.navigation-bar.focus.indicator.outline.offset` | Navigation bar focus indicator offset | md.sys.state.focus-indicator.inner-offset | -3dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.icon.size` | Size |  | 24dp |
| `md.comp.navigation-bar.active.icon.color` | Size | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-bar.inactive.icon.color` | Size | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-bar.active.hover.icon.color` | Color (active) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-bar.inactive.hover.icon.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.active.focus.icon.color` | Color (active) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-bar.inactive.focus.icon.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.active.pressed.icon.color` | Color (active) | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-bar.inactive.pressed.icon.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.label-text.font` | Font | md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-bar.label-text.line-height` | Line height | md.sys.typescale.label-medium.line-height | 16pt |
| `md.comp.navigation-bar.label-text.size` | Size | md.sys.typescale.label-medium.size | 12pt |
| `md.comp.navigation-bar.label-text.weight` | Weight | md.sys.typescale.label-medium.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-bar.active.label-text.weight` | Weight (active) | md.sys.typescale.label-medium.weight.prominent → md.ref.typeface.weight-bold | 700 |
| `md.comp.navigation-bar.label-text.tracking` | Tracking | md.sys.typescale.label-medium.tracking | 0.5pt |
| `md.comp.navigation-bar.label-text.type` | Type style | md.comp.navigation-bar.label-text.font → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.navigation-bar.active.label-text.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.label-text.color` | Color (inactive) | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-bar.active.hover.label-text.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.hover.label-text.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.active.focus.label-text.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.focus.label-text.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.active.pressed.label-text.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.pressed.label-text.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.active.hover.state-layer.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.hover.state-layer.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.hover.state-layer.opacity` | Opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.navigation-bar.active.focus.state-layer.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.focus.state-layer.color` | Color (inactive) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.focus.state-layer.opacity` | Opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.navigation-bar.active.pressed.state-layer.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.inactive.pressed.state-layer.color` | Color (active) | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-bar.pressed.state-layer.opacity` | Opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**[Deprecated] Badge**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.badge.color` *(deprecated)* | Color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.navigation-bar.badge.size` *(deprecated)* | Size |  | 6dp |
| `md.comp.navigation-bar.badge.shape` *(deprecated)* | Shape |  | rounded corners: 3dp all corners |

**[Deprecated] Large badge**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-bar.large-badge.size` *(deprecated)* | Size |  | 16dp |
| `md.comp.navigation-bar.large-badge.shape` *(deprecated)* | Shape |  | rounded corners: 8dp all corners |
| `md.comp.navigation-bar.large-badge.color` *(deprecated)* | Color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |

#### Token set: Nav bar - Common (`md.comp.nav-bar`)

Common tokens for navigation bars.

**Nav item**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.between-space` | Nav bar space between items | md.sys.measurement.space0 | 0dp |
| `md.comp.nav-bar.item.active-indicator.shape` | Nav bar item shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.nav-bar.item.active-indicator.icon-label-space` | Nav bar item space between icon label space |  | 4dp |
| `md.comp.nav-bar.item.icon.size` | Nav bar item icon size |  | 24dp |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.container.height` | Nav bar height |  | 64dp |
| `md.comp.nav-bar.container.shape` | Nav bar shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.hovered.state-layer.color` | Nav bar item active hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.hovered.state-layer.opacity` | Nav bar item active hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.nav-bar.item.inactive.hovered.state-layer.color` | Nav bar item inactive hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.pressed.state-layer.color` | Nav bar item active pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.pressed.state-layer.opacity` | Nav bar item active pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.nav-bar.item.inactive.pressed.state-layer.color` | Nav bar item inactive pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.active.focused.state-layer.color` | Nav bar item active focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.active.focused.state-layer.opacity` | Nav bar item active focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.nav-bar.item.inactive.focused.state-layer.color` | Nav bar item inactive focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.container.elevation` | Nav bar container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.nav-bar.container.shadow-color` | Nav bar container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.nav-bar.container.color` | Nav bar container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.nav-bar.item.active.indicator.color` | Nav bar item indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.nav-bar.item.active.label-text.color` | Nav bar item active label text color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.nav-bar.item.inactive.label-text.color` | Nav bar item inactive label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.nav-bar.item.active.icon.color` | Nav bar item active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-bar.item.inactive.icon.color` | Nav bar item inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: Nav bar - Item - Vertical (`md.comp.nav-bar.item.vertical`)

For vertical nav items, where elements are stacked.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.vertical.label-text.font` | Nav bar item vertical label text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-bar.item.vertical.active-indicator.height` | Nav bar item vertical active indicator height |  | 32dp |
| `md.comp.nav-bar.item.vertical.active-indicator.width` | Nav bar item vertical active indicator width |  | 56dp |
| `md.comp.nav-bar.item.vertical.container.between-space` | Nav bar item vertical container between space | md.sys.measurement.space75 | 6dp |
| `md.comp.nav-bar.item.vertical.active-indicator.icon-label-space` | Nav bar item vertical active indicator icon label space | md.sys.measurement.space50 | 4dp |

#### Token set: Nav bar - Item - Horizontal (`md.comp.nav-bar.item.horizontal`)

For horizontal nav items, where elements are side-by-side.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-bar.item.horizontal.label-text.font` | Nav bar item horizontal label text text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-bar.item.horizontal.active-indicator.height` | Nav bar item horizontal active indicator height |  | 40dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.leading-space` | Nav bar item horizontal active indicator leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.trailing-space` | Nav bar item horizontal active indicator trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-bar.item.horizontal.active-indicator.icon-label-space` | Nav bar item horizontal active indicator icon label space | md.sys.measurement.space50 | 4dp |

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 6 color roles of baseline navigation bar.]*

Navigation bar color roles used for light and dark schemes:

1. Surface
2. On secondary container
3. On surface
4. Secondary container
5. On surface variant
6. On surface variant

For badge color roles, go to [badge specs](https://m3.material.io/components/badges/specs).

### States

States are visual representations used to communicate the status of a component or an interactive element.

*[Image: 4 states of baseline navigation bar.]*

Navigation bar states: 

1. Enabled
2. Hovered
3. Focused
4. Pressed

## Measurements

*[Image: Baseline navigation bar padding and size measurements.]*

Navigation bar padding and size measurements

*[Image: Baseline navigation bar target size and margins.]*

Navigation bar target size and margins

## Configurations

*[Image: 3 configurations of the baseline navigation bar.]*

1. 3 destinations
2. 4 destinations
3. 5 destinations
