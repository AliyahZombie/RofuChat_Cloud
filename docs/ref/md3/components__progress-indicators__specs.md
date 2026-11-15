Source: https://m3.material.io/components/progress-indicators/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-29T13:37:52.778Z

# Progress indicators — Specs

## Variants

*[Image: 2 variant of progress indicators.]*

1. Linear progress indicator
2. Circular progress indicator

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Linear progress indicator | Available | Available |
| Circular progress indicator | Available | Available |

## Configurations

*[Image: 4 configurations of the linear determinate progress indicator.]*

1. Behavior: Determinate and indeterminate
2. Thickness: Default (4dp) and variable
3. Shape: Flat and wavy

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Behavior | Determinate (default), Indeterminate | Available | Available |
| Track thickness | Fixed (4dp) | Available | Available |
| Configurable | -- | Available |
| Shape | Flat (default) | Available | Available |
| Wavy | -- | Available |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [View baseline tokens](https://m3.material.io/components/progress-indicators/specs#c6f484b0-2bc6-4d37-bd75-f859a35a3594)

#### Token set: Progress Indicator - Common (`md.comp.progress-indicator`)

Common tokens for circular and linear progress indicators.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.active-indicator.color` | Progress indicator active indicator color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.progress-indicator.track.color` | Progress indicator track color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.progress-indicator.stop-indicator.color` | Progress indicator stop indicator color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.active-indicator.shape` | Progress indicator active indicator shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.progress-indicator.track.shape` | Progress indicator track shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.progress-indicator.stop-indicator.shape` | Progress indicator stop indicator shape | md.sys.shape.corner.full | fully rounded (circular) |

**[Deprecated] Active Indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.active-indicator.thickness` *(deprecated)* | Active indicator thickness |  | 4dp |

**[Deprecated] Spacing**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.active-indicator-track-space` *(deprecated)* | Spacing between active indicator and track |  | 4dp |

**[Deprecated] Stop indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.stop-indicator.size` *(deprecated)* | Stop indicator size |  | 4dp |

**[Deprecated] Track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.track.thickness` *(deprecated)* | Track thickness |  | 4dp |

#### Token set: Progress indicator - Linear (`md.comp.progress-indicator.linear`)

For linear progress indicators.

**Linear - baseline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.linear.height` | Progress indicator linear height |  | 4dp |
| `md.comp.progress-indicator.linear.with-wave.height` | Progress indicator linear with wave height |  | 10dp |
| `md.comp.progress-indicator.linear.active-indicator.thickness` | Progress indicator linear active indicator thickness |  | 4dp |
| `md.comp.progress-indicator.linear.track.thickness` | Progress indicator linear track thickness |  | 4dp |
| `md.comp.progress-indicator.linear.stop-indicator.size` | Progress indicator linear stop indicator size |  | 4dp |
| `md.comp.progress-indicator.linear.track-active-indicator-space` | Progress indicator linear track active indicator space | md.sys.measurement.space50 | 4dp |
| `md.comp.progress-indicator.linear.stop-indicator.trailing-space` | Progress indicator linear stop indicator trailing space | md.sys.measurement.space0 | 0dp |
| `md.comp.progress-indicator.linear.active-indicator.wave.amplitude` | Progress indicator linear wave amplitude |  | 3dp |
| `md.comp.progress-indicator.linear.active-indicator.wave.wavelength` | Progress indicator linear wave wavelenght |  | 40dp |
| `md.comp.progress-indicator.linear.indeterminate.active-indicator.wave.wavelength` | Progress indicator linear indeterminate wave wavelength  |  | 20dp |

**[Deprecated] Linear - thick**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.linear.thick.height` *(deprecated)* | Progress indicator linear thick height |  | 8dp |
| `md.comp.progress-indicator.linear.thick.active-indicator.thickness` *(deprecated)* | Progress indicator linear thick with wave height |  | 8dp |
| `md.comp.progress-indicator.linear.thick.with-wave.height` *(deprecated)* | Progress indicator linear thick active indicator thickness |  | 14dp |
| `md.comp.progress-indicator.linear.thick.track.thickness` *(deprecated)* | Progress indicator linear thick track thickness |  | 8dp |
| `md.comp.progress-indicator.linear.thick.stop-indicator.size` *(deprecated)* | Progress indicator linear thick stop indicator size |  | 4dp |
| `md.comp.progress-indicator.linear.thick.track-active-indicator-space` *(deprecated)* | Progress indicator linear thick track active indicator space |  | 4dp |
| `md.comp.progress-indicator.linear.thick.stop-indicator.trailing-space` *(deprecated)* | Progress indicator linear thick stop indicator trailing space |  | 2dp |

#### Token set: Progress indicator - Circular (`md.comp.progress-indicator.circular`)

For circular progress indicators.

**Circular - baseline**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.circular.size` | Progress indicator circular size |  | 40dp |
| `md.comp.progress-indicator.circular.with-wave.size` | Progress indicator circular size with wave |  | 48dp |
| `md.comp.progress-indicator.circular.active-indicator.thickness` | Progress indicator circular active indicator thickness |  | 4dp |
| `md.comp.progress-indicator.circular.track.thickness` | Progress indicator circular track thickness |  | 4dp |
| `md.comp.progress-indicator.circular.track-active-indicator-space` | Progress indicator circular track active indicator space | md.sys.measurement.space50 | 4dp |
| `md.comp.progress-indicator.circular.active-indicator.wave.amplitude` | Progress indicator circular active indicator wave amplitude |  | 1.6dp |
| `md.comp.progress-indicator.circular.active-indicator.wave.wavelength` | Progress indicator circular active indicator wave wavelength |  | 15dp |

**[Deprecated] Circular - thick**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.progress-indicator.circular.thick.size` *(deprecated)* | Progress indicator circular thick size |  | 52dp |
| `md.comp.progress-indicator.circular.thick.active-indicator.thickness` *(deprecated)* | Progress indicator circular thick active indicator thickness |  | 8dp |
| `md.comp.progress-indicator.circular.thick.track.thickness` *(deprecated)* | Progress indicator circular thick track thickness |  | 8dp |
| `md.comp.progress-indicator.circular.thick.track-active-indicator-space` *(deprecated)* | Progress indicator circular thick track active indicator space |  | 4dp |

## Anatomy

*[Image: 3 elements of a progress indicator.]*

1. Active indicator
2. Track
3. Stop indicator

## Color

*[Image: 2 color roles of a linear progress indicator in light and dark themes: the active indicator and stop indicator are primary and the track is secondary container.]*

Progress indicator color roles used for light and dark schemes:

1. Primary
2. Secondary container

## Measurements

Wavy indicators use **amplitude** and **wavelength** to determine the shape of the wave. The height is the overall container height.

*[Image: Definitions of wave measurements for height and amplitude.]*

**Amplitude** measures from the center of the resting position to the center of the peak

*[Image: Definitions of wave measurements for wavelength.]*

**Wavelength** measures the distance between two adjacent peaks

*[Image: Linear progress indicator measurements.]*

Size measurements for linear progress indicators. The thicker variants are provided as sample measurement for makers to adjust the default version based on their use cases.

*[Image: Circular progress indicator measurements.]*

Size measurements for circular progress indicators. The thicker variants are provided as sample measurement for makers to adjust the default version based on their use cases.

*[Image: 4dp padding on the left and right of the linear progress indicator.]*

The linear progress indicator is inset from the edge of the screen by 4dp

## Baseline tokens

The circular and linear progress indicator had separate token sets. These are no longer recommended.

#### Token set: [Deprecated] Progress indicator - Circular (`md.comp.circular-progress-indicator`)

This token set is deprecated. Use `md.comp.progress-indicator.circular` instead. Original tokens for the circular progress indicator.

**[Deprecated] Active indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.circular-progress-indicator.size` *(deprecated)* | Circular progress indicator active indicator size |  | 48dp |
| `md.comp.circular-progress-indicator.active-indicator.width` *(deprecated)* | Circular progress indicator active indicator width |  | 4dp |
| `md.comp.circular-progress-indicator.active-indicator.shape` *(deprecated)* | Circular progress indicator active indicator shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.circular-progress-indicator.active-indicator.color` *(deprecated)* | Circular progress indicator active indicator color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.circular-progress-indicator.four-color.active-indicator.one.color` *(deprecated)* | Circular progress indicator four color active indicator one color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.circular-progress-indicator.four-color.active-indicator.two.color` *(deprecated)* | Circular progress indicator four color active indicator two color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.circular-progress-indicator.four-color.active-indicator.three.color` *(deprecated)* | Circular progress indicator four color active indicator three color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.circular-progress-indicator.four-color.active-indicator.four.color` *(deprecated)* | Circular progress indicator four color active indicator four color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |

#### Token set: [Deprecated] Progress indicator - Linear (`md.comp.linear-progress-indicator`)

This token set is deprecated. Use `md.comp.progress-indicator.linear` instead. Original tokens for the linear progress indicator.

**[Deprecated] Active indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.linear-progress-indicator.active-indicator.height` *(deprecated)* | Linear progress indicator active indicator height |  | 4dp |
| `md.comp.linear-progress-indicator.active-indicator.shape` *(deprecated)* | Linear progress indicator active indicator shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.linear-progress-indicator.active-indicator.color` *(deprecated)* | Linear progress indicator active indicator color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.linear-progress-indicator.four-color.active-indicator.one.color` *(deprecated)* | Linear progress indicator four color active indicator one color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.linear-progress-indicator.four-color.active-indicator.two.color` *(deprecated)* | Linear progress indicator four color active indicator two color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.linear-progress-indicator.four-color.active-indicator.three.color` *(deprecated)* | Linear progress indicator four color active indicator three color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.linear-progress-indicator.four-color.active-indicator.four.color` *(deprecated)* | Linear progress indicator four color active indicator four color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |

**[Deprecated] Track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.linear-progress-indicator.track.height` *(deprecated)* | Linear progress indicator track height |  | 4dp |
| `md.comp.linear-progress-indicator.track.shape` *(deprecated)* | Linear progress indicator track shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |
| `md.comp.linear-progress-indicator.track.color` *(deprecated)* | Linear progress indicator track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
