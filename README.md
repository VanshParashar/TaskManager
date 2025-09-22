# Task Manager Flutter App

A modern task management application built with Flutter, featuring clean architecture, BLoC state management, and persistent storage using Hive.

## Features
![Image](https://github.com/user-attachments/assets/f128ce96-e547-456d-8759-29d2702f30df)
![Image](https://github.com/user-attachments/assets/ff1de175-7906-44c4-a791-aa697cb16639)
![Image](https://github.com/user-attachments/assets/6e68a72e-fa54-4b7b-9ed8-95deed533780)
![Image](https://github.com/user-attachments/assets/12eeb616-4b8d-4c22-8c43-5ed69bd5d096)
![Image](https://github.com/user-attachments/assets/0057dfa2-2419-43bf-b1b7-5ea7dc0623e8)
![Image](https://github.com/user-attachments/assets/d07b2b60-979b-41ef-a58e-5122b348b275)
![Image](https://github.com/user-attachments/assets/016aa2bd-052d-42eb-8ec0-7817a4586977)
![Image](https://github.com/user-attachments/assets/3acdca58-10de-4550-b753-41b48ff32d8a)
![Image](https://github.com/user-attachments/assets/f07d356f-562d-4ca1-a14b-9acf84d09913)
![Image](https://github.com/user-attachments/assets/1f8dc333-1ab4-4577-8352-3467a5c957ed)

https://drive.google.com/file/d/1AYl1i8rbm9CY7LECPtk-Ocr8PNLR7LOb/view?usp=sharing

✅ **Core Features**
- Create, read, update, and delete tasks
- Task status management (To Do, In Progress, Done)
- Due date tracking with overdue indicators
- Filter tasks by status
- Reorderable task list with drag & drop
- Swipe to delete functionality

✅ **UI/UX Features**
- Material 3 design system
- Dark mode support with toggle
- Responsive layout (mobile & tablet)
- Animated status chips and transitions
- Professional and modern interface
- Custom empty states for different filters

✅ **Technical Features**
- Clean Architecture (Domain, Data, Presentation layers)
- BLoC pattern for state management
- Persistent storage with Hive
- Form validation
- Unit and widget tests
- Proper error handling

## Architecture

### Clean Architecture Layers

### State Management with BLoC

The app uses the BLoC pattern for predictable state management:

- **TaskBloc**: Manages task CRUD operations and filtering
- **ThemeBloc**: Handles dark/light mode switching
- **Events**: User actions trigger events
- **States**: UI reacts to state changes
- **Repository Pattern**: Abstracts data access logic

### Data Flow

1. **User Interaction** → Triggers an event
2. **Event** → Processed by BLoC
3. **Use Case** → Executes business logic
4. **Repository** → Accesses data through data source
5. **State Update** → BLoC emits new state
6. **UI Update** → Widgets rebuild based on new state

## Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.3      # State management
  hive: ^2.2.3              # Local storage
  hive_flutter: ^1.1.0      # Flutter integration for Hive
  equatable: ^2.0.5         # Value equality
  uuid: ^4.1.0              # Unique ID generation
  intl: ^0.18.1             # Date formatting

dev_dependencies:
  hive_generator: ^2.0.1    # Code generation for Hive
  build_runner: ^2.4.7      # Build system
  bloc_test: ^9.1.4         # BLoC testing utilities
  mocktail: ^1.0.0          # Mocking framework

