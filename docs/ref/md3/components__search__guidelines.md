Source: https://m3.material.io/components/search/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-27T04:04:05.736Z

# Search — Guidelines

*[Video: A mobile UI search with hinted text “Search recipes”, “Mexican dishes” is entered, and a list of recipe results appear.]*

When focused, a search bar can show a list of search suggestions. As text is entered, search results appear.

## Usage

Search helps people find information quickly.  
  
Use search for products with many items to manage, such as files or messages.

*[Image: Mobile UI shows a search bar at the top of a message inbox.]*

Search helps people find information in large inboxes like messages or emails

### Different ways to search

The search entry point is dependent on a product’s needs, and should be easy to find:

- Search bar: Use to search contents in a specific view, like **Search your messages**
- Search app bar: Use this app bar variant when search is the primary, global function
- Search icon button: Use when search is a secondary action or not the main focus

*[Image: A mobile app with a search bar below the page title.]*

Add a **search bar** below a title to search specific content

*[Image: A mobile app with a search app bar.]*

For global search, use a persistent **search app bar**, integrated into an app bar

*[Image: A mobile app with a magnifying glass icon on the leading side of the app bar.]*

Use a **search** **icon button** when search is a secondary action

### Focused search

When a search entry point is selected, it opens focused search.

- Search suggestions can appear before text is entered
- Search results can show as someone is typing or after a search is executed
- Individual elements maintain their own interaction states when search is focused

