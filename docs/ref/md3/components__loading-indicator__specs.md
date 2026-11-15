Source: https://m3.material.io/components/loading-indicator/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-29T13:35:08.589Z

# Loading indicator — Specs

## Variants

*[Image: 2 elements of a loading indicator.]*

1. Loading indicator

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Loading indicator | -- | Available |

## Configurations

*[Image: 2 configurations of loading indicators.]*

1. Default
2. Contained

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Containment | Default | -- | Available |
| Contained | -- | Available |

## Tokens & specs

Loading indicators have a single token set.

#### Token set: Loading indicator (`md.comp.loading-indicator`)

For loading indicators.

**Color**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.loading-indicator.active-indicator.color` | Loading indicator active indicator color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.loading-indicator.container.color` *(deprecated)* | Loading indicator container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.loading-indicator.contained.container.color` | Loading indicator contained container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.loading-indicator.contained.active-indicator.color` | Loading indicator contained active indicator color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |

**Size**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.loading-indicator.active-indicator.size` | Loading indicator container width |  | 38dp |
| `md.comp.loading-indicator.container.height` | Loading indicator container height |  | 48dp |
| `md.comp.loading-indicator.container.width` | Loading indicator active indicator size |  | 48dp |

**Shape**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.loading-indicator.container.shape` | Loading indicator container shape | md.sys.shape.corner.full | fully rounded (circular) |

## Anatomy

*[Image: 2 elements of a loading indicator.]*

1. Active indicator
2. Container

## Color

### Default

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens; in implementation, a color value will be a token that references a value.

*[Image: 2 color roles of a loading progress indicator in light and dark themes.: the active indicator is primary and the container is secondary container.]*

Loading indicator color roles used for light and dark schemes:

1. Primary

### Contained

*[Image: 2 color roles of a loading progress indicator in light and dark themes. The active indicator is primary and the container is secondary container.]*

Contained loading indicator color roles used for light and dark schemes:

1. On primary container
2. Primary container

## Measurements

*[Image: Loading progress indicator measurements.]*

To ensure sufficient margins, the size is 48dp while the shape container is 38dp
