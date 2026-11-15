Source: https://m3.material.io/styles/icons/designing-icons
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T05:07:23.551Z

# Icons — Designing icons

Icons are small symbols to easily identify actions and categories

## Design principles

Icons are an essential element of any interface, packing an informative punch into a small form factor. They’re designed to be simple, modern, friendly, and sometimes quirky. To ensure consistency and readability, their limited size means that each icon must strictly adhere to guidance while still expressing essential characteristics.

> ✅ **Do** — *[Image: Front view of boat icon.]*
> Simplify icons for greater clarity and legibility

> ❌ **Don't** — *[Image: Boat image with sails, mast, and flag.]*
> Don’t be overly literal. Avoid complex icons.

> ✅ **Do** — *[Image: Use geometric, consistent shapes.]*
> Make icons graphic and bold

> ❌ **Don't** — *[Image: Detailed thumbs-up icon with contoured fingers in outline.]*
> Don’t use delicate or loose organic shapes

> ✅ **Do** — *[Image: Four icons with a consistent style.]*
> Use and maintain a consistent visual style throughout one icon set

> ❌ **Don't** — *[Image: Four icons with a inconsistent styles.]*
> Avoid mixing styles for one icon set

## Icon sizes and layout

### Standard (Baseline) icon size

Standard icons are displayed as 24dp x 24dp. For pixel-perfect accuracy, create icons for viewing at 100% scale.

*[Image: Icon at 100% scale on a 24dp grid.]*

24dp grid at 100% scale

*[Image: Icon at 1000% scale on a 24dp grid.]*

24dp grid at 1000% scale

### Additional optical icon sizes

Icons support additional sizes: 20dp, 40dp, and 48dp, with 20dp primarily for desktop, dense layouts, and small scale visuals, and 40dp and 48dp optimized for display or headline type, plus larger screen sizes.

*[Image: Four document icons shown at increasing scales.]*

Supported icon sizes: 20dp, 24dp, 40dp, and 48dp

### Standard (Baseline) icon layout

Icon content should remain inside of the **live area**, which is the region of an image that is unlikely to be hidden from view (such as an area where sidebars appear upon scrolling).

If additional visual weight is needed, content may extend into the padding between the live area and the **trim area** (the complete size of a graphic). No parts of the icon should extend outside of the trim area.

*[Image: A 24dp-by-24dp icon grid with the 20dp-by-20dp live area highlighted.]*

**Live area**

Icon content is limited to the 20dp x 20dp live area, with 2dp of padding around the perimeter

*[Image: A 24dp-by-24dp icon grid with the inner 2dp padding highlighted.]*

**Padding**

2dp of padding surrounds the live area

> ✅ **Do** — *[Image: A 24dp-by-24dp icon grid with the inner 2dp padding highlighted.]*
> Icon content is limited to the 20dp-x-20dp live area, with 2dp of padding around the perimeter

> ⚠️ **Caution** — *[Image: Icon using live area and trim area.]*
> If additional visual weight is needed, content may extend into the padding between the live area and the trim area

> ❌ **Don't** — *[Image: Icon exceeding trim area.]*
> No parts of the icon should extend outside of the trim area

## Grid and keyline shapes

### Icon design template

