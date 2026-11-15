Source: https://m3.material.io/components/navigation-drawer/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-30T05:22:52.002Z

# Navigation drawer — Specs

star

Note:

The navigation drawer is no longer recommended in the Material 3 Expressive update. For those who have updated, use an [expanded navigation rail](https://m3.material.io/components/navigation-rail/overview/), which has mostly the same functionality of the navigation drawer and adapts better across breakpoints.

*[Image: Navigation drawer diagram numbering 7 elements]*

1. Container
2. Headline
3. Label text
4. Active indicator
5. Badge label text
6. Scrim
7. Icon

## Tokens & specs

The navigation drawer has one token set. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: Navigation drawers (baseline) (`md.comp.navigation-drawer`)

For the baseline navigation drawer. For expressive, use the expanded nav rail instead `md.comp.nav-rail.expanded`.

**Active indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.active-indicator.color` | Navigation drawers active indicator color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.navigation-drawer.active-indicator.height` | Navigation drawers active indicator height |  | 56dp |
| `md.comp.navigation-drawer.active-indicator.shape` | Navigation drawers active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.navigation-drawer.active-indicator.width` | Navigation drawers active indicator width |  | 336dp |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.container.color` *(deprecated)* | Navigation drawers container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.navigation-drawer.modal.container.color` | Navigation drawers modal container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.navigation-drawer.standard.container.color` | Navigation drawers standard container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.navigation-drawer.container.surface-tint-layer.color` *(deprecated)* | Navigation drawers container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.navigation-drawer.modal.container.elevation` | Navigation drawers modal container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.navigation-drawer.standard.container.elevation` | Navigation drawers standard container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.navigation-drawer.container.height` | Navigation drawers container height |  | 100% |
| `md.comp.navigation-drawer.container.shape` | Navigation drawers container shape | md.sys.shape.corner.large.end | rounded corners: topRight 16dp, bottomRight 16dp (others 0dp) |
| `md.comp.navigation-drawer.bottom.container.shape` | Navigation drawers bottom container shape | md.sys.shape.corner.large.top | rounded corners: topLeft 16dp, topRight 16dp (others 0dp) |
| `md.comp.navigation-drawer.container.width` | Navigation drawers container width |  | 360dp |

**Divider**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.divider.color` *(deprecated)* | Navigation drawers divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.focus.indicator.color` | Navigation drawers focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.navigation-drawer.focus.indicator.thickness` | Navigation drawers focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.navigation-drawer.focus.indicator.outline.offset` | Navigation drawers focus indicator offset | md.sys.state.focus-indicator.inner-offset | -3dp |

**Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.headline.color` | Navigation drawers headline color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-drawer.headline.font` | Navigation drawers headline font | md.sys.typescale.title-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-drawer.headline.line-height` | Navigation drawers headline line height | md.sys.typescale.title-small.line-height | 20pt |
| `md.comp.navigation-drawer.headline.size` | Navigation drawers headline size | md.sys.typescale.title-small.size | 14pt |
| `md.comp.navigation-drawer.headline.tracking` | Navigation drawers headline tracking | md.sys.typescale.title-small.tracking | 0.1pt |
| `md.comp.navigation-drawer.headline.weight` | Navigation drawers headline weight | md.sys.typescale.title-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-drawer.headline.type` | Type style | md.comp.navigation-drawer.headline.font → md.sys.typescale.title-small.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.active.focus.icon.color` | Navigation drawers active focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.hover.icon.color` | Navigation drawers active hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.icon.color` | Navigation drawers active icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.pressed.icon.color` | Navigation drawers active pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.inactive.focus.icon.color` | Navigation drawers inactive focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.hover.icon.color` | Navigation drawers inactive hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.icon.color` | Navigation drawers inactive icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-drawer.inactive.pressed.icon.color` | Navigation drawers inactive pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.icon.size` | Navigation drawers icon size |  | 24dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.active.focus.label-text.color` | Navigation drawers active focus label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.hover.label-text.color` | Navigation drawers active hover label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.label-text.color` | Navigation drawers active label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.pressed.label-text.color` | Navigation drawers active pressed label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.inactive.focus.label-text.color` | Navigation drawers inactive focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.hover.label-text.color` | Navigation drawers inactive hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.label-text.color` | Navigation drawers inactive label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-drawer.inactive.pressed.label-text.color` | Navigation drawers inactive pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.label-text.font` | Navigation drawers label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-drawer.label-text.line-height` | Navigation drawers label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.navigation-drawer.label-text.size` | Navigation drawers label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.navigation-drawer.label-text.tracking` | Navigation drawers label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.navigation-drawer.label-text.weight` | Navigation drawers label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-drawer.active.label-text.weight` | Navigation drawers active label text weight | md.sys.typescale.label-large.weight.prominent → md.ref.typeface.weight-bold | 700 |
| `md.comp.navigation-drawer.label-text.type` | Navigation drawers label text type | md.comp.navigation-drawer.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**Large badge label**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.large-badge-label.color` | Navigation drawers large badge label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.navigation-drawer.large-badge-label.font` | Navigation drawers large badge label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.navigation-drawer.large-badge-label.line-height` | Navigation drawers large badge label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.navigation-drawer.large-badge-label.size` | Navigation drawers large badge label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.navigation-drawer.large-badge-label.tracking` | Navigation drawers large badge label tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.navigation-drawer.large-badge-label.weight` | Navigation drawers large badge label weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.navigation-drawer.large-badge-label.type` | Navigation drawers large badge label type | md.comp.navigation-drawer.large-badge-label.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.active.focus.state-layer.color` | Navigation drawers active focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.hover.state-layer.color` | Navigation drawers active hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.active.pressed.state-layer.color` | Navigation drawers active pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.inactive.focus.state-layer.color` | Navigation drawers inactive focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.hover.state-layer.color` | Navigation drawers inactive hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.navigation-drawer.inactive.pressed.state-layer.color` | Navigation drawers inactive pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.navigation-drawer.focus.state-layer.opacity` | Navigation drawers focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.navigation-drawer.hover.state-layer.opacity` | Navigation drawers hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.navigation-drawer.pressed.state-layer.opacity` | Navigation drawers pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**[Deprecated] Scrim**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.navigation-drawer.scrim.color` *(deprecated)* | Navigation drawers scrim color | md.ref.palette.neutral-variant20 | #322F37 |
| `md.comp.navigation-drawer.scrim.opacity` *(deprecated)* | Navigation drawers scrim opacity |  | 0.4 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Navigation drawer diagram numbering 9 color roles.]*

