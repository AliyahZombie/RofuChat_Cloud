Source: https://m3.material.io/foundations/interaction/states/state-layers
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T05:30:22.307Z

# States — State layers

States show the interaction status of a component or UI element

## State layers

A state layer is a semi-transparent covering on an element that indicates its state. State layers provide a systematic approach to visualizing states by using opacity. A layer can be applied to an entire element or in a circular shape and only one state layer can be applied at a given time.

To transition from an enabled style to a stateful style requires the addition of a state layer.

The state layer is an overlay with a fixed opacity for each state and uses the same color as the content.

For example, if the enabled style uses the **secondary container** color for the container and **on secondary container** for content, the state layer will be an overlay using the **on secondary container** color.

If the enabled style uses the **surface** color for the container and the **primary** color role for content, then the state layer will be an overlay using the **primary** color.

*[Image: State layer sandwiched between the container and content.]*

1. Container
2. State layer
3. Content

The size of state layers is 40dp while the interactive target size is 48dp.

*[Image: Interaction target is larger than the state layer.]*

1. State layer
2. Interactive target

### On colors

By default, a component’s state layer color is derived from the color of its content, either the color of an icon or label text if no icon is present.

An [on color](https://m3.material.io/styles/color/roles#19e75989-7485-4f5b-a769-940c4e4364bc) is a color role used by the content. Each container color has its own corresponding on color.   
  
For example, if a container color is **secondary container**, the content will use the **on secondary container** color role.

*[Image: State layer sandwiched between  the content and container.]*

Order of surface layers shows the state layer (2) between the container (1) and content (3) layers

### State layer tokens & values

The state layer uses a fixed percentage for the opacity for each state. A state layer uses the color used by content (usually the [on color](https://m3.material.io/styles/color/roles#19e75989-7485-4f5b-a769-940c4e4364bc)) and the percentage opacity for its respective state.

*[Image: The opacity values of four overlay states.]*

Four overlay states and their values:

1. Hover +8% opacity
2. Focus +10% opacity
3. Press +10% opacity
4. Drag +16% opacity

#### Token set: State opacities (`md.sys.state`)

Opacity values for state layers.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.state.dragged.state-layer-opacity` | Dragged state layer opacity |  | 0.16 |
| `md.sys.state.pressed.state-layer-opacity` | Pressed state layer opacity |  | 0.1 |
| `md.sys.state.focus.state-layer-opacity` | Focus state layer opacity |  | 0.1 |
| `md.sys.state.hover.state-layer-opacity` | Hover state layer opacity |  | 0.08 |
| `md.sys.state.disabled.state-layer-opacity` | Disabled state layer opacity |  | 0.38 |
