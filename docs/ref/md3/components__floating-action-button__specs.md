Source: https://m3.material.io/components/floating-action-button/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-27T13:59:42.096Z

# FABs — Specs

## Variants

*[Image: An icon on the container of a FAB, medium FAB, and large FAB.]*

1. FAB
2. Medium FAB
3. Large FAB

### Baseline variants

The small FAB is still available, but no longer recommended. [Jump to baseline specs](https://m3.material.io/components/floating-action-button/specs#cd336045-e97d-4a6d-ac23-f778fa695e3c)

*[Image: An icon on the container of a small FAB.]*

1. Small FAB

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| FAB | Available | Available |
| Medium FAB | -- | Available |
| Large FAB | Available | Available |
| Small FAB | Available | Not recommended.  Use a larger size. |

## Configurations

In the expressive update, the **primary**, **secondary**, and **tertiary** set colors were renamed to **primary container**, **secondary container**, and **tertiary container**to match the actual color roles used. New primary, secondary, and tertiary color styles were created to match the corresponding color roles. [View details in the color styles section](https://m3.material.io/components/floating-action-button/specs#67e71ec7-b520-405a-aa06-2decfa0b92a3)

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Color | Primary container, secondary container, tertiary container | Available as primary, secondary, tertiary | Available |
| Primary. secondary, tertiary | -- | Available |

## Tokens & specs

Use the table's menu to select a token set. FAB tokens are organized by size and color. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: FAB - Size - Regular (`md.comp.fab`)

For the default, regular FAB size.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.container.height` | FAB container height |  | 56dp |
| `md.comp.fab.container.width` | FAB container width |  | 56dp |
| `md.comp.fab.icon.size` | FAB icon size |  | 24dp |
| `md.comp.fab.container.shape` | FAB container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |

#### Token set: FAB - Size - Medium (`md.comp.fab.medium`)

For medium FABs.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.medium.container.height` | FAB medium container height |  | 80dp |
| `md.comp.fab.medium.container.width` | FAB medium container width |  | 80dp |
| `md.comp.fab.medium.icon.size` | FAB medium icon size |  | 28dp |
| `md.comp.fab.medium.container.shape` | FAB medium container shape | md.sys.shape.corner.large-increased | rounded corners: 20dp all corners |

#### Token set: FAB - Size - Large (`md.comp.fab.large`)

For large FABs.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.large.container.height` | FAB large container height |  | 96dp |
| `md.comp.fab.large.container.width` | FAB large container width |  | 96dp |
| `md.comp.fab.large.icon.size` | FAB large icon size |  | 36dp |
| `md.comp.fab.large.container.shape` | FAB large container shape | md.sys.shape.corner.extra-large | rounded corners: 28dp all corners |

#### Token set: FAB - Color - Tonal primary (`md.comp.fab.primary-container`)

For tonal primary container FABs.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary-container.container.color` | FAB tonal primary container color | dark: md.sys.color.primary-container → md.ref.palette.primary30<br>light: md.sys.color.primary-container → md.ref.palette.primary90 | dark: #4F378B<br>light: #EADDFF |
| `md.comp.fab.primary-container.container.shadow-color` | FAB tonal primary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.primary-container.container.elevation` | FAB tonal primary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary-container.icon.color` | FAB tonal primary icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary-container.hovered.container.elevation` | FAB tonal primary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.primary-container.hovered.state-layer.color` | FAB tonal primary hovered state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary-container.hovered.state-layer.opacity` | FAB tonal primary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.primary-container.hovered.icon.color` | FAB tonal primary hovered icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary-container.focused.container.elevation` | FAB tonal primary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary-container.focused.state-layer.color` | FAB tonal primary focused state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary-container.focused.state-layer.opacity` | FAB tonal primary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.primary-container.focused.icon.color` | FAB tonal primary focused icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary-container.pressed.container.elevation` | FAB tonal primary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary-container.pressed.state-layer.color` | FAB tonal primary pressed state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary-container.pressed.state-layer.opacity` | FAB tonal primary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.primary-container.pressed.icon.color` | FAB tonal primary pressed icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |

#### Token set: FAB - Color - Tonal secondary (`md.comp.fab.secondary-container`)

For tonal secondary container FABs.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary-container.container.color` | FAB tonal secondary container color | dark: md.sys.color.secondary-container → md.ref.palette.secondary30<br>light: md.sys.color.secondary-container → md.ref.palette.secondary90 | dark: #4A4458<br>light: #E8DEF8 |
| `md.comp.fab.secondary-container.container.shadow-color` | FAB tonal secondary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.secondary-container.container.elevation` | FAB tonal secondary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary-container.icon.color` | FAB tonal secondary icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary-container.hovered.container.elevation` | FAB tonal secondary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.secondary-container.hovered.state-layer.color` | FAB tonal secondary hovered state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary-container.hovered.state-layer.opacity` | FAB tonal secondary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.secondary-container.hovered.icon.color` | FAB tonal secondary hovered icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary-container.focused.container.elevation` | FAB tonal secondary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary-container.focused.state-layer.color` | FAB tonal secondary focused state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary-container.focused.state-layer.opacity` | FAB tonal secondary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.secondary-container.focused.icon.color` | FAB tonal secondary focused icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary-container.pressed.container.elevation` | FAB tonal secondary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary-container.pressed.state-layer.color` | FAB tonal secondary pressed state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary-container.pressed.state-layer.opacity` | FAB tonal secondary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.secondary-container.pressed.icon.color` | FAB tonal secondary pressed icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |

#### Token set: FAB - Color - Tonal tertiary (`md.comp.fab.tertiary-container`)

For tonal tertiary container FABs.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary-container.container.color` | FAB tonal tertiary container color | dark: md.sys.color.tertiary-container → md.ref.palette.tertiary30<br>light: md.sys.color.tertiary-container → md.ref.palette.tertiary90 | dark: #633B48<br>light: #FFD8E4 |
| `md.comp.fab.tertiary-container.container.shadow-color` | FAB tonal tertiary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.tertiary-container.container.elevation` | FAB tonal tertiary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary-container.icon.color` | FAB tonal tertiary icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary-container.hovered.container.elevation` | FAB tonal tertiary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.tertiary-container.hovered.state-layer.color` | FAB tonal tertiary hovered state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary-container.hovered.state-layer.opacity` | FAB tonal tertiary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.tertiary-container.hovered.icon.color` | FAB tonal tertiary hovered icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary-container.focused.container.elevation` | FAB tonal tertiary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary-container.focused.state-layer.color` | FAB tonal tertiary focused state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary-container.focused.state-layer.opacity` | FAB tonal tertiary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.tertiary-container.focused.icon.color` | FAB tonal tertiary focused icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary-container.pressed.container.elevation` | FAB tonal tertiary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary-container.pressed.state-layer.color` | FAB tonal tertiary pressed state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary-container.pressed.state-layer.opacity` | FAB tonal tertiary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.tertiary-container.pressed.icon.color` | FAB tonal tertiary pressed icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |

#### Token set: FAB - Color - Primary (`md.comp.fab.primary`)

For primary color FABs.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.container.color` | FAB primary container color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.primary.container.shadow-color` | FAB primary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.primary.container.elevation` | FAB primary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary.icon.color` | FAB primary icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.hovered.container.elevation` | FAB primary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.primary.hovered.state-layer.color` | FAB primary hovered state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.fab.primary.hovered.state-layer.opacity` | FAB primary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.primary.hovered.icon.color` | FAB primary hovered icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.focused.container.elevation` | FAB primary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary.focused.state-layer.color` | FAB primary focused state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.fab.primary.focused.state-layer.opacity` | FAB primary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.primary.focused.icon.color` | FAB primary focused icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.pressed.container.elevation` | FAB primary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary.pressed.state-layer.color` | FAB primary pressed state layer color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |
| `md.comp.fab.primary.pressed.state-layer.opacity` | FAB primary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.primary.pressed.icon.color` | FAB primary pressed icon color | dark: md.sys.color.on-primary → md.ref.palette.primary20<br>light: md.sys.color.on-primary → md.ref.palette.primary100 | dark: #381E72<br>light: #FFFFFF |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.focus.container.elevation` *(deprecated)* | FAB (primary) focus container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.primary.hover.container.elevation` *(deprecated)* | FAB (primary) hover container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.primary.container.shape` *(deprecated)* | FAB (primary) container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.fab.primary.lowered.focus.container.elevation` *(deprecated)* | FAB (primary) lowered focus container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.primary.lowered.hover.container.elevation` *(deprecated)* | FAB (primary) lowered hover container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.fab.primary.lowered.pressed.container.elevation` *(deprecated)* | FAB (primary) lowered pressed container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.primary.container.width` *(deprecated)* | FAB (primary) container width |  | 56dp |
| `md.comp.fab.primary.container.height` *(deprecated)* | FAB (primary) container height |  | 56dp |
| `md.comp.fab.primary.lowered.container.elevation` *(deprecated)* | FAB (primary) lowered container elevation | md.sys.elevation.level1 | 1dp |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.focus.indicator.color` *(deprecated)* | FAB (primary) focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.fab.primary.focus.indicator.thickness` *(deprecated)* | FAB (primary) focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.fab.primary.focus.indicator.outline.offset` *(deprecated)* | FAB (primary) focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.focus.icon.color` *(deprecated)* | FAB (primary) focus icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary.hover.icon.color` *(deprecated)* | FAB (primary) hover icon color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary.icon.size` *(deprecated)* | FAB (primary) icon size |  | 24dp |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.primary.focus.state-layer.color` *(deprecated)* | FAB (primary) focus state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary.hover.state-layer.color` *(deprecated)* | FAB (primary) hover state layer color | dark: md.sys.color.on-primary-container → md.ref.palette.primary90<br>light: md.sys.color.on-primary-container → md.ref.palette.primary30 | dark: #EADDFF<br>light: #4F378B |
| `md.comp.fab.primary.focus.state-layer.opacity` *(deprecated)* | FAB (primary) focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.primary.hover.state-layer.opacity` *(deprecated)* | FAB (primary) hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

#### Token set: FAB - Color - Secondary (`md.comp.fab.secondary`)

For secondary color FABs.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.container.color` | FAB secondary container color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.fab.secondary.container.shadow-color` | FAB secondary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.secondary.container.elevation` | FAB secondary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary.icon.color` | FAB secondary icon color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.hovered.container.elevation` | FAB secondary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.secondary.hovered.state-layer.color` | FAB secondary hovered state layer color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.fab.secondary.hovered.state-layer.opacity` | FAB secondary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.secondary.hovered.icon.color` | FAB secondary hovered icon color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.focused.container.elevation` | FAB secondary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary.focused.state-layer.color` | FAB secondary focused state layer color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.fab.secondary.focused.state-layer.opacity` | FAB secondary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.secondary.focused.icon.color` | FAB secondary focused icon color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.pressed.container.elevation` | FAB secondary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary.pressed.state-layer.color` | FAB secondary pressed state layer color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |
| `md.comp.fab.secondary.pressed.state-layer.opacity` | FAB secondary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.secondary.pressed.icon.color` | FAB secondary pressed icon color | dark: md.sys.color.on-secondary → md.ref.palette.secondary20<br>light: md.sys.color.on-secondary → md.ref.palette.secondary100 | dark: #332D41<br>light: #FFFFFF |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.focus.container.elevation` *(deprecated)* | FAB (secondary) focus container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.secondary.hover.container.elevation` *(deprecated)* | FAB (secondary) hover container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.secondary.container.shape` *(deprecated)* | FAB (secondary) container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.fab.secondary.lowered.focus.container.elevation` *(deprecated)* | FAB (secondary) lowered focus container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.secondary.lowered.hover.container.elevation` *(deprecated)* | FAB (secondary) lowered hover container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.fab.secondary.lowered.pressed.container.elevation` *(deprecated)* | FAB (secondary) lowered pressed container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.secondary.container.width` *(deprecated)* | FAB (secondary) container width |  | 56dp |
| `md.comp.fab.secondary.container.height` *(deprecated)* | FAB (secondary) container height |  | 56dp |
| `md.comp.fab.secondary.lowered.container.elevation` *(deprecated)* | FAB (secondary) lowered container elevation | md.sys.elevation.level1 | 1dp |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.focus.indicator.color` *(deprecated)* | FAB (secondary) focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.fab.secondary.focus.indicator.thickness` *(deprecated)* | FAB (secondary) focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.fab.secondary.focus.indicator.outline.offset` *(deprecated)* | FAB (secondary) focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.focus.icon.color` *(deprecated)* | FAB (secondary) focus icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary.hover.icon.color` *(deprecated)* | FAB (secondary) hover icon color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary.icon.size` *(deprecated)* | FAB (secondary) icon size |  | 24dp |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.secondary.focus.state-layer.color` *(deprecated)* | FAB (secondary) focus state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary.hover.state-layer.color` *(deprecated)* | FAB (secondary) hover state layer color | dark: md.sys.color.on-secondary-container → md.ref.palette.secondary90<br>light: md.sys.color.on-secondary-container → md.ref.palette.secondary30 | dark: #E8DEF8<br>light: #4A4458 |
| `md.comp.fab.secondary.focus.state-layer.opacity` *(deprecated)* | FAB (secondary) focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.secondary.hover.state-layer.opacity` *(deprecated)* | FAB (secondary) hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

#### Token set: FAB - Color - Tertiary (`md.comp.fab.tertiary`)

For the tertiary style fab.

**Enabled**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.container.color` | FAB tertiary container color | dark: md.sys.color.tertiary → md.ref.palette.tertiary80<br>light: md.sys.color.tertiary → md.ref.palette.tertiary40 | dark: #EFB8C8<br>light: #7D5260 |
| `md.comp.fab.tertiary.container.shadow-color` | FAB tertiary container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.tertiary.container.elevation` | FAB tertiary container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary.icon.color` | FAB tertiary icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Hovered**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.hovered.container.elevation` | FAB tertiary hovered container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.tertiary.hovered.state-layer.color` | FAB tertiary hovered state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.fab.tertiary.hovered.state-layer.opacity` | FAB tertiary hovered state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.tertiary.hovered.icon.color` | FAB tertiary hovered icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Focused**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.focused.container.elevation` | FAB tertiary focused container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary.focused.state-layer.color` | FAB tertiary focused state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.fab.tertiary.focused.state-layer.opacity` | FAB tertiary focused state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.tertiary.focused.icon.color` | FAB tertiary focused icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.pressed.container.elevation` | FAB tertiary pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary.pressed.state-layer.color` | FAB tertiary pressed state layer color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |
| `md.comp.fab.tertiary.pressed.state-layer.opacity` | FAB tertiary pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.fab.tertiary.pressed.icon.color` | FAB tertiary pressed icon color | dark: md.sys.color.on-tertiary → md.ref.palette.tertiary20<br>light: md.sys.color.on-tertiary → md.ref.palette.tertiary100 | dark: #492532<br>light: #FFFFFF |

**[Deprecated] Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.focus.container.elevation` *(deprecated)* | FAB (tertiary) focus container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.tertiary.hover.container.elevation` *(deprecated)* | FAB (tertiary) hover container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.tertiary.lowered.focus.container.elevation` *(deprecated)* | FAB (tertiary) lowered focus container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.tertiary.lowered.hover.container.elevation` *(deprecated)* | FAB (tertiary) lowered hover container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.fab.tertiary.lowered.pressed.container.elevation` *(deprecated)* | FAB (tertiary) lowered pressed container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.tertiary.lowered.container.elevation` *(deprecated)* | FAB (tertiary) lowered container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.tertiary.container.height` *(deprecated)* | FAB (tertiary) container height |  | 56dp |
| `md.comp.fab.tertiary.container.shape` *(deprecated)* | FAB (tertiary) container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.fab.tertiary.container.width` *(deprecated)* | FAB (tertiary) container width |  | 56dp |

**[Deprecated] Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.focus.indicator.color` *(deprecated)* | FAB (tertiary) focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.fab.tertiary.focus.indicator.thickness` *(deprecated)* | FAB (tertiary) focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.fab.tertiary.focus.indicator.outline.offset` *(deprecated)* | FAB (tertiary) focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**[Deprecated] Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.focus.icon.color` *(deprecated)* | FAB (tertiary) focus icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary.hover.icon.color` *(deprecated)* | FAB (tertiary) hover icon color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary.icon.size` *(deprecated)* | FAB (tertiary) icon size |  | 24dp |

**[Deprecated] State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.tertiary.focus.state-layer.color` *(deprecated)* | FAB (tertiary) focus state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary.hover.state-layer.color` *(deprecated)* | FAB (tertiary) hover state layer color | dark: md.sys.color.on-tertiary-container → md.ref.palette.tertiary90<br>light: md.sys.color.on-tertiary-container → md.ref.palette.tertiary30 | dark: #FFD8E4<br>light: #633B48 |
| `md.comp.fab.tertiary.focus.state-layer.opacity` *(deprecated)* | FAB (tertiary) focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.tertiary.hover.state-layer.opacity` *(deprecated)* | FAB (tertiary) hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |

## Anatomy

*[Image: 2 elements of the FAB.]*

1. Container

2. Icon

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens)

### Color styles

FABs can use several combinations of **color** and **on-color** styles, such as **primary** and **on-primary**. The following color mappings provide the same legibility and functionality, so the color mapping you use depends on style alone.

*[Image: 6 FAB color styles in light and dark themes. Each style has 2 color roles, 1 for the container and icon.]*

1. Primary container & On primary container (default)
2. Secondary container & On secondary container
3. Tertiary container & On tertiary container
4. Primary & On primary
5. Secondary & On secondary
6. Tertiary & On tertiary

### Baseline color styles

Surface FAB color styles are still available, but no longer recommended.

*[Image: Baseline FAB style in all 3 sizes.]*

1. Surface FABs

## States

States are visual representations used to communicate the status of a component or interactive element.  
  
When using a non-default color mapping for FABs, make sure the state layer color is the same as the icon color. For example, the state layer color for the **primary** color style should be md.sys.color.primary.

*[Image: 4 states of a FAB shown in light and dark themes.]*

1. Enabled
2. Hovered (8% state layer) - elevation 4
3. Focused (10% state layer)
4. Pressed (10% state layer)

## Measurements

### FAB

*[Image: FAB size measurements.]*

FAB size measurements

*[Image: FAB padding measurements.]*

FAB padding measurements

### Medium FAB

*[Image: Medium FAB size measurements.]*

Medium FAB size measurements

*[Image: Medium FAB padding measurements.]*

Medium FAB padding measurements

### Large FAB

*[Image: Large FAB size measurements.]*

Large FAB size measurements

*[Image: Large FAB padding measurements.]*

Large FAB padding measurements

## Baseline tokens & specs

Use the table's menu to select a token set. This only includes tokens for small and surface FABs, which are both no longer recommended. It doesn't include other colors, or large or regular FABs, since those are still currently used.

#### Token set: FAB - Color - Surface (`md.comp.fab.surface`)

For surface color FABs. Not recommended with expressive FABs.

**Container**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.surface.container.color` | FAB (surface) container color | dark: md.sys.color.surface-container-high → md.ref.palette.neutral17<br>light: md.sys.color.surface-container-high → md.ref.palette.neutral92 | dark: #2B2930<br>light: #ECE6F0 |
| `md.comp.fab.surface.focus.container.elevation` | Surface FAB focus container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.surface.hover.container.elevation` | FAB (surface) hover container elevation | md.sys.elevation.level4 | 8dp |
| `md.comp.fab.surface.pressed.container.elevation` | FAB (surface) pressed container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.surface.lowered.container.color` | FAB (surface) lowered container color | dark: md.sys.color.surface-container-low → md.ref.palette.neutral10<br>light: md.sys.color.surface-container-low → md.ref.palette.neutral96 | dark: #1D1B20<br>light: #F7F2FA |
| `md.comp.fab.surface.lowered.focus.container.elevation` | Surface FAB lowered focus container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.surface.lowered.hover.container.elevation` | Surface FAB lowered hover container elevation | md.sys.elevation.level2 | 3dp |
| `md.comp.fab.surface.lowered.pressed.container.elevation` | Surface FAB lowered pressed container elevation | md.sys.elevation.level1 | 1dp |
| `md.comp.fab.surface.container.shape` | FAB (surface) container shape | md.sys.shape.corner.large | rounded corners: 16dp all corners |
| `md.comp.fab.surface.container.width` | FAB (surface) container width |  | 56dp |
| `md.comp.fab.surface.container.height` | FAB (surface) container height |  | 56dp |
| `md.comp.fab.surface.container.elevation` | FAB (surface) container elevation | md.sys.elevation.level3 | 6dp |
| `md.comp.fab.surface.container.surface-tint-layer.color` *(deprecated)* | FAB (surface) container surface tint layer color | dark: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.surface-tint → md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.container.shadow-color` | FAB (surface) container shadow color | md.sys.color.shadow → md.ref.palette.neutral0 | #000000 |
| `md.comp.fab.surface.lowered.container.elevation` | Surface FAB lowered container elevation | md.sys.elevation.level1 | 1dp |

**Focus indicator**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.surface.focus.indicator.color` | FAB (surface) focus indicator color | dark: md.sys.color.secondary → md.ref.palette.secondary80<br>light: md.sys.color.secondary → md.ref.palette.secondary40 | dark: #CCC2DC<br>light: #625B71 |
| `md.comp.fab.surface.focus.indicator.thickness` | FAB (surface) focus indicator thickness | md.sys.state.focus-indicator.thickness | 3dp |
| `md.comp.fab.surface.focus.indicator.outline.offset` | FAB (surface) focus indicator offset | md.sys.state.focus-indicator.outer-offset | 2dp |

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.surface.focus.icon.color` | FAB (surface) focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.hover.icon.color` | FAB (surface) hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.icon.size` | FAB (surface) icon size |  | 24dp |
| `md.comp.fab.surface.pressed.icon.color` | FAB (surface) pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.icon.color` | FAB (surface) icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.fab.surface.focus.state-layer.color` | FAB (surface) focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.hover.state-layer.color` | FAB (surface) hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.pressed.state-layer.color` | FAB (surface) pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.fab.surface.focus.state-layer.opacity` | FAB (surface) focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.fab.surface.hover.state-layer.opacity` | FAB (surface) hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.fab.surface.pressed.state-layer.opacity` | FAB (surface) pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
