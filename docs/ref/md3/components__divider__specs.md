Source: https://m3.material.io/components/divider/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:13:07.955Z

# Divider — Specs

*[Image: Diagram of divider set on horizontal line]*

1. Divider

## Tokens and specs

Browse the component elements, attributes, tokens, and their values.

#### Token set: Divider (`md.comp.divider`)

For dividers.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.divider.thickness` | Divider thickness |  | 1dp |
| `md.comp.divider.color` | Divider color | dark: md.sys.color.outline-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.outline-variant → md.ref.palette.neutral-variant80 | dark: #49454F<br>light: #CAC4D0 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview/825906c9-6eed-47d1-8812-450910c1356e)

*[Image: Divider on light background and dark background.]*

Divider color roles used for light and dark schemes:

1. Outline variant

## Measurements

*[Image: Divider's measurement.]*

Measurements

| Attribute | Value |
| --- | --- |
| Divider full-width | 100% |
| Divider inset left margin | 16dp |
| Divider inset right margin | 0dp |
| Divider middle-inset left margin | 16dp |
| Divider middle-inset right margin | 16dp |
| Space between divider & supporting-text | 4dp |
| Divider right margin | 8dp |
| Divider bottom margin | 8dp |
