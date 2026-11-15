Source: https://m3.material.io/components/tooltips/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:03:02.412Z

# Tooltips — Specs

## Tokens & specs

Select a component variant below to see its attributes, tokens, and values.

#### Token set: Tooltip - Plain (`md.comp.plain-tooltip`)

For plain tooltips.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.plain-tooltip.container.color` | Plain tooltip container color | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |
| `md.comp.plain-tooltip.container.shape` | Plain tooltip container shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |

**Supporting text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.plain-tooltip.supporting-text.font` | Plain tooltip supporting text font | md.sys.typescale.body-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.plain-tooltip.supporting-text.line-height` | Plain tooltip supporting text line height | md.sys.typescale.body-small.line-height | 16pt |
| `md.comp.plain-tooltip.supporting-text.size` | Plain tooltip supporting text size | md.sys.typescale.body-small.size | 12pt |
| `md.comp.plain-tooltip.supporting-text.weight` | Plain tooltip supporting text weight | md.sys.typescale.body-small.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.plain-tooltip.supporting-text.tracking` | Plain tooltip supporting text tracking | md.sys.typescale.body-small.tracking | 0.4pt |
| `md.comp.plain-tooltip.supporting-text.type` | Supporting text type style | md.comp.plain-tooltip.supporting-text.font → md.sys.typescale.body-small.font → md.ref.typeface.plain | Roboto; weight 400; size 12pt; line-height 16pt; tracking 0.4pt |
| `md.comp.plain-tooltip.supporting-text.color` | Plain tooltip supporting text color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |

#### Token set: Tooltip - Rich (`md.comp.rich-tooltip`)

For rich tooltips.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.rich-tooltip.container.color` | Rich tooltip container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.rich-tooltip.container.elevation` | Rich tooltip container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.rich-tooltip.container.surface-tint-layer.color` *(deprecated)* | Rich tooltip container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.container.shadow-color` | Rich tooltip container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.rich-tooltip.container.shape` | Rich tooltip container shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.rich-tooltip.action.focus.label-text.color` | Rich tooltip action focus label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.hover.label-text.color` | Rich tooltip action hover label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.label-text.font` | Rich tooltip action label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.rich-tooltip.action.pressed.label-text.color` | Rich tooltip action pressed label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.label-text.line-height` | Rich tooltip action label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.rich-tooltip.action.label-text.size` | Rich tooltip action label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.rich-tooltip.action.label-text.weight` | Rich tooltip action label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.rich-tooltip.action.label-text.tracking` | Rich tooltip action label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.rich-tooltip.action.label-text.type` | Type style | md.comp.rich-tooltip.action.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.rich-tooltip.action.label-text.color` | Rich tooltip action label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.rich-tooltip.action.focus.state-layer.color` | Rich tooltip action focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.pressed.state-layer.color` | Rich tooltip action pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.focus.state-layer.opacity` | Rich tooltip action focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.rich-tooltip.action.pressed.state-layer.opacity` | Rich tooltip action pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.rich-tooltip.action.hover.state-layer.color` | Rich tooltip action hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.rich-tooltip.action.hover.state-layer.opacity` | Rich tooltip action hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

**Subhead**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.rich-tooltip.subhead.font` | Rich tooltip subhead font | md.sys.typescale.title-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.rich-tooltip.subhead.line-height` | Rich tooltip subhead line height | md.sys.typescale.title-small.line-height | 20pt |
| `md.comp.rich-tooltip.subhead.size` | Rich tooltip subhead size | md.sys.typescale.title-small.size | 14pt |
| `md.comp.rich-tooltip.subhead.weight` | Rich tooltip subhead weight | md.sys.typescale.title-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.rich-tooltip.subhead.tracking` | Rich tooltip subhead tracking | md.sys.typescale.title-small.tracking | 0.1pt |
| `md.comp.rich-tooltip.subhead.type` | Type style | md.comp.rich-tooltip.subhead.font → md.sys.typescale.title-small.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.rich-tooltip.subhead.color` | Rich tooltip subhead color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Supporting text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.rich-tooltip.supporting-text.font` | Rich tooltip supporting text font | md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.rich-tooltip.supporting-text.line-height` | Rich tooltip supporting text line height | md.sys.typescale.body-medium.line-height | 20pt |
| `md.comp.rich-tooltip.supporting-text.size` | Rich tooltip supporting text size | md.sys.typescale.body-medium.size | 14pt |
| `md.comp.rich-tooltip.supporting-text.weight` | Rich tooltip supporting text weight | md.sys.typescale.body-medium.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.rich-tooltip.supporting-text.tracking` | Rich tooltip supporting text tracking | md.sys.typescale.body-medium.tracking | 0.25pt |
| `md.comp.rich-tooltip.supporting-text.type` | Type style | md.comp.rich-tooltip.supporting-text.font → md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto; weight 400; size 14pt; line-height 20pt; tracking 0.25pt |
| `md.comp.rich-tooltip.supporting-text.color` | Rich tooltip supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

## Plain tooltip

*[Image: 2 elements of a plain tooltip.]*

1. Supporting text
2. Container

### Plain tooltip colors

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 2 color roles of a plain tooltip.]*

Plain tooltip color roles used for light and dark themes:

1. Inverse on surface
2. Inverse surface

### Plain tooltip measurements

*[Image: Measurements of a plain tooltip.]*

Plain tooltip padding and size measurements

| Attribute | Value |
| --- | --- |
| Container height | 24dp |
| Padding | 8dp |

## Rich tooltip

*[Image: 4 elements of a rich tooltip.]*

1. Subhead
2. Container
3. Supporting text
4. Text button

### Rich tooltip colors

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 4 color roles of a rich tooltip.]*

Rich tooltip color roles used for light and dark themes:

1. On surface variant
2. Surface container
3. On surface variant
4. Primary

### Rich tooltip measurements

*[Image: Measurements of a rich tooltip.]*

Rich tooltip padding and size measurements

| Attribute | Value |
| --- | --- |
| Top padding | 12dp |
| Bottom padding | 8dp |
| Left and right padding | 16dp |

### Rich tooltip configurations

Rich tooltips can have a headline, body, and up to two buttons. The headline and number of buttons can be configured.

*[Image: 5 common configurations of a rich tooltip.]*

1. Subhead, supporting text, and two buttons
2. Subhead, supporting text, and one button
3. Subhead and supporting text
4. Supporting text and one button
5. Supporting text and two buttons
