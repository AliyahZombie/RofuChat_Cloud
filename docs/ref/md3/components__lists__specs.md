Source: https://m3.material.io/components/lists/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-08-06T17:09:16.197Z

# Lists — Specs

## Variants

### Expressive lists

Use the expressive list variant for more flexible styling, highlighted selection states, and customizable slots.

*[Image: 2 expressive lists: a photos list on a tablet, and a song list on mobile.]*

An **expressive list** has a segmented style and round corners

### Baseline lists

Baseline lists are still available to use, but don’t have the latest visual style, selection treatment, and slot functionality.  
  
On web, expressive lists are built on top of baseline lists.

[See baseline list specs](https://m3.material.io/components/lists/specs#94cf7f4d-fe29-4fab-9aae-a99e9b754329)

*[Image: 3 baseline list items with square corners.]*

**Baseline list items** have square corners and standard colors

| **Variants** | **M3** | **M3 Expressive** |
| --- | --- | --- |
| Lists (expressive) | -- | Available |
| Lists (baseline) | Available | Not recommended.  Use expressive lists instead. |

## Configurations

### Styles

The standard and segmented styles are a visual choice, and don’t affect a list’s behavior.

*[Image: A standard list and segmented list in dark mode.]*

1. Standard
2. Segmented

### List selection

A list can have only one selection mode at a time. For example, a single-action list can change to a multi-select list, but can’t be both at once.

*[Image: A single-action list with 4 items and no additional actions.]*

In a **single-action list**, each item is a single tappable area

*[Image: A list with 4 items. Each item has 2 trailing icons for additional actions.]*

**Multi-action list** items include a primary action, and one or more secondary actions

*[Image: A list with 1 item selected.]*

A **single-select list**

*[Image: A list with 2 items selected.]*

A **multi-select list**

### List interactions

Lists can:

- [Expand and collapse](https://m3.material.io/components/lists/guidelines#90a236ee-b587-4361-8911-34006f25a6f1)
- [Swipe to reveal](https://m3.material.io/components/lists/guidelines#01204f7d-ce32-4739-aece-e95db24858c9)*

[More on list interaction accessibility](https://m3.material.io/components/lists/accessibility#a6f937f5-3e1f-4db4-ba35-ac6dd9fef140)

*[Video: 1 list item expands into a list with 6 items, then collapses.]*

A list can **expand** to include multiple items

*[Image: A list item is swiped, and reveals 3 more actions.]*

A list item can be **swiped** to reveal more actions

| **Category** | **Configuration** | **M3** | **M3 Expressive** |
| --- | --- | --- | --- |
| Styles | Standard | Available | Available |
| Segmented | -- | Available |
| Selection modes | Single-action, multi-action,  single-select, multi-select | Available | Available |
| Interactions | Expand, swipe* | Available | Available |

* Swipe-to-reveal interactions are only available on Android Views

## Tokens & specs

Use the table's menu to select a token set. The **common** set combines baseline tokens with new expressive shapes and sizes. The **expand** set has tokens for the expand interaction. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: List - Common (`md.comp.list`)

Common baseline and expressive list tokens. 

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.disabled.state-layer.color` | List list item disabled state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.state-layer.opacity` | List list item disabled state layer opacity |  | 0.1 |
| `md.comp.list.list-item.disabled.label-text.color` | List list item disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.label-text.opacity` | List list item disabled label text opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.supporting-text.color` | List list item disabled supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.supporting-text.opacity` | List list item disabled supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.overline.color` | List list item disabled overline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.overline.opacity` | List list item disabled overline opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.leading-icon.color` | List list item disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.leading-icon.opacity` | List list item disabled leading icon opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.trailing-icon.color` | List list item disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.trailing-icon.opacity` | List list item disabled trailing icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.hover.state-layer.color` | List list item hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.hover.state-layer.opacity` | List list item hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.list.list-item.hover.label-text.color` | List list item hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.hover.leading-icon.icon.color` | List list item hover leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.hover.trailing-icon.icon.color` | List list item hover trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.focus.state-layer.color` | List list item focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.focus.state-layer.opacity` | List list item focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.focus.label-text.color` | List list item focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.focus.leading-icon.icon.color` | List list item focus leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.focus.trailing-icon.icon.color` | List list item focus trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Pressed (ripple)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.pressed.state-layer.color` | List list item pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.pressed.state-layer.opacity` | List list item pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.pressed.label-text.color` | List list item pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.pressed.leading-icon.icon.color` | List list item pressed leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.pressed.trailing-icon.icon.color` | List list item pressed trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Dragged (baseline only)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.dragged.container.elevation` | List list item dragged container color | md.sys.elevation.level4 | 8dp |
| `md.comp.list.list-item.dragged.label-text.color` | List list item dragged label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.dragged.label-text.color` | List list item selected dragged label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.dragged.state-layer.color` | List list item dragged state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.dragged.state-layer.opacity` | List list item dragged state layer opacity | md.sys.state.dragged.state-layer-opacity | 0.16 |
| `md.comp.list.list-item.selected.dragged.state-layer.color` | List list item selected dragged state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.dragged.state-layer.opacity` | List list item selected dragged state layer opacity | md.sys.state.dragged.state-layer-opacity | 0.16 |
| `md.comp.list.list-item.dragged.leading-icon.icon.color` | List list item dragged leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.selected.dragged.leading-icon.color` | List list item selected dragged leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.dragged.trailing-icon.icon.color` | List list item dragged trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.selected.dragged.trailing-icon.color` | List list item selected dragged trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Spacing**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.leading-space` | List list item leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.list-item.trailing-space` | List list item trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.list-item.top-space` | List list item top space | md.sys.measurement.space125 | 10dp |
| `md.comp.list.list-item.bottom-space` | List list item bottom space | md.sys.measurement.space125 | 10dp |
| `md.comp.list.list-item.between-space` | List list item between space | md.sys.measurement.space150 | 12dp |
| `md.comp.list.divider.leading-space` | List list item divider leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.divider.trailing-space` | List list item divider trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.divider.top-space` | List list item divider top space | md.sys.measurement.space0 | 0dp |
| `md.comp.list.divider.bottom-space` | List list item divider bottom space | md.sys.measurement.space0 | 0dp |
| `md.comp.list.segmented.gap` | List segment gap | md.sys.measurement.space25 | 2dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.container.shape` | List container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.container.shape` | List list item container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.list.list-item.container.expressive.shape` | List list item container expressive shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.list.list-item.disabled.container.expressive.shape` | List list item container disabled expressive shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.list.list-item.hovered.container.expressive.shape` | List list item container hovered expressive shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.list.list-item.focused.container.expressive.shape` | List list item container focused expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.pressed.container.expressive.shape` | List list item container pressed expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.dragged.container.expressive.shape` | List list item container dragged expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.container.expressive.shape` | List list item container selected expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.disabled.container.expressive.shape` | List list item container selected disabled expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.hovered.container.expressive.shape` | List list item container selected hovered expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.focused.container.expressive.shape` | List list item container selected focsued expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.pressed.container.expressive.shape` | List list item container selected pressed expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.dragged.container.expressive.shape` | List list item container selected dragged expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.leading-avatar.shape` | List list item leading avatar shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.list.list-item.leading-video.shape` | List list item leading video shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.list.list-item.leading-image.shape` | List list item leading image shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.list.list-item.leading-image.expressive.shape` | List list item leading image expressive shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.list.list-item.selected.container.shape` | List list item selected container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |

**Size and typography**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.leading-avatar-label.type` | List list item leading avatar label type | md.comp.list.list-item.leading-avatar-label.font → md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 16pt; line-height 24pt; tracking 0.15pt |
| `md.comp.list.list-item.leading-avatar.size` | List list item leading avatar size |  | 40dp |
| `md.comp.list.list-item.leading-avatar-label.font` | List list item leading avatar label font | md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.leading-avatar-label.line-height` | List list item leading avatar label line height | md.sys.typescale.title-medium.line-height | 24pt |
| `md.comp.list.list-item.leading-avatar-label.size` | List list item leading avatar label size | md.sys.typescale.title-medium.size | 16pt |
| `md.comp.list.list-item.leading-avatar-label.tracking` | List list item leading avatar label tracking | md.sys.typescale.title-medium.tracking | 0.15pt |
| `md.comp.list.list-item.leading-avatar-label.weight` | List list item leading avatar label weight | md.sys.typescale.title-medium.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.list.list-item.leading-icon.size` | List list item leading icon size |  | 24dp |
| `md.comp.list.list-item.leading-icon.expressive.size` | List list item leading icon expressive size |  | 20dp |
| `md.comp.list.list-item.leading-image.width` | List list item leading image width |  | 56dp |
| `md.comp.list.list-item.leading-image.height` | List list item leading image height |  | 56dp |
| `md.comp.list.list-item.leading-video.width` | List list item leading video width |  | 100dp |
| `md.comp.list.list-item.small.leading-video.width` | List list item small leading video width |  | 100dp |
| `md.comp.list.list-item.small.leading-video.height` | List list item small leading video height |  | 56dp |
| `md.comp.list.list-item.large.leading-video.width` | List list item large leading video width |  | 114dp |
| `md.comp.list.list-item.large.leading-video.height` | List list item large leading video height |  | 64dp |
| `md.comp.list.list-item.one-line.container.height` | One line list item container height |  | 56dp |
| `md.comp.list.list-item.two-line.container.height` | Two lines list item container height |  | 72dp |
| `md.comp.list.list-item.three-line.container.height` | Three lines list item container height |  | 88dp |
| `md.comp.list.list-item.trailing-icon.size` | List list item trailing icon size |  | 24dp |
| `md.comp.list.list-item.trailing-icon.expressive.size` | List list item trailing icon expressive size |  | 20dp |
| `md.comp.list.list-item.label-text.type` | List list item label text type | md.comp.list.list-item.label-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.list.list-item.label-text.font` | List list item label text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.label-text.line-height` | List list item label text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.list.list-item.label-text.size` | List list item label text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.list.list-item.label-text.tracking` | List list item label text tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.list.list-item.label-text.weight` | List list item label text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.list.list-item.trailing-supporting-text.type` | List list item trailing supporting text type | md.comp.list.list-item.trailing-supporting-text.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |
| `md.comp.list.list-item.trailing-supporting-text.font` | List list item trailing supporting text font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.trailing-supporting-text.line-height` | List list item trailing supporting text line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.list.list-item.trailing-supporting-text.size` | List list item trailing supporting text size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.list.list-item.trailing-supporting-text.tracking` | List list item trailing supporting text tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.list.list-item.trailing-supporting-text.weight` | List list item trailing supporting text weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.list.list-item.supporting-text.type` | List list item supporting text type | md.comp.list.list-item.supporting-text.font → md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto; weight 400; size 14pt; line-height 20pt; tracking 0.25pt |
| `md.comp.list.list-item.supporting-text.font` | List list item supporting text font | md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.supporting-text.line-height` | List list item supporting text line height | md.sys.typescale.body-medium.line-height | 20pt |
| `md.comp.list.list-item.supporting-text.size` | List list item supporting text size | md.sys.typescale.body-medium.size | 14pt |
| `md.comp.list.list-item.supporting-text.tracking` | List list item supporting text tracking | md.sys.typescale.body-medium.tracking | 0.25pt |
| `md.comp.list.list-item.supporting-text.weight` | List list item supporting text weight | md.sys.typescale.body-medium.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.list.list-item.overline.type` | List list item overline type | md.comp.list.list-item.overline.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |
| `md.comp.list.list-item.overline.font` | List list item overline font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.overline.line-height` | List list item overline line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.list.list-item.overline.size` | List list item overline size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.list.list-item.overline.tracking` | List list item overline tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.list.list-item.overline.weight` | List list item overline weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |

**Disabled - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.disabled.container.color` | List list item selected disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.container.opacity` | List list item selected disabled container opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.label-text.color` | List list item selected disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.label-text.opacity` | List list item selected disabled label text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.supporting-text.color` | List list item selected disabled supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.supporting-text.opacity` | List list item selected disabled supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.trailing-supporting-text.color` | List list item selected disabled trailing supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.trailing-supporting-text.opacity` | List list item selected disabled trailing supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.overline.color` | List list item selected disabled overline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.overline.opacity` | List list item selected disabled overline opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.state-layer.color` | List list item selected disabled state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.state-layer.opacity` | List list item selected disabled state layer opacity |  | 0.1 |
| `md.comp.list.list-item.selected.disabled.leading-icon.color` | List list item selected disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.leading-icon.opacity` | List list item selected disabled leading icon opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.trailing-icon.color` | List list item selected disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.trailing-icon.opacity` | List list item selected disabled trailing icon opacity |  | 0.38 |

**Enabled - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.container.color` | List list item selected container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.list.list-item.selected.label-text.color` | List list item selected label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.supporting-text.color` | List list item selected supporting text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.trailing-supporting-text.color` | List list item selected trailing supporting text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.leading-icon.color` | List list item selected leading icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.trailing-icon.color` | List list item selected trailing icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.overline.color` | List list item selected overline color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.pressed.state-layer.color` | List list item selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.pressed.state-layer.opacity` | List list item selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.selected.pressed.label-text.color` | List list item selected pressed label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.pressed.trailing-icon.color` | List list item selected pressed trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.pressed.leading-icon.color` | List list item selected pressed leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Focused - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.focus.state-layer.color` | List list item selected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.focus.state-layer.opacity` | List list item selected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.selected.focus.label-text.color` | List list item selected focus label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.focus.leading-icon.color` | List list item selected focus leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.focus.trailing-icon.color` | List list item selected focus trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Hovered - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.hover.state-layer.color` | List list item selected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.hover.state-layer.opacity` | List list item selected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.list.list-item.selected.hover.label-text.color` | List list item selected hover label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.hover.leading-icon.color` | List list item selected hover leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.hover.trailing-icon.color` | List list item selected hover trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.container.color` | List list item container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.list-item.segmented.container.color` | List list item segmented container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.list-item.label-text.color` | List list item label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.supporting-text.color` | List list item supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.overline.color` | List list item overline color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.divider.color` *(deprecated)* | List list item divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.list.divider.height` *(deprecated)* | List list item divider height |  | 1dp |
| `md.comp.list.list-item.container.height` *(deprecated)* | List list item container height |  | 56dp |
| `md.comp.list.md.comp.list.list-item.one-line.container.height` *(deprecated)* | One line list item container height |  | 56dp |
| `md.comp.list.md.comp.list.list-item.three-line.container.height` *(deprecated)* | Three lines list item container height |  | 88dp |
| `md.comp.list.md.comp.list.list-item.two-line.container.height` *(deprecated)* | Two lines list item container height |  | 72dp |
| `md.comp.list.list-item.leading-icon.color` | List list item leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.trailing-icon.color` | List list item trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.unselected.trailing-icon.color` | List list item unselected trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.trailing-supporting-text.color` | List list item trailing supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.leading-avatar.color` | List list item leading avatar color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.list.list-item.leading-avatar-label.color` | List list item leading avatar label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.list.list-item.container.elevation` | List list item container elevation | md.sys.elevation.level0 | 0dp |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.focus.indicator.color` | List list item focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.list.focus.indicator.thickness` | List list item focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.list.focus.indicator.outline.offset` | List list item focus indicator offset | md.sys.state.focus-indicator.inner-offset | -3dp |

#### Token set: List - Expand (`md.comp.list.expand`)

For list items that can expand and collapse.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.expand.expanded.list-item.container.color` | List expand expanded list item container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.expand.expanded.list-item.segmented.container.color` | List expand expanded list item segmented container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.expand.collapsed.list-item.trailing-icon.container.color` | List expand collapsed list item trailing icon container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.expand.collapsed.list-item.trailing-icon.icon.color` | List expand collapsed list item trailing icon icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.expand.expanded.list-item.trailing-icon.container.color` | List expand expanded list item trailing icon container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.list.expand.expanded.list-item.trailing-icon.icon.color` | List expand expanded list item trailing icon icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.expand.container.shape` | List expand container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.expand.trailing-icon.shape` | List expand trailing icon shape | md.sys.shape.corner.full | fully rounded (circular) |

## Anatomy

*[Image: Diagram with 10 elements that can be included in lists.]*

Container and label text are required. All other elements are optional:

1. Container
2. Overline
3. Label text
4. Trailing text
5. Supporting text
6. Trailing icon
7. Divider
8. Leading avatar
9. Leading icon
10. Leading media - image or video

### Flexibility & slots

The [M3 Design Kit](https://www.figma.com/community/file/1035203688168086460) includes lists with custom slots for designing flexible item layouts. Think of a custom list as a container with three different slots: leading, content, and trailing. Each slot can hold a different element.

#### **Slot accessibility**

Slots are not accessible by default. Consider the following:

- Elements must follow the rules, structure, and interaction patterns for lists
- Use standard list item padding
- Target size must be at least 48x48dp
- Don't add interactive elements that make the list item difficult to navigate, especially for people using screen readers

[More on required accessibility guidelines](https://m3.material.io/components/lists/accessibility#538f23f7-689c-4516-bfc8-5f6933a43f5e)

> ⚠️ **Caution** — *[Image: A diagram with leading, content, and trailing slots.]*
> Reserve the use of slots for use cases that maintain the list’s accessibility and functionality
> 
> 1. Leading slot
> 2. Content slot
> 3. Trailing slot

warning

Caution:

Slots require custom code implementation that you must create and maintain

The **leading** and **trailing** slot positions must be a smaller width than the **content** section.

1. **Leading slots** can contain:

- Visual elements: Avatar, icon, image, or video thumbnail
- Selection controls: Checkbox, radio button, or switch
- Customizations: Badge or larger image

2. **Content slots** must be the largest-width slot and can contain:

- Default content: Label text, supporting text
- Optional add-ons: Badge, icon, in-line label, or more text elements
- Avoid long lines of text to preserve readability

3. **Trailing slots** can contain:

- Action elements or text: Icon, icon button, or trailing text
- Selection controls: Checkbox, radio button, or switch

*[Image: Slot diagram showing slot placement in the middle of the list.]*

The content slot must be the largest section, placed in the middle of the list item

#### Selection lists

For selection lists, use only one selection interaction per list item.

> ✅ **Do** — *[Image: A selected list item with a checkmark in the leading slot.]*
> Use only one selection interaction per list item

> ❌ **Don't** — *[Image: A selected list item with both a checkmark in the leading slot and a bookmark in the trailing slot.]*
> Don't use multiple selection interactions in one item

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 10 list element color roles in light mode and dark mode.]*

List color roles used for light and dark themes:

1. Surface
2. On surface variant
3. On surface
4. On surface variant
5. On surface variant
6. On surface variant
7. Outline variant
8. Primary container
9. On primary container
10. On surface variant

## States

States are visual representations used to communicate the status of a component or an interactive element. [Learn more about interaction states](https://m3.material.io/google-material-3/pages/interaction-states/overview)[More on list focus](https://m3.material.io/components/lists/accessibility#f7e067e1-722f-40c5-a95a-63929869bf3e)

### Default list items

*[Image: 6 default list states in light and dark mode.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed
6. Dragged

### Selected list items

*[Image: 6 selected list states in light and dark mode.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed
6. Dragged

## Measurements

*[Image: Size and padding measurements for list items.]*

List item alignment, padding, and size measurements. The icon button height is dynamic, and automatically adjusts to fill the list item height.

### Shape morphing

When a list item is selected, the corner shape changes to highlight the active item:

- Unselected corner radius: 4dp inner, 16dp outer
- Selected corner radius: 16dp

*[Image: A 3-item list. The middle item is unselected, with a 4dp corner radius.]*

Unselected list items have a 4dp inner corner radius, and 16dp outer corner radius

*[Image: A 3-item list. The middle item is selected, with a 16dp corner radius.]*

Selected list items have a 16dp corner radius all around

## List (baseline)

The baseline list variant is available and continues to work in existing products. However, the [expressive list](https://m3.material.io/components/lists/specs#ebf87f58-d5bf-4cb5-a856-d2bb104eec4d) variant is recommended for new designs.

### Tokens & specs

Baseline list tokens are in the **common** token set. Note: This set also includes several expressive tokens.

#### Token set: List - Common (`md.comp.list`)

Common baseline and expressive list tokens. 

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.disabled.state-layer.color` | List list item disabled state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.state-layer.opacity` | List list item disabled state layer opacity |  | 0.1 |
| `md.comp.list.list-item.disabled.label-text.color` | List list item disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.label-text.opacity` | List list item disabled label text opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.supporting-text.color` | List list item disabled supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.supporting-text.opacity` | List list item disabled supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.overline.color` | List list item disabled overline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.overline.opacity` | List list item disabled overline opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.leading-icon.color` | List list item disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.leading-icon.opacity` | List list item disabled leading icon opacity |  | 0.38 |
| `md.comp.list.list-item.disabled.trailing-icon.color` | List list item disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.disabled.trailing-icon.opacity` | List list item disabled trailing icon opacity |  | 0.38 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.hover.state-layer.color` | List list item hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.hover.state-layer.opacity` | List list item hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.list.list-item.hover.label-text.color` | List list item hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.hover.leading-icon.icon.color` | List list item hover leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.hover.trailing-icon.icon.color` | List list item hover trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.focus.state-layer.color` | List list item focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.focus.state-layer.opacity` | List list item focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.focus.label-text.color` | List list item focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.focus.leading-icon.icon.color` | List list item focus leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.focus.trailing-icon.icon.color` | List list item focus trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Pressed (ripple)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.pressed.state-layer.color` | List list item pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.pressed.state-layer.opacity` | List list item pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.pressed.label-text.color` | List list item pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.pressed.leading-icon.icon.color` | List list item pressed leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.pressed.trailing-icon.icon.color` | List list item pressed trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Dragged (baseline only)**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.dragged.container.elevation` | List list item dragged container color | md.sys.elevation.level4 | 8dp |
| `md.comp.list.list-item.dragged.label-text.color` | List list item dragged label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.dragged.label-text.color` | List list item selected dragged label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.dragged.state-layer.color` | List list item dragged state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.dragged.state-layer.opacity` | List list item dragged state layer opacity | md.sys.state.dragged.state-layer-opacity | 0.16 |
| `md.comp.list.list-item.selected.dragged.state-layer.color` | List list item selected dragged state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.dragged.state-layer.opacity` | List list item selected dragged state layer opacity | md.sys.state.dragged.state-layer-opacity | 0.16 |
| `md.comp.list.list-item.dragged.leading-icon.icon.color` | List list item dragged leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.selected.dragged.leading-icon.color` | List list item selected dragged leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.dragged.trailing-icon.icon.color` | List list item dragged trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.selected.dragged.trailing-icon.color` | List list item selected dragged trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Spacing**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.leading-space` | List list item leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.list-item.trailing-space` | List list item trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.list-item.top-space` | List list item top space | md.sys.measurement.space125 | 10dp |
| `md.comp.list.list-item.bottom-space` | List list item bottom space | md.sys.measurement.space125 | 10dp |
| `md.comp.list.list-item.between-space` | List list item between space | md.sys.measurement.space150 | 12dp |
| `md.comp.list.divider.leading-space` | List list item divider leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.divider.trailing-space` | List list item divider trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.list.divider.top-space` | List list item divider top space | md.sys.measurement.space0 | 0dp |
| `md.comp.list.divider.bottom-space` | List list item divider bottom space | md.sys.measurement.space0 | 0dp |
| `md.comp.list.segmented.gap` | List segment gap | md.sys.measurement.space25 | 2dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.container.shape` | List container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.container.shape` | List list item container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.list.list-item.container.expressive.shape` | List list item container expressive shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.list.list-item.disabled.container.expressive.shape` | List list item container disabled expressive shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.list.list-item.hovered.container.expressive.shape` | List list item container hovered expressive shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.list.list-item.focused.container.expressive.shape` | List list item container focused expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.pressed.container.expressive.shape` | List list item container pressed expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.dragged.container.expressive.shape` | List list item container dragged expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.container.expressive.shape` | List list item container selected expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.disabled.container.expressive.shape` | List list item container selected disabled expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.hovered.container.expressive.shape` | List list item container selected hovered expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.focused.container.expressive.shape` | List list item container selected focsued expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.pressed.container.expressive.shape` | List list item container selected pressed expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.selected.dragged.container.expressive.shape` | List list item container selected dragged expressive shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.list.list-item.leading-avatar.shape` | List list item leading avatar shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.list.list-item.leading-video.shape` | List list item leading video shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.list.list-item.leading-image.shape` | List list item leading image shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.list.list-item.leading-image.expressive.shape` | List list item leading image expressive shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.list.list-item.selected.container.shape` | List list item selected container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |

**Size and typography**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.leading-avatar-label.type` | List list item leading avatar label type | md.comp.list.list-item.leading-avatar-label.font → md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 16pt; line-height 24pt; tracking 0.15pt |
| `md.comp.list.list-item.leading-avatar.size` | List list item leading avatar size |  | 40dp |
| `md.comp.list.list-item.leading-avatar-label.font` | List list item leading avatar label font | md.sys.typescale.title-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.leading-avatar-label.line-height` | List list item leading avatar label line height | md.sys.typescale.title-medium.line-height | 24pt |
| `md.comp.list.list-item.leading-avatar-label.size` | List list item leading avatar label size | md.sys.typescale.title-medium.size | 16pt |
| `md.comp.list.list-item.leading-avatar-label.tracking` | List list item leading avatar label tracking | md.sys.typescale.title-medium.tracking | 0.15pt |
| `md.comp.list.list-item.leading-avatar-label.weight` | List list item leading avatar label weight | md.sys.typescale.title-medium.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.list.list-item.leading-icon.size` | List list item leading icon size |  | 24dp |
| `md.comp.list.list-item.leading-icon.expressive.size` | List list item leading icon expressive size |  | 20dp |
| `md.comp.list.list-item.leading-image.width` | List list item leading image width |  | 56dp |
| `md.comp.list.list-item.leading-image.height` | List list item leading image height |  | 56dp |
| `md.comp.list.list-item.leading-video.width` | List list item leading video width |  | 100dp |
| `md.comp.list.list-item.small.leading-video.width` | List list item small leading video width |  | 100dp |
| `md.comp.list.list-item.small.leading-video.height` | List list item small leading video height |  | 56dp |
| `md.comp.list.list-item.large.leading-video.width` | List list item large leading video width |  | 114dp |
| `md.comp.list.list-item.large.leading-video.height` | List list item large leading video height |  | 64dp |
| `md.comp.list.list-item.one-line.container.height` | One line list item container height |  | 56dp |
| `md.comp.list.list-item.two-line.container.height` | Two lines list item container height |  | 72dp |
| `md.comp.list.list-item.three-line.container.height` | Three lines list item container height |  | 88dp |
| `md.comp.list.list-item.trailing-icon.size` | List list item trailing icon size |  | 24dp |
| `md.comp.list.list-item.trailing-icon.expressive.size` | List list item trailing icon expressive size |  | 20dp |
| `md.comp.list.list-item.label-text.type` | List list item label text type | md.comp.list.list-item.label-text.font → md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto; weight 400; size 16pt; line-height 24pt; tracking 0.5pt |
| `md.comp.list.list-item.label-text.font` | List list item label text font | md.sys.typescale.body-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.label-text.line-height` | List list item label text line height | md.sys.typescale.body-large.line-height | 24pt |
| `md.comp.list.list-item.label-text.size` | List list item label text size | md.sys.typescale.body-large.size | 16pt |
| `md.comp.list.list-item.label-text.tracking` | List list item label text tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.list.list-item.label-text.weight` | List list item label text weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.list.list-item.trailing-supporting-text.type` | List list item trailing supporting text type | md.comp.list.list-item.trailing-supporting-text.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |
| `md.comp.list.list-item.trailing-supporting-text.font` | List list item trailing supporting text font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.trailing-supporting-text.line-height` | List list item trailing supporting text line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.list.list-item.trailing-supporting-text.size` | List list item trailing supporting text size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.list.list-item.trailing-supporting-text.tracking` | List list item trailing supporting text tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.list.list-item.trailing-supporting-text.weight` | List list item trailing supporting text weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.list.list-item.supporting-text.type` | List list item supporting text type | md.comp.list.list-item.supporting-text.font → md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto; weight 400; size 14pt; line-height 20pt; tracking 0.25pt |
| `md.comp.list.list-item.supporting-text.font` | List list item supporting text font | md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.supporting-text.line-height` | List list item supporting text line height | md.sys.typescale.body-medium.line-height | 20pt |
| `md.comp.list.list-item.supporting-text.size` | List list item supporting text size | md.sys.typescale.body-medium.size | 14pt |
| `md.comp.list.list-item.supporting-text.tracking` | List list item supporting text tracking | md.sys.typescale.body-medium.tracking | 0.25pt |
| `md.comp.list.list-item.supporting-text.weight` | List list item supporting text weight | md.sys.typescale.body-medium.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.list.list-item.overline.type` | List list item overline type | md.comp.list.list-item.overline.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |
| `md.comp.list.list-item.overline.font` | List list item overline font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.list.list-item.overline.line-height` | List list item overline line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.list.list-item.overline.size` | List list item overline size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.list.list-item.overline.tracking` | List list item overline tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.list.list-item.overline.weight` | List list item overline weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |

**Disabled - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.disabled.container.color` | List list item selected disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.container.opacity` | List list item selected disabled container opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.label-text.color` | List list item selected disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.label-text.opacity` | List list item selected disabled label text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.supporting-text.color` | List list item selected disabled supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.supporting-text.opacity` | List list item selected disabled supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.trailing-supporting-text.color` | List list item selected disabled trailing supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.trailing-supporting-text.opacity` | List list item selected disabled trailing supporting text opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.overline.color` | List list item selected disabled overline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.overline.opacity` | List list item selected disabled overline opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.state-layer.color` | List list item selected disabled state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.state-layer.opacity` | List list item selected disabled state layer opacity |  | 0.1 |
| `md.comp.list.list-item.selected.disabled.leading-icon.color` | List list item selected disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.leading-icon.opacity` | List list item selected disabled leading icon opacity |  | 0.38 |
| `md.comp.list.list-item.selected.disabled.trailing-icon.color` | List list item selected disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.disabled.trailing-icon.opacity` | List list item selected disabled trailing icon opacity |  | 0.38 |

**Enabled - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.container.color` | List list item selected container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.list.list-item.selected.label-text.color` | List list item selected label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.supporting-text.color` | List list item selected supporting text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.trailing-supporting-text.color` | List list item selected trailing supporting text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.leading-icon.color` | List list item selected leading icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.trailing-icon.color` | List list item selected trailing icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.overline.color` | List list item selected overline color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.pressed.state-layer.color` | List list item selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.pressed.state-layer.opacity` | List list item selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.selected.pressed.label-text.color` | List list item selected pressed label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.pressed.trailing-icon.color` | List list item selected pressed trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.pressed.leading-icon.color` | List list item selected pressed leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Focused - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.focus.state-layer.color` | List list item selected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.focus.state-layer.opacity` | List list item selected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.list.list-item.selected.focus.label-text.color` | List list item selected focus label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.focus.leading-icon.color` | List list item selected focus leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.focus.trailing-icon.color` | List list item selected focus trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Hovered - Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.selected.hover.state-layer.color` | List list item selected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.hover.state-layer.opacity` | List list item selected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.list.list-item.selected.hover.label-text.color` | List list item selected hover label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.list.list-item.selected.hover.leading-icon.color` | List list item selected hover leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.selected.hover.trailing-icon.color` | List list item selected hover trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.list-item.container.color` | List list item container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.list-item.segmented.container.color` | List list item segmented container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.list.list-item.label-text.color` | List list item label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.supporting-text.color` | List list item supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.overline.color` | List list item overline color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.divider.color` *(deprecated)* | List list item divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.list.divider.height` *(deprecated)* | List list item divider height |  | 1dp |
| `md.comp.list.list-item.container.height` *(deprecated)* | List list item container height |  | 56dp |
| `md.comp.list.md.comp.list.list-item.one-line.container.height` *(deprecated)* | One line list item container height |  | 56dp |
| `md.comp.list.md.comp.list.list-item.three-line.container.height` *(deprecated)* | Three lines list item container height |  | 88dp |
| `md.comp.list.md.comp.list.list-item.two-line.container.height` *(deprecated)* | Two lines list item container height |  | 72dp |
| `md.comp.list.list-item.leading-icon.color` | List list item leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.trailing-icon.color` | List list item trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.unselected.trailing-icon.color` | List list item unselected trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.list.list-item.trailing-supporting-text.color` | List list item trailing supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.list.list-item.leading-avatar.color` | List list item leading avatar color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.list.list-item.leading-avatar-label.color` | List list item leading avatar label color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.list.list-item.container.elevation` | List list item container elevation | md.sys.elevation.level0 | 0dp |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.list.focus.indicator.color` | List list item focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.list.focus.indicator.thickness` | List list item focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.list.focus.indicator.outline.offset` | List list item focus indicator offset | md.sys.state.focus-indicator.inner-offset | -3dp |

### Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 9 baseline list element color roles in light and dark mode.]*

List color roles used for light and dark themes:

1. Surface
2. On surface
3. On surface variant
4. On surface variant
5. On surface variant
6. Outline variant
7. Primary container
8. On primary container
9. On surface variant

### States

States are visual representations used to communicate the status of a component or interactive element.

*[Image: 6 baseline list states in light and dark mode.]*

1. Enabled

2. Disabled

3. Hovered

4. Focused

5. Pressed

6. Dragged

### Layout

#### One-line lists

*[Image: Alignment, padding, and size specifications for baseline list items with 1 line of text.]*

Baseline one-line list alignment, padding, and size measurements

*[Image: Measurements for a 3-item list with 1 line each.]*

Baseline list item measurements and padding

#### Two-line lists

*[Image: Alignment, padding, and size specifications for baseline list items with 2 lines of text.]*

Baseline two-line list alignment, padding, and size measurements

*[Image: Measurements for a 3-item list with 2 lines each.]*

Baseline list item measurements and padding

#### Three-line lists

*[Image: Alignment, padding, and size specifications for baseline list items with 3 lines of text.]*

Baseline three-line list alignment, padding, and size measurements

*[Image: Measurements for a 3-item list with 3 lines each.]*

Baseline list item measurements and padding

| Attribute | Value |
| --- | --- |
| Label alignment | Center |
| Label alignment when height is 88dp or taller | Top |
| Label left padding | 16dp |
| Leading element alignment (vertical) | Center |
| Leading element alignment (vertical) when height is 88dp or taller | Top |
| Leading element left padding | 16dp |
| Leading icon alignment (vertical) | Top |
| Leading icon top padding | 8dp |
| Leading icon top padding when height is 88dp or taller | 12dp |
| Trailing element alignment (vertical) | Center |
| Trailing element alignment (vertical) when height is 88dp or taller | Top |
| Trailing element left padding | 16dp |
| Trailing element right padding | 24dp |
| Padding above/below divider | 0dp |
| Targets | 48dp |
| Divider full-width | 100% |
| Divider inset left padding | 16dp |
| Divider inset right padding | 24dp |

### Configurations

#### Leading avatar

*[Image: 1, 2, and 3-line list items with and without a leading avatar and trailing checkbox, in dark mode.]*

1. With leading avatar
2. With leading avatar and trailing checkbox

#### Leading image or thumbnail

*[Image: 1, 2, and 3-line list items with and without a leading image and trailing checkbox, in dark mode.]*

1. With leading image
2. With leading image and trailing checkbox

#### Leading video

*[Image: 1, 2, and 3-line list items with and without a leading video and trailing checkbox, in dark mode.]*

1. With leading video
2. With leading video and trailing checkbox

#### Leading icon

*[Image: 1, 2, and 3-line list items with and without a leading icon and trailing checkbox, in dark mode.]*

1. With leading icon
2. With leading icon and trailing checkbox

#### Text-only

*[Image: 1, 2, and 3-line text only list items with and without a trailing checkbox, in dark mode.]*

1. With text only
2. With text and trailing checkbox

#### Leading checkbox

*[Image: 1, 2, and 3-line list items with and without a leading checkbox and trailing text, in dark mode.]*

1. With leading checkbox
2. With leading checkbox and trailing text

#### Leading radio button

*[Image: 1, 2, and 3-line list items with and without a leading radio button and trailing text, in dark mode.]*

1. With leading radio button
2. With leading radio button and trailing text

#### Trailing switch

*[Image: 1, 2, and 3-line list items with and without a leading icon and trailing switch, in dark mode.]*

1. With trailing switch
2. With leading icon and trailing switch