Navigation drawer color roles used for light and dark schemes:

1. Surface container low
2. On surface variant
3. On secondary container
4. On secondary container
5. Secondary container
6. On secondary container
7. On surface variant
8. On surface variant
9. Scrim

For divider color roles, go to [divider specs](https://m3.material.io/components/divider/specs).

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](https://m3.material.io/foundations/interaction/states/overview)

*[Image: 4 navigation drawers illustrating enabled, hovered, focused, and pressed states.]*

Navigation drawer states:

1. Enabled
2. Hovered
3. Focused
4. Pressed

[State specs are in the tokens module above](https://m3.material.io/components/navigation-drawer/specs#6207b00f-a259-41d2-8146-b6efc6380976)

## Measurements

### Standard navigation drawer

*[Image: Standard navigation drawer with measurements shown for various elements.]*

Element size measurements

*[Image: Standard navigation drawer with measurements shown for padding and margins.]*

Padding and margins

| Attribute | Value |
| --- | --- |
| Container height | 100% |
| Container width | 360dp |
| Container shape | 0,16,16,0dp corner radii |
| Icon size | 24dp |
| Active indicator height | 56dp |
| Active indicator shape | 28dp |
| Active indicator width | 336dp |
| Horizontal label alignment | Start-aligned |
| Left padding | 28dp |
| Right padding | 28dp |
| Active indicator padding | 12dp |
| Padding between elements | 0dp |

### Modal navigation drawer

*[Image: Modal navigation drawer with measurements shown for various elements.]*

Element size measurements

*[Image: Modal navigation drawer with measurements shown for padding and margins.]*

Padding and margins

| Attribute | Value |
| --- | --- |
| Container height | 100% |
| Container width | 360dp |
| Icon size | 24dp |
| Active indicator height | 56dp |
| Active indicator shape | 28dp |
| Active indicator width | 336dp |
| Horizontal label alignment | Start-aligned |
| Left padding | 28dp |
| Right padding | 28dp |
| Active indicator padding | 12dp |
| Padding between elements | 0dp |
