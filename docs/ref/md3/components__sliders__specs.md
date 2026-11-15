Source: https://m3.material.io/components/sliders/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:13:18.037Z

# Sliders — Specs

## Variants

*[Image: 3 variants of sliders.]*

1. Standard
2. Centered
3. Range

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Standard | Available as “continuous” slider | Available |
| Centered | Available (web only) | Available |
| Range | Available | Available |
| Discrete | Available | Available as “stops” configuration |

## Configurations

*[Image: Orientation and size configurations of sliders.]*

1. Orientation: Horizontal, vertical
2. Size: XS, S, M, L, XL

*[Image: Optional anatomy configurations of sliders.]*

1. Inset icon
2. Stops
3. Value indicator

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Inset icon | No (default) | Available | Available |
| Yes | -- | Available |
| Orientation | Horizontal (default) | Available | Available |
| Vertical | -- | Available |
| Size | XS (default) | Available | Available |
| S, M, L, XL | -- | Available on Android Views (MDC-Android). Available as tokens on other platforms.* |
| Stop indicators | No (default), Yes | Available as “discrete” slider | Available |
| Value Indicator | No (default), Yes | Available | Available |

> *Configurations only available using tokens don’t have implemented presets in code. To change the size, swap the default size tokens md.comp.slider.**xsmall**.[...] with those of the desired size.

## Tokens & specs

Slider tokens are organized into a common token set, and token sets for each size. Switch token sets from the table’s menu. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Slider (`md.comp.slider`)

