# Average Speed Chart Y-Axis Range Fix

## Date
October 17, 2025

## Issue Reported
**User Feedback:** "the line graph why spacing out the bottom of the chart and not extend the top of chart to see the line graph properly"

**Problem:**
- Line chart (Average Speed) had Y-axis from 15 to 35
- Actual data ranged from 22 to 37
- Too much empty space at bottom (15-22 = 7 units of wasted space)
- Data was getting cut off at top (35 < 37)
- Lines were being clipped at maximum values

**Visual Issue:**
- Bottom 7 units (15-22) were completely empty
- Top values (35-37) were cut off
- Chart looked unbalanced and unprofessional
- Dots and lines at top were not fully visible

## Solution

### Updated Y-Axis Range
```dart
// Before
minY: 15,  // Too low - created empty space
maxY: 35,  // Too low - clipped top data

// After
minY: 20,  // Better minimum - only 2 units padding
maxY: 38,  // Better maximum - 1 unit padding at top
```

### Data Range Analysis
The speed data is generated with formula:
```dart
y = (i * 1.0 + (entry.key + 1) * 2 + 20)
```

**Calculated ranges for 4 vehicles (entry.key 0-3) over 10 days (i 0-9):**
- Minimum value: i=0, entry.key=0 → 0 + 2 + 20 = **22 km/h**
- Maximum value: i=9, entry.key=3 → 9 + 8 + 20 = **37 km/h**

### New Range Benefits
- **minY: 20** 
  - Only 2 units below minimum data (22)
  - Provides slight padding without wasting space
  - Shows "20" and "25" labels clearly

- **maxY: 38**
  - 1 unit above maximum data (37)
  - Ensures top dots/lines fully visible
  - Allows room for the top of the dots with stroke

### Grid Line Intervals
With interval of 5, labels show at:
- 20 km/h (bottom)
- 25 km/h
- 30 km/h
- 35 km/h (top)

This gives 4 evenly spaced grid lines covering the data range perfectly.

## Visual Improvements

### Before:
- ❌ Empty space from 15-22 (7 units wasted)
- ❌ Data clipped at 35-37 (top 2 units cut off)
- ❌ Unbalanced chart appearance
- ❌ Lines/dots at top not fully visible
- ❌ Y-axis label "15" showing with no data near it

### After:
- ✅ Minimal empty space (only 2 units at bottom for padding)
- ✅ All data fully visible (20-38 range)
- ✅ Balanced, professional appearance
- ✅ All lines and dots completely visible
- ✅ Y-axis labels (20, 25, 30, 35) all relevant to data
- ✅ Better utilization of chart area
- ✅ More accurate visual representation

## Technical Details

### Padding Strategy
- **Bottom padding**: 2 units (22 - 20 = 2)
  - Prevents data from touching bottom edge
  - Minimal wasted space
  
- **Top padding**: 1 unit (38 - 37 = 1)
  - Accounts for dot radius + stroke
  - Ensures nothing is clipped

### Chart Area Utilization
- **Before**: (35 - 15) = 20 unit range for 15 units of data = 75% efficiency
- **After**: (38 - 20) = 18 unit range for 15 units of data = 83% efficiency
- **Improvement**: 8% better space utilization

### Comparison with Dot Chart
The Dot Chart (Daily Trips) uses:
```dart
minY: 0   // Natural minimum for count data
maxY: 20  // Provides headroom for all values
```
This works because trip counts naturally start at 0.

Speed data doesn't naturally include 0, so we optimize the range to fit the actual data.

## User Experience Impact

1. **Visual clarity**: Data uses full chart height
2. **Better readability**: No distracting empty space
3. **Professional look**: Proper data-to-space ratio
4. **Complete visibility**: All data points fully shown
5. **Accurate perception**: Chart height represents actual data range

## Testing Verification

Check that:
- ✅ Bottom line (V-001 at ~22 km/h) is fully visible
- ✅ Top line (V-004 at ~37 km/h) is fully visible
- ✅ All dots show with complete circles (not clipped)
- ✅ No large empty areas at bottom
- ✅ Grid lines are evenly spaced
- ✅ Y-axis labels are meaningful (20, 25, 30, 35)

## Related Files
- `lib/pages/dashboard_page.dart`: Updated `_buildLineChart()` method
- `Fixed/CHART_SIZE_AND_TOAST_FIX.md`: Main chart improvements doc
- `Fixed/TOAST_AND_CHART_VISIBILITY_FIX.md`: Overall visibility fixes

## Future Considerations

For dynamic data, consider calculating min/max from actual data:
```dart
final allValues = [for (var vehicle in vehicles) ...generateDataForVehicle(vehicle)];
final minValue = allValues.reduce(min);
final maxValue = allValues.reduce(max);
minY: minValue - padding,
maxY: maxValue + padding,
```

For now, static values work well with mock data.
