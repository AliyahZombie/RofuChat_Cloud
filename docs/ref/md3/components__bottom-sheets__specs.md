Source: https://m3.material.io/components/bottom-sheets/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T07:45:12.661Z

# Bottom sheets — Specs

Modal bottom sheets are above a scrim while standard bottom sheets don't have a scrim. Besides this, both variants of bottom sheets have the same specs.

*[Image: Diagram of container, drag handle, scrim]*

1. Container
2. Drag handle (optional)
3. Scrim

## Tokens and specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Sheets - Bottom (`md.comp.sheet.bottom`)

For bottom sheets.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.bottom.docked.container.color` | Sheet bottom docked container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.sheet.bottom.docked.container.surface-tint-layer.color` *(deprecated)* | Sheet bottom docked container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.sheet.bottom.docked.modal.container.elevation` | Sheet bottom docked modal container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.sheet.bottom.docked.standard.container.elevation` | Sheet bottom docked standard container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.sheet.bottom.docked.container.shape` | Sheet bottom docked container shape | md.sys.shape.corner.extra-large.top | rounded corners: topLeft 28dp, topRight 28dp (others 0dp) |
| `md.comp.sheet.bottom.docked.minimized.container.shape` | Sheet bottom docked minimized container shape | md.sys.shape.corner.none | rounded corners: 0dp all corners |

**Drag handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.bottom.docked.drag-handle.color` | Sheet bottom docked drag handle color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.sheet.bottom.docked.drag-handle.opacity` *(deprecated)* | Sheet bottom docked drag handle opacity |  | 0.4 |
| `md.comp.sheet.bottom.docked.drag-handle.width` | Sheet bottom docked drag handle width |  | 32dp |
| `md.comp.sheet.bottom.docked.drag-handle.height` | Sheet bottom docked drag handle height |  | 4dp |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.sheet.bottom.focus.indicator.color` | Sheet bottom focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.sheet.bottom.focus.indicator.thickness` | Sheet bottom focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.sheet.bottom.focus.indicator.outline.offset` | Sheet bottom focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Two diagrams featuring color opposites of scrim, container, drag handle]*

Bottom sheet color roles used for both light and dark schemes:

1. Scrim*
2. On surface variant
3. Surface container low

*On Android platforms, the scrim color and opacity is automatically handled by the system UI.

## Measurements

*[Image: Bottom sheet on larger device with 56dp top and 56dp side margins]*

Bottom sheet padding and size measurements

Bottom sheets span the full window width up to 640dp. When the window width exceeds 640dp, bottom sheets adjust to have a top margin of 56dp and side margins of 56dp.

| Attribute | Value |
| --- | --- |
| Drag handle alignment (horizontal) | Center |
| Drag handle padding top/bottom | 22dp |
| Top margin | 72dp |
| Top margin (window width > 640dp) | 56dp |
| Start/end margin (window width > 640dp) | 56dp |
| Width | Full width, up to max-width 640dp |
| Height | Variable |
