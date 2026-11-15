Source: https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
Fetched: 2026-11-15
Page last updated (per site data): 2026-07-17T05:03:58.337Z

# Easing and duration — Tokens & specs

Easing and duration create responsive and expressive motion

star

Note:

In the expressive update, components and motion now use the [motion physics system](https://m3.material.io/styles/motion/overview), which uses springs. Products should migrate to the new system. The easing and duration system is still used for transitions and can be used by teams that haven't yet updated to GM3 Expressive, but is no longer maintained.

## Tokens

Motion easing and duration can be implemented using easing and duration tokens. [Learn more about design tokens](https://m3.material.io/foundations/design-tokens/overview)

#### Token set: Motion (`md.sys.motion`)

For all motion. Includes spring tokens (physics system), and legacy easing and duration tokens.

**Easing**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.motion.easing.emphasized` | Emphasized |  | "M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1" |
| `md.sys.motion.easing.emphasized.accelerate` | Emphasized accelerate |  | {"x0":0.3,"x1":0.8,"y1":0.15} |
| `md.sys.motion.easing.emphasized.decelerate` | Emphasized decelerate |  | {"x0":0.05,"y0":0.7,"x1":0.1,"y1":1} |
| `md.sys.motion.easing.standard` | Standard |  | {"x0":0.2,"y1":1} |
| `md.sys.motion.easing.standard.accelerate` | Standard accelerate |  | {"x0":0.3,"x1":1,"y1":1} |
| `md.sys.motion.easing.standard.decelerate` | Standard decelerate |  | {"y1":1} |
| `md.sys.motion.easing.legacy` | Legacy |  | {"x0":0.4,"x1":0.2,"y1":1} |
| `md.sys.motion.easing.legacy.accelerate` | Legacy accelerate |  | {"x0":0.4,"x1":1,"y1":1} |
| `md.sys.motion.easing.legacy.decelerate` | Legacy decelerate |  | {"x1":0.2,"y1":1} |
| `md.sys.motion.easing.linear` | Linear |  | {"x1":1,"y1":1} |

**Duration**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.motion.duration.short1` | Short 1 |  | 50 |
| `md.sys.motion.duration.short2` | Short 2 |  | 100 |
| `md.sys.motion.duration.short3` | Short 3 |  | 150 |
| `md.sys.motion.duration.short4` | Short 4 |  | 200 |
| `md.sys.motion.duration.medium1` | Medium 1 |  | 250 |
| `md.sys.motion.duration.medium2` | Medium 2 |  | 300 |
| `md.sys.motion.duration.medium3` | Medium 3 |  | 350 |
| `md.sys.motion.duration.medium4` | Medium 4 |  | 400 |
| `md.sys.motion.duration.long1` | Long 1 |  | 450 |
| `md.sys.motion.duration.long2` | Long 2 |  | 500 |
| `md.sys.motion.duration.long3` | Long 3 |  | 550 |
| `md.sys.motion.duration.long4` | Long 4 |  | 600 |
| `md.sys.motion.duration.extra-long1` | Extra long 1 |  | 700 |
| `md.sys.motion.duration.extra-long2` | Extra long 2 |  | 800 |
| `md.sys.motion.duration.extra-long3` | Extra long 3 |  | 900 |
| `md.sys.motion.duration.extra-long4` | Extra long 4 |  | 1000 |

**Style**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.motion.path` | Motion path |  | {"standardPath":"LINEAR"} |

**Other**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.motion.spring.fast.spatial` | Motion spring fast spatial | md.sys.motion.spring.fast.spatial.damping |  |
| `md.sys.motion.spring.fast.effects` | Motion spring fast effects  | md.sys.motion.spring.fast.effects.damping |  |
| `md.sys.motion.spring.default.spatial` | Motion spring default spatial | md.sys.motion.spring.default.spatial.damping |  |
| `md.sys.motion.spring.default.effects` | Motion spring default effects  | md.sys.motion.spring.default.effects.damping |  |
| `md.sys.motion.spring.slow.spatial` | Motion spring slow spatial | md.sys.motion.spring.slow.spatial.damping |  |
| `md.sys.motion.spring.slow.effects` | Motion spring slow effects  | md.sys.motion.spring.slow.effects.damping |  |

**Spring**

| Token | Name | References | Value |
|---|---|---|---|
| `md.sys.motion.spring.fast.spatial.damping` | Motion spring fast spatial damping |  | expressive: 0.6<br>standard: 0.9 |
| `md.sys.motion.spring.fast.spatial.stiffness` | Motion spring fast spatial stiffness |  | expressive: 800<br>standard: 1400 |
| `md.sys.motion.spring.fast.effects.damping` | Motion spring fast effects damping |  | 1 |
| `md.sys.motion.spring.fast.effects.stiffness` | Motion spring fast effects stiffness |  | 3800 |
| `md.sys.motion.spring.default.spatial.damping` | Motion spring default spatial damping |  | expressive: 0.8<br>standard: 0.9 |
| `md.sys.motion.spring.default.spatial.stiffness` | Motion spring default spatial stiffness |  | expressive: 380<br>standard: 700 |
| `md.sys.motion.spring.default.effects.damping` | Motion spring default effects damping |  | 1 |
| `md.sys.motion.spring.default.effects.stiffness` | Motion spring default effects stiffness |  | 1600 |
| `md.sys.motion.spring.slow.spatial.damping` | Motion spring slow spatial damping |  | expressive: 0.8<br>standard: 0.9 |
| `md.sys.motion.spring.slow.spatial.stiffness` | Motion spring slow spatial stiffness |  | expressive: 200<br>standard: 300 |
| `md.sys.motion.spring.slow.effects.damping` | Motion spring slow effects damping |  | 1 |
| `md.sys.motion.spring.slow.effects.stiffness` | Motion spring slow effects stiffness |  | 800 |

## Easing

### Emphasized easing set

This set is the most common because it captures the expressive style of M3.

*[Video: A line graph illustrating an emphasized easing pattern.]*

Emphasized

*[Video: A line graph illustrating an emphasized decelerate easing pattern.]*

Emphasized decelerate

*[Video: A line graph illustrating an emphasized accelerate easing pattern.]*

Emphasized accelerate

| Info/Platform | Emphasized | Emphasized decelerate | Emphasized accelerate |
| --- | --- | --- | --- |
| Token | md.sys.motion.easing.emphasized | md.sys.motion.easing.emphasized.decelerate | md.sys.motion.easing.emphasized.accelerate |
| Android | [pathInterpolator(M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.05f, 0.7f, 0.1f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.3f, 0f, 0.8f, 0.15f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) |
| CSS | N/A (Use Standard as a fallback) | [cubic-bezier(0.05, 0.7, 0.1, 1.0)](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0.3, 0.0, 0.8, 0.15)](https://www.w3schools.com/cssref/func_cubic-bezier.asp) |
| Flutter | [easeInOutCubicEmphasized](https://api.flutter.dev/flutter/animation/Curves/easeInOutCubicEmphasized-constant.html) | [Cubic(0.05, 0.7, 0.1, 1.0);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0.3, 0.0, 0.8, 0.15);](https://api.flutter.dev/flutter/animation/Cubic-class.html) |
| iOS | N/A (Use Standard as a fallback) | [ControlPoints:0.05f:0.7f:0.1f:1.0f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.3f:0.0f:0.8f:0.15f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) |
| After Effects | Use [After Effects Easing Panel](https://storage.googleapis.com/material-io-static/resources/material-easing-1.1.3.zxp) (download) | | |

### Standard easing set

This set is used for simple, small, or utility-focused transitions.

*[Video: A line graph illustrating a standard easing pattern.]*

Standard

*[Video: A line graph illustrating a standard decelerate easing pattern.]*

Standard decelerate

*[Video: A line graph illustrating a standard accelerate easing pattern.]*

Standard accelerate

|  | Standard | Standard decelerate | Standard accelerate |
| --- | --- | --- | --- |
| Token | md.sys.motion.easing.standard | md.sys.motion.easing.standard.decelerate | md.sys.motion.easing.standard.accelerate |
| Android | [PathInterpolator(0.2f, 0f, 0f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0f, 0f, 0f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) | [PathInterpolator(0.3f, 0f, 1f, 1f)](https://developer.android.com/reference/android/view/animation/PathInterpolator) |
| CSS | [cubic-bezier(0.2, 0.0, 0, 1.0);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0, 0, 0, 1);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) | [cubic-bezier(0.3, 0, 1, 1);](https://www.w3schools.com/cssref/func_cubic-bezier.asp) |
| Flutter | [Cubic(0.2, 0.0, 0, 1.0);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0, 0, 0, 1);](https://api.flutter.dev/flutter/animation/Cubic-class.html) | [Cubic(0.3, 0, 1, 1);](https://api.flutter.dev/flutter/animation/Cubic-class.html) |
| iOS | [ControlPoints:0.2f:0.0f:0.0f:1.0f](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.0f:0.0f:0.0f:1.0f](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) | [ControlPoints:0.3f:0.0f:1.0f:1.0f];](https://developer.apple.com/documentation/quartzcore/camediatimingfunction) |
| After Effects | Use [After Effects Easing Panel](https://storage.googleapis.com/material-io-static/resources/material-easing-1.1.3.zxp) (download) | | |

## Duration

### Short durations

These are used for small utility-focused transitions.

|  |  |
| --- | --- |
| **Token** | **Value** |
| md.sys.motion.duration.short1 | 50ms |
| md.sys.motion.duration.short2 | 100ms |
| md.sys.motion.duration.short3 | 150ms |
| md.sys.motion.duration.short4 | 200ms |

*[Video: Animation showing a 200ms duration and standard easing curve applied to selection control interactions.]*

Selection controls have a short duration of 200ms with Standard easing

### Medium durations

These are used for transitions that traverse a medium area of the screen.

|  |  |
| --- | --- |
| **Token** | **Value** |
| md.sys.motion.duration.medium1 | 250ms |
| md.sys.motion.duration.medium2 | 300ms |
| md.sys.motion.duration.medium3 | 350ms |
| md.sys.motion.duration.medium4 | 400ms |

*[Video: Animation showing a FAB expanding into a sheet with a 400ms duration and Emphasized easing.]*

A FAB expanding into a Sheet uses a 400ms duration with Emphasized easing

### Long durations

These durations are often paired with Emphasized easing. They're used for large expressive transitions.

|  |  |
| --- | --- |
| **Token** | **Value** |
| md.sys.motion.duration.long1 | 450ms |
| md.sys.motion.duration.long2 | 500ms |
| md.sys.motion.duration.long3 | 550ms |
| md.sys.motion.duration.long4 | 600ms |

*[Video: Animation showing a card expanding into a full screen with a 500ms duration and emphasized easing.]*

A Card expanding to full screen uses a long 500ms duration with Emphasized easing

### Extra long durations

Though rare, some transitions use durations above 600ms. These are usually used for ambient transitions that don't involve user input.

|  |  |
| --- | --- |
| **Token** | **Value** |
| md.sys.motion.duration.extra-long1 | 700ms |
| md.sys.motion.duration.extra-long2 | 800ms |
| md.sys.motion.duration.extra-long3 | 900ms |
| md.sys.motion.duration.extra-long4 | 1000ms |

*[Video: Animation showing the transition of an ambient carousel auto-advancing with a 1000ms duration and emphasized easing.]*

An ambient carousel auto-advance transition uses an extra long 1000ms duration with emphasized easing
