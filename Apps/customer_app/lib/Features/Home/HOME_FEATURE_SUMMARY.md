# Home Feature - Customer App 🏠

## Overview
A beautiful, modern Noon-inspired home screen for the E-Commerce customer app. This feature displays promotional banners, product categories, and various product sections fetched from Firebase Firestore.

---

## 📁 Project Structure

```
Features/Home/
├── domain/
│   └── entities/
│       ├── product_entity.dart      # Product data model
│       ├── category_entity.dart     # Category data model
│       └── banner_entity.dart       # Banner data model
├── data/
│   └── firebase_home_repository.dart # Firebase data fetching
├── presentation/
│   ├── cubit/
│   │   ├── home_cubit.dart          # State management
│   │   └── home_state.dart          # State definitions
│   └── widgets/
│       ├── banner_carousel.dart     # Auto-scrolling banner carousel
│       ├── category_list.dart       # Horizontal category scroll
│       └── product_card.dart        # Product display card
└── HomeScreen.dart                  # Main home screen

```

---

## 🎨 UI Features

### 1. **Modern App Bar**
- **E-Shop** branding with storefront icon
- Search icon (ready for implementation)
- Shopping cart with badge
- Notifications icon

### 2. **Search Bar**
- Prominent search field at the top
- Tap-ready for search functionality

### 3. **Banner Carousel**
- Auto-scrolling promotional banners
- Smooth page transitions
- Dot indicators for navigation
- Gradient overlays with banner titles
- Tap to navigate (action URL support)

### 4. **Categories Section**
- "Shop by Category" header
- Horizontal scrolling list
- Circular category images
- Category names with product counts
- Tap to view category products

### 5. **Product Sections**
- **⚡ Flash Deals** - Limited time offers with discount badges
- **⭐ Featured Products** - Handpicked products in grid layout
- **🆕 New Arrivals** - Recent products horizontal scroll

### 6. **Product Cards**
- Product images with loading/error states
- Discount percentage badges
- Out of stock overlays
- Original & discounted prices
- Product names with ellipsis overflow

---

## 🔥 Key Features

### Clean Architecture
- **Domain Layer**: Pure entity models
- **Data Layer**: Firebase repository for data fetching
- **Presentation Layer**: BLoC (Cubit) for state management

### State Management (BLoC/Cubit)
```dart
// States
- HomeInitial
- HomeLoading
- HomeLoaded (with all data)
- HomeError

// Actions
- fetchHomeData() - Load all sections
- refreshHomeData() - Pull to refresh
```

### Firebase Integration
All data is fetched from Firebase Firestore:
- `banners` collection - Active promotional banners
- `categories` collection - Product categories
- `products` collection - Products (featured, deals, new arrivals)

### Responsive Design
- Grey theme from `@shared_ui` package
- Proper loading states
- Error handling with retry button
- Pull-to-refresh support

---

## 🛠️ Data Fetching

### Repository Methods

```dart
fetchActiveBanners()              // Active banners sorted by priority
fetchCategories()                 // All active categories
fetchFeaturedProducts(limit: 10)  // Featured products
fetchDealsProducts(limit: 10)     // Products with discounts
fetchNewArrivals(limit: 10)       // Recent products
fetchProductsByCategory(categoryId) // Category products
fetchAllProducts(limit: 20)       // All products
```

### Parallel Data Loading
All home sections are fetched concurrently for fast loading:
```dart
await Future.wait([
  repository.fetchActiveBanners(),
  repository.fetchCategories(),
  repository.fetchFeaturedProducts(),
  repository.fetchDealsProducts(),
  repository.fetchNewArrivals(),
]);
```

---

## 🎯 Entity Models

### ProductEntity
- Basic info: id, name, description
- Pricing: price, discountPrice
- Category: categoryId, categoryName
- Media: imageUrls (list)
- Inventory: stockQuantity, isActive
- Features: isFeatured, specifications, tags
- **Computed Properties**: 
  - `currentPrice` - Final price after discount
  - `isOnSale` - Boolean discount check
  - `discountPercentage` - Discount %
  - `isInStock` - Availability check

### CategoryEntity
- id, name, description
- imageUrl (optional)
- isActive, createdAt
- productCount

### BannerEntity
- id, title, description, imageUrl
- type (main, secondary, category, product, seasonal)
- actionUrl, productId, categoryId
- isActive, startDate, endDate, priority
- **Computed Property**: `isCurrentlyActive`

