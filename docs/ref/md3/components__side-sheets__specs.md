Source: https://m3.material.io/components/side-sheets/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T07:57:48.089Z

# Side sheets — Specs

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Sheets - Side (`md.comp.sheet.side`)

For side sheets.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.container.color` *(deprecated)* | Sheet side docked container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.sheet.side.docked.modal.container.color` | Sheet side docked modal container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.sheet.side.docked.standard.container.color` | Sheet side docked standard container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.sheet.side.docked.container.surface-tint-layer.color` *(deprecated)* | Sheet side docked container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.modal.container.elevation` | Sheet side docked modal container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.sheet.side.docked.standard.container.elevation` | Sheet side docked standard container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.sheet.side.docked.container.height` | Sheet side docked container height |  | 100% |
| `md.comp.sheet.side.docked.container.shape` | Sheet side docked container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.sheet.side.detached.container.shape` | Sheet side detached container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.sheet.side.docked.container.width` | Sheet side docked container width |  | 256dp |
| `md.comp.sheet.side.docked.modal.container.shape` | Sheet side docked modal container shape | md.sys.shape.corner.large.start | rounded corners: topLeft 16dp, bottomLeft 16dp (others 0dp) |

**Divider**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.divider.color` | Sheet side docked divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.focus.indicator.color` | Sheet side docked focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.sheet.side.docked.focus.indicator.thickness` | Sheet side docked focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.sheet.side.docked.focus.indicator.outline.offset` | Sheet side docked focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.headline.color` | Sheet side docked headline color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.sheet.side.docked.headline.font` | Sheet side docked headline font | md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto |
| `md.comp.sheet.side.docked.headline.line-height` | Sheet side docked headline line height | md.sys.typescale.title-large.line-height | 28pt |
| `md.comp.sheet.side.docked.headline.size` | Sheet side docked headline size | md.sys.typescale.title-large.size | 22pt |
| `md.comp.sheet.side.docked.headline.tracking` | Sheet side docked headline tracking | md.sys.typescale.title-large.tracking | 0pt |
| `md.comp.sheet.side.docked.headline.weight` | Sheet side docked headline weight | md.sys.typescale.title-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.sheet.side.docked.headline.type` | Sheet side docked headline type style | md.comp.sheet.side.docked.headline.font → md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto; weight 400; size 22pt; line-height 28pt; tracking 0pt |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.action.focus.label-text.color` | Sheet side docked action focus label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.action.hover.label-text.color` | Sheet side docked action hover label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.action.pressed.label-text.color` | Sheet side docked action pressed label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.side.docked.action.focus.state-layer.color` | Sheet side docked action focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.action.hover.state-layer.color` | Sheet side docked action hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.action.pressed.state-layer.color` | Sheet side docked action pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.side.docked.action.focus.state-layer.opacity` | Sheet side docked action focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.sheet.side.docked.action.hover.state-layer.opacity` | Sheet side docked action hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.sheet.side.docked.action.pressed.state-layer.opacity` | Sheet side docked action pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

## Standard side sheet

*[Image: 4 elements of a standard side sheet.]*

1. Divider (optional)
2. Headline
3. Container
4. Close icon button

### Standard side sheet color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

*[Image: 4 color roles applied to a side sheet in light and dark themes.]*

Side sheet color roles used for light and dark themes:

1. Outline variant
2. On surface variant
3. Surface
4. On surface variant

### Standard side sheet measurements

*[Image: Standard side sheet padding and size measurements.]*

Side sheet padding and size measurements

| Attribute | Value |
| --- | --- |
| Start/end padding | 24dp |
| Padding between top elements | 12dp |
| Bottom actions height | 72dp |
| Bottom actions top padding | 16dp |
| Bottom actions bottom padding | 24dp |
| Bottom actions alignment (horizontal) | Left |
| Max-width | 400dp |
| Margins (when detached) | 16dp |

## Modal side sheet

*[Image: 7 elements of a modal side sheet.]*

1. Back icon button (optional)
2. Headline
3. Container
4. Close icon button
5. Divider (optional)
6. Action buttons (optional)
7. Scrim

### Modal side sheet color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview/).

*[Image: 4 color roles applied to a modal side sheet in light and dark themes.]*

Side sheet color roles used for light and dark themes:

1. On surface variant
2. On surface variant
3. Surface container low
4. On surface variant

### Modal side sheet measurements

*[Image: Modal side sheet padding and size measurements]*

Modal side sheet padding and size measurements

| Attribute | Value |
| --- | --- |
| Start/end padding | 24dp |
| Start padding with icon | 16dp |
| Padding between top elements | 12dp |
| Bottom actions height | 72dp |
| Bottom actions top padding | 16dp |
| Bottom actions bottom padding | 24dp |
| Bottom actions alignment (horizontal) | Left |
| Max-width | 400dp |
| Margins (when detached) | 16dp |
