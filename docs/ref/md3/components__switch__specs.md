Source: https://m3.material.io/components/switch/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:03:01.922Z

# Switch — Specs

*[Image: 3 elements of a switch.]*

1. Track
2. Handle (formerly "thumb")
3. Icon

## Tokens & specs

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Switch (`md.comp.switch`)

For switches.

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.switch.focus.indicator.color` | Switch focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.switch.focus.indicator.thickness` | Switch focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.switch.focus.indicator.offset` | Switch focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**Handle**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.switch.disabled.unselected.handle.opacity` | Switch disabled unselected handle opacity |  | 0.38 |
| `md.comp.switch.selected.focus.handle.color` | Switch selected focus handle color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.switch.selected.hover.handle.color` | Switch selected hover handle color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.switch.selected.pressed.handle.color` | Switch selected pressed handle color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.switch.unselected.handle.height` | Switch unselected handle height |  | 16dp |
| `md.comp.switch.disabled.selected.handle.opacity` | Switch disabled selected handle opacity |  | 1 |
| `md.comp.switch.unselected.focus.handle.color` | Switch unselected focus handle color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.switch.unselected.hover.handle.color` | Switch unselected hover handle color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.switch.unselected.pressed.handle.color` | Switch unselected pressed handle color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.switch.with-icon.handle.height` | Switch with icon handle height |  | 24dp |
| `md.comp.switch.disabled.selected.handle.color` | Switch disabled selected handle color | dark: md.sys.color.surface → md.ref.palette.neutral6<br>light: md.sys.color.surface → md.ref.palette.neutral98 | dark: #141218<br>light: #FEF7FF |
| `md.comp.switch.selected.handle.height` | Switch selected handle height |  | 24dp |
| `md.comp.switch.disabled.unselected.handle.color` | Switch disabled unselected handle color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.pressed.handle.height` | Switch pressed handle height |  | 28dp |
| `md.comp.switch.disabled.handle.opacity` *(deprecated)* | Switch disabled handle opacity |  | 0.38 |
| `md.comp.switch.unselected.handle.width` | Switch unselected handle width |  | 16dp |
| `md.comp.switch.disabled.handle.elevation` *(deprecated)* | Switch disabled handle elevation | md.sys.elevation.level0 | 0dp |
| `md.comp.switch.with-icon.handle.width` | Switch with icon handle width |  | 24dp |
| `md.comp.switch.selected.handle.width` | Switch selected handle width |  | 24dp |
| `md.comp.switch.pressed.handle.width` | Switch pressed handle width |  | 28dp |
| `md.comp.switch.handle.shape` | Switch handle shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.switch.selected.handle.color` | Switch selected handle color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.switch.unselected.handle.color` | Switch unselected handle color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.switch.handle.shadow-color` *(deprecated)* | Switch handle shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.switch.handle.elevation` *(deprecated)* | Switch handle elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.switch.handle.height` *(deprecated)* | Switch handle height |  | 20dp |
| `md.comp.switch.handle.width` *(deprecated)* | Switch handle width |  | 20dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.switch.disabled.selected.icon.color` | Switch disabled selected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.selected.focus.icon.color` | Switch selected focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.hover.icon.color` | Switch selected hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.icon.color` | Switch selected icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.pressed.icon.color` | Switch selected pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.disabled.selected.icon.opacity` | Switch disabled selected icon opacity |  | 0.38 |
| `md.comp.switch.selected.icon.size` | Switch selected icon size |  | 16dp |
| `md.comp.switch.unselected.focus.icon.color` | Switch unselected focus icon color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.unselected.hover.icon.color` | Switch unselected hover icon color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.unselected.pressed.icon.color` | Switch unselected pressed icon color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.disabled.unselected.icon.color` | Switch disabled unselected icon color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.unselected.icon.color` | Switch unselected icon color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.disabled.unselected.icon.opacity` | Switch disabled unselected icon opacity |  | 0.38 |
| `md.comp.switch.unselected.icon.size` | Switch unselected icon size |  | 16dp |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.switch.state-layer.size` | Switch state layer size |  | 40dp |
| `md.comp.switch.state-layer.shape` | Switch state layer shape | md.sys.shape.corner.full | fully rounded (circular) |

