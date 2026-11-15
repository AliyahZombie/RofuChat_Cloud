Source: https://m3.material.io/components/search/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-27T04:04:05.736Z

# Search — Specs

## Variants

*[Video: Typing “Ping” into a search bar reveals a list of email results.]*

When a person executes a **search**, results appear in a list below the search bar

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Search | Available | Available |

## Configurations

### Style

Search comes in two styles:

- Contained: Has an expressive look and feel. It uses a filled container to separate a search bar from a list of suggestions or results
- Divided (baseline): Doesn’t have the latest visual style, motion, or flexibility

*[Image: An email inbox search bar in a contained style.]*

The contained style has a persistent, filled container, expressive motion, and rounded shape

*[Image: An email inbox search bar in a divided style.]*

The divided (baseline) style uses a divider to separate the search bar from suggestions and results

### Layout

Search suggestions and results appear in customizable lists, with two layout options: full-screen and docked. [More on search layouts](https://m3.material.io/components/search/guidelines#4f6c921c-795f-4e06-9b12-27ae7d502adb)

*[Image: Full-screen search results with a search bar in the contained style.]*

Full-screen layout in the contained style

*[Image: Docked search results with a search bar in the contained style.]*

Docked layout in the contained style

*[Image: Full-screen search results with a search bar in the divided style.]*

Full-screen layout in the divided style

*[Image: Docked search results with a search bar in the divided style.]*

Docked layout in the divided style

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Style | Contained | -- | Available |
|  | Divided | Available | Not recommended. Use contained. |
| Layout | Docked, full-screen | Available | Available |

## Tokens & specs

Use the table's menu to select a token set. The **search bar** set only contains tokens for the unfocused search bar. The **search view** set contains all other tokens when interacting with search, including all styles and layouts. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

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

Search includes a search bar and a container for suggestions and results. The container is empty by default. Use the list component to add content. In the divided (baseline) style, a divider separates the search bar and results.

*[Image: 6 elements of search.]*

1. Search bar container
2. Leading icon
3. Supporting text
4. Trailing icon and avatar (optional)
5. Input text
6. Container for search suggestions or results

### Examples

1. With avatar
2. With one trailing icon button
3. With two trailing icon buttons
4. With trailing icon button and avatar

*[Image: 4 search bars with different trailing elements.]*

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.

### Full-screen layout

*[Image: 6 full-screen search color roles in light and dark themes.]*

Full-screen search color roles used in light and dark themes:

1. Surface container low
2. On surface variant
3. On surface variant
4. Surface container high
5. On surface variant
6. On surface

### Docked layout

*[Image: 6 docked search color roles in light and dark themes.]*

Docked search color roles used in light and dark themes:

1. Surface container high
2. On surface variant
3. On surface variant
4. Surface container high
5. On surface variant
6. On surface

## States

States are visual representations used to communicate the status of a component or an interactive element. In [focused search](https://m3.material.io/components/search/guidelines#a9b2df31-8561-4326-82cd-41ed6532b765), individual elements maintain their own interaction states. [Learn more about interaction states](https://m3.material.io/foundations/interaction/states/overview)

### Search bar

*[Image: 4 search bar states in light and dark mode.]*

1. Enabled
2. Hovered
3. Focused
4. Pressed (ripple)

### Search suggestions & results

Search includes a container for suggestions and results. The container is empty by default. Use the list component to add content.

*[Image: 4 search result states in light and dark mode.]*

1. Enabled
2. Hovered
3. Focused
4. Pressed (ripple)

## Measurements

### Search bar

*[Image: Search bar with leading and trailing icon size and padding measurements.]*

Unfocused search bar with leading and trailing icon measurements

*[Image: Search bar with trailing avatar size and padding measurements.]*

Unfocused search bar with avatar measurements

In M3 Expressive, the search bar expands when focused. The margins change from 24dp to 12dp.

*[Image: Unfocused search bar margins of 24dp.]*

Unfocused search bar margin measurements

*[Image: Focused search bar margins of 12dp.]*

Focused search bar margin measurements

| Element | Attribute | Value |
| --- | --- | --- |
| Container | Width | Min: 360dp, max: 720dp |
| Height | 56dp |
| Label alignment | Start-aligned |
| Leading padding | Unfocused: 24dp, focused: 12dp |
| Trailing padding | Unfocused: 24dp, focused: 12dp |
| Leading icon and label padding (from tap target) | 4dp |
| Label and trailing icon padding (from tap target) | 4dp |
| Avatar | Size | 30dp |

### Focused search

#### Contained style

*[Image: Full-screen layout size and padding measurements in contained style.]*

Full-screen search padding and size measurements for contained style

*[Image: Docked layout size and padding measurements in contained style.]*

Docked search padding and size measurements for contained style

| Element | Attribute | Value |
| --- | --- | --- |
| Full-screen container | Width | Full width |
| Height | Full height |
| Docked container | Width | Min: 360dp, max: 720dp |
| Height | Min: 240dp, max: 2/3 of screen height |
| Search bar container | Height | 56dp |
| Label alignment | Start-aligned |
| Leading padding | 16dp |
| Trailing padding | 16dp |
| Leading icon and label padding (from tap target) | 4dp |
| Leading icon and label padding (from tap target) | 4dp |

#### Divided style

*[Image: Full-screen layout size and padding measurements in divided style.]*

Full-screen search padding and size measurements for divided style

*[Image: Docked layout size and padding measurements in divided style.]*

Docked search padding and size measurements for divided style
