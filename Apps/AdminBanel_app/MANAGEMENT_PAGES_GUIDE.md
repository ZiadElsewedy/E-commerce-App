# Management Pages Guide

This document provides a comprehensive overview of all management pages in the Admin Panel and how to use them.

## Overview

The Admin Panel now features fully functional CRUD (Create, Read, Update, Delete) operations for all entities:
- **Products Management**
- **Banners Management**
- **Promos Management**
- **Coupons Management**
- **Categories Management**

All pages are designed to be **responsive** and work seamlessly on:
- 📱 **Mobile devices** (< 600px width)
- 💻 **Tablets** (600px - 900px width)
- 🖥️ **Desktop/Web** (> 900px width)

---

## 🎨 Design Features

### Consistent Color Scheme
Each management page has its own color identity:
- **Products**: 🔵 Blue (`Colors.blue`)
- **Banners**: 🟠 Orange (`Colors.orange`)
- **Promos**: 🟢 Green (`Colors.green`)
- **Coupons**: 🟣 Purple (`Colors.purple`)
- **Categories**: 🔷 Teal (`Colors.teal`)

### Responsive UI Elements
- **Mobile**: Compact layouts, condensed information, essential buttons only
- **Tablet/Desktop**: Extended layouts, additional information badges, full button sets
- **Dialog Width**: Automatically adjusts based on screen size
- **Floating Action Buttons**: Show icon only on mobile, icon + text on larger screens

### Status Badges
All entities display status badges with appropriate colors:
- ✅ **Active/Valid**: Green badge
- 🔴 **Expired/Inactive**: Red badge
- 🟡 **Low Stock**: Orange badge
- ⭐ **Featured**: Amber star icon
- 🔵 **Upcoming**: Blue badge
- 🟠 **Limit Reached**: Orange badge

---

## 📦 Products Management

### Features
- ✅ Create new products with category selection
- ✅ Edit existing products
- ✅ Delete products
- ✅ Toggle product active/inactive status
- ✅ Toggle featured status
- ✅ Filter by: All, Active, Featured, Low Stock
- ✅ View stock levels and category information

### Product Form Fields
- **Name*** (Required)
- **Description*** (Required)
- **Price*** (Required, decimal with 2 places)
- **Stock Quantity*** (Required, integer)
- **Category*** (Required, dropdown selector)
- **Image URL** (Optional)

### Actions
- **Edit**: Modify product details
- **Activate/Deactivate**: Toggle visibility
- **Feature/Unfeature**: Mark as featured product
- **Delete**: Remove product permanently

### Special Features
- Integrated with Category Management System
- Real-time category selection
- Automatic low stock detection (< 10 items)
- Featured products highlighted with star icon

---

## 🖼️ Banners Management

### Features
- ✅ Create promotional banners
- ✅ Edit banner details
- ✅ Delete banners
- ✅ Toggle active/inactive status
- ✅ Set priority (higher numbers show first)
- ✅ Set expiration dates
- ✅ Filter by: All, Active

### Banner Form Fields
- **Title*** (Required)
- **Description*** (Required)
- **Image URL*** (Required)
- **Link URL** (Optional, where banner should navigate)
- **Priority** (Optional, default: 0)
- **Expiration Date** (Optional, date picker)

### Actions
- **Edit**: Update banner information
- **Activate/Deactivate**: Control visibility
- **Delete**: Remove banner

### Special Features
- Automatic expiration detection
- Priority-based ordering
- Date picker for expiration selection
- Clear expiration date option (in edit mode)

---

## 🎯 Promos Management

### Features
- ✅ Create promotional offers
- ✅ Edit promo details
- ✅ Delete promos
- ✅ Toggle active/inactive status
- ✅ Set start and end dates
- ✅ Multiple discount types
- ✅ Filter by: All, Active, Current

