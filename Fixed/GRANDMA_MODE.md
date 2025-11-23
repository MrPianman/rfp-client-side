# MORE VISIBILITY MODE FOR GRANDMA 👓

## Overview
A toggle feature that switches between normal text/icon sizes and enhanced accessibility mode designed for older users (40-50+ age group).

## Location
**Settings Page** → **Appearance Section** → **"MORE VISIBILITY MODE FOR GRANDMA"** toggle

## What It Does

### When ENABLED (Grandma Mode ON):
- **Text Sizes:**
  - Body text: 16-18px (enhanced for readability)
  - Headings: 26-34px (larger and bolder)
  - Labels: 13-16px (easier to read)
  - Chip labels: 15px (clear labeling)

- **Icons:**
  - Default icon size: 26px (larger and more visible)
  - Better visibility across all pages

- **Buttons:**
  - Minimum height: 48px (easier to tap)
  - Button text: 16px (clear and readable)
  - Larger padding for better touch targets

- **Line Height:**
  - Increased line spacing (1.4-1.5x) for better readability

### When DISABLED (Normal Mode - Simple & Compact):
- **Text Sizes:**
  - Body text: 11-14px (compact and efficient)
  - Headings: 20-28px (clear but space-saving)
  - Labels: 10-13px (minimal space usage)
  - Chip labels: 12px (compact)

- **Icons:**
  - Default icon size: 20px (smaller, more content on screen)
  - Efficient use of space

- **Buttons:**
  - Minimum height: 40px (standard touch targets)
  - Button text: 13px (compact)
  - Reduced padding for more screen real estate

- **Line Height:**
  - Standard spacing (1.3-1.4x) for efficient layout

- **Overall:**
  - Maximizes content density
  - Modern, minimalist appearance
  - More information visible at once
  - Ideal for users comfortable with smaller text

### 📊 Size Comparison Table:

| Element | Normal Mode (Compact) | Grandma Mode (Enhanced) | Difference |
|---------|----------------------|-------------------------|------------|
| Body Text | 11-14px | 16-18px | +30-40% |
| Headings | 20-28px | 26-34px | +30% |
| Labels | 10-13px | 13-16px | +30% |
| Icons | 20px | 26px | +30% |
| Buttons Height | 40px | 48px | +20% |
| Button Text | 13px | 16px | +23% |
| Chip Labels | 12px | 15px | +25% |
| Chip Padding | 10h/6v px | 12h/8v px | +20% |

**Key Insight:** Grandma Mode increases text and icon sizes by approximately **30-40%**, making the UI significantly more accessible for older users while keeping normal mode compact and efficient for general users.

## Technical Implementation

### Files Modified:
1. **`lib/theme/theme_controller.dart`**
   - Added `ValueNotifier<bool> grandmaMode`
   - Added `setGrandmaMode(bool)` method

2. **`lib/theme/app_theme.dart`**
   - Created `_normalTextTheme()` for standard sizes
   - Renamed existing to `_enhancedTextTheme()` for grandma mode
   - Updated `light()` and `dark()` to accept `grandmaMode` parameter
   - Theme dynamically adjusts text, icons, buttons based on mode

3. **`lib/main.dart`**
   - Added nested `ValueListenableBuilder` to listen to `grandmaMode` changes
   - Passes `grandmaMode` parameter to both light and dark themes

4. **`lib/pages/settings_page.dart`**
   - Added `SwitchListTile` for "MORE VISIBILITY MODE FOR GRANDMA"
   - Shows visibility icon (filled when enabled, outlined when disabled)
   - Includes descriptive subtitle

## Usage
1. Open the app
2. Navigate to **Settings** tab (bottom navigation)
3. Scroll to **Appearance** section
4. Toggle **"MORE VISIBILITY MODE FOR GRANDMA"** switch
5. The app immediately updates all text and icon sizes across all pages

## Benefits
✅ **Better readability** for users with vision challenges  
✅ **Larger touch targets** for users with reduced dexterity  
✅ **Instant updates** - no app restart required  
✅ **Works in both light and dark modes**  
✅ **Consistent across all pages** - Dashboard, Maps, Reports, Alerts, Settings  

## Testing
- All Flutter analyzer checks pass ✅
- All widget tests pass ✅
- Hot reload works correctly ✅
- Theme persists across page navigation ✅
