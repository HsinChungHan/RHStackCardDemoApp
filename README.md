

# RHStackCard Demo App

A complete demonstration application for RHStackCard, showcasing how to integrate card stack functionality using Clean Architecture + MVVM pattern. This demo implements user card display functionality with complete data loading, caching mechanisms, and custom UI components.

https://github.com/user-attachments/assets/b9874632-1069-48e6-9087-577151d22750

## ✨ Demo Features

### 🏗️ Architecture Showcase ✅
- **Clean Architecture**: Complete separation of Domain, Data, and Presentation layers
- **MVVM Pattern**: ViewModel handles business logic, View handles UI presentation
- **Platform-Agnostic**: Domain Layer and Data Layer completely independent of platform
- **Dependency Injection**: Decoupling between layers through protocols

### 🎨 Custom Component Demonstration ✅
- **UserCard Model**: Complete example demonstrating `Card` protocol implementation
- **UserCardView View**: Shows how to inherit from `CardView` to create custom UI
- **Complete User Info**: Includes name, age, location, bio and other fields

### 💾 Data Management Strategy ✅
- **Cache First**: Prioritize loading local cached data
- **Background Update**: Simultaneously fetch latest data from server
- **Dual Callbacks**: Cache and network data trigger UI updates separately
- **Error Handling**: Complete network error and data parsing error handling

### 🔄 State Management ✅
- **Loading**: Initial loading state
- **Loaded**: Data loading completed
- **Empty**: No data state
- **Error**: Error state handling

## 🏗️ Project Architecture ✅

### Architecture Layer Diagram
```
RHStackCard Demo App
│
├── 📱 Presentation Layer
│   ├── ViewControllers
│   │   └── UserPageViewController
│   ├── ViewModels
│   │   └── UserPageViewModel
│   └── Views
│       ├── UserCardView (Inherits CardView) ✅
│       └── UI Components
│
├── 🔧 Domain Layer (Platform-Agnostic) ✅
│   ├── Models
│   │   ├── User (Domain Model)
│   │   └── UserCard (Implements Card Protocol) ✅
│   ├── Use Cases
│   │   └── UserUsecase
│   └── Repository Protocols
│       └── UserRepositoryProtocol
│
└── 💾 Data Layer (Platform-Agnostic) ✅
├── Repository Implementations
│   └── UserRepository
├── Data Sources
│   ├── UserRemoteService (Network Data)
│   └── UserStoreService (Local Cache) ✅
└── DTOs
└── UserDTO
```

## 📚 Key Achievements

### 1. Clean Architecture ✅
- **Layer Responsibilities**: Each layer has clear responsibilities and boundaries
- **Dependency Direction**: Inner layers don't depend on outer layers, following dependency inversion principle
- **Testability**: Each layer can be independently unit tested
- **Platform-Agnostic**: Domain and Data layers don't depend on any UI framework

### 2. MVVM Pattern Application ✅
- **ViewModel Business Logic**: Handles data transformation and state management
- **View Pure Presentation**: Only responsible for UI presentation and user interaction
- **Two-way Binding**: Data binding through delegates

### 3. Custom Component Development ✅
- **Custom Card Implementation**: Complete example of `Card` protocol implementation
- **Custom CardView Inheritance**: Demonstrates how to extend `CardView` functionality
- **Protocol-Oriented**: Define interface contracts through protocols
- **Component Reuse**: Design reusable UI components

### 4. Data Caching Strategy ✅
- **Cache-First**: Prioritize cache loading for better user experience
- **Background Sync**: Background updates ensure data freshness
- **Error Recovery**: Fallback to cached data during network errors
- **Smart Check**: Check cache existence first, then decide on network request

## 🧪 Testing Suggestions

### Unit Testing Focus
- **UseCase Logic Testing**: Test business logic correctness
- **Repository Cache Logic**: Test coordination between cache and network data
- **Model Transformation**: Test DTO to Domain Model transformation
- **end-to-end test**: Test the remote network service

## 🔄 Data Source

Test data sources used in the demo:
- **API Endpoint**: https://raw.githubusercontent.com/downapp/sample/main/sample.json
- **Image Resources**: https://down-static.s3.us-west-2.amazonaws.com/

## 📋 Feature Checklist

### Completed Features ✅
- [x] Clean Architecture three-layer separation
- [x] Platform-Agnostic Domain and Data layers
- [x] Custom UserCard model implementation
- [x] Custom UserCardView implementation
- [x] Data caching mechanism
- [x] Cache checking logic
- [x] User card display
- [x] Photo browsing and index indication
- [x] Loading state management
- [x] Error handling
- [x] Responsive layout
- [x] Swipe operations (Like/Nope/SuperLike)
- [ ] Should change swipe operations to 2 operations(up/down)

## 🤝 Dependencies
> **Note**: RH is the prefix from my name "ReedHsin". All Swift Packages with the RH prefix are self-developed frameworks built using only native iOS frameworks without any third-party dependencies.

- **[RHStackCard](https://github.com/HsinChungHan/RHStackCard/blob/main/README.md)**: Main card stack framework
- **[RHNetworkAPI](https://github.com/HsinChungHan/RHNetworkAPI)**: Network request framework
- **[RHCacheStoreAPI](https://github.com/HsinChungHan/RHCacheStore)**: Data caching framework
- **[RHUIComponent](https://github.com/HsinChungHan/RHUIComponent)**: UI component framework
- **SnapKit**: Auto Layout helper framework
