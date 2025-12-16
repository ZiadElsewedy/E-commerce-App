# Admin Panel - Clean Architecture Documentation

## 📁 Folder Structure

The Admin Panel follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── Admin/
│   ├── admin_page.dart              # Main admin dashboard
│   ├── domain/                      # Business logic layer
│   │   ├── Entite/                  # Domain entities
│   │   └── repo/                    # Repository interfaces
│   ├── data/                        # Data layer
│   │   └── repositories/            # Repository implementations
│   └── presentation/                # Presentation layer
│       ├── cubit/                   # State management
│       ├── Pages/                   # UI pages
│       └── widgets/                 # Reusable widgets
│
├── Features/                        # Feature modules
│   ├── Products/                    # Product management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product_entity.dart
│   │   │   └── repositories/
│   │   │       └── product_repository.dart
│   │   ├── data/
│   │   │   └── firebase_product_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── products_management_page.dart
│   │
│   ├── Banners/                     # Banner management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── banner_entity.dart
│   │   │   └── repositories/
│   │   │       └── banner_repository.dart
│   │   ├── data/
│   │   │   └── firebase_banner_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── banners_management_page.dart
│   │
│   ├── Promos/                      # Promo management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── promo_entity.dart
│   │   │   └── repositories/
│   │   │       └── promo_repository.dart
│   │   ├── data/
│   │   │   └── firebase_promo_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── promos_management_page.dart
│   │
│   └── Coupons/                     # Coupon management
│       ├── domain/
│       │   ├── entities/
│       │   │   └── coupon_entity.dart
│       │   └── repositories/
│       │       └── coupon_repository.dart
│       ├── data/
│       │   └── firebase_coupon_repository.dart
│       └── presentation/
│           └── pages/
│               └── coupons_management_page.dart
│
├── firebase_options.dart            # Firebase configuration
└── main.dart                        # App entry point
```

---

## 🏗️ Architecture Layers

### **1. Domain Layer** (Business Logic)

The domain layer contains:
- **Entities**: Pure Dart classes representing business objects
- **Repository Interfaces**: Abstract contracts for data operations

**No dependencies on external frameworks or packages.**

#### Example:
```dart
// domain/entities/product_entity.dart
class ProductEntity {
  final String id;
  final String name;
  final double price;
  // ... business logic
}

// domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<List<ProductEntity>> getAllProducts();
  Future<void> createProduct(ProductEntity product);
  // ... other operations
}
```

---

### **2. Data Layer** (Implementation)

The data layer implements repository interfaces using:
- **Firebase Firestore** for data persistence
- **Error handling** with try-catch blocks
- **Data transformation** between Firestore and domain entities

#### Example:
```dart
// data/firebase_product_repository.dart
class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) => 
        ProductEntity.fromJson({...doc.data(), 'id': doc.id})
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }
}
```

---

### **3. Presentation Layer** (UI)

The presentation layer contains:
- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components
- **Cubits**: State management (Bloc pattern)

#### Example:
```dart
// presentation/pages/products_management_page.dart
class ProductsManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Products')),
      body: // ... UI code
    );
  }
}
```

---

## 🎯 Features Implemented

### **1. Products Management**
- View all products
- Add new products
- Edit existing products
- Delete products
- Toggle active/inactive status
- Manage stock levels
- Feature products
- Search and filter

**Firestore Collection**: `products`

---

### **2. Banners Management**
- Create promotional banners
- Upload banner images
- Set priority for display order
- Set expiration dates
- Toggle active/inactive status
- Link banners to URLs

**Firestore Collection**: `banners`

**Banner Fields**:
- `id`: Unique identifier
- `title`: Banner title
- `description`: Banner description
- `imageUrl`: Banner image URL
- `linkUrl`: Optional redirect URL
- `isActive`: Active status
- `priority`: Display priority (higher = first)
- `createdAt`: Creation timestamp
- `expiresAt`: Optional expiration date

---

### **3. Promos Management**
- Create promotional offers
- Set discount percentage or fixed amount
- Apply to specific products or categories
- Set start and end dates
- Toggle active/inactive status
- Priority ordering

**Firestore Collection**: `promos`

**Promo Types**:
- `percentage`: Percentage discount (e.g., 30% off)
- `fixed`: Fixed amount discount (e.g., $50 off)
- `buyOneGetOne`: BOGO offers
- `freeShipping`: Free shipping offers

---

### **4. Coupons Management**
- Generate unique coupon codes
- Set discount type (percentage/fixed)
- Set minimum purchase amount
- Set maximum discount amount
- Set usage limits
- Set expiration dates
- Track usage count
- Validate coupon codes

**Firestore Collection**: `coupons`

**Coupon Types**:
- `percentage`: Percentage discount
- `fixed`: Fixed amount discount

**Coupon Validation**:
- Check if coupon is active
- Check if coupon is expired
- Check if usage limit is reached
- Validate minimum purchase amount

---

## 🔥 Firebase Firestore Structure

### Collections:

#### **products**
```json
{
  "name": "Product Name",
  "description": "Product description",
  "price": 99.99,
  "discountPrice": 79.99,
  "categoryId": "cat123",
  "categoryName": "Electronics",
  "imageUrls": ["url1", "url2"],
  "stockQuantity": 50,
  "isActive": true,
  "isFeatured": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-02T00:00:00.000Z",
  "specifications": {"color": "Black", "size": "Large"},
  "tags": ["electronics", "gadgets"]
}
```

#### **banners**
```json
{
  "title": "Summer Sale",
  "description": "Up to 50% off",
  "imageUrl": "https://example.com/banner.jpg",
  "linkUrl": "https://example.com/sale",
  "isActive": true,
  "priority": 10,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "expiresAt": "2024-12-31T23:59:59.000Z"
}
```

#### **promos**
```json
{
  "title": "Flash Sale",
  "description": "30% off all electronics",
  "imageUrl": "https://example.com/promo.jpg",
  "type": "percentage",
  "discountValue": 30,
  "productIds": ["prod1", "prod2"],
  "categoryIds": ["cat1"],
  "isActive": true,
  "startDate": "2024-01-01T00:00:00.000Z",
  "endDate": "2024-01-31T23:59:59.000Z",
  "priority": 5
}
```

#### **coupons**
```json
{
  "code": "SAVE20",
  "description": "20% off your order",
  "type": "percentage",
  "discountValue": 20,
  "minPurchaseAmount": 100,
  "maxDiscountAmount": 50,
  "usageLimit": 1000,
  "usageCount": 234,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "expiresAt": "2024-12-31T23:59:59.000Z"
}
```

---

## 🚀 Getting Started

### Prerequisites:
- Flutter SDK
- Firebase project set up
- Firestore database enabled

### Installation:

1. **Install dependencies**:
```bash
cd Apps/AdminBanel_app
flutter pub get
```

2. **Configure Firebase**:
- Ensure `firebase_options.dart` is properly configured
- Enable Firestore in Firebase Console

3. **Run the app**:
```bash
flutter run
```

---

## 🎨 UI Navigation Flow

```
Admin Dashboard
├── Manage Products → Products Management Page
├── Manage Banners → Banners Management Page
├── Manage Promos → Promos Management Page
└── Manage Coupons → Coupons Management Page
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  flutter_bloc: ^9.1.1
  shared_ui:
    path: ../packages/shared_ui
```

---

## 🔑 Key Benefits of This Architecture

✅ **Separation of Concerns**: Each layer has a single responsibility  
✅ **Testability**: Business logic is independent of UI and data sources  
✅ **Maintainability**: Easy to modify without affecting other layers  
✅ **Scalability**: Easy to add new features following the same pattern  
✅ **Reusability**: Entities and repositories can be shared across features  
✅ **Flexibility**: Easy to swap data sources (Firestore → REST API)  

---

## 🔄 Future Enhancements

- [ ] Add Bloc/Cubit for state management
- [ ] Implement real-time data synchronization
- [ ] Add image upload functionality
- [ ] Implement search and filters
- [ ] Add analytics and reports
- [ ] Implement user roles and permissions
- [ ] Add order management
- [ ] Add customer management
- [ ] Add inventory tracking
- [ ] Add revenue dashboard

---

## 📖 Clean Architecture Reference

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (UI, Widgets, Pages, State Management) │
└─────────────┬───────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│    (Entities, Repository Interfaces)    │
│         (Business Logic)                │
└─────────────┬───────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│  (Repository Implementations, Firebase) │
│         (Data Sources)                  │
└─────────────────────────────────────────┘
```

**Dependency Rule**: Inner layers don't depend on outer layers.  
Domain layer is independent of presentation and data layers.

---

## 👨‍💻 Contributing

When adding new features, follow this structure:

1. Create entity in `domain/entities/`
2. Create repository interface in `domain/repositories/`
3. Implement repository in `data/`
4. Create UI pages in `presentation/pages/`
5. Add navigation from admin dashboard

---

**Built with ❤️ using Flutter & Clean Architecture**

