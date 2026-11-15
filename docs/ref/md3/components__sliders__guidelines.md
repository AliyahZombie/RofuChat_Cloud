Source: https://m3.material.io/components/sliders/guidelines
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T07:13:18.037Z

# Sliders — Guidelines

*[Video: Photo editor with sliders labeled pop, sharpen, and denoise being adjusted.]*

Sliders can adjust values in real time, such as image attributes

## Usage

Sliders are used to select values along a track. They’re ideal for adjusting settings such as volume and brightness, or changing the intensity of image filters.  
  
Sliders can use icons or labels to represent a numeric or relative scale.

*[Image: Sound settings screen with continuous sliders labeled call volume and alarm volume.]*

Use sliders to pick a value from a range, like volume loudness

Changes made with sliders must take effect immediately, so people can understand the effects of their selection as they're moving the slider.

*[Video: The brightness slider changes the screen’s brightness in real time.]*

Selection changes are immediate

There are three different variants of sliders: **standard**, **centered**, and **range:**  
  
Standard sliders select one value from a range of values. Use this when the slider should start from zero or the beginning of a sequence.

*[Image: Horizontal standard slider with an end stop indicator.]*

Horizontal standard slider

*[Image: Vertical standard slider  with an end stop indicator.]*

Vertical standard slider

Centered sliders select a value from a positive and negative value range. Use this when zero, or the default value, is in the middle of the range.

*[Image: Horizontal centered slider with a negative value and visible stop indicators at each end.]*

Horizontal centered slider

*[Image: Vertical centered slider with a negative value and visible stop indicators at each end.]*

Vertical centered slider

Range sliders select two values on one slider to create a range. Use this when defining a minimum and maximum value.  
  
Avoid using range sliders vertically, as this can add too much cognitive load. People are used to most sliders being horizontal.

> ✅ **Do** — *[Image: Horizontal range selection slider with 2 values selected, and a stop indicator at each end.]*
> Horizontal range slider

> ❌ **Don't** — *[Image: Vertical range slider with 2 values selected, and a stop indicator at each end.]*
> Because of the additional cognitive load of a range slider, avoid using it in vertical orientation.

## Anatomy

*[Image: 6 elements of a slider.]*

1. Value indicator (optional)
2. Stop indicators (optional)
3. Active track
4. Handle
5. Inactive track
6. Inset icon (optional)

### Track

The track shows the full range of values that can be selected on the slider. It has two sections: active and inactive.

- The **active**section of the track is from the minimum value to the handle. For range sliders, the active track is between the two handles.
- The **inactive** section of the track is from the handle to the maximum value, or outside the two handles of a range slider.

For left-to-right (LTR) languages, the values increase from left to right. For right-to-left (RTL) languages, this is reversed.

*[Image: Sliders for font size and display size with stop indicators along the track.]*

The track on a slider shows the available range

### Handle

The handle can be moved along the track to choose a value.  
  
When sliders have two handles, the handles choose the minimum and maximum values in a range.  
  
The handle changes shape to indicate when it’s pressed.

*[Image: The handle is a vertical line on the current value of the slider. It shrinks in width when selected.]*

A handle changes shape when it's being pressed or dragged

*[Image: 2 unselected handles on a slider with range selection.]*

Two handles are used for sliders with range selection

## Configurations

### Value

The value displays the specific value that corresponds with the handle’s placement.   
  
A value appears when interacting with the corresponding handle. For range sliders, only one value should be shown at a time.  
  
If the value is shown elsewhere, the indicator is not required.

*[Image: A value of 50 is above a slider handle in the middle of the track.]*

A value can appear while the handle is being pressed or dragged

*[Image: A value of 75 is above the pressed range slider handle. The unselected slider doesn’t show the value.]*

For range sliders, the value only appears on one handle at a time

Instead of showing the built-in value label, a separate text input field can be added outside of the slider. If this is added, the slider and value in this text field should automatically update to match each other.

Make sure people can tab to the text field directly after the slider.

