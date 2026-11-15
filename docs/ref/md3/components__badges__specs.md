Source: https://m3.material.io/components/badges/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T06:58:42.753Z

# Badges — Specs

*[Image: 5 aspects of badge anatomy on a navigation bar.]*

Navigation bar

1. Small badge
2. Large badge container
3. Large badge label
4. Large badge maximum character count container
5. Large badge maximum character count label

*[Image: 5 aspects of badge anatomy on a navigation rail.]*

Navigation rail

1. Small badge
2. Large badge container
3. Large badge label
4. Large badge maximum character count container
5. Large badge maximum character count label

## Tokens & specs

Browse the component elements, attributes, tokens, and their values.

#### Token set: Badges (`md.comp.badge`)

For badges.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.badge.color` | Badge color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.badge.shape` | Badge shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.badge.size` | Badge size |  | 6dp |
| `md.comp.badge.large.color` | Badge large color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.badge.large.shape` | Badge large shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.badge.large.size` | Badge large size |  | 16dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.badge.large.label-text.color` | Badge large label text color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |
| `md.comp.badge.large.label-text.font` | Badge large label text font | md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.badge.large.label-text.line-height` | Badge large label text line height | md.sys.typescale.label-small.line-height | 16pt |
| `md.comp.badge.large.label-text.size` | Badge large label text size | md.sys.typescale.label-small.size | 11pt |
| `md.comp.badge.large.label-text.tracking` | Badge large label text tracking | md.sys.typescale.label-small.tracking | 0.5pt |
| `md.comp.badge.large.label-text.weight` | Badge large label text weight | md.sys.typescale.label-small.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.badge.large.label-text.type` | Badge large label text type | md.comp.badge.large.label-text.font → md.sys.typescale.label-small.font → md.ref.typeface.plain | Roboto; weight 500; size 11pt; line-height 16pt; tracking 0.5pt |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 5 applications of badge color on light and dark theme navigation bars.]*

Badge color roles used for light and dark schemes in navigation bar:

1. Error
2. Error
3. On error
4. On error
5. Error

*[Image: 5 applications of badge color on light and dark theme navigation rails.]*

Badge color roles used for light and dark schemes in navigation rail:

1. Error
2. On error
3. Error
4. On error
5. Error

## Measurements

*[Image: Annotation of badge sizes, padding, and measurements from the corner of the icon to the badge opposite corner.]*

Badge padding and size measurements

| Attribute | Value |
| --- | --- |
| Small badge shape | 3dp corner radius |
| Small badge size (HxW) | 6dp |
| Large badge shape | 8dp corner radius |
| Large badge one digit size (HxW) | 16dp |
| Large badge max character count size (HxW) | 16x34dp |
| Small badge: distance from top trailing icon corner to bottom leading badge corner (HxW) | 6x6dp |
| Large badge: distance from top trailing icon corner to bottom leading badge corner (HxW) | 14x12dp |
| Large badge padding between badge and text container | 4dp |

## Configuration

Different badges are shown on navigation destinations in various states.

*[Image: Diagram of 3 badge variations shown on navigation destinations in various states.]*

1. Inactive with label - small badge
2. Inactive with label - large badge
3. Inactive with label - large badge max character count
4. Inactive - small badge
5. Inactive - large badge
6. Inactive - large badge max character count
7. Active with label - small badge
8. Active with label - large badge
9. Active with label - large badge max character count
10. Active nav bar no label - small badge
11. Active nav bar no label - large badge
12. Active nav bar no label - large badge max character count
13. Active nav rail no label - small badge
14. Active nav rail no label - large badge
15. Active nav rail no label - large badge max character count
