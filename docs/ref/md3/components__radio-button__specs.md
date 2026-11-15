Source: https://m3.material.io/components/radio-button/specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:17:47.331Z

# Radio button — Specs

*[Image: Diagram of enabled radio button.]*

1. Radio button icon

## Tokens & specs

[Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Radio Button (`md.comp.radio-button`)

For radio buttons.

**Icon**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.radio-button.disabled.selected.icon.color` | Radio button disabled selected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.selected.focus.icon.color` | Radio button selected focus icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.selected.hover.icon.color` | Radio button selected hover icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.selected.icon.color` | Radio button icon selected color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.selected.pressed.icon.color` | Radio button selected pressed icon color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.disabled.selected.icon.opacity` | Radio button disabled selected icon opacity |  | 0.38 |
| `md.comp.radio-button.unselected.focus.icon.color` | Radio button unselected focus icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.unselected.hover.icon.color` | Radio button unselected hover icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.unselected.icon.color` | Radio button icon unselected color | dark: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant80<br>light: md.sys.color.on-surface-variant → md.ref.palette.neutral-variant30 | dark: #CAC4D0<br>light: #49454F |
| `md.comp.radio-button.unselected.pressed.icon.color` | Radio button unselected pressed icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.disabled.unselected.icon.color` | Radio button disabled unselected icon color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.icon.size` | Radio button icon size |  | 20dp |
| `md.comp.radio-button.disabled.unselected.icon.opacity` | Radio button disabled unselected icon opacity |  | 0.38 |

**State layer**

| Token | Name | References | Value |
|---|---|---|---|
| `md.comp.radio-button.selected.focus.state-layer.color` | Radio button selected focus state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.selected.hover.state-layer.color` | Radio button selected hover state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.selected.pressed.state-layer.color` | Radio button selected pressed state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.state-layer.size` | Radio button state layer size |  | 40dp |
| `md.comp.radio-button.selected.focus.state-layer.opacity` | Radio button selected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.radio-button.selected.hover.state-layer.opacity` | Radio button selected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.radio-button.selected.pressed.state-layer.opacity` | Radio button selected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |
| `md.comp.radio-button.unselected.focus.state-layer.color` | Radio button unselected focus state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.unselected.hover.state-layer.color` | Radio button unselected hover state layer color | dark: md.sys.color.on-surface → md.ref.palette.neutral90<br>light: md.sys.color.on-surface → md.ref.palette.neutral10 | dark: #E6E0E9<br>light: #1D1B20 |
| `md.comp.radio-button.unselected.pressed.state-layer.color` | Radio button unselected pressed state layer color | dark: md.sys.color.primary → md.ref.palette.primary80<br>light: md.sys.color.primary → md.ref.palette.primary40 | dark: #D0BCFF<br>light: #6750A4 |
| `md.comp.radio-button.unselected.focus.state-layer.opacity` | Radio button unselected focus state layer opacity | md.sys.state.focus.state-layer-opacity | 0.1 |
| `md.comp.radio-button.unselected.hover.state-layer.opacity` | Radio button unselected hover state layer opacity | md.sys.state.hover.state-layer-opacity | 0.08 |
| `md.comp.radio-button.unselected.pressed.state-layer.opacity` | Radio button unselected pressed state layer opacity | md.sys.state.pressed.state-layer-opacity | 0.1 |

## Color

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: Diagram of selected and unselected radio button colors.]*

Radio button color roles used for light and dark themes:

1. Primary
2. On surface variant

### Adjacent text label color

Use the color role **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

*[Image: Radio buttons with labels. The labels are the same color for both selected and unselected radio buttons.]*

The text color remains the same regardless if the button is selected or not

## States

States are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](https://m3.material.io/foundations/interaction/states/overview)

*[Image: Diagram of radio button states including enabled, hover, focus, pressed, and disabled.]*

1. Enabled
2. Hover
3. Focus
4. Pressed
5. Disabled

[State specs are in the token module above](https://m3.material.io/components/radio-button/specs#3eef19a6-cdcb-4ecf-b1af-2b8095d485ac)

## Measurements

*[Image: Diagram of radio button layout values.]*

Radio button size measurements

| Attribute | Value |
| --- | --- |
| Icon size | 20dp |
| State layer size | 40dp |
| Target size | 48dp |