If your design requires an icon that isn’t covered by the over 2,000 variations in [Google Font’s icon library](https://fonts.google.com/icons), you may want to create your own. [Download this 24dp keyline template](https://storage.googleapis.com/material-io-design/downloads/gm_icon_template.ai.zip)* (ZIP file) to design custom icons in Adobe Illustrator.

**This template is available under* [*Apache 2.0*](https://www.apache.org/licenses/LICENSE-2.0.html)*. By downloading this file, you agree to the* [*Google Terms of Service*](https://policies.google.com/terms)*. The* [*Google Privacy Policy*](https://policies.google.com/privacy) *describes how data is handled in this service.*

### Icon grid and keyline

The icon grid establishes clear rules for the consistent, but flexible, positioning of graphic elements.

Keyline shapes are the foundation of the grid. By using these core shapes as guidelines, you can maintain consistent visual proportions across system icons.

*[Image: A 24dp-by-24dp icon grid.]*

Grid

*[Image: A 24dp-by-24dp grid of foundational icon keylines: square, circle, vertical rectangle, horizontal rectangle.]*

24dp grid at 1000% scale

*[Image: A 24dp-by-24dp grid of foundational icon keylines with the square keyline highlighted.]*

Square height and width, 18dp

*[Image: Add chart icon on square keyline.]*

Icon drawn using square keyline

*[Image: A 24dp-by-24dp grid of foundational icon keylines with the circle keyline highlighted.]*

Circle diameter, 20dp

*[Image: Globe icon on circle keyline.]*

Icon drawn using circle keyline

*[Image: A 24dp-by-24dp grid of foundational icon keylines with the vertical rectangle keyline highlighted.]*

Vertical rectangle height, 20dp, and width, 16dp

*[Image: Document icon on vertical rectangle keyline.]*

Icon drawn using vertical rectangle keyline

*[Image: A 24dp-by-24dp grid of foundational icon keylines with the horizontal keyline highlighted.]*

Horizontal rectangle height, 16dp, and width, 20dp

*[Image: Envelope icon on horizontal rectangle keyline.]*

Icon drawn using horizontal rectangle keyline

> ✅ **Do** — *[Image: Icon grid including a folder icon aligning to the grid. X and Y placement coordinates are shown using integers.]*
> Position icons “on pixel” within the icon grid

> ❌ **Don't** — *[Image: Icon grid including a folder icon misaligned to the grid with X and Y placement coordinates shown using decimals.]*
> Don’t place the icon on a coordinate that isn’t “on pixel”

## Icon metrics

### Anatomy

*[Image: Diagram of a calendar icon on a grid highlighting six different elements.]*

1. Corner
2. Stroke terminal
3. Counter stroke
4. Stroke
5. Counter area
6. Bounding area

### Corners

Corner radii are 2dp by default. For the outlined style symbols, interior corners are square, not rounded. For shapes 2dp wide or less, stroke corners shouldn’t be rounded.

For the rounded style symbols, both exterior and interior corner radii are rounded and for the sharp style symbols, both exterior and interior corners radii reduce from 2dp to 0dp.

*[Image: Credit card symbol placed on grid with 2dp rounded exterior corners highlighted.]*

Exterior corners with 2dp corner radii

*[Image: Credit card symbol placed on grid with 2dp linear interior corners highlighted.]*

Interior corners shouldn’t be rounded

> ⚠️ **Caution** — *[Image: Document icon placed on grid with overly rounded corners highlighted.]*
> Overly round corners reduces the symbol’s legibility

> ❌ **Don't** — *[Image: ‘Add more’ icon placed on grid with inconsistent rounded corners.]*
> Don’t use inconsistent corner radii

### Weight and stroke

The recommended stroke weight for icons is 2dp or the regular weight (400), which includes curves, angles, and both interior and exterior strokes. Material Symbols can provide a range of weights between thin (100) and bold (700).

*[Image: Regular stroke weight timer icon placed on a grid.]*

Timer icon at the regular stroke weight (400)

*[Image: Weight timer symbols ranging from 100 to 700 weight.]*

Timer symbol shown across a 100–700 weight range

*[Image: Arrow symbol placed on a grid with arrowhead terminals trimmed to 45 degrees highlighted.]*

Stroke terminal on an icon

*[Image: Add circle symbol placed on grid with linear 2dp inner stroke highlighted.]*

Counter stroke on an icon

*[Image: Add chart icon placed on grid with consistent stroke weights and squared stroke terminals.]*

Use consistent stroke weights and squared stroke terminals

*[Image: Add chart icon placed on grid showing inconsistent stroke weights and rounded stroke terminals.]*

Don’t use inconsistent stroke weights or rounded stroke terminals

### Complex icon shapes

If an icon requires complex details, subtle adjustments can be made to improve its legibility. These adjustments are referred to as optical corrections. Any optical correction should use the geometric forms on which all other icons are based, without skewing or distorting those shapes.

*[Image: Paperclip icon on grid with adjusted 1.5dp stroke highlighted.]*

The paperclip icon uses 1.5dp of the possible 2dp stroke area to fit multiple curves within the 24dp x 24dp icon space

*[Image: Ramen bowl icon on grid with adjusted 1.5dp stroke highlighted.]*

The ramen bowl icon uses 1.5dp stroke and 2dp stroke together within the 24 x 24dp icon space

> ✅ **Do** — *[Image: Building icon using flat shapes.]*
> Make icons face forward

> ❌ **Don't** — *[Image: Building icon in isometric perspective.]*
> Don’t tilt, rotate, or make icons appear dimensional
