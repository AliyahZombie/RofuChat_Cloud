Source: https://m3.material.io/components/checkbox/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-08-12T09:53:04.800Z

# Checkbox — Specs

## Tokens & specs

Browse the component elements, attributes, tokens, and their values.

#### Token set: Checkbox (`md.comp.checkbox`)

For checkboxes.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.checkbox.container.width` *(deprecated)* | Checkbox container width |  | 18dp |
| `md.comp.checkbox.unselected.disabled.outline.color` | Checkbox unselected disabled outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.focus.outline.color` | Checkbox unselected focus outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.hover.outline.color` | Checkbox unselected hover outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.pressed.outline.color` | Checkbox unselected pressed outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.container.height` *(deprecated)* | Checkbox container height |  | 18dp |
| `md.comp.checkbox.unselected.disabled.outline.width` | Checkbox unselected disabled outline width |  | 2dp |
| `md.comp.checkbox.unselected.focus.outline.width` | Checkbox unselected focus outline width |  | 2dp |
| `md.comp.checkbox.unselected.hover.outline.width` | Checkbox unselected hover outline width |  | 2dp |
| `md.comp.checkbox.unselected.pressed.outline.width` | Checkbox unselected pressed outline width |  | 2dp |
| `md.comp.checkbox.container.size` | Checkbox container size |  | 18dp |
| `md.comp.checkbox.selected.focus.container.color` | Checkbox selected focus container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.hover.container.color` | Checkbox selected hover container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.pressed.container.color` | Checkbox selected pressed container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.unselected.disabled.container.opacity` | Checkbox unselected disabled container opacity |  | 0.38 |
| `md.comp.checkbox.container.shape` | Checkbox container shape |  | rounded corners: 2dp all corners |
| `md.comp.checkbox.selected.disabled.container.color` | Checkbox selected disabled container color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.selected.focus.outline.width` | Checkbox selected focus outline width |  | 0dp |
| `md.comp.checkbox.selected.hover.outline.width` | Checkbox selected hover outline width |  | 0dp |
| `md.comp.checkbox.selected.pressed.outline.width` | Checkbox selected pressed outline width |  | 0dp |
| `md.comp.checkbox.selected.disabled.container.opacity` | Checkbox selected disabled container opacity |  | 0.38 |
| `md.comp.checkbox.unselected.error.focus.outline.color` | Checkbox unselected error focus outline color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.unselected.error.hover.outline.color` | Checkbox unselected error hover outline color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.unselected.error.pressed.outline.color` | Checkbox unselected error pressed outline color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.unselected.outline.color` | Checkbox unselected outline color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.checkbox.selected.disabled.container.outline.width` | Checkbox selected disabled container outline width |  | 0dp |
| `md.comp.checkbox.unselected.error.focus.outline.width` *(deprecated)* | Checkbox unselected error focusd outline width |  | 2dp |
| `md.comp.checkbox.unselected.error.hover.outline.width` *(deprecated)* | Checkbox unselected error hover outline width |  | 2dp |
| `md.comp.checkbox.unselected.error.pressed.outline.width` *(deprecated)* | Checkbox unselected error pressed outline width |  | 2dp |
| `md.comp.checkbox.unselected.outline.width` | Checkbox unselected outline width |  | 2dp |
| `md.comp.checkbox.selected.container.color` | Checkbox selected container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.error.focus.container.color` | Checkbox selected error focus container color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.selected.error.hover.container.color` | Checkbox selected error hover container color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.selected.error.pressed.container.color` | Checkbox selected error pressed container color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.selected.error.focus.outline.width` *(deprecated)* | Checkbox selected error focus outline width |  | 0dp |
| `md.comp.checkbox.selected.error.hover.outline.width` *(deprecated)* | Checkbox selected error hover outline width |  | 0dp |
| `md.comp.checkbox.selected.error.pressed.outline.width` *(deprecated)* | Checkbox selected error pressed outline width |  | 0dp |
| `md.comp.checkbox.selected.outline.width` | Checkbox selected outline width |  | 0dp |
| `md.comp.checkbox.unselected.error.outline.color` | Checkbox unselected error outline color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.selected.error.container.color` | Checkbox selected error container color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.checkbox.focus.indicator.color` | Checkbox focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.checkbox.focus.indicator.thickness` | Checkbox focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.checkbox.focus.indicator.outline.offset` | Checkbox focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.checkbox.icon.size` | Checkbox icon size |  | 18dp |
| `md.comp.checkbox.selected.disabled.icon.color` | Checkbox selected disabled icon color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.checkbox.selected.focus.icon.color` | Checkbox selected focus icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.checkbox.selected.hover.icon.color` | Checkbox selected hover icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.checkbox.selected.pressed.icon.color` | Checkbox selected pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.checkbox.disabled.selected.icon.color` *(deprecated)* | Checkbox disabled selected icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.error.focus.icon.color` | Checkbox selected error focus icon color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |
| `md.comp.checkbox.selected.error.hover.icon.color` | Checkbox selected error hover icon color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |
| `md.comp.checkbox.selected.error.pressed.icon.color` | Checkbox selected error pressed icon color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |
| `md.comp.checkbox.selected.icon.color` | Checkbox selected icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.checkbox.disabled.selected.icon.opacity` *(deprecated)* | Checkbox disabled selected icon opacity |  | 0.38 |
| `md.comp.checkbox.selected.error.icon.color` | Checkbox selected error icon color | dark: md.sys.color.on-error → md.ref.palette.error20<br>light: md.sys.color.on-error → md.ref.palette.error100 | dark: #601410<br>light: #FFFFFF |
| `md.comp.checkbox.unselected.focus.icon.color` *(deprecated)* | Checkbox unselected focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.hover.icon.color` *(deprecated)* | Checkbox unselected hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.pressed.icon.color` *(deprecated)* | Checkbox unselected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.disabled.unselected.icon.color` *(deprecated)* | Checkbox disabled unselected icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.unselected.icon.color` *(deprecated)* | Checkbox unselected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.disabled.unselected.icon.opacity` *(deprecated)* | Checkbox disabled unselected icon opacity |  | 0.38 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.checkbox.error.focus.state-layer.opacity` | Checkbox error focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.checkbox.selected.focus.state-layer.color` | Checkbox selected focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.hover.state-layer.color` | Checkbox selected hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.state-layer.size` | Checkbox state layer size |  | 40dp |
| `md.comp.checkbox.unselected.pressed.state-layer.color` | Checkbox unselected pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.checkbox.selected.focus.state-layer.opacity` | Checkbox selected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.checkbox.selected.hover.state-layer.opacity` | Checkbox selected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.checkbox.state-layer.shape` | Checkbox state layer shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.checkbox.unselected.pressed.state-layer.opacity` | Checkbox unselected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.checkbox.selected.pressed.state-layer.color` | Checkbox selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.focus.state-layer.color` | Checkbox unselected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.unselected.hover.state-layer.color` | Checkbox unselected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.checkbox.selected.pressed.state-layer.opacity` | Checkbox selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.checkbox.unselected.focus.state-layer.opacity` | Checkbox unselected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.checkbox.unselected.hover.state-layer.opacity` | Checkbox unselected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.checkbox.error.focus.state-layer.color` | Checkbox error focus state layer color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.error.hover.state-layer.color` | Checkbox error hover state layer color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.error.pressed.state-layer.color` | Checkbox error pressed state layer color | dark: md.sys.color.error → md.ref.palette.error80<br>light: md.sys.color.error → md.ref.palette.error40 | dark: #F2B8B5<br>light: #B3261E |
| `md.comp.checkbox.error.hover.state-layer.opacity` | Checkbox error hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.checkbox.error.pressed.state-layer.opacity` | Checkbox error pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

## Checkbox

*[Image: Diagram of checkbox indicating the 2 parts of its anatomy.]*

1. Container
2. Icon

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Checkbox color roles in light and dark themes.]*

1. Checkbox
2. State-layer
3. Icon

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

*[Image: Checkboxes with text labels. The text color is the same for checked and unchecked checkboxes.]*

The text color remains the same regardless if the checkbox is selected or not

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](https://m3.material.io/foundations/interaction/states/overview)

*[Image: Side by side view of states in light and dark themes.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

## Measurements

*[Image: Diagram of a selected checkbox with a container width and height of 18dp and a state-layer width and height of 40dp.]*

| Attribute | Value |
| --- | --- |
| Container size | 18dp |
| Container corner shape | 2dp |
| Icon size | 18dp |
| Icon alignment | Center-aligned |
| Target size | 48dp |
| State-layer size | 40dp |
