Source: https://m3.material.io/styles/shape/corner-radius-scale
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T05:28:54.725Z

# Shape — Corner radius scale

The M3 shape system includes original shapes, a corner radius scale, and built-in shape morphing

Material components use a corner radius scale to define all rectangular shapes, such as buttons, carousels, and dialogs.

*[Image: Illustration of range of shapes.]*

M3 defines corner radii using a shape scale. This can be used to create both uniform and asymmetrical shapes.

## Shape tokens

Material has shape corner tokens to define all corners, and corner-value tokens for individual corners. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Shape (`md.sys.shape`)

Corner shape and directional modifier (like "top" or "end") tokens.

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.shape.corner.full` | Fully rounded |  | fully rounded (circular) |
| `md.sys.shape.corner.extra-large.top` | Extra large top rounding |  | rounded corners: topLeft 28dp, topRight 28dp (others 0dp) |
| `md.sys.shape.corner.extra-large` | Extra large rounding |  | rounded corners: 28dp all corners |
| `md.sys.shape.corner.large.top` | Large top rounding |  | rounded corners: topLeft 16dp, topRight 16dp (others 0dp) |
| `md.sys.shape.corner.large.end` | Large end rounding |  | rounded corners: topRight 16dp, bottomRight 16dp (others 0dp) |
| `md.sys.shape.corner.large.start` | Large start rounding |  | rounded corners: topLeft 16dp, bottomLeft 16dp (others 0dp) |
| `md.sys.shape.corner.large` | Large rounding |  | rounded corners: 16dp all corners |
| `md.sys.shape.corner.medium` | Medium rounding |  | rounded corners: 12dp all corners |
| `md.sys.shape.corner.small` | Small rounding |  | rounded corners: 8dp all corners |
| `md.sys.shape.corner.extra-small.top` | Extra small top rounding |  | rounded corners: topLeft 4dp, topRight 4dp (others 0dp) |
| `md.sys.shape.corner.extra-small` | Extra small rounding |  | rounded corners: 4dp all corners |
| `md.sys.shape.corner.none` | No rounding |  | rounded corners: 0dp all corners |
| `md.sys.shape.corner.large-increased` | Large increased rounding |  | rounded corners: 20dp all corners |
| `md.sys.shape.corner.extra-large-increased` | Extra large increased rounding |  | rounded corners: 32dp all corners |
| `md.sys.shape.corner.extra-extra-large` | Extra extra large rounding |  | rounded corners: 48dp all corners |
| `md.sys.shape.corner-value.none` | No corner value |  | 0dp |
| `md.sys.shape.corner-value.extra-small` | Extra small corner value |  | 4dp |
| `md.sys.shape.corner-value.small` | Small corner value |  | 8dp |
| `md.sys.shape.corner-value.medium` | Medium corner value |  | 12dp |
| `md.sys.shape.corner-value.large` | Large corner value |  | 16dp |
| `md.sys.shape.corner-value.large-increased` | Large increased corner value |  | 20dp |
| `md.sys.shape.corner-value.extra-large` | Extra large corner value |  | 28dp |
| `md.sys.shape.corner-value.extra-large-increased` | Extra large increased corner value |  | 32dp |
| `md.sys.shape.corner-value.extra-extra-large` | Extra extra large corner value |  | 48dp |

### Corner radius scale

The Material 3 shape system uses a size-based scale with ten styles. Styles are assigned to components based on the desired amount of roundedness.

1. None - 0dp
2. Extra small - 4dp
3. Small - 8dp
4. Medium - 12dp
5. Large - 16dp
6. Large increased - 20dp
7. Extra large - 28dp
8. Extra large increased - 32dp
9. Extra extra large - 48dp
10. Full - fully rounded corners

[Apply shape styles using tokens](https://m3.material.io/foundations/design-tokens/overview)

*[Image: 10 corner radii styles.]*

Steps on the scale are named for the amount of roundedness applied to the corner

*[Image: Components illustrating the old 3-level shape scale.]*

M2: Three-level shape scale based on the size of the component container

*[Image: Components illustrating the new 10-level shape scale.]*

M3: Ten-level shape scale based on the roundedness of shape corners

## Symmetry

Components can have either symmetric or asymmetric corner shapes. Symmetric shapes have the same values for all corners, while asymmetric shapes can have corners with different values.

Both symmetric and asymmetric shapes use the same 10-step scale.

Asymmetrical shapes are used in M3 components with closely-grouped items, such as menus and split buttons. These are called **inner corners**.

*[Image: 3 shapes illustrating symmetrical and asymmetrical styles.]*

**Inner corner** component tokens always map to individual corner shape tokens

## Customizing shapes

Generally, products should consistently use the Material 3 shape styles. However, customization is sometimes necessary, and even encouraged, for hero moments or custom components. Shapes can be customized at the **style** or **component** level.

### Style changes

The corner radius shape style, like **medium**, can be customized to be a different size.

This applies the change to all components mapped to that shape style, unless they have an override.

*[Video: Shapes with different corner radii.]*

Customizing the corner size of the **medium** style applies the change to all components using this style, such as cards and small FABs

### Component changes

The style of a specific component, such as a button, can be changed by customizing which corner radius shape style it maps to.

For example, by default, buttons are mapped to the **full** corner radius shape style. If your product needs a less rounded shape, remap the token to another style in the shape scale, such as **small** or **medium**.

*[Video: Components with different corner radii.]*

Remapping the shape for a component to a different style applies the change to just that component across the UI

The shape style family can be customized from **rounded** to **cut**. This makes the corner a straight line instead of curved.

Add extra padding to avoid cutting off content in information-dense components.

For example, a large cut corner on a card will clip content and images in the area more than a rounded corner of the same size.

> ⚠️ **Caution** — *[Video: Card with text and full corners.]*
> Be careful not to apply large or full corners to information-dense components, such as cards

> ✅ **Do** — *[Image: Carousel with images with rounded corners.]*
> Shapes can be intentionally rounder to add more visual variety

> ✅ **Do** — *[Image: Carousel with full rounded shapes.]*
> Add unexpected moments by switching between square and fully rounded shapes

### Adjust for optical roundness

When nesting rounded objects, avoid using the same corner radii for both objects. This can make the corners look unbalanced.

Instead, adjust the corner radii to be proportional to each other; this is called optical roundness. To calculate optical roundness:

- Outer radius - padding = inner radius
- For example: 48dp - 14dp = 34dp

*[Image: 3 parts of corner radii to adjust.]*

1. Padding
2. Outer radius
3. Inner radius

> ✅ **Do** — *[Image: Nested carousel with optical roundness.]*
> Use different corner radii values for nested components so they have optical roundness

> ❌ **Don't** — *[Image: Nested radii with the same roundness as its container.]*
> Avoid using the same corner radius value for nested objects

### Using the shape library

The Material 3 shape library can be used to create more interesting containers. Use the shape library for mostly visual elements. Avoid applying unconventional shapes to text-heavy containers.

Shapes should be used sparingly to provide a stronger emphasis and moments of delight.

*[Image: Unexpected shapes in carousel.]*

Leverage the Material shape library for moments of delight