**Track**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.switch.disabled.track.opacity` | Switch disabled track opacity |  | 0.12 |
| `md.comp.switch.selected.focus.track.color` | Switch selected focus track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.hover.track.color` | Switch selected hover track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.pressed.track.color` | Switch selected pressed track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.track.height` | Switch track height |  | 32dp |
| `md.comp.switch.disabled.selected.track.color` | Switch disabled selected track color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.selected.focus.state-layer.color` | Switch selected focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.hover.state-layer.color` | Switch selected hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.selected.pressed.state-layer.color` | Switch selected pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.track.width` | Switch track width |  | 52dp |
| `md.comp.switch.disabled.unselected.track.color` | Switch disabled unselected track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.selected.focus.state-layer.opacity` | Switch selected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.switch.selected.hover.state-layer.opacity` | Switch selected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.switch.selected.pressed.state-layer.opacity` | Switch selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.switch.unselected.track.outline.color` | Switch track outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.switch.disabled.unselected.track.outline.color` | Switch disabled unselected track outline color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.track.outline.width` | Switch track outline width |  | 2dp |
| `md.comp.switch.unselected.focus.track.color` | Switch unselected focus track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.unselected.hover.track.color` | Switch unselected hover track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.unselected.pressed.track.color` | Switch unselected pressed track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |
| `md.comp.switch.track.shape` | Switch track shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.switch.unselected.focus.track.outline.color` | Switch unselected focus track outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.switch.unselected.hover.track.outline.color` | Switch unselected hover track outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.switch.unselected.pressed.track.outline.color` | Switch unselected pressed track outline color | dark: md.sys.color.outline → md.ref.palette.neutral-variant60<br>light: md.sys.color.outline → md.ref.palette.neutral-variant50 | dark: #938F99<br>light: #79747E |
| `md.comp.switch.selected.track.color` | Switch selected track color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.switch.unselected.focus.state-layer.color` | Switch unselected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.unselected.hover.state-layer.color` | Switch unselected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.unselected.pressed.state-layer.color` | Switch unselected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.switch.unselected.focus.state-layer.opacity` | Switch unselected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.switch.unselected.hover.state-layer.opacity` | Switch unselected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.switch.unselected.pressed.state-layer.opacity` | Switch unselected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.switch.unselected.track.color` | Switch unselected track color | dark: md.sys.color.surface-container-highest → md.ref.palette.neutral22<br>light: md.sys.color.surface-container-highest → md.ref.palette.neutral90 | dark: #36343B<br>light: #E6E0E9 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

*[Image: 6 color roles of a switch in light and dark themes.]*

Switch color roles used for light and dark themes:

1. Surface container highest
2. Outline
3. Outline
4. Primary
5. On primary
6. On primary container

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

*[Image: The large body text adjacent to switches uses "on surface" color and the body text uses "on surface variant."]*

The text label uses **on surface**. Supporting text may use **on surface variant**.

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](https://m3.material.io/foundations/interaction/states)

*[Image: 5 states of a switch shown in light and dark themes.]*

1. Enabled
2. Hovered
3. Focused
4. Pressed
5. Disabled

[State specs are in the token module above](https://m3.material.io/components/switch/specs#3708644e-b4d7-4237-bb0a-7afeeae4a9b0)

## Measurements

*[Image: Measurements of switches without icons.]*

Switches without icons

*[Image: Measurements of pressed switches without icons.]*

Pressed switches without icons

*[Image: Measurements of switches with icons.]*

Switches with icons

*[Image: Measurements of pressed switches with icons.]*

Pressed switches with icons

| Element | Attribute | Value |
| --- | --- | --- |
| Track | Height | 32dp |
| Width | 52dp |
| Outline width | 2dp |
| Shape | [md.sys.shape.corner.full](https://m3.material.io/styles/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e) |
| Handle | Height (unselected) | 16dp |
| Height - with icon | 24dp |
| Height (selected) | 24dp |
| Height (pressed) | 28dp |
| Width (unselected) | 16dp |
| Width - with icon | 24dp |
| Width (selected) | 24dp |
| Width (pressed) | 28dp |
| Shape | [md.sys.shape.corner.full](https://m3.material.io/styles/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e) |
| State layer | Size | 40dp |
| Shape | [md.sys.shape.corner.full](https://m3.material.io/styles/shape/corner-radius-scale#56e2bfb5-4bec-49bd-b3a3-bd822c8ab88e) |
| Target | Size | 48dp |
| Icon | Size (selected) | 16dp |
| Icon | Size (unselected) | 16dp |

## Configurations

1. Without icons
2. Icon on selected switch
3. Icon on selected and unselected switch

*[Image: 3 example switches with and without icons in on and off states.]*
