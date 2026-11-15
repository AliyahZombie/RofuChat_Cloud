Source: https://m3.material.io/components/snackbar/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T08:03:08.607Z

# Snackbar — Specs

*[Image: Diagram of snackbar indicating the four parts of its anatomy]*

1. Container
2. Icon (optional close affordance)
3. Action (optional)
4. Supporting text

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Snackbars (`md.comp.snackbar`)

For snackbars.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.snackbar.container.color` | Snackbar container color | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |
| `md.comp.snackbar.container.shadow-color` | Snackbar container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.snackbar.container.elevation` | Snackbar container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.snackbar.container.shape` | Snackbar container shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.snackbar.with-single-line.container.height` | Snackbar container with single line height |  | 48dp |
| `md.comp.snackbar.with-two-lines.container.height` | Snackbar container with two lines height |  | 68dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.snackbar.icon.color` | Snackbar icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.focus.icon.color` | Snackbar icon focus icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.hover.icon.color` | Snackbar icon hover icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.pressed.icon.color` | Snackbar icon pressed icon color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.size` | Snackbar icon size |  | 24dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.snackbar.action.label-text.type` | Snackbar label text | md.comp.snackbar.action.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.snackbar.action.focus.label-text.color` | Snackbar focus label text color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.hover.label-text.color` | Snackbar hover label text color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.label-text.color` | Snackbar label text color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.pressed.label-text.color` | Snackbar pressed label text color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.label-text.font` | Snackbar label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.snackbar.action.label-text.line-height` | Snackbar label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.snackbar.action.label-text.size` | Snackbar label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.snackbar.action.label-text.tracking` | Snackbar label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.snackbar.action.label-text.weight` | Snackbar label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.snackbar.action.focus.state-layer.color` | Snackbar focus state layer color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.hover.state-layer.color` | Snackbar hover state layer color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.pressed.state-layer.color` | Snackbar pressed state layer color | dark: md.sys.color.inverse-primary → md.ref.palette.primary40<br>light: md.sys.color.inverse-primary → md.ref.palette.primary80 | dark: #6750A4<br>light: #D0BCFF |
| `md.comp.snackbar.action.focus.state-layer.opacity` | Snackbar focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.snackbar.action.hover.state-layer.opacity` | Snackbar hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.snackbar.action.pressed.state-layer.opacity` | Snackbar pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.snackbar.icon.focus.state-layer.color` | Snackbar icon focus state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.hover.state-layer.color` | Snackbar icon hover state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.pressed.state-layer.color` | Snackbar icon pressed state layer color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.icon.focus.state-layer.opacity` | Snackbar icon focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.snackbar.icon.hover.state-layer.opacity` | Snackbar icon hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.snackbar.icon.pressed.state-layer.opacity` | Snackbar icon pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**Supporting text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.snackbar.supporting-text.type` | Snackbar supporting text | md.comp.snackbar.supporting-text.font → md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto; weight 400; size 14pt; line-height 20pt; tracking 0.25pt |
| `md.comp.snackbar.supporting-text.color` | Snackbar supporting text color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.snackbar.supporting-text.font` | Snackbar supporting text font | md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.snackbar.supporting-text.line-height` | Snackbar supporting text line height | md.sys.typescale.body-medium.line-height | 20pt |
| `md.comp.snackbar.supporting-text.size` | Snackbar supporting text size | md.sys.typescale.body-medium.size | 14pt |
| `md.comp.snackbar.supporting-text.tracking` | Snackbar supporting text tracking | md.sys.typescale.body-medium.tracking | 0.25pt |
| `md.comp.snackbar.supporting-text.weight` | Snackbar supporting text weight | md.sys.typescale.body-medium.weight → md.ref.typeface.weight-regular | 400 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Diagram of snackbar indicating color and inverse text and labels]*

Snackbar color roles used for light and dark schemes:

1. Inverse surface
2. Inverse on surface
3. Inverse primary
4. Inverse on surface

## Measurements

*[Image: Diagram of snackbar with action]*

Snackbar padding and size measurements

## Configurations

*[Image: 5 snackbar configurations.]*

1. Single line
2. Single line with action
3. Two lines
4. Two lines with action
5. Two lines with longer action
