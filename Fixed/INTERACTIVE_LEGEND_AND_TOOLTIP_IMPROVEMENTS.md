# Interactive Legend and Tooltip Improvements

## Date
October 17, 2025

## Changes Made

### 1. Interactive Legend Chips
- **Made legend chips clickable** to toggle vehicle visibility on charts
- Clicking a vehicle legend chip will show/hide that vehicle's data across all charts
- Visual feedback for hidden vehicles:
  - Grey-tinted chip background
  - Grey-tinted color dot
  - Strikethrough text on vehicle label

### 2. Enhanced Chart Tooltips
All charts now have improved tooltips with:
- **Better visibility**: Larger font size (14px), bold text
- **Better positioning**: `fitInsideHorizontally` and `fitInsideVertically` enabled
- **Better styling**: Uses theme surface color for tooltip background
- **More context**: Shows both vehicle ID and value with units

### 3. Improved Dot Visibility
- **Daily Trips Chart (Dot Chart)**:
  - Increased dot radius from 5 to 7 pixels
  - Increased stroke width from 2 to 3 pixels
  - Increased touch area threshold to 20 pixels
  - Better tooltip showing vehicle ID and trip count

- **Average Speed Chart (Line Chart)**:
  - Now shows dots on the lines (previously hidden)
  - 4-pixel radius dots with white borders
  - Improved tooltip with vehicle ID and speed in km/h

### 4. Enhanced Bar Chart Interactions
- **Fuel Consumption Chart**:
  - Added interactive tooltips on hover/tap
  - Shows vehicle ID and fuel consumption in liters
  - Hidden vehicles are filtered from the chart

- **Daily Profit Chart**:
  - Added interactive tooltips on hover/tap
  - Shows vehicle ID and profit with $ symbol
  - Hidden vehicles are filtered from the chart

## Implementation Details

### State Management
```dart
final Set<int> _hiddenVehicleIndices = {};

void _toggleVehicleVisibility(int index) {
  setState(() {
    if (_hiddenVehicleIndices.contains(index)) {
      _hiddenVehicleIndices.remove(index);
    } else {
      _hiddenVehicleIndices.add(index);
    }
  });
}
```

### Legend Chip Component
Updated `_LegendChip` widget to accept `isHidden` parameter and apply visual styling:
- Grey colors when hidden
- Line-through decoration
- Wrapped in `GestureDetector` for tap handling

### Chart Filtering
All chart builders now filter data based on `_hiddenVehicleIndices`:
```dart
for (final entry in vehicles.asMap().entries)
  if (!_hiddenVehicleIndices.contains(entry.key))
    // render chart data
```

## User Experience Improvements
1. **Touch targets**: Increased to 20px for better mobile interaction
2. **Visual feedback**: Clear indication of which vehicles are hidden
3. **Consistent behavior**: Toggle works across all four chart types
4. **Better readability**: Larger, bolder tooltips with proper formatting
5. **Context preservation**: Tooltips show both label and value with appropriate units

## Technical Notes
- Uses Flutter's `Set` for efficient O(1) lookup of hidden vehicles
- Maintains state at page level for consistency across chart swipes
- All charts respect the hidden vehicle indices
- Tooltips are formatted with appropriate units (trips, km/h, L, $)
