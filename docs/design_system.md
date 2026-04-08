# Design System & Aesthetics

KukuFiti Mobile is built with a "premium first" design philosophy, focusing on rich aesthetics, high-quality typography, and smooth micro-animations to provide a professional farming management experience.

## Theme Architecture

The app uses `AppTheme` (located in `lib/core/theme/app_theme.dart`) to manage both Light and Dark modes.

### 1. Color Palette

The color scheme is centered around a "Growth Green" primary color, balanced with a sophisticated slate/navy foundation for dark mode and clean whites for light mode.

| Category | Light Mode | Dark Mode | Usage |
|----------|------------|-----------|-------|
| **Primary** | `#22C55E` | `#22C55E` | Actions, branding, success indicators |
| **Surface** | `#FFFFFF` | `#1E293B` | Card backgrounds, sheet surfaces |
| **Background** | `#FBFDFA` | `#0F172A` | Global scaffold background |
| **Secondary** | `#ECFDF5` | `#334155` | Subtle highlights, inactive states |
| **Tertiary** | `#F59E0B` | `#FBBF24` | Warnings, intermediate metrics |
| **Error** | `#EF4444` | `#F87171` | Fatal alerts, negative trends |

### 2. Custom Colors Extension

We use a `ThemeExtension` called `CustomColors` to provide semantic colors that strictly follow the design system:
- `success`: `#22C55E` (Green)
- `warning`: `#F59E0B` (Amber)
- `info`: `#3B82F6` (Blue)
- `neutral`: `#64748B` (Slate)
- `purple`: `#8B5CF6` (Violet)
- `indigo`: `#6366F1` (Indigo)
- `teal`: `#14B8A6` (Teal)

Usage in code:
```dart
final customColors = Theme.of(context).extension<CustomColors>()!;
final indicatorColor = customColors.success;
```

### 3. Typography

- **Font Family**: [Outfit](https://fonts.google.com/specimen/Outfit) via the `google_fonts` package.
- **Rationale**: Chosen for its geometric clarity and modern readability, which feels "cleaner" than standard system fonts.
- **Hierarchy**: Headlines use bold weights for contrast, while body text uses regular/medium for clarity in dense data views (like mortality logs).

### 4. Components

#### Navigation Bar
The `NavigationBarTheme` is customized to be "sticky" and premium:
- **Indicator**: A subtle primary-tinted pill behind the active icon.
- **Elevation**: Shadow-based depth for clear separation from content.
- **Icons**: Size-shifting (24px to 26px) on selection for a tactile feel.

#### Cards & Surfaces
- Surfaces use an `outline` color (`#E2E8F0` or `#334155`) for subtle border definition instead of heavy shadows.
- Corner Radii: Typically `12px` to `16px` for a modern, rounded aesthetic.

## Animations

KukuFiti utilizes the `flutter_animate` package to add subtle micro-interactions:
- **Fade-in/Slide-up**: Applied to dashboard tiles on initial load.
- **Pulse**: Used on critical alerts or pending M-Pesa requests.
- **Scale**: Applied to tapping interactive cards for immediate haptic-like visual feedback.

Example usage:
```dart
Animate(
  effects: [FadeEffect(), SlideEffect(begin: Offset(0, 0.1))],
  child: DashboardCard(...),
)
```

## Responsive Strategy

The app avoids hardcoded pixel values for layout. It leverages:
- **LayoutBuilder**: For adapting UI density based on screen size (e.g. tablet vs phone).
- **Flexible/Expanded**: To ensure data tables and charts fill the available space without overflow.
- **AspectRatio**: To ensure charts (`fl_chart`) maintain their proportionality across varied device dimensions.
