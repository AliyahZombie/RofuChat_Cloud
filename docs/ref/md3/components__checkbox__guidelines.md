Source: https://m3.material.io/components/checkbox/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-08-12T09:53:04.800Z

# Checkbox — Guidelines

*[Image: A list of burger additions represented with checkboxes.]*

Checkboxes in a list of items

## Usage

Use checkboxes to:

- Select one or more options from a list
- Present a list containing sub-selections
- Turn an item on or off in a desktop environment
- Visually group similar options together

*[Image: List of 80's songs indicating choice through checkbox selection.]*

Checkboxes select multiple, related options

Checkboxes should be used instead of switches if multiple, related options can be selected from a list. Checkboxes visually group similar items effectively and take up less space than switches.

> ✅ **Do** — *[Image: List indicating choice with checkbox selection.]*
> Checkboxes let users select one or more options from a list. A parent checkbox allows for easy selection or deselection of all items.

> ❌ **Don't** — *[Image: A list with multiple switches selected.]*
> If a list consists of multiple options, don't use switches. Instead, use checkboxes. Checkboxes imply the items are related, and take up less visual space.

### Alternate selection controls

Checkboxes, radio buttons, and switches are the three main selection controls. They all help people make choices, like selecting options or switching settings on or off.

- Use checkboxes to select multiple related options in a list.
- Use radio buttons to select a single option in a list.
- Use switches to select standalone or more verbose options in a list, like settings.

*[Image: Diagram of 2 radio buttons, one selected and one unselected.]*

Radio buttons

*[Image: Diagram of 2 switches, one selected and one unselected.]*

Switches

## Anatomy

*[Image: Diagram of checkbox indicating the 2 parts of its anatomy.]*

1. Container

2. Icon

## Responsive layout

In expanded breakpoints, placing checkboxes within a contained region such as a side sheet can help group related controls and available actions.

*[Image: Desktop screen showing music albums and a side sheet containing checkboxes for filtering music genres.]*

A side sheet can group related controls on larger screens

## Behavior

Multiple checkboxes in a list can be selected.

*[Video: Using checkboxes to select a list of extra ingredients, like pickles and tomatoes, to add to a meal.]*

Selecting multiple items in a list using checkboxes

Checkboxes can have a parent-child relationship with other checkboxes.

- When the parent checkbox is checked, all child checkboxes are checked
- If a parent checkbox is unchecked, all child checkboxes are unchecked
- If some, but not all, child checkboxes are checked, the parent checkbox becomes an indeterminate checkbox. Checking an indeterminate checkbox checks all child items.

*[Video: Checking parent checkbox also checks child items. Unchecking one child item makes parent indeterminate.]*

Use a parent checkbox to make it more efficient to select many items

When selected, a checkbox clearly and instantly communicates its selected state.

If used to turn something on or off, the action should be immediately executed.

*[Video: Selecting a checkbox for turning on dark mode immediately changes the phone theme.]*

Turning an item on or off using a checkbox
