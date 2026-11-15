Source: https://m3.material.io/components/menus/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-28T07:32:19.493Z

# Menus — Specs

## Variants

### Vertical menus

Use vertical menus for a more expressive look and feel, including rounded corners, standard and vibrant color styles, more selection states, and submenu motion.

*[Image: 2 vertical menus use shape and color to indicate selected state.]*

1. Vertical menu with gap
2. Vertical menu with divider

### Baseline variant

In M3 Expressive, baseline menu is still available to use, but doesn’t have the latest shapes, color styles, selection states, and motion. [See baseline menu specs](https://m3.material.io/components/menus/specs#a80df2f9-8610-4ce0-b3a3-b9ee749d5c98)

*[Image: A baseline menu variant with square corners and standard colors.]*

A baseline **menu** has square corners, as compared to a **vertical menu’s** round corners and expressive styling

| **Variant** | **M3** | **M3 Expressive** |
| --- | --- | --- |
| Vertical menus | -- | Available |
| Menu (baseline) | Available | Available |

## Configurations

### Vertical menus layout

*[Image: 2 menus: 1 standard, and 1 with a gap, creating groups.]*

1. Standard
2. Grouped

| **Category** | **Configuration** | **M3** | **M3 Expressiv****e** |
| --- | --- | --- | --- |
| Color | Standard | Available | Available |
| Vibrant | -- | Available |
| Layout | Standard | Available | Available |
| Grouped | -- | Available |

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Menus - Common (`md.comp.menus`)

Common tokens for expressive menus. For baseline menus, use "Menu (baseline)" tokens `md.comp.menu`.

**Typography**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.menu-item.label-text.font` | Menu item label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.menus.menu-item.label-text.line-height` | Menu item label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.menus.menu-item.label-text.size` | Menu item label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.menus.menu-item.label-text.tracking` | Menu item label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.menus.menu-item.label-text.weight` | Menu item label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.menus.menu-item.supporting-text.font` | Menu item supporting text font | md.sys.typescale.body-small.font → md.ref.typeface.plain | Roboto |
| `md.comp.menus.menu-item.supporting-text.line-height` | Menu item supporting text line height | md.sys.typescale.body-small.line-height | 16pt |
| `md.comp.menus.menu-item.supporting-text.size` | Menu item supporting text size | md.sys.typescale.body-small.size | 12pt |
| `md.comp.menus.menu-item.supporting-text.tracking` | Menu item supporting text tracking | md.sys.typescale.body-small.tracking | 0.4pt |
| `md.comp.menus.menu-item.supporting-text.weight` | Menu item supporting text weight | md.sys.typescale.body-small.weight → md.ref.typeface.weight-regular | 400 |
| `md.comp.menus.menu-item.trailing-supporting-text.font` | Menu item trailing supporting text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.menus.menu-item.trailing-supporting-text.line-height` | Menu item trailing supporting text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.menus.menu-item.trailing-supporting-text.size` | Menu item trailing supporting text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.menus.menu-item.trailing-supporting-text.tracking` | Menu item trailing supporting text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.menus.menu-item.trailing-supporting-text.weight` | Menu item trailing supporting text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |

**Horizontal icon-only**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.horizontal.icon-only.menu-item.leading-space` | Menu horizontal icon only menu item leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.horizontal.icon-only.menu-item.trailing-space` | Menu horizontal icon only menu item trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.horizontal.icon-only.menu-item.top-space` | Menu horizontal icon only menu item top space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.horizontal.icon-only.menu-item.bottom-space` | Menu horizontal icon only menu item bottom space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.horizontal.icon-only.gap` | Menu horizontal icon only gap | md.sys.measurement.space50 | 4dp |

**Focus ring**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.menu-item.focus.indicator.color` | Menu item focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.menus.menu-item.focus.indicator.thickness` | Menu item focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.menus.menu-item.focus.indicator.outline.offset` | Menu item focus indicator outline offset | md.sys.state.focus-indicator.inner-offset | -3dp |

**Horizontal**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.horizontal.container.top-space` | Menu horizontal container top space | md.sys.measurement.space100 | 8dp |
| `md.comp.menus.horizontal.container.bottom-space` | Menu horizontal container bottom space | md.sys.measurement.space100 | 8dp |
| `md.comp.menus.horizontal.menu-item.leading-space` | Menu horizontal menu item leading space | md.sys.measurement.space150 | 12dp |
| `md.comp.menus.horizontal.menu-item.trailing-space` | Menu horizontal menu item trailing space | md.sys.measurement.space150 | 12dp |
| `md.comp.menus.horizontal.menu-item.between-space` | Menu horizontal menu item between space | md.sys.measurement.space150 | 12dp |
| `md.comp.menus.horizontal.menu-item.top-space` | Menu horizontal menu item top space | md.sys.measurement.space75 | 6dp |
| `md.comp.menus.horizontal.menu-item.bottom-space` | Menu horizontal menu item bottom space | md.sys.measurement.space75 | 6dp |

**Horizontal, Default**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.horizontal.container.shape` | Menu horizontal container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.menus.horizontal.menu-item.hovered.shape` | Menu horizontal menu item hovered shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.menus.horizontal.menu-item.focused.shape` | Menu horizontal menu item focused shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.menus.horizontal.menu-item.pressed.shape` | Menu horizontal menu item pressed shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |

**Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.menu-item.selected.shape` | Menu item selected shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |

**Default**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.container.shape` | Menu container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.menus.active.container.shape` | Menu active container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.menus.gap` | Menu gap | md.sys.measurement.space25 | 2dp |
| `md.comp.menus.group.padding` | Menu group padding | md.sys.measurement.space25 | 2dp |
| `md.comp.menus.inactive.container.shape` | Menu inactive container shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.menus.container.elevation` | Menu container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.menus.group.shape` | Menu group shape | md.sys.shape.corner.small | rounded corners: 8dp all corners |
| `md.comp.menus.menu-item.height` | Menu item height |  | 44dp |
| `md.comp.menus.menu-item.shape` | Menu item shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.menus.menu-item.first-child.shape` | Menu item first child shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.menus.menu-item.top-space` | Menu item top space | md.sys.measurement.space100 | 8dp |
| `md.comp.menus.menu-item.bottom-space` | Menu item bottom space | md.sys.measurement.space100 | 8dp |
| `md.comp.menus.menu-item.first-child.inner-corner.corner-size` | Menu item first child inner corner corner size | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.menus.menu-item.last-child.shape` | Menu item last child shape | md.sys.shape.corner.medium | rounded corners: 12dp all corners |
| `md.comp.menus.menu-item.leading-space` | Menu item leading space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.menu-item.last-child.inner-corner.corner-size` | Menu item last child inner corner corner size | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.menus.menu-item.trailing-space` | Menu item trailing space | md.sys.measurement.space200 | 16dp |
| `md.comp.menus.menu-item.between-space` | Menu item between space | md.sys.measurement.space150 | 12dp |
| `md.comp.menus.menu-item.leading-icon.size` | Menu item leading icon size |  | 20dp |
| `md.comp.menus.menu-item.trailing-icon.size` | Menu item trailing icon size |  | 20dp |

**Horizontal icon-only, selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.horizontal.icon-only.menu-item.selected.shape` | Menu horizontal icon only menu item selected shape | md.sys.shape.corner.full | fully rounded (circular) |

**Horizontal, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.horizontal.menu-item.selected.hovered.shape` | Menu horizontal menu item selected hovered shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.menus.horizontal.menu-item.selected.focused.shape` | Menu horizontal menu item selected focused shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.menus.horizontal.menu-item.selected.pressed.shape` | Menu horizontal menu item selected pressed shape | md.sys.shape.corner.full | fully rounded (circular) |

#### Token set: Menus - Color - Vibrant (`md.comp.menus.vibrant`)

Color tokens for the vibrant expressive menu.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.container.color` | Menu vibrant container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.vibrant.menu-item.color` | Menu vibrant menu item color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.vibrant.section-label-text.color` | Menu vibrant section label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.label-text.color` | Menu vibrant menu item label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.supporting-text.color` | Menu vibrant menu item supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.trailing-supporting-text.color` | Menu vibrant menu item trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.leading-icon.color` | Menu vibrant menu item leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.trailing-icon.color` | Menu vibrant menu item trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.icon-button.container.color` | Menu vibrant icon button container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.vibrant.icon-button.icon.color` | Menu vibrant icon button icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.disabled.label-text.color` | Menu vibrant menu item disabled label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.disabled.label-text.opacity` | Menu vibrant menu item disabled label text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.disabled.supporting-text.color` | Menu vibrant menu item disabled supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.disabled.supporting-text.opacity` | Menu vibrant menu item disabled supporting text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.disabled.trailing-supporting-text.color` | Menu vibrant menu item disabled trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.disabled.trailing-supporting-text.opacity` | Menu vibrant menu item disabled trailing supporting text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.disabled.leading-icon.color` | Menu vibrant menu item disabled leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.disabled.leading-icon.opacity` | Menu vibrant menu item disabled leading icon opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.disabled.trailing-icon.color` | Menu vibrant menu item disabled trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.disabled.trailing-icon.opacity` | Menu vibrant menu item disabled trailing icon opacity |  | 0.38 |
| `md.comp.menus.vibrant.icon-button.disabled.icon.color` | Menu vibrant icon button disabled icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.hovered.state-layer.color` | Menu vibrant menu item hovered state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.hovered.state-layer.opacity` | Menu vibrant menu item hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.menus.vibrant.menu-item.hovered.label-text.color` | Menu vibrant menu item hovered label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.hovered.supporting-text.color` | Menu vibrant menu item hovered supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.hovered.trailing-supporting-text.color` | Menu vibrant menu item hovered trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.hovered.leading-icon.color` | Menu vibrant menu item hovered leading icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.menu-item.hovered.trailing-icon.color` | Menu vibrant menu item hovered trailing icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.icon-button.hovered.state-layer.color` | Menu vibrant icon button hovered state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.focused.state-layer.color` | Menu vibrant menu item focused state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.focused.state-layer.opacity` | Menu vibrant menu item focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.menus.vibrant.menu-item.focused.label-text.color` | Menu vibrant menu item focused label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.focused.supporting-text.color` | Menu vibrant menu item focused supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.focused.trailing-supporting-text.color` | Menu vibrant menu item focused trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.focused.leading-icon.color` | Menu vibrant menu item focused leading icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.menu-item.focused.trailing-icon.color` | Menu vibrant menu item focused trailing icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.icon-button.focused.state-layer.color` | Menu vibrant icon button focused state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.pressed.state-layer.color` | Menu vibrant menu item pressed state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.pressed.state-layer.opacity` | Menu vibrant menu item pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.menus.vibrant.menu-item.pressed.label-text.color` | Menu vibrant menu item pressed label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.pressed.supporting-text.color` | Menu vibrant menu item pressed supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.pressed.trailing-supporting-text.color` | Menu vibrant menu item pressed trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.pressed.leading-icon.color` | Menu vibrant menu item pressed leading icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.menu-item.pressed.trailing-icon.color` | Menu vibrant menu item pressed trailing icon color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.icon-button.pressed.state-layer.color` | Menu vibrant icon button pressed state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Enabled, Active**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.active.state-layer.color` | Menu vibrant menu item active state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.vibrant.menu-item.active.state-layer.opacity` | Menu vibrant menu item active state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

**Enabled, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.selected.container.color` | Menu vibrant menu item selected container color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.menu-item.selected.supporting-text.color` | Menu vibrant menu item selected supporting text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.trailing-supporting-text.color` | Menu vibrant menu item selected trailing supporting text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.label-text.color` | Menu vibrant menu item selected label text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.leading-icon.color` | Menu vibrant menu item selected leading icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.trailing-icon.color` | Menu vibrant menu item selected trailing icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.icon-button.selected.container.color` | Menu vibrant icon button selected container color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.menus.vibrant.icon-button.selected.icon.color` | Menu vibrant icon button selected icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Disabled, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.selected.disabled.label-text.opacity` | Menu vibrant menu item selected disabled label text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.selected.disabled.supporting-text.opacity` | Menu vibrant menu item selected disabled supporting text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.selected.disabled.trailing-supporting-text.opacity` | Menu vibrant menu item selected disabled trailing supporting text opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.selected.disabled.leading-icon.opacity` | Menu vibrant menu item selected disabled leading icon opacity |  | 0.38 |
| `md.comp.menus.vibrant.menu-item.selected.disabled.trailing-icon.opacity` | Menu vibrant menu item selected disabled trailing icon opacity |  | 0.38 |
| `md.comp.menus.vibrant.icon-button.selected.disabled.icon.color` | Menu vibrant icon button selected disabled icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Hovered, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.selected.hovered.state-layer.color` | Menu vibrant menu item selected hovered state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.hovered.state-layer.opacity` | Menu vibrant menu item selected hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.menus.vibrant.menu-item.selected.hovered.label-text.color` | Menu vibrant menu item selected hovered label text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Focused, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.selected.focused.state-layer.color` | Menu vibrant menu item selected focused state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.focused.state-layer.opacity` | Menu vibrant menu item selected focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.menus.vibrant.menu-item.selected.focused.label-text.color` | Menu vibrant menu item selected focused label text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Pressed, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.vibrant.menu-item.selected.pressed.state-layer.color` | Menu vibrant menu item selected pressed state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.menus.vibrant.menu-item.selected.pressed.state-layer.opacity` | Menu vibrant menu item selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.menus.vibrant.menu-item.selected.pressed.label-text.color` | Menu vibrant menu item selected pressed label text color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

#### Token set: Menus - Color - Standard (`md.comp.menus.standard`)

Color tokens for the standard expressive menu.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.container.color` | Menu standard container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.menus.standard.section-label-text.color` | Menu standard section label text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.container.color` | Menu standard menu item container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.menus.standard.menu-item.label-text.color` | Menu standard menu item label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.supporting-text.color` | Menu standard menu item supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.container.shadow-color` | Menu standard container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.menus.standard.menu-item.leading-icon.color` | Menu standard menu item leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.trailing-icon.color` | Menu standard menu item trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.trailing-supporting-text.color` | Menu standard menu item trailing supporting text color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.icon-button.container.color` | Menu standard icon button container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.menus.standard.icon-button.icon.color` | Menu standard icon button icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Disabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.disabled.label-text.color` | Menu standard menu item disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.disabled.label-text.opacity` | Menu standard menu item disabled label text opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.disabled.supporting-text.color` | Menu standard menu item disabled supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.disabled.supporting-text.opacity` | Menu standard menu item disabled supporting text opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.disabled.trailing-supporting-text.color` | Menu standard menu item disabled trailing supporting text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.disabled.trailing-supporting-text.opacity` | Menu standard menu item disabled trailing supporting text opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.disabled.leading-icon.color` | Menu standard menu item disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.disabled.leading-icon.opacity` | Menu standard menu item disabled leading icon opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.disabled.trailing-icon.color` | Menu standard menu item disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.disabled.trailing-icon.opacity` | Menu standard menu item disabled trailing icon opacity |  | 0.38 |
| `md.comp.menus.standard.disabled.icon-button.icon.color` | Menu standard disabled icon button icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.hovered.state-layer.color` | Menu standard menu item hovered state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.hovered.state-layer.opacity` | Menu standard menu item hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.menus.standard.menu-item.hovered.label-text.color` | Menu standard menu item hovered label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.hovered.leading-icon.color` | Menu standard menu item hovered leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.hovered.trailing-icon.color` | Menu standard menu item hovered trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.icon-button.hovered.state-layer.color` | Menu standard icon button hovered state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.focused.state-layer.color` | Menu standard menu item focused state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.focused.state-layer.opacity` | Menu standard menu item focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.menus.standard.menu-item.focused.label-text.color` | Menu standard menu item focused label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.focused.leading-icon.color` | Menu standard menu item focused leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.focused.trailing-icon.color` | Menu standard menu item focused trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.icon-button.focused.state-layer.color` | Menu standard icon button focused state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.pressed.state-layer.color` | Menu standard menu item pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.pressed.state-layer.opacity` | Menu standard menu item pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.menus.standard.menu-item.pressed.label-text.color` | Menu standard menu item pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.pressed.leading-icon.color` | Menu standard menu item pressed leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.menu-item.pressed.trailing-icon.color` | Menu standard menu item pressed trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menus.standard.icon-button.pressed.state-layer.color` | Menu standard icon button pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Enabled, Active**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.active.state-layer.color` | Menu standard menu item active state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menus.standard.menu-item.active.state-layer.opacity` | Menu standard menu item active state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

**Enabled, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.selected.container.color` | Menu standard menu item selected container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.standard.menu-item.selected.label-text.color` | Menu standard menu item selected label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.supporting-text.color` | Menu standard menu item selected supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.leading-icon.color` | Menu standard menu item selected leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.trailing-icon.color` | Menu standard menu item selected trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.trailing-supporting-text.color` | Menu standard menu item selected trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.icon-button.selected.container.color` | Menu standard icon button selected container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.standard.icon-button.selected.icon.color` | Menu standard icon button selected icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Disabled, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.selected.disabled.container.color` | Menu standard menu item selected disabled container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.menus.standard.menu-item.selected.disabled.container.opacity` | Menu standard menu item selected disabled container opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.selected.disabled.label-text.color` | Menu standard menu item selected disabled label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.disabled.label-text.opacity` | Menu standard menu item selected disabled label text opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.selected.disabled.leading-icon.color` | Menu standard menu item selected disabled leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.disabled.leading-icon.opacity` | Menu standard menu item selected disabled leading icon opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.selected.disabled.trailing-icon.color` | Menu standard menu item selected disabled trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.disabled.trailing-icon.opacity` | Menu standard menu item selected disabled trailing icon opacity |  | 0.38 |
| `md.comp.menus.standard.menu-item.selected.disabled.trailing-supporting-text.color` | Menu standard menu item selected disabled trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.icon-button.disabled.icon.color` | Menu standard icon button disabled icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Hovered, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.selected.hovered.state-layer.color` | Menu standard menu item selected hovered state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.hovered.state-layer.opacity` | Menu standard menu item selected hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.menus.standard.menu-item.selected.hovered.label-text.color` | Menu standard menu item selected hovered label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.hovered.supporting-text.color` | Menu standard menu item selected hovered supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.hovered.trailing-supporting-text.color` | Menu standard menu item selected hovered trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.hovered.leading-icon.color` | Menu standard menu item selected hovered leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.hovered.trailing-icon.color` | Menu standard menu item selected hovered trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.icon-button.selected.hovered.state-layer.color` | Menu standard icon button selected hovered state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Focused, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.selected.focused.state-layer.color` | Menu standard menu item selected focused state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.focused.state-layer.opacity` | Menu standard menu item selected focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.menus.standard.menu-item.selected.focused.label-text.color` | Menu standard menu item selected focused label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.focused.supporting-text.color` | Menu standard menu item selected focused supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.focused.trailing-supporting-text.color` | Menu standard menu item selected focused trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.focused.leading-icon.color` | Menu standard menu item selected focused leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.focused.trailing-icon.color` | Menu standard menu item selected focused trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.icon-button.selected.focused.state-layer.color` | Menu standard icon button selected focused state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Pressed, Selected**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menus.standard.menu-item.selected.pressed.state-layer.color` | Menu standard menu item selected pressed state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.pressed.state-layer.opacity` | Menu standard menu item selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.menus.standard.menu-item.selected.pressed.label-text.color` | Menu standard menu item selected pressed label text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.pressed.supporting-text.color` | Menu standard menu item selected pressed supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.pressed.trailing-supporting-text.color` | Menu standard menu item selected pressed trailing supporting text color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.pressed.leading-icon.color` | Menu standard menu item selected pressed leading icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.menu-item.selected.pressed.trailing-icon.color` | Menu standard menu item selected pressed trailing icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.menus.standard.icon-button.selected.pressed.state-layer.color` | Menu standard icon button selected pressed state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

## Anatomy

### Vertical menus

*[Image: A diagram of a vertical menu.]*

1. Menu item
2. Leading icon (optional)
3. Menu item text
4. Trailing icon (optional)
5. Badge (optional)
6. Trailing text (optional)
7. Container
8. Supporting text (optional)
9. Label text (optional)
10. Gap (optional)
11. Divider (optional)

## Color

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

Menus have two color mappings:

- Standard: Surface-based
- Vibrant: Tertiary-based

These mappings provide options for lower or higher visual emphasis. Vibrant menus are more prominent so should be used sparingly.

*[Image: 2 vertical menus: 1 with lower visual emphasis, and 1 vibrant menu with bold shades.]*

1. Standard color scheme
2. Vibrant color scheme

### Standard colors

*[Image: 2 vertical menus with standard color roles mapped to 11 elements.]*

Vertical menus color roles used for light and dark themes:

1. On surface variant
2. On surface
3. On surface (state layer)
4. Surface container low
5. On surface variant
6. On surface variant
7. Tertiary container (selected)
8. On tertiary container (selected)
9. On surface variant
10. On surface variant
11. On tertiary container (selected)

### Vibrant colors

*[Image: 2 vertical menus with vibrant color roles mapped to 11 elements.]*

Vertical menus color roles used for light and dark themes:

1. On tertiary container
2. On tertiary container
3. On tertiary container (state layer)
4. Tertiary container
5. On tertiary container
6. On tertiary container
7. Tertiary (selected)
8. On tertiary (selected)
9. On tertiary container
10. On tertiary container
11. On tertiary (selected)

## States

States are visual representations used to communicate the status of a component or an interactive element. [More on interaction states](https://m3.material.io/foundations/interaction/states/overview)  
  
Shape morphing in vertical menus creates an expressive active state. As focus moves between submenus, the corner shape changes to highlight the active menu. [More on menu focus](https://m3.material.io/components/menus/guidelines#7cc1d01b-a454-48c7-8306-e60347ffd17f)

*[Image: 6 vertical menu states in light and dark themes.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed
6. Active (main menu reveals submenu)

## Measurements

*[Image: Vertical menu marked with spacing and padding measurements.]*

Vertical menu padding and size measurements

## Menu (baseline)

The baseline menu variant is available and continues to work in existing products. However, M3 expressive vertical menus are recommended for new designs.

### Baseline tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Menu (baseline) (`md.comp.menu`)

Tokens for baseline GM3 menus. For expressive menus, use `md.comp.menus` instead.

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.pressed.label-text.color` *(deprecated)* | Menu list item pressed label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.focus.label-text.color` *(deprecated)* | Menu list item focus label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.disabled.label-text.color` *(deprecated)* | Menu list item disabled label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.disabled.label-text.opacity` *(deprecated)* | Menu list item disabled label text opacity |  | 0.38 |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.focus.indicator.color` *(deprecated)* | Menu item focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.menu.focus.indicator.thickness` *(deprecated)* | Menu item focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.menu.focus.indicator.outline.offset` *(deprecated)* | Menu item focus indicator offset | md.sys.state.focus-indicator.inner-offset | -3dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.hover.label-text.color` *(deprecated)* | Menu list item hover label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |

**Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.with-leading-icon.pressed.icon.color` *(deprecated)* | Menu list item pressed leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menu.list-item.with-leading-icon.focus.icon.color` *(deprecated)* | Menu list item focus leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menu.list-item.with-leading-icon.disabled.leading-icon.color` *(deprecated)* | Menu list item disabled leading icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.with-leading-icon.disabled.leading-icon.opacity` *(deprecated)* | Menu list item disabled leading icon opacity |  | 0.38 |
| `md.comp.menu.list-item.with-leading-icon.hover.icon.color` *(deprecated)* | Menu list item hover leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.pressed.state-layer.color` *(deprecated)* | Menu list item pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.pressed.state-layer.opacity` *(deprecated)* | Menu list item pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.menu.list-item.focus.state-layer.color` *(deprecated)* | Menu list item focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.focus.state-layer.opacity` *(deprecated)* | Menu list item focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.menu.list-item.hover.state-layer.color` *(deprecated)* | Menu list item hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.hover.state-layer.opacity` *(deprecated)* | Menu list item hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

**Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.with-trailing-icon.pressed.icon.color` *(deprecated)* | Menu list item pressed trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menu.list-item.with-trailing-icon.focus.icon.color` *(deprecated)* | Menu list item focus trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menu.list-item.with-trailing-icon.disabled.trailing-icon.color` *(deprecated)* | Menu list item disabled trailing icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.with-trailing-icon.disabled.trailing-icon.opacity` *(deprecated)* | Menu list item disabled trailing icon opacity |  | 0.38 |
| `md.comp.menu.list-item.with-trailing-icon.hover.icon.color` *(deprecated)* | Menu list item hover trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.selected.label-text.color` *(deprecated)* | Menu list item selected label text color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.menu.list-item.selected.with-leading-icon.leading-icon.color` *(deprecated)* | Menu list item with leading icon - icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.menu.list-item.selected.with-leading-icon.trailing-icon.color` *(deprecated)* | Menu list item with trailing icon - icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.menu.container.surface-tint-layer.color` *(deprecated)* | Menu container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.menu.list-item.container.height` *(deprecated)* | Menu list item container height |  | 48dp |
| `md.comp.menu.list-item.selected.container.color` *(deprecated)* | Menu list item selected container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |

**Divider**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.divider.color` *(deprecated)* | Menu divider color | dark: md.sys.color.surface-variant → md.ref.palette.neutral-variant30<br>light: md.sys.color.surface-variant → md.ref.palette.neutral-variant90 | dark: #49454F<br>light: #E7E0EC |
| `md.comp.menu.divider.height` *(deprecated)* | Menu divider height |  | 1dp |

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.container.color` | Menu container color | dark: md.sys.color.surface-container → md.ref.palette.neutral12<br>light: md.sys.color.surface-container → md.ref.palette.neutral94 | dark: #211F26<br>light: #F3EDF7 |
| `md.comp.menu.container.shape` | Menu container shape | md.sys.shape.corner.extra-small | rounded corners: 4dp all corners |
| `md.comp.menu.container.shadow-color` | Menu container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.menu.container.elevation` | Menu container elevation | md.sys.elevation.level2 | 3dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.cascading-menu-indicator.icon.color` *(deprecated)* | Menu icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.menu.cascading-menu-indicator.icon.size` *(deprecated)* | Menu icon size |  | 24dp |

**Label text**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.label-text.color` *(deprecated)* | Menu list item label text color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.menu.list-item.label-text.font` *(deprecated)* | Menu list item label text font | md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto |
| `md.comp.menu.list-item.label-text.line-height` *(deprecated)* | Menu list item label text line height | md.sys.typescale.label-large.line-height | 20pt |
| `md.comp.menu.list-item.label-text.size` *(deprecated)* | Menu list item label text size | md.sys.typescale.label-large.size | 14pt |
| `md.comp.menu.list-item.label-text.tracking` *(deprecated)* | Menu list item label text tracking | md.sys.typescale.label-large.tracking | 0.1pt |
| `md.comp.menu.list-item.label-text.weight` *(deprecated)* | Menu list item label text weight | md.sys.typescale.label-large.weight → md.ref.typeface.weight-medium | 500 |
| `md.comp.menu.list-item.label-text.type` *(deprecated)* | Label text type style | md.comp.menu.list-item.label-text.font → md.sys.typescale.label-large.font → md.ref.typeface.plain | Roboto; weight 500; size 14pt; line-height 20pt; tracking 0.1pt |

**Leading icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.with-leading-icon.leading-icon.size` *(deprecated)* | Menu list item leading icon size |  | 24dp |
| `md.comp.menu.list-item.with-leading-icon.leading-icon.color` *(deprecated)* | Menu list item leading icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

**Trailing icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.menu.list-item.with-trailing-icon.trailing-icon.size` *(deprecated)* | Menu list item trailing icon size |  | 24dp |
| `md.comp.menu.list-item.with-trailing-icon.trailing-icon.color` *(deprecated)* | Menu list item trailing icon color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |

### Anatomy

*[Image: Diagram of 6 elements of a baseline menu.]*

1. List item
2. List item leading icon
3. List item trailing icon
4. Container
5. List item trailing text
6. Divider

### Color

*[Image: 9 color roles of a baseline menu in light and dark themes.]*

Baseline menu color roles used for light and dark themes:

1. On surface variant
2. On surface
3. On surface - opacity: 0.08
4. Surface container
5. On surface variant
6. On surface variant
7. On surface variant
8. Surface container highest
9. Outline variant

### States

#### Default menu items

*[Image: Diagram numbering the 5 default states of a baseline menu.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

#### Selected menu items

*[Image: 5 states of a selected baseline menu item.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

[State specs are in the token module above](https://m3.material.io/components/menus/specs#c811d2fa-469a-4e4e-9d9f-0f535c5c9b4c)

### Measurements

*[Image: Diagram of a baseline menu’s padding, text alignment, height, and width.]*

Baseline menu padding and size measurements

| Attribute | Value |
| --- | --- |
| Container width | 112dp min, 280dp max |
| Corner radius | 4dp |
| Vertical label text alignment | Center-aligned |
| Horizontal label text alignment | Start-aligned |
| Left/right padding | 12dp |
| Left/right padding with-icon | 12dp |
| List item height | 48dp |
| Padding between elements within a list item | 12dp |
| Divider top/bottom padding | 8dp |
| Divider height | 1dp |
| Divider width | Dynamic |
| Leading/trailing icon size | 24dp |

### Configurations

A baseline menu appears when a person interacts with a button, action, or other control.

A few examples:

1. Button
2. Text field
3. Icon button
4. Selected text

*[Image: Examples of 4 baseline menu inputs.]*
