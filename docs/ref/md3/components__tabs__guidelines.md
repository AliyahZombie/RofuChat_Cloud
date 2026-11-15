Source: https://m3.material.io/components/tabs/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:03:01.541Z

# Tabs — Guidelines

## Usage

Tabs organize groups of related content that are at the same level of hierarchy.

*[Image: Mobile screen with 3 tabs: video, photos and audio. Each tab has an an icon and text.]*

Tab labels can include icons and text. Text labels should be short.

There are two variants of tabs:

1. Primary tabs
2. Secondary tabs

Primary tabs are placed at the top of the content pane under an app bar. They display the main content destinations.  
  
Secondary tabs are used within a content area to further separate related content and establish hierarchy.

*[Image: 3 primary tabs above 3 secondary tabs.]*

1. Primary tabs
2. Secondary tabs

### Related content

Use tabs to group related content, not *sequential* content.

> ✅ **Do** — *[Image: Scrolling up and down through content, then swiping left through tabs.]*
> Utilize tabs to categorize related groups of content into clearly defined sets

> ❌ **Don't** — *[Image: Mobile screen with scrollable tabs of sequential content: Chapter 1, Chapter 2, Chapter 3 and Chapter 4.]*
> Don’t use tabs to move through sequential content that needs to be read in a particular order. Instead, create hierarchy within the content using techniques like typography style and open space.

## Anatomy

*[Image: Six components of tabs.]*

1. Container
2. Icon (optional)
3. Badge (optional)
4. Label
5. Divider
6. Active indicator

### Container

The container holds multiple tabs. Its contents can be fixed or scrollable.  
  
The container should always extend the full width of the window and be divided into equal sections, one for each tab.  
  
The container is defined by a divider on the bottom edge to separate it from the content below. Content may scroll under the container.

*[Image: Mobile screen with fixed tabs with a dotted border to illustrate the container area.]*

The container is the area that contains the tabs directly under the title above

### Icon (optional)

Icons communicate the kind of content within a tab. Icons should be simple and recognizable.

*[Image: Mobile screen with tabs that use both icons and labels.]*

Tabs can use a combination of labels and icons

Icons alone aren’t as effective as text labels at communicating complex content.  
  
Use caution when representing tab content with icons alone, as an icon’s meaning may not be clear.

> ✅ **Do** — *[Image: Mobile screen with tabs represented by icons  for “wishlist” and “location”.]*
> Use icons that are globally recognized when using icons alone

> ❌ **Don't** — *[Image: Mobile screen where "purchases” tab has text only and “wishlist” tab has text and icon.]*
> Don’t use tabs with both icons and text labels on only some tabs, but not others

### Label

Text labels should clearly and succinctly describe the content within the tab.  
  
Tab labels appear in a single row. Labels can use a second line if needed, with truncated text. Alternatively, scrollable tabs can allow room for longer titles.

*[Image: Mobile screen with scrollable tabs in a single row.]*

Tab labels should be short and succinct. There should be a clear relationship to the title above.

When using scrollable tabs, the first visible tab should be offset by 52dp from the left side of the device for both web and mobile. The width of each tab is defined by the length of its text label.

Avoid using inconsistent padding on each tab.

> ✅ **Do** — *[Image: Screen with scrollable tabs offset from the leading edge by 52dp.]*
> Offset the first scrollable tab 52dp from the leading edge so it's clear that more content is available

> ❌ **Don't** — *[Image: Screen with scrollable tabs, 2 of which are truncated to “Australian” showing how truncation can confuse users.]*
> Don’t truncate labels unless required, as truncated text can impede comprehension

### Badges (optional)

Badges can be used on primary or secondary tabs to show notifications or updates related to a specific tab. Limit badge content to four characters, including a "+".

Once the user views the relevant content in the tab, the badge value should update or the badge should disappear entirely.