### Promo Form Fields
- **Title*** (Required)
- **Description*** (Required)
- **Discount Type*** (Required)
  - Percentage Discount
  - Fixed Amount Discount
  - Buy One Get One (BOGO)
  - Free Shipping
- **Discount Value*** (Required, validated based on type)
- **Priority** (Optional, default: 0)
- **Start Date*** (Required, date picker)
- **End Date*** (Required, date picker)

### Actions
- **Edit**: Modify promo details
- **Activate/Deactivate**: Control availability
- **Delete**: Remove promo

### Special Features
- Automatic status detection (Active, Upcoming, Expired)
- Date range validation (end date must be after start date)
- Smart discount value validation (percentage max 100%)
- Visual status indicators with color coding

---

## 🎟️ Coupons Management

### Features
- ✅ Create discount coupons
- ✅ Edit coupon details
- ✅ Delete coupons
- ✅ Toggle active/inactive status
- ✅ Validate coupons against order amounts
- ✅ Set usage limits
- ✅ Set minimum purchase requirements
- ✅ Filter by: All, Active

### Coupon Form Fields
- **Code*** (Required, auto-uppercase)
- **Description*** (Required)
- **Discount Type*** (Required)
  - Percentage Discount
  - Fixed Amount Discount
- **Discount Value*** (Required, validated based on type)
- **Min Purchase Amount** (Optional)
- **Max Discount Amount** (Optional)
- **Usage Limit** (Optional, unlimited if empty)
- **Expiration Date** (Optional, date picker)

### Actions
- **Edit**: Update coupon information
- **Activate/Deactivate**: Control availability
- **Validate**: Test coupon validity with order amount
- **Delete**: Remove coupon

### Special Features
- Automatic code uppercase conversion
- Usage limit tracking
- Multi-condition validation (active, not expired, usage limit not reached)
- Interactive coupon validation with order amount input
- Visual validity indicators

---

## 📂 Categories Management

### Features
- ✅ Create product categories
- ✅ Edit category details
- ✅ Delete categories (only if no products)
- ✅ Toggle active/inactive status
- ✅ Track product count per category
- ✅ Filter by: All, Active

### Category Form Fields
- **Name*** (Required, checked for duplicates)
- **Description*** (Required)
- **Image URL** (Optional)

### Actions
- **Edit**: Modify category details
- **Activate/Deactivate**: Control visibility
- **Delete**: Remove category (only if no associated products)

### Special Features
- Automatic duplicate name prevention
- Product count tracking
- Protection against deleting categories with products
- Used in Product Management for category selection

---

## 🎯 Common Features Across All Pages

### User Experience
- **Loading States**: Circular progress indicators during data fetch
- **Empty States**: Friendly messages with action buttons when no data
- **Error States**: Clear error messages with retry buttons
- **Success Feedback**: SnackBars for successful operations
- **Confirmation Dialogs**: Safety prompts before deletion

### Form Validation
- ✅ Required field validation
- ✅ Numeric input validation (prices, quantities, percentages)
- ✅ Date validation
- ✅ Format validation (decimals with 2 places)
- ✅ Range validation (e.g., percentage ≤ 100%)

### Responsive Dialogs
- **Mobile**: Full-width dialogs with scroll support
- **Tablet**: 500px fixed width
- **Desktop**: 600px fixed width
- **Auto-scroll**: Long forms automatically scrollable

### Filter Options
All pages include filter sheets with:
- **All Items**: Show everything
- **Active Items**: Show only active entities
- **Special Filters**: Custom filters per entity type

---

## 🔧 Technical Implementation

### Architecture
- **Clean Architecture**: Domain → Data → Presentation layers
- **State Management**: BLoC/Cubit pattern
- **Dependency Injection**: Repository pattern
- **Firebase Integration**: Firestore for data persistence

