Source: https://m3.material.io/components/switch/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:03:01.922Z

# Switch — Guidelines

*[Image: A switch in 2 states, off and on.]*

Switches change settings and other options immediately

## Usage

Switches are best used to adjust settings and other standalone options.

They make a binary selection:

- On and off
- True and false

The effects of a switch should start immediately, without needing to save.

*[Video: Toggling a switch turns on dark mode in Settings on a mobile device.]*

Use a switch to turn an option on and off

Use switches to:

- Toggle a single item on or off
- Immediately activate or deactivate something

*[Image: Switch used in notification settings to turn on and off the "play over notifications" function.]*

Switches are commonly used on mobile to turn settings on or off

Switches control binary options, not opposing ones. A binary option represents a single selection that's either on or off.

Opposing options are when only one option in a set can be selected at a time, like a list or map view. Use a connected button group instead.

> ✅ **Do** — *[Image: A connected button group with options of List View and Map View.]*
> Use a connected button group to choose between opposing options

> ❌ **Don't** — *[Image: A switch with non-binary options of List View and Map View.]*
> Avoid using switches to toggle between opposing options

### Alternate selection controls

Checkboxes, radio buttons, and switches are the three main kinds of selection controls. They help people make choices, like selecting options or turning settings on and off.

Use checkboxes to select multiple related options in a list.

Use radio buttons to select a single option in a list.

Use switches to select standalone or more verbose options in a list, like settings.

*[Image: 2 checkboxes, 1 unchecked and 1 checked.]*

Checkboxes

*[Image: 2 radio buttons, 1 in an enabled state, 1 in a disabled state.]*

Radio buttons

> ✅ **Do** — *[Image: Mobile screen with checkboxes to select list items and call to action button to update the list.]*
> Use checkboxes (not switches) to let people select one or more options from a list

> ❌ **Don't** — *[Image: Mobile screen with checkboxes to select list items and call to action switch to update the list.]*
> A switch can't replace a button. People expect a call to action to be a button, not a switch.

> ✅ **Do** — *[Image: Radio buttons used to select a language for a mobile app.]*
> Use radio buttons (not switches) when only one item can be selected from a list

> ❌ **Don't** — *[Image: Mobile screen with switches to select list items and call to action button to update the list.]*
> Avoid using a switch to select multiple options that require people to save. Switches should be immediate. Use checkboxes instead.

## Anatomy

*[Image: 3 elements of a switch.]*

1. Track
2. Handle
3. Icon (optional)

### Icon (optional)

The switch handle can contain an optional icon.

*[Video: A checkmark appears on the filled circle of a handle when the switch is toggled on.]*

The icon within the handle should always communicate the switch's selection

Icons can be used to visually emphasize the switch’s selection. The icon’s meaning should be clear and unambiguous to help the people understand whether switch is on or off.

> ✅ **Do** — *[Image: 2 switches, the unselected state icon is an X, and the selected state is a checkmark.]*
> Use icons that clearly communicate whether the switch is on or off, such as an X and a checkmark

> ❌ **Don't** — *[Image: A switch’s unselected handle icon is a moon and the selected state icon is a pencil.]*
> Avoid using more ambiguous or non-binary icons, such as a moon or edit icon

### Label text

Switches should always be paired with an inline label describing what the switch controls when selected.

> ✅ **Do** — *[Image: Switch label text: 1. Permission manager, App has access to your data. 2. Camera access, app has access to your camera. 3. Show password.]*
> Keep labels short and direct. A label should describe what the control does when the switch is on.

> ❌ **Don't** — *[Image: On a mobile screen’s privacy settings, 2 switches have “On” label text and checkmark icons. The last switch has “Off” label text and no icon.]*
> Don't add label text into the switch; the font size would be too small to be accessible. Use an appropriate icon instead.

## Placement

Switches are often arranged in stacked layouts.

*[Image: Screen showing labels and stacked switches in varying on/off modes.]*

Settings screens are common places to use switches

## Behavior

A switch is successfully toggled when the handle slides to the other side of the track after an interaction.

*[Video: A switch is toggled to turn on airplane mode and Wi-Fi switch automatically turns off.]*

When selected, the switch handle slides to the opposite end of the track

When a person toggles a switch, its handle size changes and the corresponding action takes effect immediately.

*[Video: When selected the switch’s handle gets larger and a checkmark appears on the filled circle.]*

The **on** state of the switch is indicated by a larger handle size
