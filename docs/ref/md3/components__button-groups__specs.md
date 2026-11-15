Source: https://m3.material.io/components/button-groups/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-09-16T18:25:16.117Z

# Button groups — Specs

## Variants

*[Image: Various colors and shapes of standard and connected button groups.]*

1. Standard button group
2. Connected button group

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Standard button group | -- | Available |
| Connected button group | Available as segmented button | Available |

## Configurations

*[Image: Five sizes of button groups and two shapes of button groups.]*

Configurations for both variants of button groups:

1. Extra small
2. Small
3. Medium
4. Large
5. Extra large
6. Single-select and multi-select
7. Round and square

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Size | XS, S, M, L, XL | -- | Available |
| Default shape | Round, square | -- | Available |
| Selection | Single-select, multi-select, selection-required | Available as segmented button | Available |

## Tokens & specs

Standard and connected button group tokens are organized by size. Select the variant and size from the token set menu. Go to the [button](https://m3.material.io/components/buttons/specs/) and [icon button](https://m3.material.io/components/icon-buttons/specs/) pages to view their tokens. [Learn about design tokens](https://m3.material.io/foundations/design-tokens/overview/)

#### Token set: Button group standard - Size - Xsmall (`md.comp.button-group.standard.xsmall`)

For XS standard button groups.

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.xsmall.pressed.item.width.motion.spring.dampening` | Button group xsmall pressed motion spring dampening | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button-group.standard.xsmall.pressed.item.width.motion.spring.stiffness` | Button group xsmall pressed motion spring stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button-group.standard.xsmall.pressed.item.width.multiplier` | Button group xsmall pressed width multiplier |  | 15% |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.xsmall.container.height` | Button group xsmall container height |  | 32dp |
| `md.comp.button-group.standard.xsmall.between-space` | Button group xsmall between space |  | 18dp |

#### Token set: Button group standard - Size - Small (`md.comp.button-group.standard.small`)

For small standard button groups.

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.small.pressed.item.width.motion.spring.dampening` | Button group small pressed motion spring dampening | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button-group.standard.small.pressed.item.width.motion.spring.stiffness` | Button group small pressed motion spring stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button-group.standard.small.pressed.item.width.multiplier` | Button group small pressed width multiplier |  | 15% |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.small.container.height` | Button group small container height |  | 40dp |
| `md.comp.button-group.standard.small.between-space` | Button group small between space | md.sys.measurement.space150 | 12dp |

#### Token set: Button group standard - Size - Medium (`md.comp.button-group.standard.medium`)

For medium standard button groups.

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.medium.pressed.item.width.motion.spring.dampening` | Button group medium pressed motion spring dampening | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button-group.standard.medium.pressed.item.width.motion.spring.stiffness` | Button group medium pressed motion spring stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button-group.standard.medium.pressed.item.width.multiplier` | Button group medium pressed width multiplier |  | 15% |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.medium.container.height` | Button group medium container height |  | 56dp |
| `md.comp.button-group.standard.medium.between-space` | Button group medium between space | md.sys.measurement.space100 | 8dp |

#### Token set: Button group standard - Size - Large (`md.comp.button-group.standard.large`)

For large standard button groups.

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.large.pressed.item.width.motion.spring.dampening` | Button group large pressed motion spring dampening | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button-group.standard.large.pressed.item.width.motion.spring.stiffness` | Button group large pressed motion spring stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button-group.standard.large.pressed.item.width.multiplier` | Button group large pressed width multiplier |  | 15% |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.large.container.height` | Button group large container height |  | 96dp |
| `md.comp.button-group.standard.large.between-space` | Button group large between space | md.sys.measurement.space100 | 8dp |

#### Token set: Button group standard - Size - Xlarge (`md.comp.button-group.standard.xlarge`)

For XL standard button groups.

**Pressed**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.xlarge.pressed.item.width.motion.spring.dampening` | Button group xlarge pressed motion spring dampening | md.sys.motion.spring.fast.spatial.damping | expressive: 0.6<br>standard: 0.9 |
| `md.comp.button-group.standard.xlarge.pressed.item.width.motion.spring.stiffness` | Button group xlarge pressed motion spring stiffness | md.sys.motion.spring.fast.spatial.stiffness | expressive: 800<br>standard: 1400 |
| `md.comp.button-group.standard.xlarge.pressed.item.width.multiplier` | Button group xlarge pressed width multiplier |  | 15% |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.standard.xlarge.container.height` | Button group xlarge container height |  | 136dp |
| `md.comp.button-group.standard.xlarge.between-space` | Button group xlarge between space | md.sys.measurement.space100 | 8dp |

#### Token set: Button group connected - Size - Xsmall (`md.comp.button-group.connected.xsmall`)

For XS connected button groups.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.connected.xsmall.container.height` | Button group connected xsmall container height |  | 32dp |
| `md.comp.button-group.connected.xsmall.between-space` | Button group connected xsmall space between buttons | md.sys.measurement.space25 | 2dp |
| `md.comp.button-group.connected.xsmall.container.shape` | Button group connected xsmall container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button-group.connected.xsmall.inner-corner.corner-size` | Button group connected xsmall inner corner size | md.sys.shape.corner-value.small | 8dp |
| `md.comp.button-group.connected.xsmall.pressed.inner-corner.corner-size` | Button group connected xsmall pressed inner corner size | md.sys.shape.corner-value.extra-small | 4dp |
| `md.comp.button-group.connected.xsmall.selected.inner-corner.corner-size` | Button group connected xsmall selected inner corner size |  | 50% |

#### Token set: Button group connected - Size - Small (`md.comp.button-group.connected.small`)

For small connected button groups.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.connected.small.container.height` | Button group connected small container height |  | 40dp |
| `md.comp.button-group.connected.small.between-space` | Button group connected small space between buttons | md.sys.measurement.space25 | 2dp |
| `md.comp.button-group.connected.small.container.shape` | Button group connected small container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button-group.connected.small.inner-corner.corner-size` | Button group connected small inner corner size | md.sys.shape.corner-value.small | 8dp |
| `md.comp.button-group.connected.small.pressed.inner-corner.corner-size` | Button group connected small pressed inner corner size | md.sys.shape.corner-value.extra-small | 4dp |
| `md.comp.button-group.connected.small.selected.inner-corner.corner-size` | Button group connected small selected inner corner size |  | 50% |

#### Token set: Button group connected - Size - Medium (`md.comp.button-group.connected.medium`)

For medium connected button groups.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.connected.medium.container.height` | Button group connected medium container height |  | 56dp |
| `md.comp.button-group.connected.medium.between-space` | Button group connected medium space between buttons | md.sys.measurement.space25 | 2dp |
| `md.comp.button-group.connected.medium.container.shape` | Button group connected medium container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button-group.connected.medium.inner-corner.corner-size` | Button group connected medium inner corner size | md.sys.shape.corner-value.small | 8dp |
| `md.comp.button-group.connected.medium.pressed.inner-corner.corner-size` | Button group connected medium pressed inner corner size | md.sys.shape.corner-value.extra-small | 4dp |
| `md.comp.button-group.connected.medium.selected.inner-corner.corner-size` | Button group connected medium selected inner corner size |  | 50% |

#### Token set: Button group connected - Size - Large (`md.comp.button-group.connected.large`)

For large connected button groups.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.connected.large.container.height` | Button group connected large container height |  | 96dp |
| `md.comp.button-group.connected.large.between-space` | Button group connected large space between buttons | md.sys.measurement.space25 | 2dp |
| `md.comp.button-group.connected.large.container.shape` | Button group connected large container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button-group.connected.large.inner-corner.corner-size` | Button group connected large inner corner size | md.sys.shape.corner-value.large | 16dp |
| `md.comp.button-group.connected.large.pressed.inner-corner.corner-size` | Button group connected large pressed inner corner size | md.sys.shape.corner-value.medium | 12dp |
| `md.comp.button-group.connected.large.selected.inner-corner.corner-size` | Button group connected large selected inner corner size |  | 50% |

#### Token set: Button group connected - Size - Xlarge (`md.comp.button-group.connected.xlarge`)

For XL connected button groups.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.button-group.connected.xlarge.container.height` | Button group connected xlarge container height |  | 136dp |
| `md.comp.button-group.connected.xlarge.between-space` | Button group connected xlarge space between buttons | md.sys.measurement.space25 | 2dp |
| `md.comp.button-group.connected.xlarge.container.shape` | Button group connected xlarge container shape | md.sys.shape.corner.full | fully rounded (circular) |
| `md.comp.button-group.connected.xlarge.inner-corner.corner-size` | Button group connected xlarge inner corner size | md.sys.shape.corner-value.large-increased | 20dp |
| `md.comp.button-group.connected.xlarge.pressed.inner-corner.corner-size` | Button group connected xlarge pressed inner corner size | md.sys.shape.corner-value.large | 16dp |
| `md.comp.button-group.connected.xlarge.selected.inner-corner.corner-size` | Button group connected xlarge selected inner corner size |  | 50% |

## Anatomy

Button groups are invisible containers that add padding between buttons and modify button shape. They don’t contain any buttons by default.

*[Image: The container outlined on both variants of button groups.]*

1. Container

### Common layouts

Mix and match buttons and icon buttons for different scenarios.

*[Image: 4 common layouts of button groups.]*

1. Label buttons
2. Label buttons and icon buttons
3. Extra small icon buttons
4. Large icon buttons

### Color

Button groups have no color properties. They can use the default button or toggle button color styles, like filled, tonal, and outlined. Avoid using standard icon buttons or text buttons, as they have no container treatment.

*[Image: The container outlined on both variants of button groups.]*

1. Filled
2. Tonal
3. Outlined
4. Elevated

## Selection & activation

**Standard button groups** add interaction between adjacent buttons when a button is selected or activated.  
  
This interaction changes the width, shape, and padding of the selected or activated button, which adjusts the width of buttons directly next to it.

*[Video: A selected button in a standard group bounces against its adjacent button, changing their widths.]*

A selected button changes shape, and briefly changes the width of itself and adjacent buttons

**Connected button groups** don’t add any interaction between buttons when selected or activated.

They only affect the shape of the button being selected or activated.

*[Video: A selected button in a connected button group only changes its own shape.]*

A selected button changes shape without affecting adjacent buttons

## States

### Standard button group

When a button is pressed, standard button groups modify the width and shape of that button and adjacent buttons.

*[Image: 5 states of a standard button group.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

When a toggle button is selected in a standard button group, its shape should change between square and round. The color should change according to the [button specs](https://m3.material.io/components/buttons/specs).

*[Image: 5 states of a standard button group with toggle buttons.]*

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

### Connected button group

Connected button groups have different shape changes than standard button groups. Selecting a button does not affect adjacent buttons.

*[Image: 5 states of a segmented button group.]*

Connected button group unselected states:

1. Enabled
2. Disabled
3. Hovered
4. Focused
5. Pressed

*[Image: 4 states of a segmented button group with toggle buttons.]*

Connected button group selected states:

1. Enabled
2. Hovered
3. Focused
4. Pressed

## Measurements

### Standard button group

Standard groups apply padding between all buttons. The amount of padding changes based on button size to ensure a minimum accessible target size of 48dp. More details on padding: [Button specs](https://m3.material.io/components/buttons/specs), [icon button specs](https://m3.material.io/components/icon-buttons/specs)

*[Image: Standard button group padding measurements.]*

Standard button group inner padding:

1. XS: 18dp
2. S: 12dp
3. M: 8dp
4. L: 8dp
5. XL: 8dp

### Connected button group

For all connected button groups, use 2dp padding. This provides visual consistency at scale.

*[Image: Connected button group padding and corner radius measurements.]*

Round connected button group inner padding is 2dp at every size. The outer shape is fully round, and the inner shape remains square with the following corner sizes:

1. XS: 4dp
2. S: 8dp
3. M: 8dp
4. L: 16dp
5. XL: 20dp

*[Image: Connected button group padding and corner radius measurements for square buttons.]*

Square connected button group inner padding is 2dp at every size. The outer shape has the following corner sizes:

1. XS: 4dp
2. S: 8dp
3. M: 8dp
4. L: 16dp
5. XL: 20dp

### Minimum widths

Extra small and small connected button groups have 48dp target areas and a minimum width of 48dp.

*[Image: 48x48dp accessible target areas on the XS and S connected button groups.]*

1. Extra small
2. Small

## Density

Button groups adapt to density of the buttons inside. [More on density](https://m3.material.io/foundations/layout/grids-spacing/density)

*[Image: Connected button groups at 0, -1, -2, and -3 density.]*

Button groups adapt to the height of the buttons inside, including when density is applied