### Responsive Utilities (from `shared_ui` package)
```dart
// Check device type
AppTheme.isMobile(context)   // < 600px
AppTheme.isTablet(context)   // 600px - 900px
AppTheme.isDesktop(context)  // > 900px

// Get responsive dimensions
AppTheme.getDialogWidth(context)
AppTheme.getResponsivePadding(context)
```

### Form Patterns
All forms use:
- `GlobalKey<FormState>` for validation
- `TextEditingController` for input management
- `StatefulBuilder` for dynamic dialog updates
- `InputFormatters` for input restrictions

---

## 🎨 Color Usage Guidelines

### Status Colors
- **Success/Active**: `Colors.green`
- **Error/Expired**: `Colors.red`
- **Warning/Low Stock**: `Colors.orange`
- **Info/Upcoming**: `Colors.blue`
- **Featured**: `Colors.amber`

### Background Alpha Values
Use `Colors.color.withValues(alpha: 0.1)` for subtle backgrounds
Use `Colors.color.withValues(alpha: 0.2)` for more prominent backgrounds

---

## 📱 Mobile vs Desktop Differences

| Feature | Mobile (< 600px) | Desktop (≥ 600px) |
|---------|-----------------|-------------------|
| FAB Label | Icon only | Icon + Text |
| Search Button | Hidden | Visible |
| Status Badges | Essential only | All badges shown |
| Dialog Width | 90% screen | Fixed 600px |
| List Details | Compact | Extended |
| Context Lines | Fewer | More details |

---

## 🚀 Usage Examples

### Creating a Product
1. Click the **"Add Product"** floating action button
2. Fill in all required fields (marked with *)
3. Select a category from the dropdown
4. Optionally add an image URL
5. Click **"Add Product"**
6. Product appears in the list with a success message

### Validating a Coupon
1. Find the coupon in the list
2. Click the **three-dot menu** → **"Validate"**
3. Enter an order amount in the dialog
4. Click **"Validate"**
5. View validation result in a SnackBar

### Setting Banner Priority
1. Create or edit a banner
2. Set **Priority** field (higher = shows first)
3. Save the banner
4. Banners are automatically ordered by priority

---

## ✨ Best Practices

### For Administrators
1. **Delete Carefully**: Always confirm before deleting (action cannot be undone)
2. **Categories First**: Create categories before adding products
3. **Test Coupons**: Use the validate feature to test coupons
4. **Check Dates**: Verify start/end dates for promos and expiration dates
5. **Low Stock**: Monitor low stock warnings on products

### For Developers
1. **Use Shared Theme**: Import `shared_ui` package for consistent theming
2. **Responsive Design**: Test on multiple screen sizes
3. **Form Validation**: Always validate user input
4. **Error Handling**: Provide clear error messages
5. **Loading States**: Show feedback during async operations

---

## 🐛 Troubleshooting

### Common Issues

**Q: Category not showing in product dropdown?**
A: Ensure the category is marked as active. Only active categories appear in the selector.

**Q: Can't delete a category?**
A: Categories with associated products cannot be deleted. Reassign or delete products first.

**Q: Dialog too small on desktop?**
A: This is by design. Dialogs are sized for optimal readability and form usability.

**Q: Form validation failing?**
A: Check for required fields (marked with *) and correct data formats (e.g., valid numbers).

---

## 📖 Related Documentation

- [Clean Architecture](./ARCHITECTURE.md)
- [Folder Structure](./FOLDER_STRUCTURE.md)
- [State Management](./STATE_MANAGEMENT.md)
- [Category System](./CATEGORIES_USAGE.md)

---

## 🎉 Summary

All management pages are now **fully functional** with:
- ✅ Complete CRUD operations
- ✅ Responsive design (mobile/tablet/desktop)
- ✅ Clean, modern UI with consistent colors
- ✅ Form validation and error handling
- ✅ Status indicators and badges
- ✅ Filtering and sorting capabilities
- ✅ Integration with shared UI theme
- ✅ No linting errors or warnings

The Admin Panel is ready for production use! 🚀