[More on search states](https://m3.material.io/components/search/specs#65c58b10-4569-43d6-9c11-64a5b02f3099)

*[Image: Focused search with a list of suggestions on a mobile screen.]*

When focused, a search bar expands to show search suggestions or results in a list

If search is the primary action, focused search can be a standalone destination reached from a navigation bar.

*[Image: Focused search on a mobile screen with a list of suggested contacts.]*

Focused search can be a standalone destination, reached by selecting an item in a navigation bar

### Search suggestions & results

Search suggestions and results both appear in a list component by default.  
  
To help people find information quickly, consider adding variety and context, such as:

- Leading icons related to suggestions
- Category labels, like **Recent**, **Contacts**, or **Suggestions**
- Avatars or other high-priority items
- Filter chips to narrow down results

*[Image: Search with suggestions organized in a column, ending with a row of 5 contact avatars with names.]*

Include high-priority items like avatars in search suggestions or results

### Gaps

Use gaps to separate a list of suggestions or results into groups.  
  
[More on using gaps in lists](https://m3.material.io/components/lists/guidelines#9e96fd72-5bf3-49df-9baf-e025dcca344d)

*[Image: A gap separates the location and calendar list items from people and pets avatars.]*

To separate list items into distinct groups, use a gap

## Placement

A search bar is typically placed at the top of a screen to remain prominent and accessible. Its location depends on whether search is the primary focus of a product or a secondary action.

*[Image: Mobile UI with a search bar directly below a Settings headline.]*

A search bar can be the primary focus of a page

*[Image: Mobile UI with a search bar centered at the top of the screen, above a row of Favorites avatars.]*

Search bars should usually be placed at the top of the content

*[Image: A photos app with a search icon.]*

Search can be a secondary action

### Focused search layouts

When focused, search suggestions and results appear in a list below the search bar.    
  
There are two layout options:

- **Docked** opens a list below the search bar, with a scrim covering main content
- **Full-screen** expands to fill the screen

[More on adaptive design](https://m3.material.io/components/search/guidelines#eb45ccc4-d1b5-4ea1-bee5-ea1c3d1c5436)

*[Image: Tablet UI shows a list of search results docked below the search bar.]*

Docked layout on a tablet

*[Image: Mobile UI shows a list of search results filling the screen.]*

Full-screen layout on mobile

## Anatomy

*[Image: 6 elements of search.]*

1. Search bar container
2. Leading icon
3. Supporting text
4. Avatar or trailing icon (optional)
5. Input text
6. Container for search suggestions or results

### Search bar container

In the contained style, the search bar container remains the same shape in both the unfocused and focused states. Avoid changing the container behavior.   
  
The container’s margins should be:

- Unfocused: 24dp
- Focused: 12dp

In the divided (baseline) style, a divider separates the search bar and results.

*[Image: Side-by-side comparison of a search container in unfocused and focused states.]*

Search bar containers have persistent, rounded corners

#### Container color

Search bars use the **surface container high** color role. This role applies when the screen background is white or a tonal **surface** color, ensuring the container has clear contrast.

*[Image: 2 mobile UIs show search bars on white and tonal backgrounds.]*

Search bars use **surface container high** to provide clear contrast

Avoid using a **surface container high** color on a **surface container** background. This can cause the search bar to blend in, making it difficult for people to find.  
  
To ensure proper contrast, use surface container roles that are more than one step apart.

> ⚠️ **Caution** — *[Image: A “surface container high” search bar on a “surface container” background.]*
> Using a **surface container high** color on a **surface container** background reduces contrast and may affect accessibility

### Icons & icon buttons

#### Leading icons

The leading side of a search bar should include either:

- A navigational icon button, such as a menu or arrow
- A non-functional search icon

*[Image: A search bar on a tablet screen contains a non-functional search icon and a trailing avatar.]*

A search bar can contain a non-functional search icon

#### Trailing icons

A search bar should have one or two trailing icons or icon buttons.  
  
Trailing actions can include:

- Additional modes of searching like voice search
- A separate high-level action such as current location or profile
- An overflow menu
- A decorative search icon

*[Image: A search bar with 2 trailing icon buttons: a microphone and an overflow menu.]*

Use a maximum of two trailing icons

*[Image: A search bar with a trailing microphone icon and avatar.]*

Combine an avatar with up to one other trailing icon button

*[Image: Focused search with a trailing x icon to clear input text.]*

Focused search can show an optional **clear** icon to remove input text

### Text

#### Hinted search text

Provide a short description of the information people can search, like **Search replies** or **Search your messages**.

#### Input text

When a person starts typing, the hinted text is replaced with the input text.

*[Video: A search bar labeled “Search replies”. “Peanut is entered and “Quick results” appear.]*

Hinted search text is replaced when a search query is entered

## Adaptive design

The search bar position and alignment should scale with the layout, and stay close to the searchable content.  
  
In most cases, a search bar should:

- Stay in its pane and scale in width accordingly
- Internal elements anchor to the left and right as the parent container scales

[More on applying layout](https://m3.material.io/foundations/layout/layout-overview)

*[Video: A search bar keeps its layout region and scales with different window sizes and layouts.]*

Keep the search bar close to the content a person can search

### Focused search

When focused, search can switch between showing suggestions or results in a:

- **Docked layout**: Best for medium and expanded windows
- **Full-screen layout**: Default for compact breakpoints

[More on search layouts](https://m3.material.io/components/search/specs#fc12e839-f356-4f48-9bd5-0ed210565bfe)

*[Image: Search suggestions in docked and full screen layouts.]*

1. A docked layout on a large screen
2. A full-screen layout, the default for compact screens

Search suggestions or results should swap from full-screen in compact windows to docked in larger breakpoints.

*[Video: Animation shows search suggestions adapting from full-screen on mobile to a docked layout as the window size increases.]*

Search suggestions and results should adapt to fit different window sizes

## Behavior

### Focused search

When a search bar is selected, search becomes focused and can:

- Show historical suggestions before typing
- Show suggestions or results as someone is typing
- Wait to show suggestions or results until a search is queried

The **back** icon releases focus, dismisses any suggestions or results, and returns the search bar to its original state.

*[Video: When a search bar is tapped, it becomes focused, and suggestions appear in a list.]*

When focused, a list of search suggestions can appear

*[Video: A person searches a photo app. The back icon returns the search bar to its original state.]*

Focus is released when the back icon is selected

### Scroll

Depending on needs, a search bar can:

- Scroll away with content, then reappear when a person begins scrolling up
- Remain fixed at the top of the screen

*[Video: Scrolling up hides the search bar. It reappears when scrolling down.]*

A search bar can scroll up with content, then reappear when a person scrolls down

### Search results

To execute a search, a person can:

- Type a query and press **Enter**
- Select a suggestion or result without querying a search

Search results appear in a list below the bar, and scroll beneath the bar.     
  
For accessibility, focused search needs a clear status indicator that it’s searching content, like a search icon or **Results** label. [More on search accessibility](https://m3.material.io/components/search/accessibility/)

*[Image: “Peanut” is the entered search query and the first suggestion in the list.]*

Show search results in a compact, organized list, with an indicator like **Quick results**

When search results are queried, the input text should remain visible, but not in focus.

*[Video: “Pla” is entered into the search bar, “Plants” is suggested and selected.]*

Search suggestions and results display in a list, and the input text remains visible

### Predictive back

On Android, [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows a person to swipe left or right on search.

- Search detaches from the screen edge to signal the full-screen layout will minimize
- The previous screen is revealed in a preview

[More predictive back design guidance](https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture)

*[Video: Swiping left on search causes the Android screen to scale left.]*

The search surface and content scale back in the direction of the gesture
