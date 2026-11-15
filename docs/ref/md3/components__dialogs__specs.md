Source: https://m3.material.io/components/dialogs/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T07:11:33.307Z

# Dialogs — Specs

## Tokens & specs

Select a component variant below to see its elements, attributes, tokens, and their values.

#### Token set: Dialog - Basic (`md.comp.dialog`)

For basic dialogs.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.container.color` | Dialog container color | dark: md.sys.color.surface-container-high → md.ref.palette.neutral17<br>light: md.sys.color.surface-container-high → md.ref.palette.neutral92 | dark: #2B2930<br>light: #ECE6F0 |
| `md.comp.dialog.container.elevation` | Dialog container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.dialog.container.surface-tint-layer.color` *(deprecated)* | Dialog container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.container.shape` | Dialog container shape | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |

**Divider**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.with-divider.divider.color` *(deprecated)* | Dialog divider color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.dialog.with-divider.divider.height` *(deprecated)* | Dialog divider color |  | 1dp |

**Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.headline.font` | Dialog headline font | md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto |
| `md.comp.dialog.headline.line-height` | Dialog headline line height | md.sys.typescale.headline-small.line-height | 32pt |
| `md.comp.dialog.headline.size` | Dialog headline size | md.sys.typescale.headline-small.size | 24pt |
| `md.comp.dialog.headline.weight` | Dialog headline weight | md.sys.typescale.headline-small.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.dialog.headline.tracking` | Dialog headline tracking | md.sys.typescale.headline-small.tracking | 0pt |
| `md.comp.dialog.headline.type` | headline type style | md.comp.dialog.headline.font → md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto; weight 400; size 24pt; line-height 32pt; tracking 0pt |
| `md.comp.dialog.headline.color` | Dialog headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.with-icon.icon.size` | Dialog icon size |  | 24dp |
| `md.comp.dialog.with-icon.icon.color` | Dialog icon color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.action.focus.label-text.color` | Dialog action focus label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.hover.label-text.color` | Dialog action hover label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.label-text.font` | Dialog action label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.dialog.action.pressed.label-text.color` | Dialog action pressed label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.label-text.line-height` | Dialog action label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.dialog.action.label-text.size` | Dialog action label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.dialog.action.label-text.weight` | Dialog action label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.dialog.action.label-text.tracking` | Dialog action label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.dialog.action.label-text.type` | Label text type style | md.comp.dialog.action.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.dialog.action.label-text.color` | Dialog action label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.action.focus.state-layer.color` | Dialog action focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.hover.state-layer.color` | Dialog action hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.pressed.state-layer.color` | Dialog action pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.dialog.action.focus.state-layer.opacity` | Dialog action focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.dialog.action.hover.state-layer.opacity` | Dialog action hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.dialog.action.pressed.state-layer.opacity` | Dialog action pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**Subhead**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.subhead.font` *(deprecated)* | Dialog subhead font | md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto |
| `md.comp.dialog.subhead.line-height` *(deprecated)* | Dialog subhead line height | md.sys.typescale.headline-small.line-height | 32pt |
| `md.comp.dialog.subhead.size` *(deprecated)* | Dialog subhead size | md.sys.typescale.headline-small.size | 24pt |
| `md.comp.dialog.subhead.weight` *(deprecated)* | Dialog subhead weight | md.sys.typescale.headline-small.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.dialog.subhead.tracking` *(deprecated)* | Dialog subhead tracking | md.sys.typescale.headline-small.tracking | 0pt |
| `md.comp.dialog.subhead.type` *(deprecated)* | Subhead type style | md.comp.dialog.subhead.font → md.sys.typescale.headline-small.font → md.ref.typeface.brand | Roboto; weight 400; size 24pt; line-height 32pt; tracking 0pt |
| `md.comp.dialog.subhead.color` *(deprecated)* | Dialog subhead color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Supporting text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.dialog.supporting-text.font` | Dialog supporting text font | md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.dialog.supporting-text.line-height` | Dialog supporting text line height | md.sys.typescale.body-medium.line-height | 20pt |
| `md.comp.dialog.supporting-text.size` | Dialog supporting text size | md.sys.typescale.body-medium.size | 14pt |
| `md.comp.dialog.supporting-text.weight` | Dialog supporting text weight | md.sys.typescale.body-medium.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.dialog.supporting-text.tracking` | Dialog supporting text tracking | md.sys.typescale.body-medium.tracking | 0.25pt |
| `md.comp.dialog.supporting-text.type` | Supporting text type style | md.comp.dialog.supporting-text.font → md.sys.typescale.body-medium.font → md.ref.typeface.plain | Roboto; weight 400; size 14pt; line-height 20pt; tracking 0.25pt |
| `md.comp.dialog.supporting-text.color` | Dialog supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

#### Token set: Dialog - Full screen (`md.comp.full-screen-dialog`)

For full-screen dialogs.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.header.on-scroll.container.color` | Full screen dialog on-scroll container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.full-screen-dialog.container.color` | Full screen dialog container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.full-screen-dialog.container.elevation` | Full screen dialog container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.full-screen-dialog.container.shape` | Full screen dialog container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.full-screen-dialog.header.container.height` | Full screen dialog header container height |  | 56dp |
| `md.comp.full-screen-dialog.header.container.color` | Full screen dialog header container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.full-screen-dialog.header.container.elevation` | Full screen dialog header container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.full-screen-dialog.header.container.surface-tint-layer.color` *(deprecated)* | Full screen dialog header container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.on-scroll.container.elevation` | Full screen dialog header on scroll container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.full-screen-dialog.action-bar.container.height` *(deprecated)* | Full screen dialog action bar container height |  | 56dp |
| `md.comp.full-screen-dialog.action-bar.container.color` *(deprecated)* | Full screen dialog action bar container color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.full-screen-dialog.action-bar.container.elevation` *(deprecated)* | Full screen dialog action bar container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.full-screen-dialog.action-bar.on-scroll.container.elevation` *(deprecated)* | Full screen dialog action bar on scroll container elevation | md.sys.elevation.level2 | 3dp |