---

## 🎨 Design System (Noon-Inspired)

### Colors
- Background: `#F8F9FA` (light grey)
- Cards: White with subtle shadows
- Primary Grey: From `@shared_ui` package
- Discount Red: `Colors.red`
- Success: `Colors.green`

### Typography
- Section Headers: 20px, Bold
- Product Names: 14px, Semi-bold
- Prices: 16px, Bold
- Subtitles: 13px, Regular

### Spacing
- Section gaps: 24px
- Card padding: 12-16px
- Horizontal lists: 12px padding
- Grid spacing: 12px

### Shadows & Elevation
- Cards: Subtle shadow (blurRadius: 10, offset: 0,4)
- Banners: Stronger shadow for depth
- Category circles: Light shadow

---

## 🚀 Integration

### main.dart Setup
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AuthCubit(...)),
    BlocProvider(create: (context) => HomeCubit(
      repository: FirebaseHomeRepository()
    )),
  ],
  child: MaterialApp(...)
)
```

### HomeScreen Usage
```dart
// HomeScreen is automatically shown when user is authenticated
if (state is Authenticated) {
  return const HomeScreen(); // HomeCubit is available from parent
}
```

---

## 📱 User Experience

### Loading States
- Initial load: Centered circular progress indicator
- Error state: Icon + message + retry button
- Empty states: Sections hide automatically

### Interactions
1. **Banner Tap** → Navigate to action URL
2. **Category Tap** → View category products
3. **Product Tap** → View product details (TODO)
4. **Search Bar Tap** → Open search (TODO)
5. **Cart Icon** → View cart (TODO)
6. **Pull Down** → Refresh all data

### Auto-Scroll
Banners automatically scroll every 5 seconds with smooth animations.

---

## 🔮 Future Enhancements (TODO)

1. **Search Functionality** - Product search page
2. **Product Details** - Detailed product view
3. **Category Products** - Category-filtered products page
4. **Shopping Cart** - Cart management
5. **Favorites** - Save favorite products
6. **Filters & Sorting** - Product filtering
7. **Infinite Scroll** - Load more products
8. **Personalization** - User-based recommendations

---

## 🎯 Data Requirements

### Firestore Collections

**banners**
```json
{
  "id": "auto-generated",
  "title": "string",
  "description": "string",
  "imageUrl": "string (URL)",
  "type": "main|secondary|category|product|seasonal",
  "actionUrl": "string (optional)",
  "productId": "string (optional)",
  "categoryId": "string (optional)",
  "isActive": "boolean",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "priority": "number",
  "createdAt": "timestamp"
}
```

**categories**
```json
{
  "id": "auto-generated",
  "name": "string",
  "description": "string",
  "imageUrl": "string (optional)",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "productCount": "number"
}
```

**products**
```json
{
  "id": "auto-generated",
  "name": "string",
  "description": "string",
  "price": "number",
  "discountPrice": "number (optional)",
  "categoryId": "string",
  "categoryName": "string",
  "imageUrls": ["string"],
  "stockQuantity": "number",
  "isActive": "boolean",
  "isFeatured": "boolean",
  "createdAt": "timestamp",
  "specifications": "map (optional)",
  "tags": ["string"] (optional)
}
```

---

## ✅ Completed Tasks

- ✅ Created domain entities (Product, Category, Banner)
- ✅ Created Firebase repository for data fetching
- ✅ Implemented Home Cubit for state management
- ✅ Built banner carousel with auto-scroll
- ✅ Built categories horizontal scroll
- ✅ Built product card widget
- ✅ Built complete Noon-inspired HomeScreen
- ✅ Integrated with main.dart
- ✅ Fixed all linter errors
- ✅ Used shared_ui theme colors

---

## 📊 Performance

- **Parallel Data Fetching**: All sections load simultaneously
- **Lazy Loading**: Images load on demand
- **Efficient Rendering**: Horizontal lists use ListView.builder
- **State Caching**: Data persists until refresh
- **Error Recovery**: Retry mechanism for failed loads

---

## 🎨 Noon Design Inspiration

The UI follows Noon.com's design principles:
- Clean, minimal interface
- Prominent search functionality
- Auto-scrolling hero banners
- Category circles for easy navigation
- Product grids with clear pricing
- Discount badges for deals
- Grey/neutral color scheme
- Card-based layout

---

**Built with ❤️ using Flutter & Firebase**
**Theme powered by @shared_ui package**