*[Video: Navigating to an adjacent text label, changing the value to 100 using arrow keys. The slider auto-updates based on input value.]*

Use **Tab** to navigate to values that are shown outside the slider, like a text input field

### Stop indicators

Stop indicators show which predetermined values can be chosen on the slider. The slider handle snaps to the closest stop.   
  
Avoid having too many stop indicators on a slider, because it can become visually crowded and difficult to adjust the value.  
  
All sliders have stops at the end of the inactive track to ensure at least a 3:1 contrast with the background. If the inactive track has this level of contrast already, the end stops can be removed.

*[Image: Stop indicators are equally spaced out on a slider.]*

Stop indicators show each available value on a slider

Icons or text can be added outside the slider to indicate the range of values and make the slider more accessible. This can be used instead of a stop indicator.

*[Image: Plus and minus icons on each end of the slider.]*

Plus and minus icons, or text, can be added to the left and right of the slider

### Orientation

Sliders can be oriented either horizontally or vertically, depending on what is best for your use case.

*[Image: Horizontal slider.]*

Standard slider in horizontal orientation

*[Image: Vertical slider. Zero is at the bottom.]*

Standard slider in vertical orientation

### Inset icon

Standard sliders that are M, L, or XL can include an icon within the track. This icon should illustrate what the slider controls. Avoid adding inset icons to XS or S sliders.  
  
When there’s not enough space for the icon on the active track, like at a low value, the icon moves to the inactive track.  
  
Consider swapping which icon is displayed at zero, like a volume icon becoming a mute icon.

> ✅ **Do** — *[Image: Inset icon on the active track when the handle is at 50%, and on the inactive track when the handle is at 0.]*
> Inset icons change placement based on the handle

> ❌ **Don't** — *[Image: An inset icon on an XS slider. The icon bounds are cut off by the slider container.]*
> Don’t use an inset icon with sliders that have track thicknesses under 40dp

Don’t use inset icons on centered or range sliders. It makes it unclear where the start of the slider is.

> ❌ **Don't** — *[Image: Centered slider with an inset icon on one end, and a stop indicator on the other.]*
> Don’t use an inset icon on a centered slider

> ❌ **Don't** — *[Image: Range slider with an inset icon on one end, and a stop indicator on the other.]*
> Don’t use an inset icon on a range slider

### Size

Sliders come in different sizes: XS, S, M, L, and XL. Use larger sizes to increase the targets and provide a larger visual emphasis.  
  
The active and inactive tracks should always be the same size.

*[Image: 5 sizes of sliders.]*

1. XS: 16dp
2. S: 24dp
3. M: 40dp
4. L: 56dp
5. XL: 96dp

XL sliders should be reserved for hero moments, where the slider itself is the most important element on the page.

*[Image: An XL slider used to adjust living room temperature on mobile. No other controls are on screen.]*

XL sliders should be the focus of the page

## Behaviors

### Select & drag

Select a value by dragging the handle.

*[Video: Slider handle moves smoothly. The value increases and decreases by single digits.]*

**Standard slider**: The handle drags smoothly

*[Video: Slider handle snaps to the nearest multiple of 10 when moved.]*

**Slider with stop indicators:** The handle snaps to the closest stop indicator while dragged

### Select jump

Select a value by selecting part of the track.

*[Video: Slider handle moves smoothly to selected value of the slider.]*

**Standard****slider**: The handle moves to the selected location

*[Video: Slider handle moves smoothly to the closest stop indicator value.]*

**Slider with stop indicators:** The handle moves to the closest stop indicator

### Select & arrow

Select a value using the keyboard.  
  
**Tab:** Focus lands on handle   
  
**Arrows:**Selected value increases or decreases by one value or stop indicator  
  
**Space & arrows:** Selected value increases or decreases by a larger interval or stop indicator

*[Video: Tab selects the slider, and arrow keys move the value by 1.]*

**Standard****slider**: The handle moves one value

*[Video: Tab selects the slider, and arrow keys move the value by 10.]*

**Slider with stop indicators:**The handle moves to the next stop indicator