**Divider**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.with-divider.divider.color` *(deprecated)* | Full screen dialog divider color | dark: md.sys.color.surface-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.surface-variant → md.ref.palette.neutral-variant90 | dark: #49454F<br>light: #E7E0EC |
| `md.comp.full-screen-dialog.with-divider.divider.height` *(deprecated)* | Full screen dialog divider height |  | 1dp |

**Headline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.header.headline.color` | Full screen dialog header headline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.full-screen-dialog.header.headline.font` | Full screen dialog header headline font | md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto |
| `md.comp.full-screen-dialog.header.headline.line-height` | Full screen dialog header headline line height | md.sys.typescale.title-large.line-height | 28pt |
| `md.comp.full-screen-dialog.header.headline.size` | Full screen dialog header headline size | md.sys.typescale.title-large.size | 22pt |
| `md.comp.full-screen-dialog.header.headline.weight` | Full screen dialog header headline weight | md.sys.typescale.title-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.full-screen-dialog.header.headline.tracking` | Full screen dialog header headline tracking | md.sys.typescale.title-large.tracking | 0pt |
| `md.comp.full-screen-dialog.header.headline.type` | Header type style | md.comp.full-screen-dialog.header.headline.font → md.sys.typescale.title-large.font → md.ref.typeface.brand | Roboto; weight 400; size 22pt; line-height 28pt; tracking 0pt |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.header.icon.color` | Full screen dialog header icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.full-screen-dialog.header.icon.size` | Full screen dialog header icon size |  | 24dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.header.action.focus.label-text.color` | Full screen dialog header action focus label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.hover.label-text.color` | Full screen dialog header action hover label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.label-text.font` | Full screen dialog header action label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.full-screen-dialog.header.action.pressed.label-text.color` | Full screen dialog header action pressed label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.focus.label-text.color` *(deprecated)* | Full screen dialog action bar focus label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.hover.label-text.color` *(deprecated)* | Full screen dialog action bar hover label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.pressed.label-text.color` *(deprecated)* | Full screen dialog action bar pressed label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.label-text.line-height` | Full screen dialog header action label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.full-screen-dialog.header.action.label-text.size` | Full screen dialog header action label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.full-screen-dialog.header.action.label-text.weight` | Full screen dialog header action label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.full-screen-dialog.header.action.label-text.tracking` | Full screen dialog header action label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.full-screen-dialog.header.action.label-text.type` | Full screen dialog header action label text type | md.comp.full-screen-dialog.header.action.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.full-screen-dialog.header.action.label-text.color` | Full screen dialog header action label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.label-text.font` *(deprecated)* | Full screen dialog action bar label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.full-screen-dialog.action-bar.label-text.line-height` *(deprecated)* | Full screen dialog action bar label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.full-screen-dialog.action-bar.label-text.size` *(deprecated)* | Full screen dialog action bar label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.full-screen-dialog.action-bar.label-text.weight` *(deprecated)* | Full screen dialog action bar label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.full-screen-dialog.action-bar.label-text.tracking` *(deprecated)* | Full screen dialog action bar label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.full-screen-dialog.action-bar.label-text.type` *(deprecated)* | Full screen dialog action bar label text type | md.comp.full-screen-dialog.action-bar.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |
| `md.comp.full-screen-dialog.action-bar.label-text.color` *(deprecated)* | Full screen dialog action bar label text color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.full-screen-dialog.header.action.focus.state-layer.color` | Full screen dialog header action focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.hover.state-layer.color` | Full screen dialog header action hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.pressed.state-layer.color` | Full screen dialog header action pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.header.action.focus.state-layer.opacity` | Full screen dialog header action focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.full-screen-dialog.header.action.hover.state-layer.opacity` | Full screen dialog header action hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.full-screen-dialog.header.action.pressed.state-layer.opacity` | Full screen dialog header action pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.full-screen-dialog.action-bar.focus.state-layer.color` *(deprecated)* | Full screen dialog action bar focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.hover.state-layer.color` *(deprecated)* | Full screen dialog action bar hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.pressed.state-layer.color` *(deprecated)* | Full screen dialog action bar pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.full-screen-dialog.action-bar.focus.state-layer.opacity` *(deprecated)* | Full screen dialog action bar focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.full-screen-dialog.action-bar.hover.state-layer.opacity` *(deprecated)* | Full screen dialog action bar hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.full-screen-dialog.action-bar.pressed.state-layer.opacity` *(deprecated)* | Full screen dialog action bar pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

## Basic dialogs

*[Image: Anatomy diagram numbering dialog elements.]*

1. Container
2. Icon (optional)
3. Headline (optional)
4. Supporting text
5. Divider (optional)
6. Button label text
7. Scrim

### Basic dialog color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Color mapping diagram labeling 6 color roles across the dialog and scrim.]*

Basic dialog color roles used for light and dark themes:

1. Surface container high
2. Secondary
3. On surface
4. On surface variant
5. Primary
6. Scrim

### Basic dialog measurements

*[Image: Annotated diagram showing padding values.]*

Basic dialog padding and size measurements

| Attribute | Value |
| --- | --- |
| Container shape | 28dp corner radius |
| Container height | Dynamic |
| Container width | Min 280dp; Max 560dp |
| Divider height | 1dp |
| Icon size | 24dp |
| Minimum width | 280dp |
| Maximum width | 560dp |
| Alignment with icon | Center-aligned |
| Alignment without icon | Start-aligned |
| Top/Left/right/bottom padding | 24dp |
| Padding between buttons | 8dp |
| Padding between title and body | 16dp |
| Padding between icon and title | 16dp |
| Padding between body and actions | 24dp |

## Full-screen dialogs

*[Image: Diagram numbering 6 full-screen dialog elements.]*

1. Container
2. Header
3. Icon (close affordance)
4. Headline (optional)
5. Text button
6. Divider (optional)

### Full-screen dialog color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value.

*[Image: Color mapping diagram shows 5 callout markers across the dialog.]*

Full-screen dialog color roles used for light and dark themes:

1. Surface container high
2. On surface
3. On surface
4. Primary
5. On surface variant

### Full-screen dialog measurements

*[Image: Diagram noting layout measurements for padding values, title, height, and action regions.]*

Full-screen dialog padding and size measurements

| Attribute | Value |
| --- | --- |
| Container shape | 0dp corner radius |
| Container height | Dynamic |
| Container width | Container width; Max 560dp |
| Header height | 56dp |
| Header width | Container width |
| Headline text alignment | Start-aligned |
| Divider height | 1dp |
| Icon (close affordance) size | 24dp |
| Bottom action bar height | 56dp |
| Bottom action bar width | Container width |
| Top/left/right padding | 24dp |
| Padding between elements | 8dp |
