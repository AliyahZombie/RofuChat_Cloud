Source: https://m3.material.io/components/segmented-buttons/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-09-16T18:18:17.328Z

# Segmented buttons — Specs

star

Note:

Segmented buttons are no longer recommended in the Material 3 expressive update. For those who have updated, use the [connected button group](https://m3.material.io/components/button-groups/overview/) instead, which has mostly the same functionality but with an updated visual design.

*[Image: Diagram of segmented button indicating 3 parts of its anatomy.]*

1. Container
2. Icon (optional for unselected state)
3. Label text

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Segmented button - Outlined (`md.comp.outlined-segmented-button`)

This component is not recommended. Use connected button groups instead.

For outlined segmented buttons.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-segmented-button.disabled.outline.color` | Outlined segmented button disabled outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.outline.color` | Outlined segmented button outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.outlined-segmented-button.disabled.outline.opacity` | Outlined segmented button disabled outline opacity |  | 0.12 |
| `md.comp.outlined-segmented-button.outline.width` | Outlined segmented button outline width |  | 1dp |
| `md.comp.outlined-segmented-button.container.height` | Outlined segmented button container height |  | 40dp |
| `md.comp.outlined-segmented-button.selected.container.color` | Outlined segmented button selected container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.outlined-segmented-button.shape` | Outlined segmented button shape | md.sys.shape.corner.full | fully rounded (circular) |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-segmented-button.focus.indicator.color` | Outlined segmented button focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.outlined-segmented-button.focus.indicator.thickness` | Outlined segmented button focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.outlined-segmented-button.focus.indicator.outline.offset` | Outlined segmented button focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-segmented-button.disabled.icon.color` | Outlined segmented button disabled icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.focus.icon.color` | Outlined segmented button unselected focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.hover.icon.color` | Outlined segmented button unselected hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.pressed.icon.color` | Outlined segmented button unselected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.with-icon.icon.color` | Outlined segmented button unselected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.disabled.icon.opacity` | Outlined segmented button disabled icon opacity |  | 0.38 |
| `md.comp.outlined-segmented-button.selected.focus.icon.color` | Outlined segmented button selected focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.hover.icon.color` | Outlined segmented button selected hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.pressed.icon.color` | Outlined segmented button selected pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.with-icon.icon.color` | Outlined segmented button selected icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.with-icon.icon.size` | Outlined segmented button icon size |  | 18dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-segmented-button.disabled.label-text.color` | Outlined segmented button disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.focus.label-text.color` | Outlined segmented button unselected focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.hover.label-text.color` | Outlined segmented button unselected hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.label-text.color` | Outlined segmented button unselected label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.pressed.label-text.color` | Outlined segmented button unselected pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.disabled.label-text.opacity` | Outlined segmented button disabled label text opacity |  | 0.38 |
| `md.comp.outlined-segmented-button.selected.focus.label-text.color` | Outlined segmented button selected focus label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.hover.label-text.color` | Outlined segmented button selected hover label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.label-text.color` | Outlined segmented button selected label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.pressed.label-text.color` | Outlined segmented button selected pressed label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.label-text.font` | Outlined segmented button label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.outlined-segmented-button.label-text.line-height` | Outlined segmented button label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.outlined-segmented-button.label-text.size` | Outlined segmented button label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.outlined-segmented-button.label-text.tracking` | Outlined segmented button label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.outlined-segmented-button.label-text.weight` | Outlined segmented button label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.outlined-segmented-button.label-text.type` | Outlined segmented button label text type | md.comp.outlined-segmented-button.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.outlined-segmented-button.unselected.focus.state-layer.color` | Outlined segmented button unselected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.hover.state-layer.color` | Outlined segmented button unselected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.unselected.pressed.state-layer.color` | Outlined segmented button unselected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.outlined-segmented-button.selected.focus.state-layer.color` | Outlined segmented button selected  focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.hover.state-layer.color` | Outlined segmented button selected hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.selected.pressed.state-layer.color` | Outlined segmented button selected pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.outlined-segmented-button.focus.state-layer.opacity` | Outlined segmented button focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.outlined-segmented-button.hover.state-layer.opacity` | Outlined segmented button hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.outlined-segmented-button.pressed.state-layer.opacity` | Outlined segmented button pressed state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Diagram of segmented button indicating its color mappings]*

Segmented button color roles used for light and dark schemes:

1. On surface
2. Outline
3. Secondary container
4. On secondary container

## States

States are visual representations used to communicate the status of a component or interactive element.  [Learn more about interaction states](https://m3.material.io/foundations/interaction/states/overview)

### Unselected

*[Image: Side by side view of segmented buttons with 5 unselected states.]*

Unselected button states:

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Selected

*[Image: Side by side view of segmented buttons with 4 selected states.]*

Selected button states:

1. Selected
2. Hovered on selected
3. Focused on selected
4. Pressed on selected

## Measurements

*[Image: Diagram indicating layout values, paddings, and target size for segmented buttons]*

1. Padding and container size
2. Target size

| Attribute | Value |
| --- | --- |
| Container width | Dynamic based on labels |
| Segment width | Container width / total segments (Example: 1/3) |
| Height | 40dp |
| Outline width | 1dp |
| Label alignment | Center |
| Left/right padding | Min 12dp |
| Padding between elements | 8dp |
| Target size | 48dp |

### Density

Density can be used in denser UIs where space is limited. Density is only applied to the height.

*[Image: Side by side view of segmented buttons with 4 different density heights]*

Each step down in density removes 4dp from the height
