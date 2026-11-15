Source: https://m3.material.io/components/navigation-rail/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-24T07:30:37.949Z

# Navigation rail — Specs

## Variants

*[Image: 2 variants of navigation rails.]*

1. Collapsed navigation rail
2. Expanded navigation rail

### Baseline variants

The baseline navigation rail is no longer recommended, and should be replaced by the collapsed navigation rail. [View baseline tokens](https://m3.material.io/components/navigation-rail/specs#d4d97764-20ec-496f-a6f3-0d423940ec5a)

*[Image: Baseline navigation rail.]*

1. The baseline navigation rail is no longer recommended

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Collapsed navigation rail | -- | Available |
| Expanded navigation rail | -- | Available |
| Navigation rail (baseline) | Available | Not recommended.  Use **collapsed navigation rail**. |

## Configurations

*[Image: Standard and modal layouts of navigation rail.]*

1. Expanded layout: standard
2. Expanded layout: modal

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Expanded layout | Standard (default) | Available as navigation drawer | Available |
| Modal | Available as navigation drawer | Available |
| Expanded behavior | Hide when collapsed | -- | Available |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: Nav rail - Common (`md.comp.nav-rail`)

Common tokens for nav rail.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.indicator.color` | Nav rail item active indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.nav-rail.item.active.label-text.color` | Nav rail item active label text color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.nav-rail.item.inactive.label-text.color` | Nav rail item inactive label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.nav-rail.item.active.icon.color` | Nav rail item active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.inactive.icon.color` | Nav rail item inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.hovered.state-layer.color` | Nav rail item active hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.hovered.state-layer.opacity` | Nav rail item active hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.nav-rail.item.inactive.hovered.state-layer.color` | Nav rail item inactive hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.focused.state-layer.color` | Nav rail item active focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.focused.state-layer.opacity` | Nav rail item active focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.nav-rail.item.inactive.focused.state-layer.color` | Nav rail item inactive focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.pressed.state-layer.color` | Nav rail item active pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.pressed.state-layer.opacity` | Nav rail item active pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.nav-rail.item.inactive.pressed.state-layer.color` | Nav rail item inactive pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: Nav rail - Collapsed (`md.comp.nav-rail.collapsed`)

For collapsed nav rail.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.collapsed.container.width` | Nav rail collapsed container width |  | 96dp |
| `md.comp.nav-rail.collapsed.narrow.container.width` | Nav rail collapsed narrow container width |  | 80dp |
| `md.comp.nav-rail.collapsed.container.elevation` | Nav rail collapsed container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.nav-rail.collapsed.container.shape` | Nav rail collapsed container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.collapsed.container.color` | Nav rail collapsed container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.nav-rail.collapsed.item.vertical-space` | Nav rail collapsed item vertical space | md.sys.measurement.space50 | 4dp |
| `md.comp.nav-rail.collapsed.top-space` | Nav rail collapsed item top space |  | 44dp |

#### Token set: Nav rail - Expanded (`md.comp.nav-rail.expanded`)

For expanded nav rail.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.expanded.container.width.minimum` | Nav rail expanded container width minimum |  | 220dp |
| `md.comp.nav-rail.expanded.container.width.maximum` | Nav rail expanded container width maximum |  | 360dp |
| `md.comp.nav-rail.expanded.top-space` | Nav rail expanded top space |  | 44dp |
| `md.comp.nav-rail.expanded.container.elevation` | Nav rail expanded container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.nav-rail.expanded.modal.container.elevation` | Nav rail expanded modal container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.nav-rail.expanded.container.color` | Nav rail expanded container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.nav-rail.expanded.modal.container.color` | Nav rail expanded modal container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.nav-rail.expanded.container.shape` | Nav rail expanded container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.expanded.modal.container.shape` | Nav rail expanded modal container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.nav-rail.expanded.between-item-space` *(deprecated)* | Nav rail expanded between item space |  | 0dp |
| `md.comp.nav-rail.expanded.vertical.trailing-space` *(deprecated)* | Nav rail expanded vertical trailing space |  | 20dp |

#### Token set: Nav rail item - Common (`md.comp.nav-rail.item`)

Common tokens for all nav items.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.icon.size` | Nav rail item icon size |  | 24dp |
| `md.comp.nav-rail.item.active-indicator.shape` | Nav rail item active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.nav-rail.item.active-indicator.leading-space` | Nav rail item active indicator leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.active-indicator.icon-label-space` | Nav rail item active indicator icon label space | md.sys.measurement.space100 | 8dp |
| `md.comp.nav-rail.item.active-indicator.trailing-space` | Nav rail item active indicator trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.container.height` | Nav rail item container height |  | 64dp |
| `md.comp.nav-rail.item.short.container.height` | Nav rail item short container height |  | 56dp |
| `md.comp.nav-rail.item.container.shape` | Nav rail item container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.item.container.vertical-space` | Nav rail item container vertical space | md.sys.measurement.space75 | 6dp |
| `md.comp.nav-rail.item.header-space-minimum` | Nav rail item header space minimum | md.sys.measurement.space500 | 40dp |

#### Token set: Nav rail item - Vertical (`md.comp.nav-rail.item.vertical`)

For vertical nav rail items, where elements are stacked. 

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.vertical.active-indicator.height` | Nav rail item vertical active indicator height |  | 32dp |
| `md.comp.nav-rail.item.vertical.active-indicator.width` | Nav rail item vertical active indicator width |  | 56dp |
| `md.comp.nav-rail.item.vertical.label-text.font` | Nav rail item vertical label text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-rail.item.vertical.icon-label-space` | Nav rail item vertical icon label space | md.sys.measurement.space50 | 4dp |
| `md.comp.nav-rail.item.vertical.leading-space` | Nav rail item vertical icon leading-space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.vertical.trailing-space` | Nav rail item vertical icon trailing space | md.sys.measurement.space200 | 16dp |

#### Token set: Nav rail item - Horizontal (`md.comp.nav-rail.item.horizontal`)

For horizontal nav rail items, where elements are side-by-side.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.horizontal.label-text.font` | Nav rail item horizontal label text | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.nav-rail.item.horizontal.active-indicator.height` | Nav rail item horizontal active indicator height |  | 56dp |
| `md.comp.nav-rail.item.horizontal.full-width.leading-space` | Nav rail item horizontal full width leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.horizontal.full-width.trailing-space` | Nav rail item horizontal full width trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.horizontal.icon-label-space` | Nav rail item horizontal icon-label-space | md.sys.measurement.space100 | 8dp |

## Anatomy

*[Image: 9 elements of collapsed and expanded navigation rails.]*

Collapsed and expanded navigation rail elements:

1. Container
2. Menu (optional)
3. FAB or Extended FAB (optional)
4. Icon
5. Active indicator
6. Label text
7. Large badge (optional)
8. Large badge label (optional)
9. Small badge (optional)

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Color roles of 9 elements of collapsed and expanded navigation rails in light and dark color schemes.]*

Navigation rail color roles used for light and dark schemes:

1. Surface container (optional)
2. On secondary container
3. Secondary container
4. Secondary (vertical), On secondary container (horizontal)
5. On surface variant
6. On surface variant
7. Error
8. On error
9. Error

## States

States are visual representations used to communicate the status of a component or an interactive element.  
  
The navigation item’s target area always spans the full width of the nav rail, even if the item container hugs its contents.

*[Image: 4 states of collapsed navigation rails.]*

*[Image: 4 states of expanded navigation rails.]*

1. Enabled
2. Hovered
3. Focused
4. Pressed

## Measurements

*[Image: Padding and measurements for expanded and collapsed navigation rails.]*

Navigation rail padding and size measurements

## Common layouts

*[Image: 4 common layouts of collapsed navigation rail.]*

*[Image: 4 common layouts of expanded navigation rail.]*

1. Three navigation items
2. Three navigation items with a menu
3. Three navigation items with a FAB
4. Three navigation items with a menu and FAB

---

## Baseline navigation rail

*[Image: 8 elements of baseline navigation rail.]*

1. Container
2. Menu icon (optional)
3. Icon
4. Active indicator
5. Label text
6. Large badge label (optional)
7. Large badge (optional)
8. Badge (optional)

### Tokens & specs

#### Token set: Navigation rail (baseline) (`md.comp.navigation-rail`)

For baseline navigation rails. For expressive, use all nav rail token sets`md.comp.nav-rail` and corresponding `.collapsed` and `.item` token sets.

**Active indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.active-indicator.color` | Navigation rail active indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.navigation-rail.active-indicator.height` | Navigation rail active indicator height |  | 32dp |
| `md.comp.navigation-rail.no-label.active-indicator.height` | Navigation rail no label active indicator height |  | 56dp |
| `md.comp.navigation-rail.active-indicator.shape` | Navigation rail active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.navigation-rail.no-label.active-indicator.shape` | Navigation rail no label active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.navigation-rail.active-indicator.width` | Navigation rail active indicator width |  | 56dp |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.container.color` | Navigation rail container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.navigation-rail.container.shape` | Navigation rail container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.navigation-rail.container.width` | Navigation rail container width |  | 80dp |
| `md.comp.navigation-rail.container.elevation` | Navigation rail container elevation | md.sys.elevation.level0 | 0dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.active.focus.icon.color` | Navigation rail active focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-rail.active.hover.icon.color` | Navigation rail active hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-rail.active.pressed.icon.color` | Navigation rail active pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-rail.icon.size` | Navigation rail icon size |  | 24dp |
| `md.comp.navigation-rail.active.icon.color` | Navigation rail active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-rail.inactive.focus.icon.color` | Navigation rail inactive focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.hover.icon.color` | Navigation rail inactive hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.pressed.icon.color` | Navigation rail inactive pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.icon.color` | Navigation rail inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-rail.menu.focus.icon.color` *(deprecated)* | Navigation rail menu focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.hover.icon.color` *(deprecated)* | Navigation rail menu hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.pressed.icon.color` *(deprecated)* | Navigation rail menu pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.icon.color` *(deprecated)* | Navigation rail menu icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-rail.menu.icon.size` *(deprecated)* | Navigation rail menu icon size |  | 24dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.active.focus.label-text.color` | Navigation rail focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.active.hover.label-text.color` | Navigation rail active hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.active.pressed.label-text.color` | Navigation rail active pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.label-text.font` | Navigation rail label font | md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-rail.inactive.focus.label-text.color` | Navigation rail inactive focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.hover.label-text.color` | Navigation rail inactive hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.pressed.label-text.color` | Navigation rail inactive pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.label-text.line-height` | Navigation rail label line height | md.sys.typescale.label-medium.line-height | 16pt |
| `md.comp.navigation-rail.label-text.size` | Navigation rail label size | md.sys.typescale.label-medium.size | 12pt |
| `md.comp.navigation-rail.label-text.weight` | Navigation rail label weight | md.sys.typescale.label-medium.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-rail.active.label-text.weight` | Navigation rail active label weight | md.sys.typescale.label-medium.weight.prominent → md.ref.typeface.weight-bold | 700 |
| `md.comp.navigation-rail.label-text.tracking` | Navigation rail label tracking | md.sys.typescale.label-medium.tracking | 0.5pt |
| `md.comp.navigation-rail.label-text.type` | Label text type style | md.comp.navigation-rail.label-text.font → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.navigation-rail.active.label-text.color` | Navigation rail label active text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.label-text.color` | Navigation rail label inactive text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-rail.label-text.font-family` *(deprecated)* | Navigation rail label font family | md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-rail.label-text.font-size` *(deprecated)* | Navigation rail label font size | md.sys.typescale.label-medium.size | 12pt |
| `md.comp.navigation-rail.label-text.letter-spacing` *(deprecated)* | Navigation rail label letter spacing | md.sys.typescale.label-medium.tracking | 0.5pt |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.active.focus.state-layer.color` | Navigation rail active focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.active.hover.state-layer.color` | Navigation rail active hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.active.pressed.state-layer.color` | Navigation rail active pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.focus.state-layer.color` | Navigation rail inactive focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.hover.state-layer.color` | Navigation rail inactive hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.inactive.pressed.state-layer.color` | Navigation rail inactive pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.focus.state-layer.opacity` | Navigation rail active focus state layer color | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.navigation-rail.hover.state-layer.opacity` | Navigation rail hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.navigation-rail.pressed.state-layer.opacity` | Navigation rail pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.navigation-rail.menu.focus.state-layer.color` *(deprecated)* | Navigation rail menu focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.hover.state-layer.color` *(deprecated)* | Navigation rail menu hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.pressed.state-layer.color` *(deprecated)* | Navigation rail menu pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-rail.menu.focus.state-layer.opacity` *(deprecated)* | Navigation rail menu focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.navigation-rail.menu.hover.state-layer.opacity` *(deprecated)* | Navigation rail menu hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.navigation-rail.menu.pressed.state-layer.opacity` *(deprecated)* | Navigation rail menu pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**[Deprecated] Badge**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.badge.color` *(deprecated)* | Navigation rail badge color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.navigation-rail.badge.size` *(deprecated)* | Navigation rail badge size |  | 6dp |
| `md.comp.navigation-rail.badge.shape` *(deprecated)* | Navigation rail badge shape |  | rounded corners: 3dp all corners |

**[Deprecated] Large badge**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.large-badge.size` *(deprecated)* | Navigation rail large badge size |  | 16dp |
| `md.comp.navigation-rail.large-badge.shape` *(deprecated)* | Navigation rail large badge shape |  | rounded corners: 8dp all corners |
| `md.comp.navigation-rail.large-badge.color` *(deprecated)* | Navigation rail large badge color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |

**[Deprecated] Large badge label**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-rail.large-badge-label.font-family` *(deprecated)* | Navigation rail large badge label font family | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-rail.large-badge-label.font` *(deprecated)* | Navigation rail large badge label font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-rail.large-badge-label.line-height` *(deprecated)* | Navigation rail large badge label line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.navigation-rail.large-badge-label.size` *(deprecated)* | Navigation rail large badge label size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.navigation-rail.large-badge-label.weight` *(deprecated)* | Navigation rail large badge label weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-rail.large-badge-label.tracking` *(deprecated)* | Navigation rail large badge label tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.navigation-rail.large-badge-label.type` *(deprecated)* | Navigation rail large badge label type style | md.comp.navigation-rail.large-badge-label.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |
| `md.comp.navigation-rail.large-badge-label.color` *(deprecated)* | Navigation rail large badge label color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |

#### Token set: Nav rail item - Horizontal (`md.comp.nav-rail.item.horizontal`)

For horizontal nav rail items, where elements are side-by-side.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.horizontal.label-text.font` | Nav rail item horizontal label text | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.nav-rail.item.horizontal.active-indicator.height` | Nav rail item horizontal active indicator height |  | 56dp |
| `md.comp.nav-rail.item.horizontal.full-width.leading-space` | Nav rail item horizontal full width leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.horizontal.full-width.trailing-space` | Nav rail item horizontal full width trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.horizontal.icon-label-space` | Nav rail item horizontal icon-label-space | md.sys.measurement.space100 | 8dp |

#### Token set: Nav rail item - Common (`md.comp.nav-rail.item`)

Common tokens for all nav items.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.icon.size` | Nav rail item icon size |  | 24dp |
| `md.comp.nav-rail.item.active-indicator.shape` | Nav rail item active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.nav-rail.item.active-indicator.leading-space` | Nav rail item active indicator leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.active-indicator.icon-label-space` | Nav rail item active indicator icon label space | md.sys.measurement.space100 | 8dp |
| `md.comp.nav-rail.item.active-indicator.trailing-space` | Nav rail item active indicator trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.container.height` | Nav rail item container height |  | 64dp |
| `md.comp.nav-rail.item.short.container.height` | Nav rail item short container height |  | 56dp |
| `md.comp.nav-rail.item.container.shape` | Nav rail item container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.item.container.vertical-space` | Nav rail item container vertical space | md.sys.measurement.space75 | 6dp |
| `md.comp.nav-rail.item.header-space-minimum` | Nav rail item header space minimum | md.sys.measurement.space500 | 40dp |

#### Token set: Nav rail - Common (`md.comp.nav-rail`)

Common tokens for nav rail.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.indicator.color` | Nav rail item active indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.nav-rail.item.active.label-text.color` | Nav rail item active label text color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.nav-rail.item.inactive.label-text.color` | Nav rail item inactive label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.nav-rail.item.active.icon.color` | Nav rail item active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.inactive.icon.color` | Nav rail item inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.hovered.state-layer.color` | Nav rail item active hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.hovered.state-layer.opacity` | Nav rail item active hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.nav-rail.item.inactive.hovered.state-layer.color` | Nav rail item inactive hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.focused.state-layer.color` | Nav rail item active focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.focused.state-layer.opacity` | Nav rail item active focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.nav-rail.item.inactive.focused.state-layer.color` | Nav rail item inactive focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.active.pressed.state-layer.color` | Nav rail item active pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.nav-rail.item.active.pressed.state-layer.opacity` | Nav rail item active pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.nav-rail.item.inactive.pressed.state-layer.color` | Nav rail item inactive pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: Nav rail - Collapsed (`md.comp.nav-rail.collapsed`)

For collapsed nav rail.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.collapsed.container.width` | Nav rail collapsed container width |  | 96dp |
| `md.comp.nav-rail.collapsed.narrow.container.width` | Nav rail collapsed narrow container width |  | 80dp |
| `md.comp.nav-rail.collapsed.container.elevation` | Nav rail collapsed container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.nav-rail.collapsed.container.shape` | Nav rail collapsed container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.collapsed.container.color` | Nav rail collapsed container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.nav-rail.collapsed.item.vertical-space` | Nav rail collapsed item vertical space | md.sys.measurement.space50 | 4dp |
| `md.comp.nav-rail.collapsed.top-space` | Nav rail collapsed item top space |  | 44dp |

#### Token set: Nav rail - Expanded (`md.comp.nav-rail.expanded`)

For expanded nav rail.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.expanded.container.width.minimum` | Nav rail expanded container width minimum |  | 220dp |
| `md.comp.nav-rail.expanded.container.width.maximum` | Nav rail expanded container width maximum |  | 360dp |
| `md.comp.nav-rail.expanded.top-space` | Nav rail expanded top space |  | 44dp |
| `md.comp.nav-rail.expanded.container.elevation` | Nav rail expanded container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.nav-rail.expanded.modal.container.elevation` | Nav rail expanded modal container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.nav-rail.expanded.container.color` | Nav rail expanded container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.nav-rail.expanded.modal.container.color` | Nav rail expanded modal container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.nav-rail.expanded.container.shape` | Nav rail expanded container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.nav-rail.expanded.modal.container.shape` | Nav rail expanded modal container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.nav-rail.expanded.between-item-space` *(deprecated)* | Nav rail expanded between item space |  | 0dp |
| `md.comp.nav-rail.expanded.vertical.trailing-space` *(deprecated)* | Nav rail expanded vertical trailing space |  | 20dp |

#### Token set: Nav rail item - Vertical (`md.comp.nav-rail.item.vertical`)

For vertical nav rail items, where elements are stacked. 

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.nav-rail.item.vertical.active-indicator.height` | Nav rail item vertical active indicator height |  | 32dp |
| `md.comp.nav-rail.item.vertical.active-indicator.width` | Nav rail item vertical active indicator width |  | 56dp |
| `md.comp.nav-rail.item.vertical.label-text.font` | Nav rail item vertical label text | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.nav-rail.item.vertical.icon-label-space` | Nav rail item vertical icon label space | md.sys.measurement.space50 | 4dp |
| `md.comp.nav-rail.item.vertical.leading-space` | Nav rail item vertical icon leading-space | md.sys.measurement.space200 | 16dp |
| `md.comp.nav-rail.item.vertical.trailing-space` | Nav rail item vertical icon trailing space | md.sys.measurement.space200 | 16dp |

### Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 8 color roles of baseline navigation rail.]*

Navigation rail color roles used for light and dark themes:

1. On secondary container
2. Secondary container
3. On surface
4. On surface variant
5. On surface variant
6. Error
7. On error
8. Error

### States

States are visual representations used to communicate the status of a component or interactive element.

*[Image: 8 states of baseline navigation rail.]*

Navigation rail states:

1. Enabled (on active destination)
2. Hovered (on active destination)
3. Focused (on active destination)
4. Pressed (on active destination)
5. Enabled (on inactive destination)
6. Hovered (on inactive destination)
7. Focused (on inactive destination)
8. Pressed (on inactive destination)

### Measurements

*[Image: Baseline nav rail size measurements.]*

Navigation rail size measurements

*[Image: Baseline nav rail padding and margin measurements.]*

Navigation rail padding and margin measurements

### Configurations

Common arrangements of elements within a navigation rail.

*[Image: 5 configurations of the baseline navigation rail.]*

1. With a menu
2. With a FAB
3. With menu and FAB, without labels
4. All destinations with text labels
5. With menu, FAB, and label text for all destinations
