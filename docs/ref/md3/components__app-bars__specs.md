Source: https://m3.material.io/components/app-bars/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-24T06:22:06.561Z

# App bars — Specs

## Variants

*[Image: 4 variants of app bars.]*

1. Search app bar
2. Small
3. Medium flexible
4. Large flexible

### Baseline variants

The baseline M3 **medium** and **large** app bars are no longer recommended in M3 Expressive, and should be replaced with **medium flexible** and **large flexible** app bars, which are similar visually, but have multi-line support, a shorter height, and can contain a wide variety of elements, like images. [Jump to baseline app bar specs](https://m3.material.io/components/app-bars/specs#faec9baf-140f-41dc-8b88-2792e90d9d5d)

*[Image: 2 baseline app bar variants, medium and large.]*

Baseline variants

1. Medium
2. Large

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Search app bar | -- | Available |
| Small | Available | Available |
| Center-aligned | Available | Merged into **small**.  Use centered-text configuration. |
| Medium (baseline) | Available | Not recommended.  Use **medium flexible** |
| Medium flexible | -- | Available |
| Large (baseline) | Available | Not recommended.  Use **large flexible** |
| Large flexible | -- | Available |

## Configurations

### Text alignment

*[Image: 4 variants of app bars with different left and center aligned text headlines.]*

Text labels, including supporting text, can be aligned to the leading edge or centered

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Text alignment | Leading edge (default) | Available | Available |
| Centered | -- | Available |

## Tokens & specs

Select a token set to view in the table's menu. App bar token sets are organized into a common token set, and size-specific tokens. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: App bar - Common (`md.comp.app-bar`)

Common tokens for all app bars.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.container.color` | App bar container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.app-bar.search.container.color` | Search container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.app-bar.search.label.color` | Search label color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.app-bar.on-scroll.container.color` | App bar container color on scroll | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.app-bar.search.on-scroll.container.color` | Search container color on scroll | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.app-bar.container.elevation` | App bar container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.app-bar.on-scroll.container.elevation` | App bar container elevation on scroll | md.sys.elevation.level2 | 3dp |
| `md.comp.app-bar.title.color` | App bar title text | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.app-bar.subtitle.color` | App bar subtitle text | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.app-bar.leading-icon.color` | App bar leading icon  | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.app-bar.trailing-icon.color` | App bar trailing icon  | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Spacing**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.leading-space` | App bar left padding | md.sys.measurement.space50 | 4dp |
| `md.comp.app-bar.trailing-space` | App bar right padding | md.sys.measurement.space50 | 4dp |
| `md.comp.app-bar.icon-button-space` | App bar icon spacing | md.sys.measurement.space0 | 0dp |
| `md.comp.app-bar.search.leading-space` | Search left padding | md.sys.measurement.space100 | 8dp |
| `md.comp.app-bar.search.trailing-space` | Search right padding | md.sys.measurement.space100 | 8dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.container.shape` | App bar container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.avatar.size` | App bar avatar size |  | 32dp |
| `md.comp.app-bar.icon.size` | App bar icon size |  | 24dp |

#### Token set: App bar - Size - Small (`md.comp.app-bar.small`)

For the expressive small app bar and search app bar.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.small.container.height` | App bar small container height |  | 64dp |
| `md.comp.app-bar.small.title.font` | App bar small title font | md.sys.typescale.title-large → md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto; weight 400; size 22pt; line-height 28pt; tracking 0pt |
| `md.comp.app-bar.small.subtitle.font` | App bar small subtitle font | md.sys.typescale.label-medium → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |
| `md.comp.app-bar.small.icon.size` *(deprecated)* | App bar small icon button size |  | 24dp |
| `md.comp.app-bar.small.search.container.height` | Search container height |  | 56dp |
| `md.comp.app-bar.small.search.container.shape` | Search container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.app-bar.small.search.label-text.font` | Search title font | md.sys.typescale.body-large → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |

#### Token set: App bar - Size - Medium Flexible (`md.comp.app-bar.medium-flexible`)

For the medium flexible app bar.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.medium-flexible.container.height` | App bar medium flexible container height |  | 112dp |
| `md.comp.app-bar.medium-flexible.with-subtitle.container.height` | App bar medium flexible container height with subtitle |  | 136dp |
| `md.comp.app-bar.medium-flexible.title.font` | App bar medium Title font | md.sys.typescale.headline-medium → md.sys.typescale.headline-medium.font → md.ref.typeface.brand | Roboto; weight 400; size 28pt; line-height 36pt; tracking 0pt |
| `md.comp.app-bar.medium-flexible.subtitle.font` | App bar medium Subtitle font | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

#### Token set: App bar - Size - Large Flexible (`md.comp.app-bar.large-flexible`)

For the large flexible app bar.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.large-flexible.container.height` | App bar large flexible container height |  | 120dp |
| `md.comp.app-bar.large-flexible.with-subtitle.container.height` | App bar large flexible container height with subtitle |  | 152dp |
| `md.comp.app-bar.large-flexible.title.font` | App bar large Title font | md.sys.typescale.display-small → md.sys.typescale.display-small.font → md.ref.typeface.brand | Roboto; weight 400; size 36pt; line-height 44pt; tracking 0pt |
| `md.comp.app-bar.large-flexible.subtitle.font` | App bar large Subtitle font | md.sys.typescale.title-medium → md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 16pt; line-height 24pt; tracking 0.15pt |

### Search component tokens & specs

The default search component tokens are used in the search app bar.

#### Token set: Search - View (`md.comp.search-view`)

For baseline search view and expressive search when activated.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-view.container.color` | Search view container color | dark: md.sys.color.surface-container-high → md.ref.palette.neutral17<br>light: md.sys.color.surface-container-high → md.ref.palette.neutral92 | dark: #2B2930<br>light: #ECE6F0 |
| `md.comp.search-view.contained.background.color` | Search view contained background color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.search-view.container.elevation` | Search view container background elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.search-view.header.supporting-text.color` | Search view header supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.search-view.header.input-text.color` | Search view header input text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.search-view.header.leading-icon.color` | Search view header leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.search-view.header.trailing-icon.color` | Search view header trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.search-view.divider.color` | Search view divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |

**Common tokens**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-view.full-screen.container.shape` | Search view full screen container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.search-view.header.supporting-text.type` | Search view header supporting text type | md.comp.search-view.header.supporting-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.search-view.header.supporting-text.font` | Search view header supporting text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.search-view.header.supporting-text.line-height` | Search view header supporting text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.search-view.header.supporting-text.size` | Search view header supporting text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.search-view.header.supporting-text.weight` | Search view header supporting text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.search-view.header.supporting-text.tracking` | Search view header supporting text tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.search-view.header.input-text.type` | Search view header input text type | md.comp.search-view.header.input-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.search-view.header.input-text.font` | Search view header input text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.search-view.header.input-text.line-height` | Search view header input text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.search-view.header.input-text.size` | Search view header input text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.search-view.header.input-text.weight` | Search view header input text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.search-view.header.input-text.tracking` | Search view header input text tracking | md.sys.typescale.body-large.tracking | 0.5pt |

**Contained (expressive)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-view.contained.leading-margin` | Search view contained leading margin | md.sys.measurement.space150 | 12dp |
| `md.comp.search-view.contained.trailing-margin` | Search view contained trailing margin | md.sys.measurement.space150 | 12dp |
| `md.comp.search-view.contained.docked.bar-results.gap` | Search view contained docked bar results gap | md.sys.measurement.space25 | 2dp |
| `md.comp.search-view.contained.docked.results.shape` | Search view contained docked results shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.search-view.contained.docked.bar.shape` | Search view contained docked bar shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.search-view.contained.full-screen.bar.container.height` | Search view contained full screen bar container height |  | 56dp |
| `md.comp.search-view.contained.icon-label.gap` | Search view contained icon label gap | md.sys.measurement.space50 | 4dp |

**Divided (baseline)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-view.docked.container.shape` | Search view docked container shape | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |
| `md.comp.search-view.full-screen.header.container.height` | Search view full screen header container height |  | 72dp |
| `md.comp.search-view.docked.header.container.height` | Search view docked header container height |  | 56dp |
| `md.comp.search-view.leading-space` | Search view leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-view.trailing-space` | Search view trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-view.leading-icon.leading-icon-label-space` | Search view leading icon leading icon label space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-view.trailing-icon.label-trailing-icon-space` | Search view trailing icon label trailing icon space | md.sys.measurement.space200 | 16dp |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-view.container.surface-tint-layer.color` *(deprecated)* | Search view container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

#### Token set: Search - Bar (`md.comp.search-bar`)

For baseline search bar and expressive search.

**Common tokens**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.container.height` | Search bar container height |  | 56dp |
| `md.comp.search-bar.container.shape` | Search bar container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.search-bar.avatar.size` | Search bar avatar size |  | 30dp |
| `md.comp.search-bar.avatar.shape` | Search bar avatar shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.search-bar.icon.size` | Search bar icon size |  | 24dp |
| `md.comp.search-bar.supporting-text.type` | Search bar supporting text type | md.comp.search-bar.supporting-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.search-bar.supporting-text.font` | Search bar supporting text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.search-bar.supporting-text.line-height` | Search bar supporting text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.search-bar.supporting-text.size` | Search bar supporting text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.search-bar.supporting-text.weight` | Search bar supporting text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.search-bar.supporting-text.tracking` | Search bar supporting text tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.search-bar.input-text.type` | Search bar input text type | md.comp.search-bar.input-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.search-bar.input-text.font` | Search bar input text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.search-bar.input-text.line-height` | Search bar input text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.search-bar.input-text.size` | Search bar input text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.search-bar.input-text.weight` | Search bar input text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.search-bar.input-text.tracking` | Search bar input text tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.search-bar.container.surface-tint-layer.color` *(deprecated)* | Search bar container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Contained (expressive)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.contained.leading-margin` | Search bar contained pane leading margin | md.sys.measurement.space300 | 24dp |
| `md.comp.search-bar.contained.trailing-margin` | Search bar contained pane trailing margin | md.sys.measurement.space300 | 24dp |
| `md.comp.search-bar.contained.motion.spring` | Search bar contained motion | md.sys.motion.spring.fast.spatial → md.sys.motion.spring.fast.spatial.damping |  |
| `md.comp.search-bar.contained.leading-space` | Search bar contained leading space | md.sys.measurement.space50 | 4dp |
| `md.comp.search-bar.contained.trailing-space` | Search bar contained trailing space | md.sys.measurement.space50 | 4dp |
| `md.comp.search-bar.contained.no-actions.leading-space` | Search bar contained no actions leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-bar.contained.no-actions.trailing-space` | Search bar contained no actions trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-bar.contained.icon-label.gap` | Search bar contained icon label gap | md.sys.measurement.space50 | 4dp |
| `md.comp.search-bar.contained.avatar.target-size` | Search bar contained avatar target size |  | 48dp |
| `md.comp.search-bar.contained.trailing-actions.gap` | Search bar contained trailing actions gap | md.sys.measurement.space0 | 0dp |
| `md.comp.search-bar.contained.trailing-actions.leading-space` | Search bar contained trailing actions leading space | md.sys.measurement.space50 | 4dp |
| `md.comp.search-bar.contained.trailing-actions.trailing-space` | Search bar contained trailing actions trailing space | md.sys.measurement.space50 | 4dp |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.container.color` | Search bar container color | dark: md.sys.color.surface-container-high → md.ref.palette.neutral17<br>light: md.sys.color.surface-container-high → md.ref.palette.neutral92 | dark: #2B2930<br>light: #ECE6F0 |
| `md.comp.search-bar.container.elevation` | Search bar container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.search-bar.leading-icon.color` | Search bar leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.search-bar.trailing-icon.color` | Search bar trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.search-bar.supporting-text.color` | Search bar supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.search-bar.input-text.color` | Search bar input text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.hover.state-layer.color` | Search bar hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.search-bar.hover.state-layer.opacity` | Search bar hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.search-bar.hover.supporting-text.color` | Search bar hover supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Baseline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.leading-space` | Search bar leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-bar.trailing-space` | Search bar trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-bar.leading-icon.leading-icon-label-space` | Search bar leading icon leading icon label space | md.sys.measurement.space200 | 16dp |
| `md.comp.search-bar.trailing-icon.label-trailing-icon-space` | Search bar trailing icon label trailing icon space | md.sys.measurement.space200 | 16dp |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.pressed.state-layer.color` | Search bar pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.search-bar.pressed.state-layer.opacity` | Search bar pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.search-bar.pressed.supporting-text.color` | Search bar pressed supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.search-bar.focus.indicator.color` | Search bar focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.search-bar.focus.indicator.thickness` | Search bar focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.search-bar.focus.indicator.outline.offset` | Search bar focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

## Anatomy

*[Image: 5 elements of the component.]*

1. Container
2. Leading button
3. Trailing elements
4. Headline
5. Subtitle

App bars can be customized to include:

- An image or logo
- A subtitle
- A filled icon button

Avoid customizing the size of the heading and subtitle, or adding too many actions.

*[Image: 3 app bars: 1 with a newspaper logo, 1 with a subtitle, and 1 with a filled icon button.]*

The app bar can have different layouts depending on which elements are shown

### Search

The search app bar can include trailing actions inside and outside the search bar. When the search bar is selected, it should open the search view component.

*[Image: 5 elements of the search app bar.]*

1. Container
2. Leading icon button
3. Hinted search text
4. Trailing icon or avatar
5. Search container

*[Image: 3 layouts of icons in the search app bar.]*

1. A leading element and a trailing element outside search
2. A leading element, a trailing element inside search, and a trailing element outside search
3. A leading element and two trailing elements outside search

### Image

An image can be placed in the app bar. In small app bars, this can replace the label text.

*[Image: Graphic replacing text headline content.]*

Images can be added to app bars and can replace label text on small app bars

### Filled trailing icon button

The app bar's trailing icon buttons can be replaced with a single, primary, or tonal filled icon button in default or wide sizes.

*[Image: App bars configured with filled trailing icons.]*

The trailing icons can be configured to be a single filled icon button

### Subtitle

*[Image: App bars configured with subtitles below their headlines.]*

The medium flexible and large flexible app bars hug the text contents, so they are taller when a subtitle is visible

1. Small
2. Small with subtitle
3. Medium flexible
4. Medium flexible with subtitle
5. Large flexible
6. Large flexible with subtitle

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

All app bars share the same color roles. On scroll, the container changes color to **surface container**.

*[Image: 4 color roles of the leading edge app bar in light and dark scheme.]*

App bar color roles used for light and dark themes:

1. Surface
2. On surface
3. On surface variant
4. On surface
5. On surface variant
6. Surface container (on scroll)

*[Image: 4 color roles of the center-aligned app bar in light and dark scheme.]*

Search app bar color roles used for light and dark themes:

1. Surface
2. On surface variant
3. On surface variant
4. On surface variant
5. Surface container
6. Surface container
7. Surface container highest

### Scroll states

*[Image: Color roles for app bars when flat and on scroll.]*

The app bar changes color when flat or on scroll. The search bar can also change color on scroll.

1. Flat
2. On scroll

## Measurements

### Search app bar

*[Image: Search app bar size and padding measurements.]*

Search app bar padding and size measurements

### Small app bar

*[Image: Small app bar size and padding measurements.]*

Small app bar padding and size measurements

### Medium flexible app bar

*[Image: Medium flexible app bar padding and size measurements.]*

Medium flexible app bar padding and size measurements

### Large flexible app bar

*[Image: Large flexible app bar padding and size measurements]*

Large flexible app bar padding and size measurements

---

## Baseline app bars

The **medium** and **large** app bars are no longer recommended in M3 Expressive. Use the **medium flexible** and **large flexible** app bars in their place.

*[Image: 4 elements of medium and large app bars.]*

Medium and large app bars have the same elements:

1. Container
2. Leading button
3. Trailing icons
4. Headline

### Tokens & specs

Select a token set to view in the table's menu. Baseline app bar token sets are organized into medium, large, and older baseline token sets. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: App bar - Size - Medium (baseline) (`md.comp.app-bar.medium`)

For the baseline medium app bar. In expressive, consider using medium flexible instead `md.comp.app-bar.medium-flexible`.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.medium.container.height` | App bar medium container height |  | 112dp |
| `md.comp.app-bar.medium.title.font` | App bar medium title font | md.sys.typescale.headline-small → md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto; weight 400; size 24pt; line-height 32pt; tracking 0pt |
| `md.comp.app-bar.medium.icon.size` *(deprecated)* | App bar medium icon button size |  | 24dp |
| `md.comp.app-bar.medium.subtitle.font` *(deprecated)* | App bar medium subtitle font | md.sys.typescale.label-large → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

#### Token set: App bar - Size - Large (baseline) (`md.comp.app-bar.large`)

For the baseline large app bar. In expressive, consider using large flexible instead `md.comp.app-bar.large-flexible`.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.app-bar.large.container.height` | App bar large container height |  | 152dp |
| `md.comp.app-bar.large.title.font` | App bar large title font | md.sys.typescale.headline-medium → md.sys.typescale.headline-medium.font → md.ref.typeface.brand | Roboto; weight 400; size 28pt; line-height 36pt; tracking 0pt |
| `md.comp.app-bar.large.icon.size` *(deprecated)* | App bar large icon button size |  | 24dp |
| `md.comp.app-bar.large.subtitle.font` *(deprecated)* | App bar large subtitle font | md.sys.typescale.title-medium → md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 16pt; line-height 24pt; tracking 0.15pt |

#### Token set: [Deprecated] Top app bar - Small (`md.comp.top-app-bar.small`)

This token set is deprecated. Use `md.comp.app-bar` and `md.comp.app-bar.small` tokens instead.

Original tokens for the small top app bar.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.container.color` *(deprecated)* | Top app bar (small) container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.top-app-bar.small.on-scroll.container.color` *(deprecated)* | Top app bar (small) on-scroll container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.top-app-bar.small.container.shape` *(deprecated)* | Top app bar (small) container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.top-app-bar.small.container.height` *(deprecated)* | Top app bar (small) container height |  | 64dp |
| `md.comp.top-app-bar.small.container.elevation` *(deprecated)* | Top app bar (small) container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.top-app-bar.small.container.surface-tint-layer.color` *(deprecated)* | Top app bar (small) container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.top-app-bar.small.on-scroll.container.shadow-color` *(deprecated)* | Top app bar (small) on scroll container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |

**[Deprecated] Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.headline.font` *(deprecated)* | Top app bar (small) headline font | md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto |
| `md.comp.top-app-bar.small.headline.line-height` *(deprecated)* | Top app bar (small) headline height | md.sys.typescale.title-large.line-height | 28pt |
| `md.comp.top-app-bar.small.headline.size` *(deprecated)* | Top app bar (small) headline size | md.sys.typescale.title-large.size | 22pt |
| `md.comp.top-app-bar.small.headline.tracking` *(deprecated)* | Top app bar (small) headline tracking | md.sys.typescale.title-large.tracking | 0pt |
| `md.comp.top-app-bar.small.headline.weight` *(deprecated)* | Top app bar (small) headline weight | md.sys.typescale.title-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.top-app-bar.small.headline.type` *(deprecated)* | Type style | md.comp.top-app-bar.small.headline.font → md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto; weight 400; size 22pt; line-height 28pt; tracking 0pt |
| `md.comp.top-app-bar.small.headline.color` *(deprecated)* | Top app bar (small) headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.leading-icon.size` *(deprecated)* | Top app bar (small) leading icon size |  | 24dp |
| `md.comp.top-app-bar.small.leading-icon.color` *(deprecated)* | Top app bar (small) leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] On scroll**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.on-scroll.container.elevation` *(deprecated)* | Top app bar (small) on scroll container elevation | md.sys.elevation.level2 | 3dp |

**[Deprecated] Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.trailing-icon.size` *(deprecated)* | Top app bar (small) trailing icon size |  | 24dp |
| `md.comp.top-app-bar.small.trailing-icon.color` *(deprecated)* | Top app bar (small) trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: [Deprecated] Top app bar - Medium (`md.comp.top-app-bar.medium`)

This token set is deprecated. Use `md.comp.app-bar` and `md.comp.app-bar.medium` tokens instead. Original tokens for the medium top app bar.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.medium.container.color` *(deprecated)* | Top app bar (medium) container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.top-app-bar.medium.container.shape` *(deprecated)* | Top app bar (medium) container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.top-app-bar.medium.container.height` *(deprecated)* | Top app bar (medium) container height |  | 112dp |
| `md.comp.top-app-bar.medium.container.elevation` *(deprecated)* | Top app bar (medium) container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.top-app-bar.medium.container.surface-tint-layer.color` *(deprecated)* | Top app bar (medium) container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.medium.headline.font` *(deprecated)* | Top app bar (medium) headline font | md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto |
| `md.comp.top-app-bar.medium.headline.line-height` *(deprecated)* | Top app bar (medium) headline height | md.sys.typescale.headline-small.line-height | 32pt |
| `md.comp.top-app-bar.medium.headline.size` *(deprecated)* | Top app bar (medium) headline size | md.sys.typescale.headline-small.size | 24pt |
| `md.comp.top-app-bar.medium.headline.tracking` *(deprecated)* | Top app bar (medium) headline tracking | md.sys.typescale.headline-small.tracking | 0pt |
| `md.comp.top-app-bar.medium.headline.weight` *(deprecated)* | Top app bar (medium) headline weight | md.sys.typescale.headline-small.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.top-app-bar.medium.headline.type` *(deprecated)* | Type style | md.comp.top-app-bar.medium.headline.font → md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto; weight 400; size 24pt; line-height 32pt; tracking 0pt |
| `md.comp.top-app-bar.medium.headline.color` *(deprecated)* | Top app bar (medium) headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.medium.leading-icon.size` *(deprecated)* | Top app bar (medium) leading icon size |  | 24dp |
| `md.comp.top-app-bar.medium.leading-icon.color` *(deprecated)* | Top app bar (medium) leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.medium.trailing-icon.size` *(deprecated)* | Top app bar (medium) trailing icon size |  | 24dp |
| `md.comp.top-app-bar.medium.trailing-icon.color` *(deprecated)* | Top app bar (medium) trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: [Deprecated] Top app bar -  Large (`md.comp.top-app-bar.large`)

This token set is deprecated. Use `md.comp.app-bar` and `md.comp.app-bar.large` tokens instead. Original tokens for the large top app bar.

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.large.container.color` *(deprecated)* | Top app bar (large) container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.top-app-bar.large.container.shape` *(deprecated)* | Top app bar (large) container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.top-app-bar.large.container.height` *(deprecated)* | Top app bar (large) container height |  | 152dp |
| `md.comp.top-app-bar.large.container.elevation` *(deprecated)* | Top app bar (large) container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.top-app-bar.large.container.surface-tint-layer.color` *(deprecated)* | Top app bar (large) container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.large.headline.font` *(deprecated)* | Top app bar (large) headline font | md.sys.typescale.headline-medium.font → md.ref.typeface.brand | Roboto |
| `md.comp.top-app-bar.large.headline.line-height` *(deprecated)* | Top app bar (large) headline height | md.sys.typescale.headline-medium.line-height | 36pt |
| `md.comp.top-app-bar.large.headline.size` *(deprecated)* | Top app bar (large) headline size | md.sys.typescale.headline-medium.size | 28pt |
| `md.comp.top-app-bar.large.headline.tracking` *(deprecated)* | Top app bar (large) headline tracking | md.sys.typescale.headline-medium.tracking | 0pt |
| `md.comp.top-app-bar.large.headline.weight` *(deprecated)* | Top app bar (large) headline weight | md.sys.typescale.headline-medium.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.top-app-bar.large.headline.type` *(deprecated)* | Type style | md.comp.top-app-bar.large.headline.font → md.sys.typescale.headline-medium.font → md.ref.typeface.brand | Roboto; weight 400; size 28pt; line-height 36pt; tracking 0pt |
| `md.comp.top-app-bar.large.headline.color` *(deprecated)* | Top app bar (large) headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.large.leading-icon.size` *(deprecated)* | Top app bar (large) leading icon size |  | 24dp |
| `md.comp.top-app-bar.large.leading-icon.color` *(deprecated)* | Top app bar (large) leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**[Deprecated] Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.large.trailing-icon.size` *(deprecated)* | Top app bar (large) trailing icon size |  | 24dp |
| `md.comp.top-app-bar.large.trailing-icon.color` *(deprecated)* | Top app bar (large) trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: [Deprecated] Top app bar - Small, Center-aligned (`md.comp.top-app-bar.small.centered`)

This token set is deprecated. Use `md.comp.app-bar` and `md.comp.app-bar.small` tokens instead. 

Original component tokens for the center-aligned top app bar. 

**Avatar**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.avatar.size` *(deprecated)* | Top app bar (small) on scroll avatar size |  | 30dp |
| `md.comp.top-app-bar.small.centered.avatar.shape` *(deprecated)* | Top app bar (small) on scroll avatar shape | md.sys.shape.corner.full | fully rounded (circular) |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.on-scroll.container.color` *(deprecated)* | Top app bar (small centered) on-scroll container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.top-app-bar.small.centered.container.color` *(deprecated)* | Top app bar (small centered) container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.top-app-bar.small.centered.container.shape` *(deprecated)* | Top app bar (small centered) container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.top-app-bar.small.centered.container.height` *(deprecated)* | Top app bar (small centered) container height |  | 64dp |
| `md.comp.top-app-bar.small.centered.container.elevation` *(deprecated)* | Top app bar (small centered) container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.top-app-bar.small.centered.container.surface-tint-layer.color` *(deprecated)* | Top app bar (small centered) container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.top-app-bar.small.centered.on-scroll.container.shadow-color` *(deprecated)* | Top app bar (small) on scroll container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |

**Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.headline.font` *(deprecated)* | Top app bar (small centered) headline font | md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto |
| `md.comp.top-app-bar.small.centered.headline.line-height` *(deprecated)* | Top app bar (small centered) headline height | md.sys.typescale.title-large.line-height | 28pt |
| `md.comp.top-app-bar.small.centered.headline.size` *(deprecated)* | Top app bar (small centered) headline size | md.sys.typescale.title-large.size | 22pt |
| `md.comp.top-app-bar.small.centered.headline.tracking` *(deprecated)* | Top app bar (small centered) headline tracking | md.sys.typescale.title-large.tracking | 0pt |
| `md.comp.top-app-bar.small.centered.headline.weight` *(deprecated)* | Top app bar (small centered) headline weight | md.sys.typescale.title-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.top-app-bar.small.centered.headline.type` *(deprecated)* | Type style | md.comp.top-app-bar.small.centered.headline.font → md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto; weight 400; size 22pt; line-height 28pt; tracking 0pt |
| `md.comp.top-app-bar.small.centered.headline.color` *(deprecated)* | Top app bar (small centered) headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.leading-icon.size` *(deprecated)* | Top app bar (small centered) leading icon size |  | 24dp |
| `md.comp.top-app-bar.small.centered.leading-icon.color` *(deprecated)* | Top app bar (small centered) leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**On scroll**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.on-scroll.container.elevation` *(deprecated)* | Top app bar (small) on scroll container elevation | md.sys.elevation.level2 | 3dp |

**Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.top-app-bar.small.centered.trailing-icon.size` *(deprecated)* | Top app bar (small centered) trailing icon size |  | 24dp |
| `md.comp.top-app-bar.small.centered.trailing-icon.color` *(deprecated)* | Top app bar (small centered) trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 4 color roles of the medium top app bar in light and dark scheme.]*

Medium top app bar color roles used for light and dark schemes:

1. Surface
2. On surface
3. On surface
4. On surface variant

### Measurements

#### Medium app bar

*[Image: Diagram of medium app bar padding and size measurements.]*

Medium app bar padding and size measurements

#### Large app bar

*[Image: Diagram of large app bar padding and size measurements.]*

Large app bar padding and size measurements