Common tokens for all expressive slider sizes, and baseline sliders.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.with-tick-marks.container.size` *(deprecated)* | Slider with tick marks container size |  | 2dp |
| `md.comp.slider.with-tick-marks.container.shape` *(deprecated)* | Slider with tick marks container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.with-tick-marks.active.container.color` *(deprecated)* | Slider with tick marks active container color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.slider.active.stop-indicator.container.color` | Slider active stop indicator container color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.slider.with-tick-marks.active.container.opacity` *(deprecated)* | Slider with tick marks active container opacity |  | 0.38 |
| `md.comp.slider.active.stop-indicator.container.opacity` | Slider active stop indicator container opacity |  | 1 |
| `md.comp.slider.with-tick-marks.inactive.container.color` *(deprecated)* | Slider with tick marks inactive container color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.slider.inactive.stop-indicator.container.color` | Slider inactive stop indicator container color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.slider.with-tick-marks.inactive.container.opacity` *(deprecated)* | Slider with tick marks inactive container opacity |  | 0.38 |
| `md.comp.slider.inactive.stop-indicator.container.opacity` | Slider inactive stop indicator container opacity |  | 1 |
| `md.comp.slider.label.container.height` *(deprecated)* | Slider label container height |  | 28dp |
| `md.comp.slider.label.container.color` *(deprecated)* | Slider label container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.label.container.elevation` *(deprecated)* | Slider label container elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.slider.active.container.opacity` *(deprecated)* | Slider active container opacity |  | 1 |
| `md.comp.slider.inactive.container.opacity` *(deprecated)* | Slider inactive container opacity |  | 1 |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.disabled.handle.color` | Slider disabled handle color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.focus.handle.color` *(deprecated)* | Slider focus handle color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.handle.height` | Slider handle height |  | 44dp |
| `md.comp.slider.hover.handle.color` *(deprecated)* | Slider hover handle color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.pressed.handle.color` | Slider pressed handle color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.disabled.handle.elevation` *(deprecated)* | Slider disabled handle elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.slider.focus.handle.width` | Slider focus handle width |  | 2dp |
| `md.comp.slider.handle.width` | Slider handle width |  | 4dp |
| `md.comp.slider.hover.handle.width` | Slider hover handle width |  | 4dp |
| `md.comp.slider.pressed.handle.width` | Slider pressed handle width |  | 2dp |
| `md.comp.slider.disabled.handle.opacity` | Slider disabled handle opacity |  | 0.38 |
| `md.comp.slider.handle.shape` | Slider handle shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.disabled.handle.width` | Slider disabled handle width |  | 4dp |
| `md.comp.slider.handle.elevation` *(deprecated)* | Slider handle elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.slider.handle.shadow-color` *(deprecated)* | Slider handle shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.slider.handle.color` | Slider handle color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.active.handle.color` | Slider active handle color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.active.handle.height` | Slider active handle height |  | 44dp |
| `md.comp.slider.active.handle.width` | Slider active handle width |  | 4dp |
| `md.comp.slider.with-overlap.handle.outline.color` *(deprecated)* | Slider with overlap handle outline color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.slider.with-overlap.handle.outline.width` *(deprecated)* | Slider with overlap handle outline width |  | 1dp |
| `md.comp.slider.active.handle.shape` | Slider active handle shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.active.handle.leading-space` | Slider active handle leading space | md.sys.measurement.space75 | 6dp |
| `md.comp.slider.active.handle.trailing-space` | Slider active handle trailing space | md.sys.measurement.space75 | 6dp |
| `md.comp.slider.active.handle.padding` | Slider active handle padding | md.sys.measurement.space75 | 6dp |

**Stop indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.disabled.stop-indicator.color` *(deprecated)* | Slider disabled stop color inactive track | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.stop-indicator.size` | Slider stop indicator size |  | 4dp |
| `md.comp.slider.disabled.stop-indicator.color-selected` *(deprecated)* | Slider disabled stop color active track | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.slider.stop-indicator.shape` | Slider stop indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.disabled.active.stop-indicator.container.color` | Slider disabled active stop indicator container color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.slider.stop-indicator.trailing-space` | Slider stop indicator trailing space | md.sys.measurement.space50 | 4dp |
| `md.comp.slider.disabled.inactive.stop-indicator.container.color` | Slider disabled inactive stop indicator container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.stop-indicator.color` | Slider stop indicator color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.slider.stop-indicator.color-selected` | Slider stop indicator color selected | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.active.track.height` | Slider active track height |  | 16dp |
| `md.comp.slider.disabled.active.track.color` | Slider disabled active track color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.focus.active.track.color` | Slider focus active track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.pressed.active.track.color` | Slider pressed active track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.disabled.active.track.opacity` | Slider disabled active track opacity |  | 0.38 |
| `md.comp.slider.focus.inactive.track.color` | Slider focus inactive track color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.slider.inactive.track.height` | Slider inactive track height |  | 16dp |
| `md.comp.slider.pressed.inactive.track.color` | Slider pressed inactive track color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.slider.active.track.shape` | Slider active track shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.disabled.inactive.track.color` | Slider disabled inactive track color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.disabled.inactive.track.opacity` | Slider disabled inactive track opacity |  | 0.12 |
| `md.comp.slider.active.track.outer-corner.corner-size` | Slider active track outer corner size | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.active.track.inner-corner.corner-size` | Slider active track inner corner size |  | rounded corners: topRight 2dp, bottomRight 2dp (others 0dp) |
| `md.comp.slider.inactive.track.shape` | Slider inactive track shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.slider.track.elevation` *(deprecated)* | Slider track elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.slider.active.track.color` | Slider active track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.inactive.track.color` | Slider inactive track color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |

