Source: https://m3.material.io/components/badges/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T06:58:42.753Z

# Badges — Guidelines

*[Image: Diagram of 4 badges in different configurations on a navigation bar's destination icons.]*

Large badges and a small badge in a navigation bar

## Usage

Badges are used to indicate a notification, item count, or other information relating to a navigation destination. They are placed on the ending edge of icons, typically within other components.

There are two variants:

1. Small badge
2. Large badge

*[Image: Diagram of 4 badges in different configurations on a navigation bar's destination icons.]*

Navigation bar with four badges

A **small badge** is a simple circle, used to indicate an unread notification.

A **large badge** contains label text communicating item count information.

*[Image: A small badge is a circle with no characters.]*

Small badge

*[Image: A large badge holds 4 characters and expands its container's width but not height.]*

Large badge

### With other components

Badges are most commonly used within other components, such as navigation bar, navigation rail, app bars, and tabs.

*[Image: Navigation bar with 3 icon buttons. 2 icons buttons have badges and 1 doesn't.]*

In navigation bars, hide the badge once the destination has been selected

## Anatomy

*[Image: Small and large badges on 2 icon buttons.]*

1. Small badge
2. Large badge container
3. Large badge label

## Container

There are two container options for the badge:

- Small badge with no text
- Large badge with text

*[Image: A small badge on a navigation item.]*

A small badge uses only shape to indicate a status change or new notification

*[Image: Number 10 displayed within large badge on a navigation item.]*

A large badge displays a number within a container to indicate a quantifiable status change related to a destination

Badge containers are anchored inside the icon bounding box. As the number count increases for large badges, their width expands, but keeps the same placement.

Badges use a color intended to stand out against labels, icons, and navigation elements. Use the default color mapping to avoid color conflict issues.

> ✅ **Do** — *[Image: Small and large badges on the left side of 2 navigation items in a right-to-left language.]*
> Change the position of the badge for right-to-left languages

> ❌ **Don't** — *[Image: Small and large badges at random positions on 3 icon buttons on a navigation rail.]*
> Badges have fixed positions. Don’t change the position of the badge arbitrarily or place the badge over the icon.

> ✅ **Do** — *[Image: Small and large badges in default red color on 3 navigation items.]*
> Use the default badge color

> ❌ **Don't** — *[Image: Small and large badges in custom colors on 3 navigation items.]*
> Avoid using custom color roles for the badge container and label text. If custom roles are necessary, make sure they have contrast of at least 3:1.

### Label text

Label large badges with counts or a status. The maximum number of characters within large badge label text is four, including a + to indicate more.

*[Image: 4 icons with increasing number badges. The badges represent quantities, using a "+" symbol for quantities over 999.]*

Large badges with one to four characters

Use the recommended maximum character count to ensure labels don’t extend beyond the badge container.

> ✅ **Do** — *[Image: 4-digit numbers condensed to a 3-digit badge with "+" to fit the badge container's width.]*
> Truncate badge labels as needed

> ❌ **Don't** — *[Image: 4-digit and 5-digit number badges on navigation items exceed the badge container's width and get cut off at the edge.]*
> Don’t let the badge get cut off or collide with another element

## Placement

> ✅ **Do** — *[Image: Large badge to the right of a navigation rail item.]*
> Use a large badge to show count information when visual collisions aren’t an issue, such as in a navigation rail

> ⚠️ **Caution** — *[Image: Small badge on an icon button in an app bar.]*
> Use a small badge when spaces are tightly constrained, such as app bars. Small badges won’t run into the edge of the screen.

> ✅ **Do** — *[Image: Large badge placed at the end of a tab.]*
> When an icon with a badge is followed by text or another element, place a large badge at the trailing edge

> ❌ **Don't** — *[Image: Large badge overlapping the icon and text in a tab.]*
> Avoid using a large badge when it might overlap with a trailing element. Either place it at the trailing edge or use a small badge instead.
