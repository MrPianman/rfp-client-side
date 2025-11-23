# Legend Scrolling and Contrast Improvements

## Date
October 17, 2025

## Changes Made

### 1. Horizontal Scrollable Legend
- **Replaced Wrap widget with horizontally scrollable SingleChildScrollView**
- Legend chips now scroll sideways when there are many vehicles
- Prevents screen clutter with multiple vehicles
- Fixed height container (42px) for consistent layout
- Smooth horizontal scrolling for better mobile experience

### 2. Minimum Visible Vehicles
- **At least one vehicle chip must remain visible at all times**
- Users cannot hide all vehicles simultaneously
- Prevents empty chart state
- Logic: Only allows hiding if `hiddenCount < totalVehicles - 1`

### 3. Grandma Mode Enhanced Contrast
Legend chips now feature **high-contrast colors** when Grandma Mode is enabled:

#### Dark Mode Grandma:
- Increased lightness to 0.7
- Increased saturation to 0.9
- Brighter, more vibrant colors for better visibility

#### Light Mode Grandma:
- Decreased lightness to 0.35 (darker)
- Increased saturation to 0.95
- Higher contrast against white background

#### Visual Enhancements:
- **Larger avatar dots**: 8px radius (vs 6px normal)
- **Bold text labels** for better readability
- **Colored chip backgrounds**: 15% alpha tint of the vehicle color
- **2px colored border** around each chip
- Better visual separation between chips

### 4. Improved Chip Styling
- `materialTapTargetSize: MaterialTapTargetSize.shrinkWrap` for tighter spacing
- Consistent spacing between chips (12px)
- Better touch targets for mobile interaction

## Implementation Details

### Toggle Function with Minimum Check
```dart
void _toggleVehicleVisibility(int index, int totalVehicles) {
  setState(() {
    if (_hiddenVehicleIndices.contains(index)) {
      _hiddenVehicleIndices.remove(index);
    } else {
      // Only hide if at least one other vehicle is still visible
      if (_hiddenVehicleIndices.length < totalVehicles - 1) {
        _hiddenVehicleIndices.add(index);
      }
    }
  });
}
```

### Scrollable Legend Layout
```dart
SizedBox(
  height: 42,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final entry in vehicles.asMap().entries) ...[
          GestureDetector(...),
          if (entry.key < vehicles.length - 1)
            const SizedBox(width: 12),
        ],
      ],
    ),
  ),
)
```

### Color Enhancement Algorithm
```dart
Color _getEnhancedColor(Color baseColor, bool isDark, bool isGrandmaMode) {
  if (!isGrandmaMode) return baseColor;
  
  final hsl = HSLColor.fromColor(baseColor);
  if (isDark) {
    return hsl.withLightness(0.7).withSaturation(0.9).toColor();
  } else {
    return hsl.withLightness(0.35).withSaturation(0.95).toColor();
  }
}
```

## User Experience Improvements

1. **Better scalability**: Works with any number of vehicles without UI overflow
2. **Accessibility**: High contrast colors in Grandma Mode improve readability
3. **Safety**: Always at least one vehicle visible prevents confusion
4. **Mobile-friendly**: Horizontal scrolling is intuitive on mobile devices
5. **Visual clarity**: Enhanced borders and backgrounds in Grandma Mode
6. **Consistent behavior**: Scrolling preserves all chip functionality

## Technical Notes
- Uses HSL color space for intelligent color adjustments
- Preserves hue while modifying lightness and saturation
- Grandma Mode detection via `ThemeController.instance.grandmaMode.value`
- Brightness detection via `Theme.of(context).brightness`
- Row layout ensures proper spacing between chips
- Fixed height prevents layout shifts during scrolling

## Chart Color Palette Enhancement

### High Contrast Colors
Completely redesigned color palette for better visibility:

#### Grandma Mode - Dark Theme:
```dart
Bright Cyan:   #00E5FF
Bright Pink:   #FF6B9D
Bright Green:  #76FF03
Bright Yellow: #FFD600
Bright Orange: #FF5722
Bright Purple: #9C27B0
Bright Teal:   #00BCD4
Bright Amber:  #FF9100
```

#### Grandma Mode - Light Theme:
```dart
Deep Blue:        #0277BD
Deep Pink:        #C2185B
Deep Green:       #2E7D32
Deep Orange:      #F57C00
Deep Purple:      #6A1B9A
Deep Red-Orange:  #D84315
Deep Teal:        #00838F
Deep Brown:       #4E342E
```

#### Normal Mode Enhancement:
- Container colors in light mode are darkened by 30% lightness for better contrast
- Maintains theme consistency while improving readability

### Fluttertoast Message
When attempting to hide the last visible chip:
- **Package**: `fluttertoast: ^8.2.8`
- **Message**: "At least one chip has to be shown"
- **Styling**: Native toast with grey background (#808080) and white text
- **Duration**: Short (2 seconds for iOS/Web)
- **Position**: Bottom gravity (native Android position)
- **Font Size**: 16px
- **Behavior**: Non-intrusive, auto-dismissible, native platform styling

## Before & After

### Before:
- Wrap layout could overflow with many vehicles
- Could hide all vehicles (empty charts)
- Pastel colors hard to distinguish
- Same colors in normal and Grandma Mode
- Small, uniform chip styling
- No feedback when trying to hide last chip

### After:
- Horizontal scrolling handles unlimited vehicles
- Always at least one vehicle visible with toast feedback
- High-contrast, vibrant colors in Grandma Mode
- Enhanced colors in normal mode too
- Larger, bolder chips with colored borders in Grandma Mode
- Clear user feedback with "At least one chip has to be shown" message