**Value indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.value-indicator.container.color` | Slider value indicator container color | dark: md.sys.color.inverse-surface → md.ref.palette.neutral90<br>light: md.sys.color.inverse-surface → md.ref.palette.neutral20 | dark: #E6E0E9<br>light: #322F35 |
| `md.comp.slider.value-indicator.label.label-text.font` | Slider value indicator label font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.slider.value-indicator.label.label-text.color` | Slider value indicator label font color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.slider.value-indicator.label.label-text.line-height` | Slider value indicator label line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.slider.value-indicator.label.label-text.size` | Slider value indicator label size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.slider.value-indicator.label.label-text.tracking` | Slider value indicator label tracking | md.sys.typescale.body-large.tracking | 0.5pt |
| `md.comp.slider.value-indicator.label.label-text.weight` | Slider value indicator label weight | md.sys.typescale.body-large.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.slider.value-indicator.active.bottom-space` | Slider value indicator active bottom space | md.sys.measurement.space150 | 12dp |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.with-tick-marks.disabled.container.color` *(deprecated)* | Slider with tick marks disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.disabled.stop-indicator.container.color` *(deprecated)* | Slider disabled stop indicator container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.slider.with-tick-marks.disabled.container.opacity` *(deprecated)* | Slider with tick marks disabled container opacity |  | 0.38 |
| `md.comp.slider.disabled.stop-indicator.container.opacity` *(deprecated)* | Slider disabled stop indicator container opacity |  | 0.38 |

**[Deprecated] Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.label.label-text.font` *(deprecated)* | Slider label label text font | md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto |
| `md.comp.slider.label.label-text.size` *(deprecated)* | Slider label label text font size | md.sys.typescale.label-medium.size | 12pt |
| `md.comp.slider.label.label-text.line-height` *(deprecated)* | Slider label label text line height | md.sys.typescale.label-medium.line-height | 16pt |
| `md.comp.slider.label.label-text.weight` *(deprecated)* | Slider label label text weight | md.sys.typescale.label-medium.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.slider.label.label-text.tracking` *(deprecated)* | Slider label label text tracking | md.sys.typescale.label-medium.tracking | 0.5pt |
| `md.comp.slider.label.label-text.color` *(deprecated)* | Slider label label text color | dark: md.sys.color.inverse-on-surface → md.ref.palette.neutral20<br>light: md.sys.color.inverse-on-surface → md.ref.palette.neutral95 | dark: #322F35<br>light: #F5EFF7 |
| `md.comp.slider.label.label-text.font-size` *(deprecated)* | Slider label label text font size | md.sys.typescale.label-medium.size | 12pt |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.focus.state-layer.color` *(deprecated)* | Slider focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.hover.state-layer.color` *(deprecated)* | Slider hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.pressed.state-layer.color` *(deprecated)* | Slider pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.state-layer.size` *(deprecated)* | Slider state layer size |  | 40dp |
| `md.comp.slider.focus.state-layer.opacity` *(deprecated)* | Slider focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.slider.hover.state-layer.opacity` *(deprecated)* | Slider hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.slider.pressed.state-layer.opacity` *(deprecated)* | Slider pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

**[Deprecated] Stop**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.focus.stop.color` *(deprecated)* | Slider focus stop color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.hover.stop.color` *(deprecated)* | Slider hover stop color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.slider.pressed.stop.color` *(deprecated)* | Slider pressed stop color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**[Deprecated] Subhead**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.label.label-text.type` *(deprecated)* | Type style | md.comp.slider.label.label-text.font → md.sys.typescale.label-medium.font → md.ref.typeface.plain | Roboto; weight 500; size 12pt; line-height 16pt; tracking 0.5pt |

#### Token set: Slider - Size - Xsmall (`md.comp.slider.xsmall`)

For expressive XS sliders.

**Active track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xsmall.active.track.height` | Slider xsmall active track height |  | 16dp |
| `md.comp.slider.xsmall.active.track.shape.leading` | Slider xsmall active track leading shape |  | 8dp |

**Inactive track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xsmall.inactive.track.height` | Slider xsmall inactive track height |  | 16dp |
| `md.comp.slider.xsmall.inactive.track.shape.trailing` | Slider xsmall inactive track trailing shape |  | 8dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xsmall.active.handle.height` | Slider xsmall active handle height |  | 44dp |

#### Token set: Slider - Size - Small (`md.comp.slider.small`)

For expressive small sliders.

