# 🛍️ Flutter E-Commerce App

A modern, responsive e-commerce application built with Flutter and adaptive design principles. Features smooth animations, micro-interactions, and a beautiful user interface.

## ✨ Features

### 🎨 **UI/UX**
- **Adaptive Layout**: Responsive design that adapts to different screen sizes
- **Smooth Animations**: Page transitions, loading animations, and micro-interactions
- **Modern Design**: Material Design 3 with custom theming
- **Interactive Elements**: Animated buttons, ripple effects, and hover states

### 🛒 **E-Commerce Features**
- **Product Catalog**: Browse products with categories and search
- **Shopping Cart**: Add/remove items with real-time updates
- **Product Details**: Detailed product information with specifications
- **Checkout Process**: Complete checkout flow (UI ready)
- **Order Management**: Track orders and order history

### 🔧 **Technical Features**
- **State Management**: Provider pattern for efficient state management
- **Responsive Navigation**: Adaptive navigation based on screen size
- **Image Handling**: Support for local assets and network images
- **Error Handling**: Graceful error handling and loading states

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/michaelgermini/flutter-ecommerce-app.git
   cd flutter-ecommerce-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## 📱 Screenshots

### Desktop View
![Desktop View](screenshots/desktop.png)

### Mobile View
![Mobile View](screenshots/mobile.png)

### Tablet View
![Tablet View](screenshots/tablet.png)

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── product.dart         # Product model
│   └── cart_item.dart       # Cart item model
├── providers/               # State management
│   ├── app_provider.dart    # App state provider
│   ├── cart_provider.dart   # Cart state provider
│   └── product_provider.dart # Product state provider
├── screens/                 # UI screens
│   ├── adaptive_home_screen.dart # Main adaptive screen
│   ├── home_screen.dart     # Home screen
│   ├── products_screen.dart # Products listing
│   ├── cart_screen.dart     # Shopping cart
│   ├── profile_screen.dart  # User profile
│   └── orders_screen.dart   # Order history
├── widgets/                 # Reusable widgets
│   ├── product_card.dart    # Product card widget
│   ├── cart_item_widget.dart # Cart item widget
│   ├── category_chips.dart  # Category filter chips
│   ├── micro_interactions.dart # Animation widgets
│   └── loading_animations.dart # Loading animations
├── utils/                   # Utilities
│   └── page_transitions.dart # Page transition animations
└── assets/                  # Static assets
    └── images/              # Images and icons
```

## 🎨 Animations & Interactions

### Page Transitions
- **Slide from Right**: Standard navigation transitions
- **Slide from Bottom**: Modal and overlay transitions
- **Fade Transition**: Smooth fade effects
- **Scale Transition**: Zoom effects for emphasis
- **Hero Transition**: Product card transitions

### Micro-Interactions
- **Animated Buttons**: Scale effects on press
- **Icon Animations**: Rotation and bounce effects
- **Ripple Effects**: Touch feedback on cards
- **Counter Animations**: Animated cart badge
- **Pulse Effects**: Notification indicators

### Loading Animations
- **Shimmer Effect**: Content loading states
- **Pulsing Dots**: Loading indicators
- **Rotating Circle**: Progress indicators
- **Bouncing Dots**: Playful loading animation

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_adaptive_scaffold: ^1.0.0
  provider: ^6.0.5
  cached_network_image: ^3.2.3
  flutter_rating_bar: ^4.0.1
  flutter_svg: ^2.0.7
```

## 🎯 Key Features Implementation

### Adaptive Layout
The app uses `flutter_adaptive_scaffold` to provide different layouts based on screen size:
- **Mobile**: Bottom navigation bar
- **Tablet**: Side navigation drawer
- **Desktop**: Top navigation with sidebar

### State Management
Uses Provider pattern for efficient state management:
- **AppProvider**: Manages navigation and app state
- **CartProvider**: Handles shopping cart operations
- **ProductProvider**: Manages product data and filtering

### Responsive Design
- **Breakpoint-aware**: Different layouts for different screen sizes
- **Flexible grids**: Adaptive product grids
- **Touch-friendly**: Optimized for touch interactions

## 🚀 Deployment

### Web Deployment
```bash
# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy
```

### Mobile Deployment
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Flutter community for packages and support

## 📞 Contact

- **GitHub**: [@michaelgermini](https://github.com/michaelgermini)
- **Email**: michael@germini.info
- **Repository**: [Flutter E-Commerce App](https://github.com/michaelgermini/flutter-ecommerce-app)

---

⭐ **Star this repository if you found it helpful!**
