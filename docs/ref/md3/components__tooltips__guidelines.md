Source: https://m3.material.io/components/tooltips/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:03:02.412Z

# Tooltips — Guidelines

*[Image: A plain tooltip labeling a button, and a rich tooltip announcing new settings available.]*

Plain and rich tooltips serve different purposes

## Usage

A tooltip provides additional context for a UI element.

**Plain tooltips**  
Plain tooltips briefly describe a UI element. They're best used for labelling UI elements with no text, like icon-only buttons and fields.

**Rich tooltips**  
Rich tooltips provide additional context about a UI element. They can optionally contain a subhead, buttons, and hyperlinks.

Rich tooltips are best used for longer text like definitions or explanations.

*[Image: 2 variants of tooltips.]*

1. Plain tooltip
2. Rich tooltip

> ✅ **Do** — *[Image: Plain tooltip labeling an icon-only button in Google Meet as "Present now".]*
> Use plain tooltips to label icon-only buttons

> ❌ **Don't** — *[Image: Button with an icon and label text saying "Edit". It has a plain tooltip on hover that also says "Edit".]*
> Plain tooltips aren't needed when the UI element already has label text

> ✅ **Do** — *[Image: Rich tooltip describing a new button for adding people. It has a subhead, description, and a button to learn more.]*
> Use rich tooltips to provide extra information and actions about a UI element or new feature

> ❌ **Don't** — *[Image: Rich tooltip explaining that an action is destructive and permanently deletes files.]*
> Don't hide critical information within tooltips as it’s easy to miss. Use an interruptive dialog instead.

## Anatomy

### Plain tooltip

*[Image: 2 elements of a plain tooltip.]*

1. Container
2. Supporting text

### Supporting text

> ✅ **Do** — *[Image: Plain tooltip for an icon-only button shaped like a gear. The tooltip text is "Settings".]*
> Briefly describe a UI element

> ⚠️ **Caution** — *[Image: Plain tooltip for the account switcher. The supporting text includes the user's name and email address on new lines.]*
> Avoid wrapping text to multiple lines or including many pieces of information

### Rich tooltip

*[Image: 4 elements of a rich tooltip.]*

1. Subhead (optional)
2. Container
3. Supporting text
4. Text button (optional)

### Subhead (optional)

Keep subheads brief, ideally to one line. They should summarize or describe the message of the rich tooltip.

Subheads are important to include when the rich tooltip appears automatically, like when the page loads.

> ✅ **Do** — *[Image: Rich tooltip with a brief subhead, supporting text, and a text button.]*
> Summarize the message in a few words

> ❌ **Don't** — *[Image: Rich tooltip with a subhead wrapping to multiple lines.]*
> Avoid wrapping to more than one line

### Text buttons (optional)

Rich tooltips can have up to two text buttons. These should be brief and relevant to the message in the supporting text.

Keep buttons short so they can be side by side. Avoid stacking them when possible.

> ⚠️ **Caution** — *[Image: Rich tooltip with 2 buttons stacked on each other.]*
> Avoid stacking buttons

## Placement

### Plain tooltips

By default, plain tooltips are positioned directly above the parent element.

- If there's a visual boundary, like a button, the distance is 4dp
- If there's no visual boundary, like with text baselines, the distance is 8dp

If the element is in an app bar, the plain tooltip appears below the element at the same distance.

*[Image: Plain tooltip appearing 4dp below a button with a clear visual boundary.]*

Plain tooltip with a 4dp distance between the target and tooltip

### Rich tooltips

By default, rich tooltips are positioned to the bottom right of the parent element. They adjust position to avoid going off screen.  Tooltips shouldn't cover the parent element.

**Dynamic positioning**  
The position of the tooltip adjusts in increments of 8dp to avoid going off-screen.

**Desktop placement**  
On desktop, tooltips may appear centered below the parent element and remain visible while moving within the target region.

*[Image: A rich tooltip in 4 different corners. It   changes position to remain fully on screen.]*

Four different rich tooltip locations based on dynamic positioning

## Behavior

To show a tooltip, hover on the parent element on desktop, or tap and hold the element on mobile. Persistent rich tooltips only appear when clicked or tapped.

### Transient by default

Both plain and rich tooltips disappear 1.5 seconds after navigating away from the target region.

Triggering a new tooltip immediately closes any other open tooltip.

*[Video: Hovering and moving from a button with a plain tooltip.]*

Tooltips disappear after a 1.5 second delay when no other element is hovered

> ❌ **Don't** — *[Image: 2 buttons both showing plain tooltips at once.]*
> Only display one tooltip at a time

### Persistent rich tooltips

Persistent rich tooltips appear when either:

- The parent element is clicked
- The page loads and a new feature is being explained

Persistent rich tooltips remain active even when leaving the target region. They only disappear once a person interacts with another UI element. Hovering doesn't trigger the tooltip.

When appearing on page load, the tooltip can introduce and explain new features on various parent elements.

Avoid using persistent rich tooltips on icon buttons.

> ❌ **Don't** — *[Image: Persistent rich tooltip about a new sharing feature in the Photos app. The button says  "Learn more.”]*
> Don’t use a persistent rich tooltip on icon buttons