**Active track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.small.active.track.height` | Slider small active track height |  | 24dp |
| `md.comp.slider.small.active.track.shape.leading` | Slider small active track leading shape |  | 8dp |

**Inactive track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.small.inactive.track.height` | Slider small inactive track height |  | 24dp |
| `md.comp.slider.small.inactive.track.shape.trailing` | Slider small inactive track trailing shape |  | 8dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.small.active.handle.height` | Slider small active handle height |  | 44dp |

#### Token set: Slider - Size - Medium (`md.comp.slider.medium`)

For expressive medium sliders.

**Active track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.medium.active.track.height` | Slider medium active track height |  | 40dp |
| `md.comp.slider.medium.active.track.shape.leading` | Slider medium active track leading shape |  | 12dp |

**Inactive track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.medium.inactive.track.height` | Slider medium inactive track height |  | 40dp |
| `md.comp.slider.medium.inactive.track.shape.trailing` | Slider medium inactive track trailing shape |  | 12dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.medium.active.handle.height` | Slider medium active handle height |  | 44dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.medium.icon.padding` | Slider medium icon padding |  | 6dp |
| `md.comp.slider.medium.icon.size` | Slider medium icon size |  | 24dp |

#### Token set: Slider - Size - Large (`md.comp.slider.large`)

For expressive large sliders.

**Active track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.large.active.track.height` | Slider large active track height |  | 56dp |
| `md.comp.slider.large.active.track.shape.leading` | Slider large active track leading shape |  | 16dp |

**Inactive track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.large.inactive.track.height` | Slider large inactive track trailing shape |  | 56dp |
| `md.comp.slider.large.inactive.track.shape.trailing` | Slider large inactive track trailing shape |  | 16dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.large.active.handle.height` | Slider large active handle height |  | 68dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.large.icon.padding` | Slider large icon padding |  | 6dp |
| `md.comp.slider.large.icon.size` | Slider large icon size |  | 24dp |

#### Token set: Slider - Size - Xlarge (`md.comp.slider.xlarge`)

For expressive XL sliders.

**Active track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xlarge.active.track.height` | Slider xlarge active track height |  | 96dp |
| `md.comp.slider.xlarge.active.track.shape.leading` | Slider xlarge active track leading shape |  | 28dp |

**Inactive track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xlarge.inactive.track.height` | Slider xlarge inactive track height |  | 96dp |
| `md.comp.slider.xlarge.inactive.track.shape.trailing` | Slider xlarge inactive track trailing shape |  | 28dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xlarge.active.handle.height` | Slider xlarge active handle height |  | 108dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.slider.xlarge.icon.padding` | Slider xlarge icon padding |  | 8dp |
| `md.comp.slider.xlarge.icon.size` | Slider xlarge icon size |  | 32dp |

## Anatomy

*[Image: 6 elements of a slider.]*

1. Value indicator (optional)
2. Stop indicators (optional)
3. Active track
4. Handle
5. Inactive track
6. Inset icon (optional)

## Color

*[Image: 9 color roles of a slider.]*

Slider color roles used for light and dark schemes:

1. Inverse surface
2. Inverse on surface
3. Primary
4. On primary
5. Primary
6. Secondary container
7. On secondary container
8. On secondary container
9. On primary

## States

*[Image: 5 states of sliders in light and dark schemes.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

## Measurements

*[Image: Common slider padding and size measurements.]*

Padding and size measurements for common sliders

*[Image: Slider padding and size measurements at each size configuration, XS to XL.]*

Padding and size measurements for XS, S, M, L, and XL sliders

| Attribute | XS | S | M | L | XL |
| --- | --- | --- | --- | --- | --- |
| Track height | 16dp | 24dp | 40dp | 56dp | 96dp |
| Label container height | 44dp | | | | |
| Label container width | 48dp | | | | |
| Handle height | 44dp | 44dp | 52dp | 68dp | 108dp |
| Handle width | 4dp | | | | |
| Track shape | 8dp | 8dp | 12dp | 16dp | 28dp |
| Inset icon size | -- | -- | 24dp | 24dp | 32dp |