Small and large badges can both be used with tabs. Read the [badge guidance](https://m3.material.io/components/badges/overview) for more details.

*[Image: Mobile screen with tabs that use both icons and labels.]*

Badges are used to highlight notifications related to tab specific content

### Active indicator

To differentiate an active tab from an inactive tab, apply an underline and color change to the active tab’s text and icon.

*[Video: Selecting a tab creates an underline below the  icon and text, both which have changed color to show the tab is active.]*

An underline and color change differentiate an active tab from the inactive ones

## Choosing the tab variant

Primary tabs should be used when just one set of tabs are needed.

Secondary tabs are necessary when a screen requires more than one level of tabs. These tabs use a simpler style of indicator, but their function is identical to primary tabs.

*[Image: Mobile screen with primary tabs near the top of the screen.]*

Tabs can be joined with components like app bars, embedded in a specific UI region, or nested within components like cards and sheets. Tabs control the UI region displayed below them.

## Placement

Tabs are displayed in a single row, with each tab connected to the content it represents. As a set, all tabs are unified by a shared topic.  
  
Secondary tabs should always be placed below primary tabs.

*[Image: Mobile screen with secondary tabs below the primary tabs.]*

Secondary tabs are found within other content to assist users with greater detail

## Responsive layout

For fixed tabs, the maximum width for each tab should be determined by the width of the widest tab. The group of tabs should use a fluid margin and align to the center or leading edge of the body region.

Avoid using more than four tabs at once. At five or more tabs, the container becomes cramped.

*[Image: Four fixed tabs spaced to match one another.]*

Tabs can grow in width in relation to the number of items contained within

## Behavior

### States

By default, tabs inherit enabled states with one active state.The inactive and active states of a tab can inherit a hover, focus, and pressed states.

*[Image: Four states of a tab.]*

Active, hover, focused, and pressed states

### Fixed tabs

Fixed tabs display all tabs in a set simultaneously. They are best for switching between related content quickly, such as between transportation methods in a map. To navigate between fixed tabs, tap an individual tab, or swipe left or right in the content area.

*[Video: Mobile screen with fixed tabs, text only.]*

Fixed tabs allow users to see all possible kinds of content available

#### Tap a tab

Navigate to a tab by tapping on it.

*[Video: Tapping a tab selects it.]*

Tapping on a tab directly

#### Swipe within the content area

To navigate between tabs, users can swipe left or right within the content area.

*[Video: Swiping left or right on the content area moves the focus between fixed tabs.]*

Users can swipe between fixed tabs to see related content quickly

Use caution when placing other swipeable content (such as interactive maps or list items) in the content area.

> ✅ **Do** — *[Video: Scrolling up and down through content, then swiping left through tabs.]*
> Use different gesture directions when using tabs

> ❌ **Don't** — *[Video: Swiping to change tabs accidentally swipes to delete a list item in the UI instead.]*
> Avoid placing swipeable items in the content area of a UI that has tabs, as the user may mistakenly swipe the wrong component

### Scrollable tabs

When a set of tabs cannot fit on screen, use scrollable tabs. Scrollable tabs can use longer text labels and a larger number of tabs. They are best used for browsing on touch interfaces.

*[Video: Scrolling left and right on scrollable tabs.]*

Padding should remain the same when using scrolllable tabs and long labels

### Scrolling content

When a screen scrolls up and down through content, tabs can either be fixed to the top of the screen, or scroll off the screen. If they scroll off the screen, they will return when the user scrolls upward.

*[Video: Scrolling through content with fixed tabs  at top of the screen.]*

Tabs can be use to create elevation

> ✅ **Do** — *[Video: When scrolling up through content, tabs scroll off screen, then reappear when scrolling back down.]*
> Tabs can scroll offscreen on scroll, and reappear when the page is scrolled up

> ❌ **Don't** — *[Video: When scrolling up through content, tabs scroll behind the app bar then reappear when scrolling back down.]*
> Don’t scroll tabs behind an app bar. When tabs are attached to a component, they should appear and move as a single unit.
