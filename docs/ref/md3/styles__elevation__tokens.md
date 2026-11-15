Source: https://m3.material.io/styles/elevation/tokens
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T05:03:59.318Z

# Elevation — Tokens

Elevation is the distance between two surfaces on the z-axis

## Tokens

Elevation levels can be implemented with tokens. Surface tint color is deprecated. Use elevation level tokens (0–5) instead. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Elevation (`md.sys.elevation`)

Elevation level tokens

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.elevation.surface-tint-color` *(deprecated)* | Surface tint color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.sys.elevation.level5` | +5 |  | 12dp |
| `md.sys.elevation.level4` | +4 |  | 8dp |
| `md.sys.elevation.level3` | +3 |  | 6dp |
| `md.sys.elevation.level2` | +2 |  | 3dp |
| `md.sys.elevation.level1` | +1 |  | 1dp |
| `md.sys.elevation.level0` | 0 |  | 0dp |

## Component elevation

Most components have a default elevation. Component elevation is only used to determine where the component sits in relation to other components, including when hovered or focused (which usually raises elevation by one level). Elevation has no shadow or value of its own by default.

| Resting level | Component | DP Height |
| --- | --- | --- |
| 5 | (not assigned as resting level) | 12dp |
| 4 | (not assigned as resting level) | 8dp |
| 3 | Date pickers  Dialogs (modal)  Extended FAB  FAB  FAB menu (close button)  Search  Time pickers | 6dp |
| 2 | App bar (scrolled)  Menu  Navigation bar  Rich tooltip  Toolbar | 3dp |
| 1 | Banner  Bottom sheet (modal)  Button (elevated)  Card (elevated)  Chips (elevated)  Navigation drawer (modal)  Side sheet (modal) | 1dp |
| 0 | App bar (not scrolled)  Buttons (filled, tonal, outlined)  Button groups  Cards (filled, outlined)  Carousel  Chips  Dialog (full-screen)  Extended FAB (in navigation rail)  FAB (in navigation rail)  FAB menu (list items)  Icon buttons  List  Navigation rail  Segmented button  Side sheet (docked)  Slider  Split button  Tabs | 0dp |
